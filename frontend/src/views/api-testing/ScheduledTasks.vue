<template>
  <div class="scheduled-tasks">
    <div class="header">
      <h3>{{ $t('apiTesting.scheduledTask.title') }}</h3>
      <div class="actions">
        <el-select
          v-model="selectedProject"
          :placeholder="$t('apiTesting.common.selectProject')"
          style="width: 200px; margin-right: 12px;"
          @change="onProjectChange"
        >
          <el-option
            v-for="project in projects"
            :key="project.id"
            :label="project.name"
            :value="project.id"
          />
        </el-select>
        <el-button type="primary" @click="handleCreateClick">
          <el-icon><Plus /></el-icon>
          {{ $t('apiTesting.scheduledTask.createTask') }}
        </el-button>
      </div>
    </div>

    <!-- 筛选条件 -->
    <div class="filters">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-select v-model="filters.task_type" :placeholder="$t('apiTesting.scheduledTask.taskType')" clearable>
            <el-option :label="$t('apiTesting.scheduledTask.taskTypes.testSuite')" value="TEST_SUITE" />
            <el-option :label="$t('apiTesting.scheduledTask.taskTypes.apiRequest')" value="API_REQUEST" />
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-select v-model="filters.trigger_type" :placeholder="$t('apiTesting.scheduledTask.triggerType')" clearable>
            <el-option :label="$t('apiTesting.scheduledTask.triggerTypes.cron')" value="CRON" />
            <el-option :label="$t('apiTesting.scheduledTask.triggerTypes.interval')" value="INTERVAL" />
            <el-option :label="$t('apiTesting.scheduledTask.triggerTypes.once')" value="ONCE" />
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-select v-model="filters.is_enabled" placeholder="任务状态" clearable>
            <el-option label="启用" :value="true" />
            <el-option label="暂停" :value="false" />
          </el-select>
        </el-col>
        <el-col :span="6">
          <el-button @click="resetFilters">{{ $t('apiTesting.common.reset') }}</el-button>
          <el-button type="primary" @click="loadTasks">{{ $t('apiTesting.common.search') }}</el-button>
        </el-col>
      </el-row>
    </div>

    <!-- 任务列表 -->
    <div class="task-list">
      <el-table :data="tasks" v-loading="loading">
        <el-table-column prop="name" :label="$t('apiTesting.scheduledTask.taskName')" min-width="200" />
        <el-table-column prop="trigger_type" :label="$t('apiTesting.scheduledTask.triggerType')" width="120">
          <template #default="scope">
            <el-tag>
              {{ getTriggerTypeText(scope.row.trigger_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_enabled" :label="$t('apiTesting.common.status')" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.is_enabled ? 'success' : 'warning'">
              {{ scope.row.is_enabled ? $t('apiTesting.scheduledTask.status.active') : $t('apiTesting.scheduledTask.status.paused') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="notification_config" :label="$t('apiTesting.scheduledTask.notificationType')" width="120">
          <template #default="scope">
            <el-tag :type="getNotificationTypeTag(scope.row.notification_config)" size="small">
              {{ getNotificationTypeDisplay(scope.row.notification_config) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column :label="$t('apiTesting.scheduledTask.nextRunTime')" width="180">
          <template #default="scope">
            <span v-if="scope.row.trigger_type === 'ONCE'">
              {{ formatDateTime(scope.row.once_time) }}
            </span>
            <span v-else>
              {{ formatDateTime(scope.row.next_run_at) }}
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="last_run_at" :label="$t('apiTesting.scheduledTask.lastRunTime')" width="180">
          <template #default="scope">
            {{ formatDateTime(scope.row.last_run_at) }}
          </template>
        </el-table-column>
        <el-table-column :label="$t('apiTesting.common.operation')" width="200" fixed="right">
          <template #default="scope">
            <el-button size="small" @click="runTaskNow(scope.row)" :loading="scope.row.running">
              {{ $t('apiTesting.scheduledTask.runNow') }}
            </el-button>
            <el-dropdown @command="(command) => handleTaskAction(command, scope.row)">
              <el-button size="small">
                {{ $t('apiTesting.common.more') }}<el-icon><arrow-down /></el-icon>
              </el-button>
              <template #dropdown>
                <el-dropdown-menu>
                  <el-dropdown-item command="edit">{{ $t('apiTesting.common.edit') }}</el-dropdown-item>
                  <el-dropdown-item command="pause" v-if="scope.row.is_enabled">{{ $t('apiTesting.scheduledTask.pause') }}</el-dropdown-item>
                  <el-dropdown-item command="activate" v-if="!scope.row.is_enabled">{{ $t('apiTesting.scheduledTask.activate') }}</el-dropdown-item>
                  <el-dropdown-item command="logs">{{ $t('apiTesting.scheduledTask.executionLogs') }}</el-dropdown-item>
                  <el-dropdown-item command="delete" divided>{{ $t('apiTesting.common.delete') }}</el-dropdown-item>
                </el-dropdown-menu>
              </template>
            </el-dropdown>
          </template>
        </el-table-column>
      </el-table>
    </div>

    <!-- 分页 -->
    <div class="pagination">
      <el-pagination
        v-model:current-page="pagination.current"
        v-model:page-size="pagination.size"
        :total="pagination.total"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="loadTasks"
        @current-change="loadTasks"
      />
    </div>

    <!-- 创建/编辑对话框 -->
    <el-dialog
      v-model="showCreateDialog"
      :title="editingTask ? $t('apiTesting.scheduledTask.editTask') : $t('apiTesting.scheduledTask.createTask')"
      width="800px"
      :close-on-click-modal="false"
      @close="resetTaskForm"
    >
      <el-form :model="taskForm" label-width="120px">
        <el-form-item :label="$t('apiTesting.scheduledTask.taskName')" required>
          <el-input v-model="taskForm.name" :placeholder="$t('apiTesting.scheduledTask.inputTaskName')" />
        </el-form-item>

        <el-form-item :label="$t('apiTesting.scheduledTask.taskDescription')">
          <el-input v-model="taskForm.description" type="textarea" :placeholder="$t('apiTesting.scheduledTask.inputTaskDesc')" />
        </el-form-item>

        <el-form-item :label="$t('apiTesting.scheduledTask.taskType')" required>
          <el-radio-group v-model="taskForm.task_type">
            <el-radio label="TEST_SUITE">{{ $t('apiTesting.scheduledTask.taskTypes.testSuite') }}</el-radio>
            <el-radio label="API_REQUEST">{{ $t('apiTesting.scheduledTask.taskTypes.apiRequest') }}</el-radio>
          </el-radio-group>
        </el-form-item>

        <el-form-item :label="$t('apiTesting.scheduledTask.triggerType')" required>
          <el-radio-group v-model="taskForm.trigger_type">
            <el-radio label="CRON">{{ $t('apiTesting.scheduledTask.triggerTypes.cron') }}</el-radio>
            <el-radio label="INTERVAL">{{ $t('apiTesting.scheduledTask.triggerTypes.interval') }}</el-radio>
            <el-radio label="ONCE">{{ $t('apiTesting.scheduledTask.triggerTypes.once') }}</el-radio>
          </el-radio-group>
        </el-form-item>

        <!-- CRON 可视化构建器 -->
        <el-form-item v-if="taskForm.trigger_type === 'CRON'" label="调度规则" required>
          <div class="cron-builder">
            <!-- 模式切换 -->
            <el-radio-group v-model="cronMode" size="small" style="margin-bottom: 12px;">
              <el-radio-button value="preset">常用预设</el-radio-button>
              <el-radio-button value="custom">自定义</el-radio-button>
              <el-radio-button value="advanced">高级</el-radio-button>
            </el-radio-group>

            <!-- 常用预设 -->
            <div v-if="cronMode === 'preset'" class="cron-presets">
              <el-button
                v-for="p in cronPresets"
                :key="p.value"
                :type="taskForm.cron_expression === p.value ? 'primary' : 'default'"
                @click="selectCronPreset(p)"
                size="small"
              >
                {{ p.label }}
              </el-button>
            </div>

            <!-- 自定义构建 -->
            <div v-if="cronMode === 'custom'" class="cron-custom">
              <el-row :gutter="12">
                <el-col :span="8">
                  <div class="cron-field-label">分钟</div>
                  <el-select v-model="cronFields.minuteType" @change="onCronFieldChange" style="width: 100%;">
                    <el-option label="每分钟" value="*" />
                    <el-option label="每N分钟" value="*/N" />
                    <el-option label="指定" value="fixed" />
                  </el-select>
                  <el-select
                    v-if="cronFields.minuteType === '*/N'"
                    v-model="cronFields.minuteStep"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                  >
                    <el-option v-for="n in [2,3,5,10,15,20,30]" :key="n" :label="'每' + n + '分钟'" :value="n" />
                  </el-select>
                  <el-select
                    v-if="cronFields.minuteType === 'fixed'"
                    v-model="cronFields.minuteValue"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                    filterable
                  >
                    <el-option v-for="n in 60" :key="n-1" :label="(n-1) + '分'" :value="n-1" />
                  </el-select>
                </el-col>
                <el-col :span="8">
                  <div class="cron-field-label">小时</div>
                  <el-select v-model="cronFields.hourType" @change="onCronFieldChange" style="width: 100%;">
                    <el-option label="每小时" value="*" />
                    <el-option label="每N小时" value="*/N" />
                    <el-option label="指定" value="fixed" />
                  </el-select>
                  <el-select
                    v-if="cronFields.hourType === '*/N'"
                    v-model="cronFields.hourStep"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                  >
                    <el-option v-for="n in [2,3,4,6,8,12]" :key="n" :label="'每' + n + '小时'" :value="n" />
                  </el-select>
                  <el-select
                    v-if="cronFields.hourType === 'fixed'"
                    v-model="cronFields.hourValue"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                    filterable
                  >
                    <el-option v-for="n in 24" :key="n-1" :label="(n-1) + '时'" :value="n-1" />
                  </el-select>
                </el-col>
                <el-col :span="8">
                  <div class="cron-field-label">日</div>
                  <el-select v-model="cronFields.dayType" @change="onCronFieldChange" style="width: 100%;">
                    <el-option label="每天" value="*" />
                    <el-option label="指定日期" value="fixed" />
                  </el-select>
                  <el-select
                    v-if="cronFields.dayType === 'fixed'"
                    v-model="cronFields.dayValue"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                    filterable
                  >
                    <el-option v-for="n in 31" :key="n" :label="n + '号'" :value="n" />
                  </el-select>
                </el-col>
              </el-row>
              <el-row :gutter="12" style="margin-top: 8px;">
                <el-col :span="12">
                  <div class="cron-field-label">月</div>
                  <el-select v-model="cronFields.monthType" @change="onCronFieldChange" style="width: 100%;">
                    <el-option label="每月" value="*" />
                    <el-option label="指定月份" value="fixed" />
                  </el-select>
                  <el-select
                    v-if="cronFields.monthType === 'fixed'"
                    v-model="cronFields.monthValue"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                    filterable
                  >
                    <el-option v-for="n in 12" :key="n" :label="n + '月'" :value="n" />
                  </el-select>
                </el-col>
                <el-col :span="12">
                  <div class="cron-field-label">星期</div>
                  <el-select v-model="cronFields.weekdayType" @change="onCronFieldChange" style="width: 100%;">
                    <el-option label="不限" value="?" />
                    <el-option label="工作日 (周一至周五)" value="MON-FRI" />
                    <el-option label="周末" value="SAT-SUN" />
                    <el-option label="指定" value="fixed" />
                  </el-select>
                  <el-select
                    v-if="cronFields.weekdayType === 'fixed'"
                    v-model="cronFields.weekdayValue"
                    @change="onCronFieldChange"
                    style="width: 100%; margin-top: 4px;"
                  >
                    <el-option label="周一" value="MON" />
                    <el-option label="周二" value="TUE" />
                    <el-option label="周三" value="WED" />
                    <el-option label="周四" value="THU" />
                    <el-option label="周五" value="FRI" />
                    <el-option label="周六" value="SAT" />
                    <el-option label="周日" value="SUN" />
                  </el-select>
                </el-col>
              </el-row>
            </div>

            <!-- 高级模式 -->
            <div v-if="cronMode === 'advanced'">
              <el-input v-model="taskForm.cron_expression" placeholder="0 0 9 * * ?" />
              <div style="margin-top: 4px; font-size: 12px; color: #909399;">
                格式: 秒 分 时 日 月 星期 (Spring CRON 6位)
              </div>
            </div>

            <!-- 表达式预览 -->
            <div class="cron-preview">
              <div class="cron-preview-expr">
                <span class="cron-preview-label">表达式:</span>
                <code>{{ taskForm.cron_expression }}</code>
              </div>
              <div class="cron-preview-desc">
                <span class="cron-preview-label">说明:</span>
                <span>{{ getCronDescription(taskForm.cron_expression) }}</span>
              </div>
            </div>
          </div>
        </el-form-item>

        <el-form-item v-if="taskForm.trigger_type === 'INTERVAL'" :label="$t('apiTesting.scheduledTask.intervalTime')" required>
          <el-input-number v-model="taskForm.interval_seconds" :min="60" :step="60" />
          <span class="unit">{{ $t('apiTesting.scheduledTask.seconds') }}</span>
        </el-form-item>

        <el-form-item v-if="taskForm.trigger_type === 'ONCE'" :label="$t('apiTesting.scheduledTask.executeTime')" required>
          <el-date-picker
            v-model="taskForm.execute_at"
            type="datetime"
            :placeholder="$t('apiTesting.scheduledTask.selectExecuteTime')"
          />
        </el-form-item>

        <!-- 根据任务类型显示不同配置 -->
        <el-form-item v-if="taskForm.task_type === 'TEST_SUITE'" :label="$t('apiTesting.automation.testSuite')" required>
          <el-select v-model="taskForm.test_suite" :placeholder="$t('apiTesting.scheduledTask.selectTestSuite')">
            <el-option
              v-for="suite in testSuites"
              :key="suite.id"
              :label="suite.name"
              :value="suite.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item v-if="taskForm.task_type === 'API_REQUEST'" :label="$t('apiTesting.scheduledTask.apiRequest')" required>
          <el-select v-model="taskForm.api_request" :placeholder="$t('apiTesting.scheduledTask.selectApiRequest')">
            <el-option
              v-for="request in apiRequests"
              :key="request.id"
              :label="request.name"
              :value="request.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item :label="$t('apiTesting.scheduledTask.executeEnvironment')">
          <el-select v-model="taskForm.environment" :placeholder="$t('apiTesting.scheduledTask.selectEnvironment')">
            <el-option
              v-for="env in environments"
              :key="env.id"
              :label="env.name"
              :value="env.id"
            />
          </el-select>
        </el-form-item>

        <el-form-item :label="$t('apiTesting.scheduledTask.notificationSettings')">
          <el-checkbox v-model="taskForm.notify_on_success">{{ $t('apiTesting.scheduledTask.notifyOnSuccess') }}</el-checkbox>
          <el-checkbox v-model="taskForm.notify_on_failure">{{ $t('apiTesting.scheduledTask.notifyOnFailure') }}</el-checkbox>
        </el-form-item>

        <el-form-item v-if="taskForm.notify_on_success || taskForm.notify_on_failure" :label="$t('apiTesting.scheduledTask.notificationType')">
          <el-select v-model="taskForm.notification_type" :placeholder="$t('apiTesting.scheduledTask.selectNotificationType')">
            <el-option :label="$t('apiTesting.notification.types.email')" value="email" />
            <el-option :label="$t('apiTesting.notification.types.webhook')" value="webhook" />
            <el-option :label="$t('apiTesting.notification.types.both')" value="both" />
          </el-select>
        </el-form-item>

        <el-form-item v-if="(taskForm.notify_on_success || taskForm.notify_on_failure) && taskForm.notification_type !== 'webhook'" :label="$t('apiTesting.scheduledTask.notifyEmails')">
          <el-select
            v-model="taskForm.notify_emails"
            multiple
            filterable
            :placeholder="$t('apiTesting.scheduledTask.selectNotifyEmails')"
          >
            <el-option
              v-for="user in users"
              :key="user.id"
              :label="user.display_name"
              :value="user.email"
            />
          </el-select>
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="showCreateDialog = false">{{ $t('apiTesting.common.cancel') }}</el-button>
        <el-button type="primary" @click="submitTaskForm" :loading="submitting">
          {{ editingTask ? $t('apiTesting.common.update') : $t('apiTesting.common.create') }}
        </el-button>
      </template>
    </el-dialog>

    <!-- 执行日志对话框 -->
    <el-dialog v-model="showLogsDialog" :title="$t('apiTesting.scheduledTask.executionLogs')" width="1100px">
      <el-table :data="executionLogs" v-loading="logsLoading">
        <el-table-column prop="executed_at" label="执行时间" width="180">
          <template #default="scope">
            <div class="time-cell">{{ formatDateTime(scope.row.executed_at) }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="total_requests" label="总请求数" width="100" />
        <el-table-column label="通过" width="80">
          <template #default="scope">
            <span style="color: #67c23a">{{ scope.row.passed_requests }}</span>
          </template>
        </el-table-column>
        <el-table-column label="失败" width="80">
          <template #default="scope">
            <span style="color: #f56c6c">{{ scope.row.failed_requests }}</span>
          </template>
        </el-table-column>
        <el-table-column label="状态" width="100">
          <template #default="scope">
            <el-tag :type="scope.row.status ? 'success' : 'danger'">
              {{ scope.row.status ? $t('apiTesting.common.success') : $t('apiTesting.common.failed') }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="执行者" width="120">
          <template #default="scope">
            {{ scope.row.executed_by?.username || (scope.row.trigger_type === 'scheduled' ? '定时任务' : '-') }}
          </template>
        </el-table-column>
        <el-table-column label="耗时" width="100">
          <template #default="scope">
            {{ scope.row.duration ? scope.row.duration + 'ms' : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120">
          <template #default="scope">
            <el-button size="small" type="primary" @click="viewExecutionDetail(scope.row)">
              查看详情
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { useI18n } from 'vue-i18n'
import { Plus, ArrowDown } from '@element-plus/icons-vue'
import api from '@/utils/api'
import {
  getScheduledTasks,
  createScheduledTask,
  updateScheduledTask,
  deleteScheduledTask,
  runScheduledTask,
  getExecutionLogs,
  getTestSuites,
  getApiRequests,
  getEnvironments,
  getUsers
} from '@/api/api-testing.js'

const { t } = useI18n()

// 获取状态文本
const getStatusText = (status) => {
  const statusKey = {
    'ACTIVE': 'active',
    'PAUSED': 'paused',
    'COMPLETED': 'completed',
    'FAILED': 'failed'
  }[status]
  return statusKey ? t(`apiTesting.scheduledTask.status.${statusKey}`) : status
}

// 获取触发器类型文本
const getTriggerTypeText = (type) => {
  const typeKey = {
    'CRON': 'cron',
    'INTERVAL': 'interval',
    'ONCE': 'once'
  }[type]
  return typeKey ? t(`apiTesting.scheduledTask.triggerTypes.${typeKey}`) : type
}

// 数据状态
const tasks = ref([])
const executionLogs = ref([])
const testSuites = ref([])
const apiRequests = ref([])
const environments = ref([])
const users = ref([]) // 添加用户列表
const projects = ref([])
const selectedProject = ref(null)
const loading = ref(false)
const logsLoading = ref(false)
const submitting = ref(false)
const showCreateDialog = ref(false)
const showLogsDialog = ref(false)
const editingTask = ref(null)

// 筛选条件
const filters = reactive({
  task_type: '',
  trigger_type: '',
  is_enabled: ''
})

// 分页配置
const pagination = reactive({
  current: 1,
  size: 10,
  total: 0
})

// 表单数据
const taskForm = reactive({
  name: '',
  description: '',
  task_type: 'TEST_SUITE',
  trigger_type: 'CRON',
  cron_expression: '0 0 * * * ?',
  interval_seconds: 3600,
  execute_at: '',
  test_suite: '',
  api_request: '',
  environment: '',
  notify_on_success: false,
  notify_on_failure: false,
  notify_emails: []
})

// CRON 构建器
const cronMode = ref('preset')
const cronFields = reactive({
  minuteType: '*',
  minuteStep: 5,
  minuteValue: 0,
  hourType: '*',
  hourStep: 1,
  hourValue: 0,
  dayType: '*',
  dayValue: 1,
  monthType: '*',
  monthValue: 1,
  weekdayType: '?',
  weekdayValue: 'MON'
})

const cronPresets = [
  { label: '每分钟', value: '0 * * * * ?' },
  { label: '每5分钟', value: '0 */5 * * * ?' },
  { label: '每小时', value: '0 0 * * * ?' },
  { label: '每天凌晨0点', value: '0 0 0 * * ?' },
  { label: '每天早上9点', value: '0 0 9 * * ?' },
  { label: '每天下午6点', value: '0 0 18 * * ?' },
  { label: '每周一早上9点', value: '0 0 9 * * MON' },
  { label: '工作日早上9点', value: '0 0 9 * * MON-FRI' },
  { label: '每月1号0点', value: '0 0 0 1 * ?' }
]

// 生命周期
onMounted(async () => {
  await loadProjects()
  if (selectedProject.value) {
    loadTasks()
    loadTestSuites()
    loadApiRequests()
    loadEnvironments()
  }
  loadUsers() // 加载用户列表
})

// 加载项目列表
const loadProjects = async () => {
  try {
    const response = await api.get('/api-projects')
    projects.value = response.data.records || response.data || []
    if (projects.value.length > 0) {
      selectedProject.value = projects.value[0].id
    }
  } catch (error) {
    console.error('加载项目失败:', error)
    ElMessage.error(t('apiTesting.messages.error.loadProjects'))
  }
}

// 项目切换
const onProjectChange = () => {
  loadTasks()
  loadTestSuites()
  loadApiRequests()
  loadEnvironments()
}

// 加载任务列表
const allTasks = ref([])
const loadTasks = async () => {
  if (!selectedProject.value) return
  loading.value = true
  try {
    const params = {
      page: pagination.current,
      page_size: pagination.size,
      projectId: selectedProject.value
    }
    const response = await getScheduledTasks(params)
    const data = response.data
    allTasks.value = Array.isArray(data) ? data : (data.results || data.records || [])
    applyFilters()
  } catch (error) {
    ElMessage.error(t('apiTesting.messages.error.loadTasksFailed'))
  } finally {
    loading.value = false
  }
}

// 应用前端筛选
const applyFilters = () => {
  let filtered = [...allTasks.value]
  if (filters.trigger_type) {
    filtered = filtered.filter(t => t.trigger_type === filters.trigger_type)
  }
  if (filters.is_enabled !== '' && filters.is_enabled !== null && filters.is_enabled !== undefined) {
    filtered = filtered.filter(t => t.is_enabled === filters.is_enabled)
  }
  tasks.value = filtered
  pagination.total = filtered.length
}

// 加载测试套件
const loadTestSuites = async () => {
  if (!selectedProject.value) return
  try {
    const response = await getTestSuites({ projectId: selectedProject.value })
    const data = response.data
    testSuites.value = Array.isArray(data) ? data : (data.results || data.records || [])
  } catch (error) {
    console.error('加载测试套件失败:', error)
  }
}

// 加载API请求
const loadApiRequests = async () => {
  if (!selectedProject.value) return
  try {
    const response = await getApiRequests({ projectId: selectedProject.value })
    const data = response.data
    apiRequests.value = Array.isArray(data) ? data : (data.results || data.records || [])
  } catch (error) {
    console.error('加载API请求失败:', error)
  }
}

// 加载环境
const loadEnvironments = async () => {
  if (!selectedProject.value) return
  try {
    const response = await getEnvironments({ projectId: selectedProject.value })
    const data = response.data
    environments.value = Array.isArray(data) ? data : (data.results || data.records || [])
  } catch (error) {
    console.error('加载环境失败:', error)
  }
}

// 加载用户列表
const loadUsers = async () => {
  try {
    const response = await getUsers()
    const data = response.data
    const usersData = Array.isArray(data) ? data : (data.results || data.records || [])
    users.value = usersData.map(user => ({
      ...user,
      display_name: user.first_name ? `${user.first_name}（${user.email}）` : `${user.username}（${user.email}）`
    }))
  } catch (error) {
    console.error('加载用户列表失败:', error)
  }
}

// 新建按钮点击
const handleCreateClick = () => {
  console.log('新建按钮点击')
  editingTask.value = null
  resetTaskForm()
  showCreateDialog.value = true
}

// 重置表单
const resetTaskForm = () => {
  Object.assign(taskForm, {
    name: '',
    description: '',
    task_type: 'TEST_SUITE',
    trigger_type: 'CRON',
    cron_expression: '0 0 * * * ?',
    interval_seconds: 3600,
    execute_at: '',
    test_suite: '',
    api_request: '',
    environment: '',
    notify_on_success: false,
    notify_on_failure: false,
    notification_type: 'email',
    notify_emails: []
  })
  cronMode.value = 'preset'
  Object.assign(cronFields, {
    minuteType: '*', minuteStep: 5, minuteValue: 0,
    hourType: '*', hourStep: 1, hourValue: 0,
    dayType: '*', dayValue: 1,
    monthType: '*', monthValue: 1,
    weekdayType: '?', weekdayValue: 'MON'
  })
}

// 重置筛选
const resetFilters = () => {
  Object.assign(filters, {
    task_type: '',
    trigger_type: '',
    is_enabled: ''
  })
  loadTasks()
}

// === CRON 构建器方法 ===

// 选择预设
const selectCronPreset = (preset) => {
  taskForm.cron_expression = preset.value
}

// 自定义字段变化时重新生成表达式
const onCronFieldChange = () => {
  taskForm.cron_expression = buildCronFromFields()
}

// 从自定义字段构建 CRON 表达式
const buildCronFromFields = () => {
  const minute = cronFields.minuteType === '*/N'
    ? '*/' + cronFields.minuteStep
    : cronFields.minuteType === 'fixed'
      ? String(cronFields.minuteValue)
      : '*'

  const hour = cronFields.hourType === '*/N'
    ? '*/' + cronFields.hourStep
    : cronFields.hourType === 'fixed'
      ? String(cronFields.hourValue)
      : '*'

  const day = cronFields.dayType === 'fixed' ? String(cronFields.dayValue) : '*'
  const month = cronFields.monthType === 'fixed' ? String(cronFields.monthValue) : '*'

  const weekday = cronFields.weekdayType === 'fixed' ? cronFields.weekdayValue : cronFields.weekdayType

  // 如果指定了星期，日字段用 ?；如果指定了日，星期用 ?
  const dayField = weekday !== '?' ? '?' : day
  const weekdayField = day !== '*' ? '?' : weekday

  return `0 ${minute} ${hour} ${dayField} ${month} ${weekdayField}`
}

// 根据表达式匹配预设或切到自定义/高级
const detectCronMode = (expr) => {
  if (!expr) {
    cronMode.value = 'preset'
    return
  }
  // 匹配预设
  const matched = cronPresets.find(p => p.value === expr)
  if (matched) {
    cronMode.value = 'preset'
    return
  }
  // 尝试解析为自定义字段
  const parts = expr.trim().split(/\s+/)
  if (parts.length === 6) {
    cronMode.value = 'custom'
    parseCronToFields(parts)
  } else {
    cronMode.value = 'advanced'
  }
}

// 解析 CRON 表达式到自定义字段
const parseCronToFields = (parts) => {
  const [,, minute, hour, day, month, weekday] = parts

  // 分钟
  if (minute === '*') {
    cronFields.minuteType = '*'
  } else if (minute.startsWith('*/')) {
    cronFields.minuteType = '*/N'
    cronFields.minuteStep = parseInt(minute.slice(2))
  } else {
    cronFields.minuteType = 'fixed'
    cronFields.minuteValue = parseInt(minute)
  }

  // 小时
  if (hour === '*') {
    cronFields.hourType = '*'
  } else if (hour.startsWith('*/')) {
    cronFields.hourType = '*/N'
    cronFields.hourStep = parseInt(hour.slice(2))
  } else {
    cronFields.hourType = 'fixed'
    cronFields.hourValue = parseInt(hour)
  }

  // 日
  if (day === '*') {
    cronFields.dayType = '*'
  } else if (day !== '?') {
    cronFields.dayType = 'fixed'
    cronFields.dayValue = parseInt(day)
  }

  // 月
  if (month === '*') {
    cronFields.monthType = '*'
  } else {
    cronFields.monthType = 'fixed'
    cronFields.monthValue = parseInt(month)
  }

  // 星期
  if (weekday === '?') {
    cronFields.weekdayType = '?'
  } else if (weekday === 'MON-FRI') {
    cronFields.weekdayType = 'MON-FRI'
  } else if (weekday === 'SAT-SUN') {
    cronFields.weekdayType = 'SAT-SUN'
  } else {
    cronFields.weekdayType = 'fixed'
    cronFields.weekdayValue = weekday
  }
}

// CRON 表达式转人类可读描述
const getCronDescription = (expr) => {
  if (!expr) return '请选择调度规则'
  const parts = expr.trim().split(/\s+/)
  if (parts.length !== 6) return expr

  const [second, minute, hour, day, month, weekday] = parts

  // 每分钟
  if (minute === '*' && hour === '*') return '每分钟执行'
  // 每N分钟
  if (minute.startsWith('*/') && hour === '*') return `每 ${minute.slice(2)} 分钟执行`

  // 构建时间部分
  let timeStr = ''
  if (hour === '*' && minute === '*') {
    timeStr = '每分钟'
  } else if (hour === '*') {
    if (minute.startsWith('*/')) {
      timeStr = `每小时每 ${minute.slice(2)} 分钟`
    } else {
      timeStr = `每小时 ${minute} 分`
    }
  } else if (hour.startsWith('*/')) {
    timeStr = `每 ${hour.slice(2)} 小时`
    if (minute !== '0' && minute !== '*') timeStr += ` ${minute} 分`
  } else {
    const h = hour.padStart(2, '0')
    const m = minute.padStart(2, '0')
    timeStr = `${h}:${m}`
  }

  // 构建日期部分
  let dateStr = ''
  if (day !== '?' && day !== '*') {
    dateStr += `每月 ${day} 号`
  }
  if (month !== '*') {
    dateStr += ` ${month} 月`
  }
  if (weekday !== '?' && weekday !== '*') {
    const weekdayNames = {
      'MON': '周一', 'TUE': '周二', 'WED': '周三', 'THU': '周四',
      'FRI': '周五', 'SAT': '周六', 'SUN': '周日',
      'MON-FRI': '工作日', 'SAT-SUN': '周末'
    }
    dateStr = weekdayNames[weekday] || weekday
  }

  if (dateStr) return `${dateStr} ${timeStr} 执行`
  return `每天 ${timeStr} 执行`
}

// 提交任务表单
const submitTaskForm = async () => {
  submitting.value = true
  try {
    // 准备提交数据，字段名需匹配后端实体（SNAKE_CASE）
    const submitData = {
      name: taskForm.name,
      suite_id: taskForm.test_suite,  // 后端字段名是 suite_id
      trigger_type: taskForm.trigger_type
    }

    // 根据触发器类型添加对应字段
    if (taskForm.trigger_type === 'CRON') {
      submitData.cron_expression = taskForm.cron_expression
    } else if (taskForm.trigger_type === 'INTERVAL') {
      submitData.interval_value = taskForm.interval_seconds
      submitData.interval_unit = 'seconds'
    } else if (taskForm.trigger_type === 'ONCE') {
      submitData.once_time = taskForm.execute_at
    }

    // 通知配置
    if (taskForm.notify_on_success || taskForm.notify_on_failure) {
      submitData.notification_config = JSON.stringify({
        on_success: taskForm.notify_on_success,
        on_failure: taskForm.notify_on_failure,
        type: taskForm.notification_type,
        emails: taskForm.notify_emails
      })
    }

    if (editingTask.value) {
      await updateScheduledTask(editingTask.value.id, submitData)
      ElMessage.success(t('apiTesting.messages.success.taskUpdated'))
    } else {
      await createScheduledTask(submitData)
      ElMessage.success(t('apiTesting.messages.success.taskCreated'))
    }
    showCreateDialog.value = false
    loadTasks()
  } catch (error) {
    console.error('Task operation failed:', error)
    ElMessage.error(error.response?.data?.error ||
                   error.response?.data?.detail ||
                   (editingTask.value ? t('apiTesting.messages.error.updateTaskFailed') : t('apiTesting.messages.error.createTaskFailed')))
  } finally {
    submitting.value = false
  }
}

// 立即执行任务
const runTaskNow = async (task) => {
  try {
    task.running = true
    await runScheduledTask(task.id)
    ElMessage.success(t('apiTesting.messages.success.taskStarted'))
    // 等待一段时间后刷新任务状态
    setTimeout(() => {
      loadTasks()
    }, 2000)
  } catch (error) {
    ElMessage.error(t('apiTesting.messages.error.executeTaskFailed'))
  } finally {
    task.running = false
  }
}

// 格式化日期时间
const formatDateTime = (dateString) => {
  if (!dateString) return '-'
  const date = new Date(dateString)
  return date.toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit',
    second: '2-digit'
  }).replace(/\//g, '-')
}

// 获取通知类型显示文本
const getNotificationTypeDisplay = (config) => {
  if (!config) return '-'
  try {
    const c = typeof config === 'string' ? JSON.parse(config) : config
    const typeMap = { email: '邮箱通知', webhook: 'Webhook', both: '两种都发送' }
    return typeMap[c.type] || '-'
  } catch {
    return '-'
  }
}

// 获取通知类型标签样式
const getNotificationTypeTag = (config) => {
  if (!config) return 'info'
  try {
    const c = typeof config === 'string' ? JSON.parse(config) : config
    const typeMap = { email: '', webhook: 'primary', both: 'warning' }
    return typeMap[c.type] || 'info'
  } catch {
    return 'info'
  }
}

// 查看执行日志
const viewTaskLogs = async (task) => {
  logsLoading.value = true
  try {
    const response = await getExecutionLogs(task.id)
    executionLogs.value = response.data.results || response.data
    showLogsDialog.value = true
  } catch (error) {
    console.error('Load execution logs failed:', error)
    ElMessage.error(t('apiTesting.messages.error.loadLogsFailed'))
  } finally {
    logsLoading.value = false
  }
}

// 查看执行详情
const viewExecutionDetail = (row) => {
  window.open(`/api-testing/reports?highlight=${row.id}`, '_blank')
}

// 处理任务操作
const handleTaskAction = (command, task) => {
  switch (command) {
    case 'pause':
      pauseTask(task)
      break
    case 'activate':
      activateTask(task)
      break
    case 'edit':
      editTask(task)
      break
    case 'logs':
      viewTaskLogs(task)
      break
    case 'delete':
      deleteTask(task)
      break
  }
}

// 编辑任务
const editTask = (task) => {
  editingTask.value = task

  // 解析通知配置
  let notifyOnSuccess = false
  let notifyOnFailure = false
  let notificationType = 'email'
  let notifyEmails = []
  if (task.notification_config) {
    try {
      const config = typeof task.notification_config === 'string'
        ? JSON.parse(task.notification_config)
        : task.notification_config
      notifyOnSuccess = config.on_success || false
      notifyOnFailure = config.on_failure || false
      notificationType = config.type || 'email'
      notifyEmails = config.emails || []
    } catch (e) {
      console.warn('解析通知配置失败:', e)
    }
  }

  Object.assign(taskForm, {
    name: task.name,
    description: task.description,
    task_type: task.suite_id ? 'TEST_SUITE' : 'API_REQUEST',
    trigger_type: task.trigger_type,
    cron_expression: task.cron_expression,
    interval_seconds: task.interval_value || 3600,
    execute_at: task.once_time,
    test_suite: task.suite_id || null,
    api_request: task.api_request || null,
    environment: task.environment || null,
    notify_on_success: notifyOnSuccess,
    notify_on_failure: notifyOnFailure,
    notification_type: notificationType,
    notify_emails: notifyEmails
  })

  // 检测 CRON 模式
  if (task.trigger_type === 'CRON') {
    detectCronMode(task.cron_expression)
  }

  showCreateDialog.value = true
}

// 暂停任务
const pauseTask = async (task) => {
  try {
    await api.put(`/api-scheduled-tasks/${task.id}/disable`)
    ElMessage.success(t('apiTesting.messages.success.taskPaused'))
    loadTasks()
  } catch (error) {
    console.error('Pause task failed:', error)
    ElMessage.error(t('apiTesting.messages.error.pauseTaskFailed'))
  }
}

// 激活任务
const activateTask = async (task) => {
  try {
    await api.put(`/api-scheduled-tasks/${task.id}/enable`)
    ElMessage.success(t('apiTesting.messages.success.taskActivated'))
    loadTasks()
  } catch (error) {
    ElMessage.error(t('apiTesting.messages.error.activateTaskFailed'))
  }
}

// 删除任务
const deleteTask = async (task) => {
  try {
    await ElMessageBox.confirm(
      t('apiTesting.scheduledTask.confirmDeleteTask'),
      t('apiTesting.common.tip'),
      {
        confirmButtonText: t('apiTesting.common.confirm'),
        cancelButtonText: t('apiTesting.common.cancel'),
        type: 'warning'
      }
    )
    await deleteScheduledTask(task.id)
    ElMessage.success(t('apiTesting.messages.success.taskDeleted'))
    loadTasks()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error(t('apiTesting.messages.error.deleteTaskFailed'))
    }
  }
}
</script>

<style scoped>
.scheduled-tasks {
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

.actions {
  display: flex;
  align-items: center;
}

.filters {
  margin-bottom: 20px;
  background: #f8f9fa;
  padding: 20px;
  border-radius: 8px;
}

.task-list {
  flex: 1;
  overflow: hidden;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.cron-help {
  margin-top: 8px;
  font-size: 12px;
}

.cron-builder {
  width: 100%;
}

.cron-presets {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.cron-field-label {
  font-size: 12px;
  color: #606266;
  margin-bottom: 4px;
}

.cron-custom {
  background: #f5f7fa;
  padding: 12px;
  border-radius: 6px;
}

.cron-preview {
  margin-top: 12px;
  padding: 10px 14px;
  background: #ecf5ff;
  border-radius: 6px;
  border: 1px solid #d9ecff;
  font-size: 13px;
  line-height: 1.8;
}

.cron-preview-label {
  color: #909399;
  margin-right: 6px;
}

.cron-preview-expr code {
  font-family: 'Courier New', monospace;
  color: #409eff;
  font-weight: 600;
}

.unit {
  margin-left: 8px;
  color: #606266;
}
</style>