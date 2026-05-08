/**
 * 核心功能模块相关 API (Java 后端)
 */
import request from '@/utils/api'

// ==================== 统一通知配置 ====================

// 获取所有通知配置 (分页)
export function getUnifiedNotificationConfigs(params) {
  return request({
    url: '/notification-configs',
    method: 'get',
    params
  })
}

// 获取通知配置详情
export function getUnifiedNotificationConfigDetail(id) {
  return request({
    url: `/notification-configs/${id}`,
    method: 'get'
  })
}

// 创建通知配置
export function createUnifiedNotificationConfig(data) {
  return request({
    url: '/notification-configs',
    method: 'post',
    data
  })
}

// 更新通知配置
export function updateUnifiedNotificationConfig(id, data) {
  return request({
    url: `/notification-configs/${id}`,
    method: 'put',
    data
  })
}

// 删除通知配置
export function deleteUnifiedNotificationConfig(id) {
  return request({
    url: `/notification-configs/${id}`,
    method: 'delete'
  })
}

// 设置为默认配置
export function setDefaultNotificationConfig(id) {
  return request({
    url: `/notification-configs/${id}/set-default`,
    method: 'post'
  })
}

// 获取所有启用的配置
export function getActiveNotificationConfigs() {
  return request({
    url: '/notification-configs/active',
    method: 'get'
  })
}

// 测试Webhook连接
export function testNotificationWebhook(id, botType) {
  return request({
    url: `/notification-configs/${id}/test-webhook`,
    method: 'post',
    params: { botType }
  })
}
