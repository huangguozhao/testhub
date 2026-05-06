<template>
  <div class="request-history">
    <div class="header">
      <h3>{{ $t('apiTesting.history.title') }}</h3>
      <div class="filters">
        <el-input
          v-model="searchText"
          :placeholder="$t('apiTesting.history.searchRequest')"
          style="width: 200px"
          clearable
          @input="loadHistory"
        />
        <el-button
          type="danger"
          :disabled="selectedIds.length === 0"
          @click="handleBatchDelete"
        >
          {{ $t('apiTesting.history.batchDelete') }}
        </el-button>
        <el-button @click="clearHistory" type="danger" plain>
          {{ $t('apiTesting.history.clearHistory') }}
        </el-button>
      </div>
    </div>

    <el-tabs v-model="activeTab" @tab-change="onTabChange">
      <el-tab-pane :label="$t('apiTesting.history.httpRequest')" name="HTTP">
        <HistoryTable
          :data="httpHistory"
          :loading="loading"
          @view-detail="viewDetail"
          @retry-request="retryRequest"
          @selection-change="handleSelectionChange"
          @delete-item="handleDelete"
        />
      </el-tab-pane>
      <el-tab-pane :label="$t('apiTesting.history.websocketRequest')" name="WEBSOCKET">
        <HistoryTable
          :data="websocketHistory"
          :loading="loading"
          @view-detail="viewDetail"
          @retry-request="retryRequest"
          @selection-change="handleSelectionChange"
          @delete-item="handleDelete"
        />
      </el-tab-pane>
    </el-tabs>

    <!-- 分页 -->
    <el-pagination
      v-model:current-page="currentPage"
      v-model:page-size="pageSize"
      :page-sizes="[10, 20, 50, 100]"
      :total="total"
      layout="total, sizes, prev, pager, next, jumper"
      @size-change="handleSizeChange"
      @current-change="handleCurrentChange"
      class="pagination"
    />

    <!-- 详情对话框 -->
    <el-dialog
      v-model="showDetailDialog"
      :title="$t('apiTesting.history.requestDetail')"
      width="80%"
      :top="'5vh'"
    >
      <div v-if="selectedHistory" class="history-detail">
        <el-descriptions :title="$t('apiTesting.history.basicInfo')" :column="2" border>
          <el-descriptions-item :label="$t('apiTesting.interface.requestName')">
            {{ selectedHistory.url || '-' }}
          </el-descriptions-item>
          <el-descriptions-item :label="$t('apiTesting.history.requestMethod')">
            <el-tag :type="getMethodType(selectedHistory.method)">
              {{ selectedHistory.method || 'GET' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item :label="$t('apiTesting.history.statusCode')">
            <el-tag :type="getStatusType(selectedHistory.response_status_code)">
              {{ selectedHistory.response_status_code || $t('apiTesting.history.noResponse') }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item :label="$t('apiTesting.history.responseTime')">
            {{ selectedHistory.response_time?.toFixed(0) || 0 }}ms
          </el-descriptions-item>
          <el-descriptions-item :label="$t('apiTesting.history.executionTime')">
            {{ formatDate(selectedHistory.executed_at) }}
          </el-descriptions-item>
          <el-descriptions-item :label="$t('apiTesting.history.executor')">
            {{ selectedHistory.executed_by?.username || selectedHistory.executed_by || '-' }}
          </el-descriptions-item>
        </el-descriptions>

        <el-tabs v-model="detailTab" class="detail-tabs">
          <el-tab-pane :label="$t('apiTesting.history.requestInfo')" name="request">
            <div class="detail-section">
              <h4>{{ $t('apiTesting.history.requestUrl') }}</h4>
              <el-input v-model="selectedHistory.url" readonly />

              <h4>{{ $t('apiTesting.history.requestHeaders') }}</h4>
              <el-table :data="parseHeaders(selectedHistory.request_headers)" style="width: 100%">
                <el-table-column prop="key" label="Key" width="200" />
                <el-table-column prop="value" label="Value" />
              </el-table>

              <h4 v-if="selectedHistory.request_body">{{ $t('apiTesting.history.requestBody') }}</h4>
              <pre v-if="selectedHistory.request_body" class="json-content">
                {{ formatRequestBody(selectedHistory.request_body) }}
              </pre>
            </div>
          </el-tab-pane>

          <el-tab-pane :label="$t('apiTesting.history.responseInfo')" name="response">
            <div v-if="selectedHistory.response_body" class="detail-section">
              <h4>{{ $t('apiTesting.history.responseHeaders') }}</h4>
              <el-table :data="parseHeaders(selectedHistory.response_headers)" style="width: 100%">
                <el-table-column prop="key" label="Key" width="200" />
                <el-table-column prop="value" label="Value" />
              </el-table>

              <h4>{{ $t('apiTesting.history.responseBody') }}</h4>
              <div class="response-actions">
                <el-button size="small" @click="formatResponseBody">{{ $t('apiTesting.interface.format') }}</el-button>
                <el-button size="small" @click="copyResponseBody">{{ $t('apiTesting.common.copy') }}</el-button>
              </div>
              <pre class="json-content">{{ responseBodyText }}</pre>
            </div>

            <div v-else-if="selectedHistory.error_message" class="error-section">
              <h4>{{ $t('apiTesting.automation.status.failed') }}</h4>
              <el-alert
                :title="selectedHistory.error_message"
                type="error"
                :closable="false"
                show-icon
              />
            </div>

            <div v-else class="empty-response">
              <el-empty :description="$t('apiTesting.history.noResponseData')" />
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>

      <template #footer>
        <el-button @click="showDetailDialog = false">{{ $t('apiTesting.common.close') }}</el-button>
        <el-button type="primary" @click="retryRequest(selectedHistory)">
          {{ $t('apiTesting.history.retryRequest') }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 执行结果弹窗 -->
    <el-dialog
      v-model="showResultDialog"
      :title="resultDialogTitle"
      width="70%"
      :top="'8vh'"
      :close-on-click-modal="true"
    >
      <div v-if="executeResult" class="execute-result">
        <!-- 结果头部 -->
        <div class="result-header" :class="{ 'success': executeResult.success, 'failed': !executeResult.success }">
          <div class="result-status">
            <el-icon v-if="executeResult.success" class="status-icon success"><CircleCheck /></el-icon>
            <el-icon v-else class="status-icon failed"><CircleClose /></el-icon>
            <span class="status-text">{{ executeResult.success ? '请求成功' : '请求失败' }}</span>
          </div>
          <div class="result-meta">
            <el-tag :type="getResultStatusType(executeResult.status_code)">
              {{ executeResult.status_code || 'N/A' }}
            </el-tag>
            <span class="response-time">
              <el-icon><Clock /></el-icon>
              {{ executeResult.response_time ? executeResult.response_time + 'ms' : '-' }}
            </span>
          </div>
        </div>

        <!-- 结果内容 -->
        <el-tabs v-model="resultTab" class="result-tabs">
          <el-tab-pane label="响应体" name="body">
            <div class="result-body">
              <div class="result-actions">
                <el-button size="small" @click="formatResultBody">格式化</el-button>
                <el-button size="small" @click="copyResultBody">复制</el-button>
              </div>
              <pre class="result-content" v-html="highlightedResultBody"></pre>
            </div>
          </el-tab-pane>
          <el-tab-pane label="响应头" name="headers">
            <div class="result-headers">
              <div v-for="(value, key) in resultHeaders" :key="key" class="header-row">
                <strong>{{ key }}:</strong> {{ value }}
              </div>
              <el-empty v-if="Object.keys(resultHeaders).length === 0" description="无响应头" />
            </div>
          </el-tab-pane>
          <el-tab-pane v-if="executeResult.assertion_results && executeResult.assertion_results.length > 0" label="断言结果" name="assertions">
            <div class="assertions-results">
              <div
                v-for="(result, index) in executeResult.assertion_results"
                :key="index"
                class="assertion-item"
                :class="{ 'passed': result.passed, 'failed': !result.passed }"
              >
                <el-tag :type="result.passed ? 'success' : 'danger'" size="small">
                  {{ result.passed ? '通过' : '失败' }}
                </el-tag>
                <span class="assertion-name">{{ result.name || '断言 ' + (index + 1) }}</span>
              </div>
            </div>
          </el-tab-pane>
          <el-tab-pane v-if="executeResult.error" label="错误信息" name="error">
            <div class="error-content">
              <el-alert
                :title="executeResult.error"
                type="error"
                :closable="false"
                show-icon
              />
            </div>
          </el-tab-pane>
        </el-tabs>
      </div>

      <!-- 加载中 -->
      <div v-else class="executing">
        <el-icon class="is-loading" :size="32"><Loading /></el-icon>
        <span>正在执行请求...</span>
      </div>

      <template #footer>
        <el-button @click="showResultDialog = false">关闭</el-button>
        <el-button type="primary" @click="openInInterface">
          在接口管理中打开
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import api from '@/utils/api'
import { deleteRequestHistory, batchDeleteRequestHistory } from '@/api/api-testing'
import dayjs from 'dayjs'
import HistoryTable from './components/HistoryTable.vue'

const { t } = useI18n()
const activeTab = ref('HTTP')
const httpHistory = ref([])
const websocketHistory = ref([])
const loading = ref(false)
const searchText = ref('')
const currentPage = ref(1)
const pageSize = ref(20)
const total = ref(0)
const showDetailDialog = ref(false)
const selectedHistory = ref(null)
const detailTab = ref('request')
const selectedIds = ref([])

// 执行结果弹窗
const showResultDialog = ref(false)
const executeResult = ref(null)
const resultTab = ref('body')
const resultRequestId = ref(null)

const currentHistory = computed(() => {
  return activeTab.value === 'HTTP' ? httpHistory.value : websocketHistory.value
})

const responseBodyText = computed(() => {
  if (!selectedHistory.value?.response_body) return ''
  return selectedHistory.value.response_body
})

// 执行结果相关
const resultDialogTitle = computed(() => {
  if (executeResult.value) {
    return `执行结果 - ${executeResult.value.method || 'GET'} ${executeResult.value.url || ''}`
  }
  return '执行结果'
})

const resultHeaders = computed(() => {
  if (!executeResult.value?.headers) return {}
  try {
    return typeof executeResult.value.headers === 'string'
      ? JSON.parse(executeResult.value.headers)
      : executeResult.value.headers
  } catch (e) {
    return {}
  }
})

const highlightedResultBody = computed(() => {
  if (!executeResult.value?.body) return ''
  try {
    const json = JSON.parse(executeResult.value.body)
    return highlightJson(JSON.stringify(json, null, 2))
  } catch (e) {
    return escapeHtml(executeResult.value.body)
  }
})

const getResultStatusType = (status) => {
  if (!status) return 'info'
  if (status >= 200 && status < 300) return 'success'
  if (status >= 300 && status < 400) return 'warning'
  if (status >= 400) return 'danger'
  return 'info'
}

const highlightJson = (str) => {
  if (!str) return ''
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/("(\\u[a-zA-Z0-9]{4}|\\[^u]|[^\\"])*"(\s*:)?|\b(true|false|null)\b|-?\d+(?:\.\d*)?(?:[eE][+\-]?\d+)?)/g, (match) => {
      let cls = 'number'
      if (/^"/.test(match)) {
        cls = /:$/.test(match) ? 'key' : 'string'
      } else if (/true|false/.test(match)) {
        cls = 'boolean'
      } else if (/null/.test(match)) {
        cls = 'null'
      }
      return `<span class="json-${cls}">${match}</span>`
    })
}

const escapeHtml = (str) => {
  if (!str) return ''
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

const formatResultBody = () => {
  // 格式化已在 computed 中处理
}

const copyResultBody = () => {
  if (executeResult.value?.body) {
    navigator.clipboard.writeText(executeResult.value.body)
    ElMessage.success('已复制到剪贴板')
  }
}

const openInInterface = () => {
  showResultDialog.value = false
  // 可以导航到接口管理页面
}

// 解析 headers（可能是 JSON 字符串）
const parseHeaders = (headers) => {
  if (!headers) return []
  try {
    const parsed = typeof headers === 'string' ? JSON.parse(headers) : headers
    return Object.keys(parsed).map(key => ({
      key,
      value: parsed[key]
    }))
  } catch (e) {
    return []
  }
}

// 格式化请求体
const formatRequestBody = (body) => {
  if (!body) return ''
  try {
    const parsed = typeof body === 'string' ? JSON.parse(body) : body
    return JSON.stringify(parsed, null, 2)
  } catch (e) {
    return body
  }
}

const getMethodType = (method) => {
  const typeMap = {
    'GET': 'success',
    'POST': 'primary',
    'PUT': 'warning',
    'DELETE': 'danger',
    'PATCH': 'info'
  }
  return typeMap[method] || 'info'
}

const getStatusType = (status) => {
  if (!status) return 'info'
  if (status >= 200 && status < 300) return 'success'
  if (status >= 300 && status < 400) return 'warning'
  if (status >= 400) return 'danger'
  return 'info'
}

const formatDate = (dateString) => {
  return dayjs(dateString).format('YYYY-MM-DD HH:mm:ss')
}

const formatHeaders = (headers) => {
  if (!headers || typeof headers !== 'object') return []
  return Object.keys(headers).map(key => ({
    key,
    value: headers[key]
  }))
}

const loadHistory = async () => {
  loading.value = true
  try {
    const params = {
      current: currentPage.value,
      size: pageSize.value
    }

    if (searchText.value) {
      params.keyword = searchText.value
    }

    const response = await api.get('/api-request-histories', { params })
    // 响应拦截器已提取 response.data.data，所以 response.data 就是 { records, total, ... }
    const records = response.data?.records || []
    const totalCount = response.data?.total || 0

    if (activeTab.value === 'HTTP') {
      httpHistory.value = records
    } else {
      websocketHistory.value = records
    }

    total.value = totalCount
  } catch (error) {
    ElMessage.error(t('apiTesting.messages.error.loadHistory'))
    console.error(error)
  } finally {
    loading.value = false
  }
}

const onTabChange = () => {
  currentPage.value = 1
  selectedIds.value = []
  loadHistory()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  loadHistory()
}

const handleCurrentChange = (page) => {
  currentPage.value = page
  loadHistory()
}

const viewDetail = (history) => {
  selectedHistory.value = history
  detailTab.value = 'request'
  showDetailDialog.value = true
}

const retryRequest = async (history) => {
  resultRequestId.value = history.request_id
  executeResult.value = null
  resultTab.value = 'body'
  showResultDialog.value = true

  try {
    const response = await api.post(`/api-requests/${history.request_id}/execute`, {})
    executeResult.value = response.data

    // 刷新历史列表
    await loadHistory()
  } catch (error) {
    executeResult.value = {
      success: false,
      errorMessage: error.response?.data?.message || error.message || '请求执行失败',
      statusCode: error.response?.status,
      responseTime: 0
    }
  }
}

const clearHistory = async () => {
  try {
    await ElMessageBox.confirm(
      t('apiTesting.history.confirmClearHistory'),
      t('apiTesting.messages.confirm.clearTitle'),
      {
        confirmButtonText: t('apiTesting.common.confirm'),
        cancelButtonText: t('apiTesting.common.cancel'),
        type: 'warning'
      }
    )

    // 这里需要后端提供批量删除接口
    // 目前先用批量删除当前页的方式模拟，或者需要后端增加清空接口
    // 暂时提示未实现
    ElMessage.warning(t('apiTesting.history.clearNotImplemented'))
  } catch (error) {
    if (error !== 'cancel') {
      console.error(error)
    }
  }
}

const handleSelectionChange = (selection) => {
  selectedIds.value = selection.map(item => item.id)
}

const handleDelete = (row) => {
  ElMessageBox.confirm(t('apiTesting.history.confirmDelete'), t('apiTesting.common.tip'), {
    confirmButtonText: t('apiTesting.common.confirm'),
    cancelButtonText: t('apiTesting.common.cancel'),
    type: 'warning'
  }).then(async () => {
    try {
      await deleteRequestHistory(row.id)
      ElMessage.success(t('apiTesting.messages.success.delete'))
      loadHistory()
    } catch (error) {
      console.error('Delete failed:', error)
      ElMessage.error(t('apiTesting.messages.error.deleteFailed'))
    }
  })
}

const handleBatchDelete = () => {
  if (selectedIds.value.length === 0) return

  ElMessageBox.confirm(t('apiTesting.history.confirmBatchDelete', { n: selectedIds.value.length }), t('apiTesting.common.tip'), {
    confirmButtonText: t('apiTesting.common.confirm'),
    cancelButtonText: t('apiTesting.common.cancel'),
    type: 'warning'
  }).then(async () => {
    try {
      await batchDeleteRequestHistory(selectedIds.value)
      ElMessage.success(t('apiTesting.messages.success.batchDeleteSuccess'))
      selectedIds.value = []
      loadHistory()
    } catch (error) {
      console.error('Batch delete failed:', error)
      ElMessage.error(t('apiTesting.messages.error.batchDeleteFailed'))
    }
  })
}

const formatResponseBody = () => {
  // 响应体已经在 computed 中处理
}

const copyResponseBody = () => {
  if (responseBodyText.value) {
    navigator.clipboard.writeText(responseBodyText.value)
    ElMessage.success(t('apiTesting.messages.success.copiedToClipboard'))
  }
}

onMounted(() => {
  loadHistory()
})
</script>

<style scoped>
.request-history {
  padding: 20px;
  height: 100%;
  display: flex;
  flex-direction: column;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.header h3 {
  margin: 0;
  color: #303133;
}

.filters {
  display: flex;
  gap: 10px;
  align-items: center;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: center;
}

.history-detail {
  max-height: 70vh;
  overflow-y: auto;
}

.detail-tabs {
  margin-top: 20px;
}

.detail-section {
  padding: 10px 0;
}

.detail-section h4 {
  margin: 20px 0 10px 0;
  color: #303133;
  font-size: 14px;
  font-weight: 600;
}

.json-content {
  background: #f8f9fa;
  padding: 15px;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 12px;
  max-height: 400px;
  overflow: auto;
  white-space: pre-wrap;
  word-break: break-all;
  border: 1px solid #e4e7ed;
}

.response-actions {
  margin-bottom: 10px;
}

.error-section {
  padding: 20px 0;
}

.empty-response {
  padding: 40px 0;
  text-align: center;
}

/* 执行结果弹窗样式 */
.execute-result {
  min-height: 400px;
}

.result-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-radius: 8px;
  margin-bottom: 20px;
}

.result-header.success {
  background: linear-gradient(135deg, #67c23a20 0%, #67c23a10 100%);
  border: 1px solid #67c23a40;
}

.result-header.failed {
  background: linear-gradient(135deg, #f56c6c20 0%, #f56c6c10 100%);
  border: 1px solid #f56c6c40;
}

.result-status {
  display: flex;
  align-items: center;
  gap: 10px;
}

.status-icon {
  font-size: 24px;
}

.status-icon.success {
  color: #67c23a;
}

.status-icon.failed {
  color: #f56c6c;
}

.status-text {
  font-size: 18px;
  font-weight: 600;
  color: #303133;
}

.result-meta {
  display: flex;
  align-items: center;
  gap: 16px;
}

.response-time {
  display: flex;
  align-items: center;
  gap: 4px;
  color: #606266;
  font-size: 14px;
}

.result-tabs {
  margin-top: 0;
}

.result-body {
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  border: 1px solid #e9ecef;
}

.result-actions {
  margin-bottom: 16px;
  display: flex;
  gap: 8px;
}

.result-content {
  background: white;
  padding: 20px;
  border-radius: 8px;
  border: 1px solid #e9ecef;
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 14px;
  line-height: 1.6;
  max-height: 500px;
  overflow: auto;
  white-space: pre-wrap;
  word-wrap: break-word;
  margin: 0;
}

.result-headers {
  padding: 20px;
  background: #f8f9fa;
  border-radius: 8px;
  max-height: 500px;
  overflow: auto;
}

.result-headers .header-row {
  padding: 10px 0;
  border-bottom: 1px solid #e9ecef;
}

.result-headers .header-row:last-child {
  border-bottom: none;
}

.result-headers strong {
  color: #881391;
}

.assertions-results {
  padding: 20px;
}

.assertion-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 16px;
  background: white;
  border-radius: 8px;
  margin-bottom: 8px;
  border: 1px solid #e9ecef;
}

.assertion-item.passed {
  border-left: 4px solid #67c23a;
}

.assertion-item.failed {
  border-left: 4px solid #f56c6c;
}

.assertion-name {
  font-size: 14px;
  color: #303133;
}

.error-content {
  padding: 20px;
}

.executing {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  min-height: 300px;
  gap: 16px;
  color: #606266;
}

/* JSON 语法高亮 */
:deep(.json-key) {
  color: #881391;
}

:deep(.json-string) {
  color: #0b7500;
}

:deep(.json-number) {
  color: #00f;
}

:deep(.json-boolean) {
  color: #d73a49;
}

:deep(.json-null) {
  color: #808080;
}
</style>