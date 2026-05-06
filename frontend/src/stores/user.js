import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import api from '@/utils/api'

export const useUserStore = defineStore('user', () => {
  const user = ref(null)
  const accessToken = ref(localStorage.getItem('access_token') || '')
  const refreshToken = ref(localStorage.getItem('refresh_token') || '')
  const tokenExpiresAt = ref(parseInt(localStorage.getItem('token_expires_at') || '0'))

  // token刷新定时器
  let refreshTimer = null

  const isAuthenticated = computed(() => !!accessToken.value && !!user.value)

  // 检查token是否即将过期（5分钟内）
  const isTokenExpiringSoon = computed(() => {
    if (!tokenExpiresAt.value) return false
    const now = Date.now()
    const timeLeft = tokenExpiresAt.value - now
    return timeLeft < 5 * 60 * 1000 // 5分钟
  })

  // 检查token是否已过期
  const isTokenExpired = computed(() => {
    if (!tokenExpiresAt.value) return false
    return Date.now() > tokenExpiresAt.value
  })

  // 启动自动刷新token定时器
  let visibilityHandler = null

  const startAutoRefresh = () => {
    // 清除现有定时器
    if (refreshTimer) {
      clearTimeout(refreshTimer)
    }

    const checkAndRefresh = async () => {
      if (!refreshToken.value || !accessToken.value) {
        return
      }

      // 如果token已过期，立即刷新
      if (isTokenExpired.value) {
        console.log('Token已过期，自动刷新...')
        try {
          await refreshAccessToken()
          console.log('自动刷新token成功')
        } catch (error) {
          console.error('自动刷新token失败:', error)
          return
        }
      } else if (isTokenExpiringSoon.value) {
        // 如果token即将过期（5分钟内），刷新
        console.log('Token即将过期，自动刷新...')
        try {
          await refreshAccessToken()
          console.log('自动刷新token成功')
        } catch (error) {
          console.error('自动刷新token失败:', error)
        }
      }

      // 继续调度下一次检查（每30秒检查一次）
      refreshTimer = setTimeout(checkAndRefresh, 30 * 1000)
    }

    // 监听页面可见性变化，用户从后台切回时立即检查token
    if (visibilityHandler) {
      document.removeEventListener('visibilitychange', visibilityHandler)
    }
    visibilityHandler = () => {
      if (document.visibilityState === 'visible') {
        console.log('页面恢复可见，检查token状态...')
        // 清除当前定时器，立即执行检查
        if (refreshTimer) {
          clearTimeout(refreshTimer)
          refreshTimer = null
        }
        checkAndRefresh()
      }
    }
    document.addEventListener('visibilitychange', visibilityHandler)

    // 立即执行一次检查
    checkAndRefresh()
  }

  // 停止自动刷新定时器
  const stopAutoRefresh = () => {
    if (refreshTimer) {
      clearTimeout(refreshTimer)
      refreshTimer = null
    }
    if (visibilityHandler) {
      document.removeEventListener('visibilitychange', visibilityHandler)
      visibilityHandler = null
    }
  }

  const login = async (credentials) => {
    try {
      const response = await api.post('/auth/login', credentials)
      // api interceptor已提取data: response.data = { access_token, refresh_token, user }
      // 注意：后端返回的是下划线格式
      accessToken.value = response.data.access_token
      refreshToken.value = response.data.refresh_token
      user.value = response.data.user

      // 计算过期时间（当前时间 + 15分钟，与后端一致）
      const expiresAt = Date.now() + 15 * 60 * 1000
      tokenExpiresAt.value = expiresAt

      // 持久化存储
      localStorage.setItem('access_token', accessToken.value)
      localStorage.setItem('refresh_token', refreshToken.value)
      localStorage.setItem('token_expires_at', expiresAt.toString())
      localStorage.setItem('user', JSON.stringify(user.value))

      // 启动自动刷新
      startAutoRefresh()

      return response.data
    } catch (error) {
      throw error
    }
  }

  const register = async (userData) => {
    try {
      const response = await api.post('/auth/register', userData)
      return response.data
    } catch (error) {
      throw error
    }
  }

  // 添加一个标记防止logout过程中的循环调用
  let isLoggingOut = false

  const logout = async () => {
    if (isLoggingOut) {
      return
    }
    isLoggingOut = true

    stopAutoRefresh()

    // 先保存refreshToken用于调用logout API，然后立即清除本地状态
    // 这样请求拦截器不会因为看到过期的accessToken而尝试刷新（导致死锁）
    const savedRefreshToken = refreshToken.value

    accessToken.value = ''
    refreshToken.value = ''
    user.value = null
    tokenExpiresAt.value = 0

    localStorage.removeItem('access_token')
    localStorage.removeItem('refresh_token')
    localStorage.removeItem('token_expires_at')
    localStorage.removeItem('user')

    try {
      if (savedRefreshToken) {
        try {
          await api.post('/auth/logout', { refresh_token: savedRefreshToken })
        } catch (apiError) {
          console.error('Logout API调用失败:', apiError)
        }
      }
    } finally {
      isLoggingOut = false
      window.location.href = '/login'
    }
  }

  // 刷新access token
  const refreshAccessToken = async () => {
    try {
      const response = await api.post('/auth/refresh', {
        refresh_token: refreshToken.value
      })

      // api interceptor已提取data，后端返回下划线格式
      accessToken.value = response.data.access_token
      const expiresAt = Date.now() + 15 * 60 * 1000
      tokenExpiresAt.value = expiresAt

      if (response.data.refresh_token) {
        refreshToken.value = response.data.refresh_token
        localStorage.setItem('refresh_token', refreshToken.value)
      }

      localStorage.setItem('access_token', accessToken.value)
      localStorage.setItem('token_expires_at', expiresAt.toString())

      return response.data.access_token
    } catch (error) {
      console.error('Token refresh failed:', error)
      // 不await logout()，避免死锁（响应拦截器可能已经调用了logout）
      logout()
      throw error
    }
  }

  const fetchUser = async () => {
    try {
      const response = await api.get('/auth/me')
      user.value = response.data
      localStorage.setItem('user', JSON.stringify(user.value))
    } catch (error) {
      await logout()
      throw error
    }
  }

  const fetchProfile = async () => {
    try {
      const response = await api.get('/auth/profile')
      user.value = response.data
      localStorage.setItem('user', JSON.stringify(user.value))
      return response.data
    } catch (error) {
      if (error.response?.status === 401) {
        await logout()
      }
      throw error
    }
  }

  const initAuth = async () => {
    console.log('initAuth 开始:', {
      hasAccessToken: !!accessToken.value,
      hasRefreshToken: !!refreshToken.value,
      hasUser: !!user.value,
      isExpired: isTokenExpired.value
    })

    if (!user.value) {
      const savedUser = localStorage.getItem('user')
      if (savedUser) {
        try {
          user.value = JSON.parse(savedUser)
        } catch (e) {
          console.error('解析用户信息失败:', e)
        }
      }
    }

    if (accessToken.value) {
      if (isTokenExpired.value && refreshToken.value) {
        console.log('Token已过期，尝试刷新...')
        try {
          await refreshAccessToken()
          console.log('Token刷新成功')
        } catch (error) {
          console.error('Token刷新失败:', error)
          return
        }
      }

      if (!user.value) {
        try {
          console.log('获取用户信息...')
          await fetchProfile()
          console.log('用户信息获取成功:', user.value?.username)
        } catch (error) {
          console.error('获取用户信息失败:', error)
          await logout()
        }
      } else {
        console.log('用户信息已存在，跳过获取')
      }

      startAutoRefresh()
    } else {
      console.log('没有access token，跳过认证初始化')
    }
  }

  return {
    user,
    accessToken,
    refreshToken,
    tokenExpiresAt,
    isAuthenticated,
    isTokenExpiringSoon,
    isTokenExpired,
    login,
    register,
    logout,
    refreshAccessToken,
    fetchProfile,
    initAuth,
    startAutoRefresh,
    stopAutoRefresh
  }
})
