<template>
  <div class="page-container">
    <div class="page-header">
      <h1 class="page-title">{{ $t('testcase.detail') }}</h1>
      <div>
        <el-button @click="$router.back()">{{ $t('common.back') }}</el-button>
        <el-button type="primary" @click="editTestCase">{{ $t('common.edit') }}</el-button>
      </div>
    </div>

    <div class="card-container" v-if="testcase">
      <el-descriptions :column="2" border>
        <el-descriptions-item :label="$t('testcase.caseTitle')" :span="2">{{ testcase.title }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.priority')">
          <el-tag :class="`priority-tag ${testcase.priority}`">{{ getPriorityText(testcase.priority) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.testType')">{{ getTypeText(testcase.type) }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.project')">{{ testcase.project_name || $t('testcase.noProject') }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.relatedVersions')" :span="2">
          <div v-if="testcase.versions && testcase.versions.length > 0" class="version-tags">
            <el-tag
              v-for="version in testcase.versions"
              :key="version.id"
              size="small"
              :type="version.is_baseline ? 'warning' : 'info'"
              class="version-tag"
            >
              {{ version.name }}
            </el-tag>
          </div>
          <span v-else class="no-version">{{ $t('testcase.noVersion') }}</span>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.author')">{{ testcase.creator_username || testcase.creator_real_name || '-' }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.createdAt')" :span="2">{{ formatDate(testcase.created_at || testcase.createdAt) }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.caseDescription')" :span="2">{{ testcase.description || $t('testcase.noDescription') }}</el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.preconditions')" :span="2">
          <div class="steps-content" v-html="formatMultiline(testcase.precondition || testcase.preconditions) || $t('testcase.none')"></div>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.steps')" :span="2">
          <div v-if="hasStepDetails" class="steps-table-wrapper">
            <table class="steps-table">
              <thead>
                <tr>
                  <th class="step-num-col">#</th>
                  <th>{{ $t('testcase.stepAction') || '操作步骤' }}</th>
                  <th>{{ $t('testcase.expectedResult') }}</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="step in testcase.steps" :key="step.step_number || step.stepNumber">
                  <td class="step-num-col">{{ step.step_number || step.stepNumber }}</td>
                  <td v-html="formatMultiline(step.description || step.action)"></td>
                  <td v-html="formatMultiline(step.expected_result || step.expectedResult)"></td>
                </tr>
              </tbody>
            </table>
          </div>
          <div v-else class="steps-content" v-html="formatMultiline(testcase.steps_text) || $t('testcase.none')"></div>
        </el-descriptions-item>
        <el-descriptions-item :label="$t('testcase.expectedResult')" :span="2">
          <div class="steps-content" v-html="formatMultiline(testcase.expected_result || testcase.expectedResult) || $t('testcase.none')"></div>
        </el-descriptions-item>
      </el-descriptions>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import api from '@/utils/api'
import dayjs from 'dayjs'

const { t } = useI18n()
const route = useRoute()
const router = useRouter()
const testcase = ref(null)

const hasStepDetails = computed(() => {
  return Array.isArray(testcase.value?.steps) && testcase.value.steps.length > 0
})

const formatMultiline = (text) => {
  if (!text) return ''
  return String(text).replace(/\n/g, '<br>')
}

const fetchTestCase = async () => {
  try {
    const response = await api.get(`/testcases/${route.params.id}`)
    testcase.value = response.data
  } catch (error) {
    ElMessage.error(t('testcase.fetchDetailFailed'))
  }
}

const editTestCase = () => {
  router.push(`/ai-generation/testcases/${route.params.id}/edit`)
}

const getPriorityText = (priority) => {
  const textMap = {
    low: t('testcase.low'),
    medium: t('testcase.medium'),
    high: t('testcase.high'),
    critical: t('testcase.critical')
  }
  return textMap[priority] || priority
}

const getTypeText = (type) => {
  const textMap = {
    functional: t('testcase.functional'),
    integration: t('testcase.integration'),
    api: t('testcase.api'),
    ui: t('testcase.ui'),
    performance: t('testcase.performance'),
    security: t('testcase.security')
  }
  return textMap[type] || '-'
}

const formatDate = (dateString) => {
  return dayjs(dateString).format('YYYY-MM-DD HH:mm')
}

onMounted(() => {
  fetchTestCase()
})
</script>

<style lang="scss" scoped>
.priority-tag {
  &.low { color: #67c23a; }
  &.medium { color: #e6a23c; }
  &.high { color: #f56c6c; }
  &.critical { color: #f56c6c; font-weight: bold; }
}

.version-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  
  .version-tag {
    margin: 0;
  }
}

.no-version {
  color: #909399;
  font-size: 14px;
  font-style: italic;
}

.steps-content {
  white-space: pre-wrap;
  line-height: 1.6;
  color: #303133;
  font-family: inherit;
}

.steps-table-wrapper {
  overflow-x: auto;
}

.steps-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 14px;
  line-height: 1.6;
  color: #303133;
}

.steps-table th,
.steps-table td {
  border: 1px solid #ebeef5;
  padding: 10px 12px;
  text-align: left;
  vertical-align: top;
}

.steps-table th {
  background: #fafafa;
  font-weight: 600;
  color: #606266;
}

.step-num-col {
  width: 50px;
  text-align: center;
}
</style>