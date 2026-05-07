import api from '@/utils/api'

// 仪表盘相关API
export function getDashboardStats() {
  return api({
    url: '/api-testing/dashboard/stats',
    method: 'get'
  })
}

// 获取定时任务列表
export function getScheduledTasks(params) {
  return api({
    url: '/api-scheduled-tasks',
    method: 'get',
    params
  })
}

// 创建定时任务
export function createScheduledTask(data) {
  return api({
    url: '/api-scheduled-tasks',
    method: 'post',
    data
  })
}

// 更新定时任务
export function updateScheduledTask(id, data) {
  return api({
    url: `/api-scheduled-tasks/${id}`,
    method: 'put',
    data
  })
}

// 删除定时任务
export function deleteScheduledTask(id) {
  return api({
    url: `/api-scheduled-tasks/${id}`,
    method: 'delete'
  })
}

// 立即执行定时任务
export function runScheduledTask(id) {
  return api({
    url: `/api-scheduled-tasks/${id}/execute`,
    method: 'post'
  })
}

// 获取执行日志
export function getExecutionLogs(taskId, params = {}) {
  return api({
    url: `/api-execution-records/trigger/${taskId}`,
    method: 'get',
    params
  })
}

// 获取测试套件列表
export function getTestSuites(params) {
  return api({
    url: '/api-test-suites',
    method: 'get',
    params
  })
}

// 获取API请求列表
export function getApiRequests(params) {
  return api({
    url: '/api-requests',
    method: 'get',
    params
  })
}

// 获取环境列表
export function getEnvironments(params) {
  return api({
    url: '/api-environments',
    method: 'get',
    params
  })
}

// 获取项目列表
export function getApiProjects(params) {
  return api({
    url: '/api-projects',
    method: 'get',
    params
  })
}

// 获取集合列表
export function getApiCollections(params) {
  return api({
    url: '/api-collections',
    method: 'get',
    params
  })
}

// 执行测试套件
export function executeTestSuite(id, data) {
  return api({
    url: `/api-test-suites/${id}/execute`,
    method: 'post',
    data
  })
}

// 执行API请求
export function executeApiRequest(id, data) {
  return api({
    url: `/api-requests/${id}/execute`,
    method: 'post',
    data
  })
}

// 获取执行结果
export function getExecutionResult(id) {
  return api({
    url: `/api-execution-records/${id}`,
    method: 'get'
  })
}

// 获取请求历史
export function getRequestHistory(params) {
  return api({
    url: '/api-request-histories',
    method: 'get',
    params
  })
}

// 删除请求历史
export function deleteRequestHistory(id) {
  return api({
    url: `/api-request-histories/${id}`,
    method: 'delete'
  })
}

// 批量删除请求历史
export function batchDeleteRequestHistory(ids) {
  return api({
    url: '/api-request-histories/batch',
    method: 'delete',
    data: { ids }
  })
}

// 获取用户列表
export function getUsers(params) {
  return api({
    url: '/users',
    method: 'get',
    params
  })
}

// 获取操作日志
export function getOperationLogs(params) {
  return api({
    url: '/operation-logs',
    method: 'get',
    params
  })
}