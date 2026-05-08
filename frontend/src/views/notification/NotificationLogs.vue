<template>
  <div class="notification-logs-container">
    <!-- 页面操作栏 -->
    <div class="page-actions">
      <el-row :gutter="20" class="filter-row">
        <el-col :span="6">
          <el-input
              v-model="searchForm.taskName"
              :placeholder="$t('notification.logs.searchTaskName')"
              clearable
              @clear="handleSearch"
              @keyup.enter="handleSearch"
          >
            <template #prefix>
              <el-icon>
                <Search/>
              </el-icon>
            </template>
          </el-input>
        </el-col>
        <el-col :span="6">
          <el-date-picker
              v-model="searchForm.dateRange"
              type="daterange"
              :range-separator="$t('notification.logs.rangeSeparator')"
              :start-placeholder="$t('notification.logs.startDate')"
              :end-placeholder="$t('notification.logs.endDate')"
              value-format="YYYY-MM-DD"
              @change="handleSearch"
          />
        </el-col>
        <el-col :span="6">
          <el-select
              v-model="searchForm.status"
              :placeholder="$t('notification.logs.notificationStatus')"
              clearable
              @change="handleSearch"
          >
            <el-option :label="$t('notification.logs.statusOptions.all')" value=""/>
            <el-option :label="$t('notification.logs.statusOptions.success')" value="SUCCESS"/>
            <el-option :label="$t('notification.logs.statusOptions.failed')" value="FAILED"/>
            <el-option :label="$t('notification.logs.statusOptions.retrying')" value="RETRYING"/>
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-button type="primary" @click="handleSearch">
            <el-icon>
              <Search/>
            </el-icon>
            {{ $t('notification.logs.search') }}
          </el-button>
          <el-button @click="handleReset">
            {{ $t('notification.logs.reset') }}
          </el-button>
        </el-col>
      </el-row>
    </div>

    <!-- 通知列表 -->
    <div class="logs-table-container">
      <el-table
          :data="logsData"
          v-loading="loading"
          :element-loading-text="$t('notification.logs.loading')"
          stripe
          style="width: 100%"
          @sort-change="handleSortChange"
      >
        <el-table-column
            prop="task_name"
            :label="$t('notification.logs.columns.taskName')"
            min-width="150"
        />
        <el-table-column
            prop="task_type"
            :label="$t('notification.logs.columns.taskType')"
            min-width="100"
        >
          <template #default="{ row }">
            <span v-if="row.task_type">
              <el-tag type="info" size="small">
                {{ getTaskTypeDisplay(row.task_type) }}
              </el-tag>
            </span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column
            prop="channel"
            :label="$t('notification.logs.columns.notificationType')"
            min-width="120"
        >
          <template #default="{ row }">
            <el-tag
                :type="getChannelTagType(row.channel)"
                size="small"
            >
              {{ getChannelDisplay(row.channel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
            :label="$t('notification.logs.columns.notificationTarget')"
            min-width="150"
        >
          <template #default="{ row }">
            <span>{{ formatRecipientDisplay(row.recipient_info) }}</span>
          </template>
        </el-table-column>
        <el-table-column
            prop="created_at"
            :label="$t('notification.logs.columns.notificationTime')"
            min-width="180"
        >
          <template #default="{ row }">
            {{ formatDate(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column
            prop="status"
            :label="$t('notification.logs.columns.status')"
            min-width="100"
        >
          <template #default="{ row }">
            <el-tag
                :type="getStatusTagType(row.status)"
                size="small"
            >
              {{ getStatusDisplay(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column
            :label="$t('notification.logs.columns.operation')"
            fixed="right"
            width="120"
        >
          <template #default="{ row }">
            <el-button
                type="primary"
                link
                size="small"
                @click="viewDetail(row)"
            >
              {{ $t('notification.logs.viewDetail') }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-container">
        <el-pagination
            v-model:current-page="pagination.currentPage"
            v-model:page-size="pagination.pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="pagination.total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
        />
      </div>
    </div>

    <!-- 详情弹窗 -->
    <el-dialog
        v-model="detailDialogVisible"
        :title="$t('notification.logs.detailDialog.title')"
        width="600px"
        :before-close="handleDetailDialogClose"
        :close-on-click-modal="false"
        :close-on-press-escape="false"
        :modal="true"
        :destroy-on-close="false"
    >
      <el-form
          v-if="selectedLog"
          label-position="top"
          class="notification-detail-form"
      >
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.taskName')">
              <span>{{ selectedLog.task_name || (selectedLog.task_id ? 'ID: ' + selectedLog.task_id : '-') }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.taskType')">
              <span>{{ selectedLog.task_type ? getTaskTypeDisplay(selectedLog.task_type) : '-' }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.notificationType')">
              <el-tag :type="getChannelTagType(selectedLog.channel)">
                {{ getChannelDisplay(selectedLog.channel) }}
              </el-tag>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.status')">
              <el-tag :type="getStatusTagType(selectedLog.status)">
                {{ getStatusDisplay(selectedLog.status) }}
              </el-tag>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.notificationTime')">
              <span>{{ formatDate(selectedLog.created_at) }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item :label="$t('notification.logs.detailDialog.sentTime')">
              <span>{{ selectedLog.sent_at ? formatDate(selectedLog.sent_at) : '-' }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="24" v-if="selectedLog.recipient_info">
            <el-form-item :label="$t('notification.logs.detailDialog.notificationTarget')">
              <span>{{ formatRecipientDisplay(selectedLog.recipient_info) }}</span>
            </el-form-item>
          </el-col>
          <el-col :span="24">
            <el-form-item :label="$t('notification.logs.detailDialog.notificationContent')">
              <div class="notification-content">
                <div v-if="parsedNotificationContent" class="notification-content-parsed">
                  <div class="content-item" v-for="(item, index) in parsedNotificationContent" :key="index">
                    <span class="content-label">{{ item.label }}:</span>
                    <span class="content-value">{{ item.value }}</span>
                  </div>
                </div>
                <div v-else class="notification-content-raw">
                  <pre>{{ selectedLog.content || '-' }}</pre>
                </div>
              </div>
            </el-form-item>
          </el-col>
          <el-col :span="24" v-if="selectedLog.error_message">
            <el-form-item :label="$t('notification.logs.detailDialog.errorMessage')">
              <div class="error-message">
                <el-alert
                    :title="selectedLog.error_message"
                    type="error"
                    show-icon
                    :closable="false"
                />
              </div>
            </el-form-item>
          </el-col>
        </el-row>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="detailDialogVisible = false">{{ $t('notification.logs.detailDialog.close') }}</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script>
import {Search} from '@element-plus/icons-vue'
import {ref, reactive, onMounted, computed} from 'vue'
import {useI18n} from 'vue-i18n'
import {ElMessage} from 'element-plus'
import api from '@/utils/api'

export default {
  name: 'NotificationLogs',
  components: {
    Search
  },
  setup() {
    const {t, locale} = useI18n()

    // 数据状态
    const loading = ref(false)
    const logsData = ref([])
    const detailDialogVisible = ref(false)
    const selectedLog = ref(null)

    // 搜索表单
    const searchForm = reactive({
      taskName: '',
      dateRange: [],
      status: ''
    })

    // 分页配置
    const pagination = reactive({
      currentPage: 1,
      pageSize: 10,
      total: 0
    })

    // 排序参数
    const sortParams = reactive({
      prop: 'created_at',
      order: 'descending'
    })

    // 获取通知日志数据
    const fetchLogsData = async () => {
      loading.value = true
      try {
        const params = {
          current: pagination.currentPage,
          size: pagination.pageSize
        }

        if (searchForm.status) {
          params.status = searchForm.status
        }

        const response = await api.get('/notifications/logs', {params})
        logsData.value = response.data.records || []
        pagination.total = response.data.total || 0
      } catch (error) {
        console.error('Fetch notification logs failed:', error)
        ElMessage.error(t('notification.logs.messages.fetchFailed'))
      } finally {
        loading.value = false
      }
    }

    // 处理搜索
    const handleSearch = () => {
      pagination.currentPage = 1
      fetchLogsData()
    }

    // 重置搜索
    const handleReset = () => {
      searchForm.taskName = ''
      searchForm.dateRange = []
      searchForm.status = ''
      pagination.currentPage = 1
      fetchLogsData()
    }

    // 处理分页变化
    const handleSizeChange = (val) => {
      pagination.pageSize = val
      pagination.currentPage = 1
      fetchLogsData()
    }

    const handleCurrentChange = (val) => {
      pagination.currentPage = val
      fetchLogsData()
    }

    // 处理排序
    const handleSortChange = ({prop, order}) => {
      sortParams.prop = prop
      sortParams.order = order || 'descending'
      fetchLogsData()
    }

    // 查看详情
    const viewDetail = async (row) => {
      try {
        const response = await api.get(`/notifications/logs/${row.id}`)
        selectedLog.value = response.data
        detailDialogVisible.value = true
      } catch (error) {
        console.error('Fetch notification detail failed:', error)
        ElMessage.error(t('notification.logs.messages.fetchDetailFailed'))
      }
    }

    // 关闭详情弹窗
    const handleDetailDialogClose = (done) => {
      selectedLog.value = null
      done()
    }

    // 格式化日期
    const formatDate = (dateString) => {
      if (!dateString) return '-'
      const date = new Date(dateString)
      return date.toLocaleString(locale.value === 'zh-cn' ? 'zh-CN' : 'en-US')
    }

    // 获取状态标签类型
    const getStatusTagType = (status) => {
      const typeMap = {
        'success': 'success',
        'failed': 'danger',
        'pending': 'info',
        'sending': 'warning',
        'cancelled': 'info'
      }
      return typeMap[status] || 'info'
    }

    // 获取状态显示文本
    const getStatusDisplay = (status) => {
      const map = {
        'success': '成功',
        'failed': '失败',
        'pending': '待发送',
        'sending': '发送中',
        'cancelled': '已取消'
      }
      return map[status] || status || '-'
    }

    // 获取任务类型显示文本
    const getTaskTypeDisplay = (taskType) => {
      const map = {
        'api_test': '接口测试',
        'ui_automation': 'UI自动化',
        'app_automation': 'APP自动化'
      }
      return map[taskType] || taskType || '-'
    }

    // 获取通知渠道显示文本
    const getChannelDisplay = (channel) => {
      const map = {
        'email': '邮件通知',
        'feishu': '飞书通知',
        'wechat': '企微通知',
        'dingtalk': '钉钉通知'
      }
      return map[channel] || channel || '-'
    }

    // 获取通知渠道标签类型
    const getChannelTagType = (channel) => {
      const map = {
        'email': '',
        'feishu': 'primary',
        'wechat': 'success',
        'dingtalk': 'warning'
      }
      return map[channel] || 'info'
    }

    // 格式化收件人显示
    const formatRecipientDisplay = (recipientInfo) => {
      if (!recipientInfo) return '-'
      try {
        const info = typeof recipientInfo === 'string' ? JSON.parse(recipientInfo) : recipientInfo
        if (Array.isArray(info)) {
          if (info.length === 0) return '-'
          if (typeof info[0] === 'string') return info.join(', ')
          return info.map(item => item.email || item.name || '-').join(', ')
        }
        if (typeof info === 'object') return info.email || info.name || '-'
        return String(info)
      } catch {
        return recipientInfo
      }
    }

    // 解析通知内容为结构化数据
    const parsedNotificationContent = computed(() => {
      if (!selectedLog.value || !selectedLog.value.content) {
        return null
      }

      const content = selectedLog.value.content

      try {
        const jsonContent = JSON.parse(content)
        const result = []

        let contentText = ''

        if (jsonContent.msgtype === 'markdown' && jsonContent.markdown) {
          if (jsonContent.markdown.text) {
            contentText = jsonContent.markdown.text
          } else if (jsonContent.markdown.content) {
            contentText = jsonContent.markdown.content
          }
        }
        else if (jsonContent.msg_type === 'interactive' && jsonContent.card) {
          if (jsonContent.card.elements && jsonContent.card.elements[0] && jsonContent.card.elements[0].text) {
            contentText = jsonContent.card.elements[0].text.content
          }
        }

        if (contentText) {
          const lines = contentText.split('\n').filter(line => line.trim())

          lines.forEach(line => {
            if (line.includes('**') || line.trim() === '') {
              return
            }

            const colonIndex = line.indexOf(':')
            if (colonIndex > 0) {
              const label = line.substring(0, colonIndex).trim()
              const value = line.substring(colonIndex + 1).trim()

              if (label && value) {
                result.push({
                  label: label,
                  value: value
                })
              }
            }
          })

          return result.length > 0 ? result : null
        }
      } catch (e) {
        console.log('Trying to parse as plain text format')
      }

      try {
        const result = []
        const lines = content.split('\n').filter(line => line.trim())

        lines.forEach(line => {
          if (!line.trim()) {
            return
          }

          const colonIndex = line.indexOf(':')
          if (colonIndex > 0) {
            const label = line.substring(0, colonIndex).trim()
            const value = line.substring(colonIndex + 1).trim()

            if (label && value && !value.includes("'results':") && !value.includes('"results":')) {
              result.push({
                label: label,
                value: value
              })
            }
          }
        })

        return result.length > 0 ? result : null
      } catch (e) {
        console.error('Parse notification content failed:', e)
        return null
      }
    })

    // 组件挂载时获取数据
    onMounted(() => {
      fetchLogsData()
    })

    return {
      loading,
      logsData,
      detailDialogVisible,
      selectedLog,
      searchForm,
      pagination,
      sortParams,
      parsedNotificationContent,
      handleSearch,
      handleReset,
      handleSizeChange,
      handleCurrentChange,
      handleSortChange,
      viewDetail,
      handleDetailDialogClose,
      formatDate,
      getStatusTagType,
      getStatusDisplay,
      getTaskTypeDisplay,
      getChannelDisplay,
      getChannelTagType,
      formatRecipientDisplay
    }
  }
}
</script>

<style scoped>
.notification-logs-container {
  padding: 20px;
  background: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 12px 0 rgba(0, 0, 0, 0.1);
}

.page-actions {
  margin-bottom: 20px;
  padding: 20px;
  background: #f8f9fa;
  border-radius: 6px;
}

.filter-row {
  display: flex;
  align-items: center;
  gap: 15px;
}

.logs-table-container {
  margin-top: 20px;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.notification-detail-form :deep(.el-form-item) {
  margin-bottom: 18px;
}

.notification-targets {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.target-tag {
  margin: 0;
}

.notification-content {
  width: 100%;
}

.notification-content-parsed {
  background: #ffffff;
  border-radius: 8px;
  padding: 20px;
  border: 1px solid #e4e7ed;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.06);
}

.content-item {
  display: flex;
  align-items: flex-start;
  padding: 12px 0;
  border-bottom: 1px solid #f0f2f5;
}

.content-item:last-child {
  border-bottom: none;
  padding-bottom: 0;
}

.content-item:first-child {
  padding-top: 0;
}

.content-label {
  font-weight: 600;
  color: #606266;
  min-width: 100px;
  flex-shrink: 0;
  margin-right: 16px;
  font-size: 14px;
  line-height: 1.8;
}

.content-value {
  color: #303133;
  flex: 1;
  word-break: break-word;
  font-size: 14px;
  line-height: 1.8;
}

.notification-content-raw pre {
  white-space: pre-wrap;
  word-break: break-word;
  margin: 0;
  padding: 16px;
  background: #f5f7fa;
  border-radius: 8px;
  border: 1px solid #e4e7ed;
  font-size: 13px;
  line-height: 1.6;
  color: #606266;
  max-height: 400px;
  overflow-y: auto;
}

.notification-content-raw pre::-webkit-scrollbar {
  width: 6px;
  height: 6px;
}

.notification-content-raw pre::-webkit-scrollbar-thumb {
  background: #c0c4cc;
  border-radius: 3px;
}

.notification-content-raw pre::-webkit-scrollbar-thumb:hover {
  background: #a8abb2;
}

.error-message {
  margin-top: 8px;
}

.response-info pre {
  white-space: pre-wrap;
  word-break: break-word;
  margin: 0;
  padding: 12px;
  background: #f5f7fa;
  border-radius: 4px;
  max-height: 150px;
  overflow-y: auto;
  font-family: monospace;
  font-size: 12px;
}

.dialog-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
