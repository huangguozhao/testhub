import axios from 'axios'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'

const api = axios.create({
  baseURL: '/api',
  timeout: 30000,
  headers: {
    'Content-Type': 'application/json',
  },
})

// 正在刷新的标志
let isRefreshing = false
// 等待刷新的请求队列
let failedQueue = []

// 处理队列中的请求
const processQueue = (error, token = null) => {
  failedQueue.forEach(prom => {
    if (error) {
      prom.reject(error)
    } else {
      prom.resolve(token)
    }
  })

  failedQueue = []
}

// 请求拦截器
api.interceptors.request.use(
  async (config) => {
    const userStore = useUserStore()

    // 检查是否是刷新token的请求
    if (config.url === '/auth/refresh') {
      return config
    }

    // 如果有access token
    if (userStore.accessToken) {
      // 检查token是否已过期或即将过期，需要刷新
      if (userStore.isTokenExpired || userStore.isTokenExpiringSoon) {
        // 如果没有正在刷新，开始刷新
        if (!isRefreshing) {
          isRefreshing = true
          console.log('Token已过期或即将过期，开始刷新...')

          try {
            const newToken = await userStore.refreshAccessToken()
            console.log('Token刷新成功')
            processQueue(null, newToken)

            // 更新当前请求的token
            config.headers.Authorization = `Bearer ${newToken}`
          } catch (error) {
            console.error('Token刷新失败:', error)
            processQueue(error, null)
            return Promise.reject(error)
          } finally {
            isRefreshing = false
          }
        } else {
          // 如果正在刷新，将请求加入队列
          console.log('Token正在刷新，请求加入队列等待...')
          return new Promise((resolve, reject) => {
            failedQueue.push({ resolve, reject })
          }).then(token => {
            config.headers.Authorization = `Bearer ${token}`
            return config
          }).catch(err => {
            return Promise.reject(err)
          })
        }
      } else {
        // token仍然有效，直接使用
        config.headers.Authorization = `Bearer ${userStore.accessToken}`
      }
    }

    return config
  },
  (error) => {
    return Promise.reject(error)
  }
)

// 响应拦截器
api.interceptors.response.use(
  (response) => {
    // Java后端返回: { code, message, data }
    // 检查业务状态码，只有成功时才提取data
    if (response.data && typeof response.data.code !== 'undefined') {
      if (response.data.code !== 0 && response.data.code !== '0' && response.data.code !== '200' && response.data.code !== 200) {
        // 业务错误，抛出错误让catch处理
        const error = new Error(response.data.message || '请求失败')
        error.response = response
        error.response.data = response.data
        return Promise.reject(error)
      }
      // 成功时提取data字段
      if (response.data.data !== undefined) {
        response.data = response.data.data
      }
    }
    return response
  },
  async (error) => {
    const userStore = useUserStore()
    const originalRequest = error.config

    // 如果是请求拦截器因token刷新失败而拒绝的请求，不重复处理
    if (originalRequest?._refreshFailed) {
      return Promise.reject(error)
    }

    // 如果是401错误且不是刷新token的请求
    if (error.response?.status === 401 && !originalRequest._retry) {
      // 如果是logout请求失败，直接清除本地状态不再重试logout，防止死循环
      if (originalRequest.url === '/auth/logout') {
        console.error('Logout请求401，直接清除本地状态')
        userStore.$patch((state) => {
          state.accessToken = ''
          state.refreshToken = ''
          state.user = null
          state.tokenExpiresAt = 0
        })
        localStorage.removeItem('access_token')
        localStorage.removeItem('refresh_token')
        localStorage.removeItem('token_expires_at')
        localStorage.removeItem('user')
        window.location.href = '/login'
        return Promise.reject(error)
      }

      // 如果是刷新token的请求失败
      if (originalRequest.url === '/auth/refresh') {
        console.error('Refresh token失败，跳转登录页')
        // 必须先重置isRefreshing并清空队列，否则logout内部的API调用会被卡在队列中导致死锁
        isRefreshing = false
        processQueue(error, null)
        userStore.logout()
        return Promise.reject(error)
      }

      // 如果有refresh token，尝试刷新
      if (userStore.refreshToken && !isRefreshing) {
        originalRequest._retry = true
        isRefreshing = true

        try {
          console.log('收到401响应，尝试刷新token...')
          const newToken = await userStore.refreshAccessToken()
          console.log('Token刷新成功，重试原请求')
          processQueue(null, newToken)

          // 更新当前请求的token
          originalRequest.headers.Authorization = `Bearer ${newToken}`

          // 重试原请求
          return api(originalRequest)
        } catch (refreshError) {
          console.error('Token刷新失败:', refreshError)
          processQueue(refreshError, null)
          // refreshAccessToken 内部已处理 logout（仅在 token 确实无效时）
          // 这里不再重复调用 logout，避免网络问题导致误登出
          return Promise.reject(refreshError)
        } finally {
          isRefreshing = false
        }
      } else if (!userStore.refreshToken) {
        // 没有refresh token，直接退出
        console.error('没有refresh token，跳转登录页')
        userStore.logout()
        return Promise.reject(error)
      } else {
        // 正在刷新token时收到401，将请求加入队列等待
        console.log('Token正在刷新中，401请求加入队列等待...')
        return new Promise((resolve, reject) => {
          failedQueue.push({
            resolve: (token) => {
              originalRequest.headers.Authorization = `Bearer ${token}`
              resolve(api(originalRequest))
            },
            reject: (err) => {
              reject(err)
            }
          })
        })
      }
    }

    // 其他错误处理（跳过请求拦截器已处理的刷新失败场景，避免重复报错）
    if (error.response?.status === 401) {
      // 已在重试后仍然401，或没有refresh token
      ElMessage.error('登录已过期，请重新登录')
    } else if (error.response?.status >= 500) {
      ElMessage.error('服务器错误，请稍后重试')
    } else if (error.response?.data?.error) {
      ElMessage.error(error.response.data.error)
    } else if (error.response?.data?.detail) {
      ElMessage.error(error.response.data.detail)
    } else if (error.response?.data?.message) {
      ElMessage.error(error.response.data.message)
    }

    return Promise.reject(error)
  }
)

export default api
