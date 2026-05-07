<template>
  <div class="report-view">
    <div class="header">
      <h3>{{ $t('apiTesting.report.title') }}</h3>
      <div class="actions">
        <el-select
          v-model="selectedProject"
          :placeholder="$t('apiTesting.common.selectProject')"
          style="width: 200px; margin-right: 12px;"
          @change="loadReports"
        >
          <el-option
            v-for="project in projects"
            :key="project.id"
            :label="project.name"
            :value="project.id"
          />
        </el-select>
        <el-button type="primary" @click="refreshReports">{{ $t('apiTesting.report.refreshReport') }}</el-button>
      </div>
    </div>

    <div class="content">
      <el-table :data="reports" v-loading="loading" style="width: 100%" row-key="id">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="test_suite_name" :label="$t('apiTesting.report.testSuite')" min-width="200">
          <template #default="scope">
            {{ scope.row.test_suite_name || '-' }}
          </template>
        </el-table-column>
        <el-table-column label="状态" width="120">
          <template #default="scope">
            <el-tag :type="getStatusType(scope.row.status)">
              {{ getStatusText(scope.row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="total_requests" :label="$t('apiTesting.report.totalRequests')" width="100" />
        <el-table-column :label="$t('apiTesting.report.passedCount')" width="100">
          <template #default="scope">
            <span style="color: #67c23a">{{ scope.row.passed_requests }}</span>
          </template>
        </el-table-column>
        <el-table-column :label="$t('apiTesting.report.failedCount')" width="100">
          <template #default="scope">
            <span style="color: #f56c6c">{{ scope.row.failed_requests }}</span>
          </template>
        </el-table-column>
        <el-table-column label="执行者" width="120">
          <template #default="scope">
            {{ scope.row.executed_by?.username || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="created_at" :label="$t('apiTesting.report.executionTime')" width="180">
          <template #default="scope">
            {{ formatDate(scope.row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column :label="$t('apiTesting.common.operation')" width="240" fixed="right">
          <template #default="scope">
            <el-button size="small" type="primary" @click="viewDetail(scope.row)">
              查看详情
            </el-button>
            <el-button
              size="small"
              type="success"
              :loading="generatingReportId === scope.row.id"
              @click="generateReport(scope.row)"
            >
              {{ $t('apiTesting.report.generateAndViewReport') }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 执行详情弹窗 -->
    <el-dialog
      v-model="showDetailDialog"
      title="执行详情"
      width="900px"
      :close-on-click-modal="false"
    >
      <div v-if="detailRecord" class="detail-content">
        <el-descriptions :column="3" border style="margin-bottom: 16px;">
          <el-descriptions-item label="套件名称">{{ detailRecord.test_suite_name || '-' }}</el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="getStatusType(detailRecord.status)">
              {{ getStatusText(detailRecord.status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="执行时间">{{ formatDate(detailRecord.created_at) }}</el-descriptions-item>
          <el-descriptions-item label="总请求数">{{ detailRecord.total_requests }}</el-descriptions-item>
          <el-descriptions-item label="通过">
            <span style="color: #67c23a">{{ detailRecord.passed_requests }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="失败">
            <span style="color: #f56c6c">{{ detailRecord.failed_requests }}</span>
          </el-descriptions-item>
        </el-descriptions>

        <h4 style="margin: 16px 0 8px;">请求执行结果</h4>
        <el-table :data="detailResults" style="width: 100%" max-height="400">
          <el-table-column type="index" width="50" />
          <el-table-column label="请求名称" min-width="150">
            <template #default="scope">
              {{ scope.row.request_name || scope.row.requestName || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="方法" width="80">
            <template #default="scope">
              <el-tag size="small" :type="getMethodType(scope.row.method)">
                {{ scope.row.method || 'GET' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="URL" min-width="250" show-overflow-tooltip>
            <template #default="scope">
              {{ scope.row.url || '-' }}
            </template>
          </el-table-column>
          <el-table-column label="状态码" width="80">
            <template #default="scope">
              <span :style="{ color: getStatusColor(scope.row.status_code) }">
                {{ scope.row.status_code || '-' }}
              </span>
            </template>
          </el-table-column>
          <el-table-column label="耗时" width="80">
            <template #default="scope">
              {{ scope.row.response_time != null ? scope.row.response_time + 'ms' : '-' }}
            </template>
          </el-table-column>
          <el-table-column label="结果" width="80">
            <template #default="scope">
              <el-tag :type="scope.row.success ? 'success' : 'danger'" size="small">
                {{ scope.row.success ? '通过' : '失败' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="错误信息" min-width="150" show-overflow-tooltip>
            <template #default="scope">
              {{ scope.row.error || '-' }}
            </template>
          </el-table-column>
        </el-table>

        <!-- 断言结果 -->
        <div v-if="hasAssertions" style="margin-top: 16px;">
          <h4 style="margin: 0 0 8px;">断言结果</h4>
          <div v-for="(result, idx) in detailResults" :key="idx">
            <div v-if="result.assertions && result.assertions.length > 0" style="margin-bottom: 12px;">
              <strong>{{ result.requestName || '请求 ' + (idx + 1) }}</strong>
              <el-table :data="result.assertions" style="width: 100%; margin-top: 4px;" size="small">
                <el-table-column prop="name" label="断言名称" min-width="150" />
                <el-table-column label="结果" width="80">
                  <template #default="scope">
                    <el-tag :type="scope.row.passed ? 'success' : 'danger'" size="small">
                      {{ scope.row.passed ? '通过' : '失败' }}
                    </el-tag>
                  </template>
                </el-table-column>
                <el-table-column prop="expected" label="期望值" min-width="120" />
                <el-table-column prop="actual" label="实际值" min-width="120" />
                <el-table-column prop="error" label="错误" min-width="120" />
              </el-table>
            </div>
          </div>
        </div>
      </div>

      <template #footer>
        <el-button @click="showDetailDialog = false">关闭</el-button>
        <el-button type="primary" :loading="generatingReportId === detailRecord?.id" @click="generateReport(detailRecord)">
          {{ $t('apiTesting.report.generateAndViewReport') }}
        </el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import api from '@/utils/api'
import dayjs from 'dayjs'

const { t } = useI18n()
const reports = ref([])
const projects = ref([])
const selectedProject = ref(null)
const loading = ref(false)
const showDetailDialog = ref(false)
const detailRecord = ref(null)
const detailResults = ref([])

const hasAssertions = computed(() => {
  return detailResults.value.some(r => r.assertions && r.assertions.length > 0)
})

const loadProjects = async () => {
  try {
    const response = await api.get('/api-projects')
    projects.value = response.data?.records || response.data || []
    if (projects.value.length > 0) {
      selectedProject.value = projects.value[0].id
    }
  } catch (error) {
    ElMessage.error('加载项目列表失败')
  }
}

const loadReports = async () => {
  if (!selectedProject.value) return

  loading.value = true
  try {
    const response = await api.get(`/api-execution-records/project/${selectedProject.value}`)
    reports.value = response.data || []
  } catch (error) {
    ElMessage.error(t('apiTesting.messages.error.loadReports'))
  } finally {
    loading.value = false
  }
}

const refreshReports = async () => {
  await loadReports()
}

const viewDetail = async (record) => {
  try {
    const response = await api.get(`/api-execution-records/${record.id}`)
    detailRecord.value = response.data

    // 解析 result_data (SNAKE_CASE)
    const data = response.data
    const resultData = data.result_data || data.resultData
    if (resultData) {
      try {
        detailResults.value = typeof resultData === 'string'
          ? JSON.parse(resultData)
          : resultData
      } catch {
        detailResults.value = []
      }
    } else {
      detailResults.value = []
    }

    showDetailDialog.value = true
  } catch (error) {
    ElMessage.error('加载详情失败')
  }
}

const generatingReportId = ref(null)

const generateReport = async (record) => {
  generatingReportId.value = record.id
  try {
    const response = await api.post(
      `/api-execution-records/${record.id}/generate-allure-report`,
      null,
      { timeout: 300000 } // Allure 生成较慢，5分钟超时
    )
    const reportUrl = response.data?.report_url
    if (reportUrl) {
      // 支持绝对 URL（MinIO）和相对路径
      const fullUrl = reportUrl.startsWith('http') ? reportUrl : window.location.origin + reportUrl
      const opened = window.open(fullUrl, '_blank')
      // 浏览器拦截弹窗时，显示链接让用户手动打开
      if (!opened || opened.closed) {
        ElMessageBox.alert(
          `<div>报告已生成，但浏览器拦截了弹窗。请点击下方链接查看：</div>
           <a href="${fullUrl}" target="_blank" style="color: #409eff; word-break: break-all;">${fullUrl}</a>`,
          '报告已生成',
          { dangerouslyUseHTMLString: true, confirmButtonText: '确定' }
        )
      }
    }
  } catch (error) {
    ElMessage.error('生成报告失败: ' + (error.message || '未知错误'))
  } finally {
    generatingReportId.value = null
  }
}

const getStatusType = (status) => {
  if (status === true || status === 'COMPLETED') return 'success'
  if (status === false || status === 'FAILED') return 'danger'
  if (status === 'RUNNING') return 'warning'
  return 'info'
}

const getStatusText = (status) => {
  if (status === true || status === 'COMPLETED') return '成功'
  if (status === false || status === 'FAILED') return '失败'
  if (status === 'RUNNING') return '执行中'
  if (status === 'PENDING') return '待执行'
  return '未知'
}

const getMethodType = (method) => {
  const map = { GET: 'success', POST: 'primary', PUT: 'warning', DELETE: 'danger', PATCH: 'info' }
  return map[method?.toUpperCase()] || 'info'
}

const getStatusColor = (code) => {
  if (!code) return '#909399'
  if (code >= 200 && code < 300) return '#67c23a'
  if (code >= 300 && code < 400) return '#e6a23c'
  return '#f56c6c'
}

const formatDate = (dateString) => {
  if (!dateString) return '-'
  return dayjs(dateString).format('YYYY-MM-DD HH:mm:ss')
}

onMounted(async () => {
  await loadProjects()
  if (selectedProject.value) {
    await loadReports()
  }
})
</script>

<style scoped>
.report-view {
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

.actions {
  display: flex;
  align-items: center;
}

.content {
  flex: 1;
  overflow: auto;
}

.detail-content {
  max-height: 70vh;
  overflow-y: auto;
}
</style>
