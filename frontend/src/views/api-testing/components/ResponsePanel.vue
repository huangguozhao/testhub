<template>
  <div class="response-section">
    <div class="response-header">
      <h3>{{ $t('apiTesting.interface.response') }}</h3>
      <div class="response-info">
        <el-tag :type="getStatusType(response.status_code)">
          {{ response.status_code }}
        </el-tag>
        <span class="response-time">{{ response.response_time ? response.response_time.toFixed(0) : 0 }}ms</span>
      </div>
    </div>

    <el-tabs v-model="activeTab" class="response-tabs">
      <el-tab-pane label="Body" name="body">
        <div class="response-body">
          <div class="response-actions">
            <el-button-group>
              <el-button size="small" @click="handleFormat">{{ $t('apiTesting.interface.format') }}</el-button>
              <el-button size="small" @click="handleCopy">{{ $t('apiTesting.interface.copy') }}</el-button>
              <el-button size="small" @click="toggleJsonPathExtractor">
                {{ $t('apiTesting.interface.jsonPathExtract') }}
              </el-button>
            </el-button-group>
          </div>
          <div v-if="showJsonPathExtractor" class="jsonpath-extractor">
            <div class="jsonpath-input">
              <el-input
                v-model="jsonPathExpression"
                :placeholder="$t('apiTesting.interface.jsonPathExample')"
                size="small"
                @input="handleJsonPathInput"
              >
                <template #append>
                  <el-button size="small" @click="handleCopyJsonPathResult">{{ $t('apiTesting.interface.copyResult') }}</el-button>
                </template>
              </el-input>
            </div>
            <div v-if="jsonPathResult !== null" class="jsonpath-result">
              <strong>{{ $t('apiTesting.interface.extractResult') }}</strong>
              <pre>{{ jsonPathResult }}</pre>
            </div>
          </div>
          <div class="response-content" v-html="highlightedBody"></div>
        </div>
      </el-tab-pane>

      <el-tab-pane label="Headers" name="headers">
        <div class="response-headers">
          <div v-for="(value, key) in (response.headers || {})" :key="key" class="header-row">
            <strong>{{ key }}:</strong> {{ value }}
          </div>
        </div>
      </el-tab-pane>

      <el-tab-pane :label="$t('apiTesting.interface.assertionResults')" name="assertions" v-if="assertionResults && assertionResults.length > 0">
        <div class="assertions-results">
          <div
            v-for="(result, index) in assertionResults"
            :key="index"
            class="assertion-result-item"
            :class="{ 'passed': result.passed, 'failed': !result.passed }"
          >
            <div class="assertion-result-header">
              <el-tag :type="result.passed ? 'success' : 'danger'" size="small">
                {{ result.passed ? $t('apiTesting.interface.passed') : $t('apiTesting.interface.failed') }}
              </el-tag>
              <span class="assertion-name">{{ result.name }}</span>
            </div>
            <div class="assertion-result-details">
              <div class="result-row">
                <span class="label">{{ $t('apiTesting.interface.expected') }}</span>
                <span class="value">{{ formatValue(result.expected) }}</span>
              </div>
              <div class="result-row">
                <span class="label">{{ $t('apiTesting.interface.actual') }}</span>
                <span class="value">{{ formatValue(result.actual) }}</span>
              </div>
              <div class="result-row" v-if="result.error">
                <span class="label">{{ $t('apiTesting.interface.error') }}</span>
                <span class="value error">{{ result.error }}</span>
              </div>
            </div>
          </div>
        </div>
      </el-tab-pane>

      <!-- 脚本执行结果 -->
      <el-tab-pane label="脚本结果" name="scripts" v-if="preScriptResult || postScriptResult">
        <div class="script-results">
          <!-- Pre-request Script 结果 -->
          <div v-if="preScriptResult" class="script-result-section">
            <h4>Pre-request Script</h4>
            <div class="script-status">
              <el-tag :type="preScriptResult.success ? 'success' : 'danger'" size="small">
                {{ preScriptResult.success ? '执行成功' : '执行失败' }}
              </el-tag>
              <span v-if="preScriptResult.error" class="script-error">
                {{ preScriptResult.error }}
              </span>
            </div>
            <div v-if="preScriptResult.logs && preScriptResult.logs.length > 0" class="script-logs">
              <h5>Console Output:</h5>
              <pre class="log-output">{{ preScriptResult.logs.join('\n') }}</pre>
            </div>
            <div v-if="preScriptResult.variables && Object.keys(preScriptResult.variables).length > 0" class="script-variables">
              <h5>更新变量:</h5>
              <pre class="variables-output">{{ formatVariables(preScriptResult.variables) }}</pre>
            </div>
          </div>

          <!-- Tests 结果 -->
          <div v-if="postScriptResult" class="script-result-section">
            <h4>Tests</h4>
            <div class="script-status">
              <el-tag :type="postScriptResult.success ? 'success' : 'danger'" size="small">
                {{ postScriptResult.success ? '执行成功' : '执行失败' }}
              </el-tag>
              <span v-if="postScriptResult.error" class="script-error">
                {{ postScriptResult.error }}
              </span>
            </div>
            <div v-if="postScriptResult.test_results && Object.keys(postScriptResult.test_results).length > 0" class="test-results">
              <h5>测试结果:</h5>
              <div
                v-for="(passed, name) in postScriptResult.test_results"
                :key="name"
                class="test-result-item"
                :class="{ 'passed': passed, 'failed': !passed }"
              >
                <el-tag :type="passed ? 'success' : 'danger'" size="small">
                  {{ passed ? '通过' : '失败' }}
                </el-tag>
                <span class="test-name">{{ name }}</span>
              </div>
            </div>
            <div v-if="postScriptResult.logs && postScriptResult.logs.length > 0" class="script-logs">
              <h5>Console Output:</h5>
              <pre class="log-output">{{ postScriptResult.logs.join('\n') }}</pre>
            </div>
          </div>
        </div>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()

const props = defineProps({
  response: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['format', 'copy'])

const activeTab = ref('body')
const showJsonPathExtractor = ref(false)
const jsonPathExpression = ref('')
const jsonPathResult = ref(null)
const rawBodyContent = ref('')

// 从 props 提取数据
const assertionResults = computed(() => props.response?.assertion_results || [])
const preScriptResult = computed(() => props.response?.pre_script_result || null)
const postScriptResult = computed(() => props.response?.post_script_result || null)

// 响应体内容
const bodyContent = computed(() => props.response?.body || '')

// 高亮显示的响应体
const highlightedBody = computed(() => {
  const body = bodyContent.value
  if (!body) return ''

  try {
    const json = JSON.parse(body)
    const formatted = JSON.stringify(json, null, 2)
    return highlightJson(formatted)
  } catch {
    return escapeHtml(body)
  }
})

// 状态颜色
const getStatusType = (status) => {
  if (status >= 200 && status < 300) return 'success'
  if (status >= 300 && status < 400) return 'warning'
  if (status >= 400 && status < 500) return 'danger'
  if (status >= 500) return 'danger'
  return 'info'
}

// 格式化值
const formatValue = (value) => {
  if (value === null || value === undefined) return ''
  if (typeof value === 'object') {
    try {
      return JSON.stringify(value)
    } catch {
      return String(value)
    }
  }
  return String(value)
}

// 格式化变量
const formatVariables = (variables) => {
  if (!variables) return ''
  try {
    return JSON.stringify(variables, null, 2)
  } catch {
    return String(variables)
  }
}

// JSON高亮
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

// HTML转义
const escapeHtml = (str) => {
  if (!str) return ''
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
}

// 处理格式化
const handleFormat = () => {
  emit('format')
}

// 处理复制
const handleCopy = () => {
  navigator.clipboard.writeText(bodyContent.value).then(() => {
    ElMessage.success('复制成功')
  }).catch(() => {
    ElMessage.error('复制失败')
  })
  emit('copy')
}

// 切换JSONPath提取器
const toggleJsonPathExtractor = () => {
  showJsonPathExtractor.value = !showJsonPathExtractor.value
  if (!showJsonPathExtractor.value) {
    jsonPathExpression.value = ''
    jsonPathResult.value = null
  }
}

// 处理JSONPath输入
const handleJsonPathInput = () => {
  if (!jsonPathExpression.value || !bodyContent.value) {
    jsonPathResult.value = null
    return
  }

  try {
    const json = JSON.parse(bodyContent.value)
    const result = evalJsonPath(json, jsonPathExpression.value)
    jsonPathResult.value = result !== undefined ? JSON.stringify(result) : null
  } catch (e) {
    jsonPathResult.value = null
  }
}

// 简单的JSONPath实现
const evalJsonPath = (obj, path) => {
  if (!path.startsWith('$')) return obj
  path = path.replace(/^\$\.?/, '')
  if (!path) return obj

  const parts = path.split('.')
  let result = obj

  for (const part of parts) {
    if (part.includes('[')) {
      const [key, idx] = part.replace(/\]/g, '').split('[')
      if (key) result = result[key]
      if (idx !== undefined) result = result[parseInt(idx)]
    } else {
      result = result[part]
    }
    if (result === undefined) break
  }

  return result
}

// 复制JSONPath结果
const handleCopyJsonPathResult = () => {
  if (jsonPathResult.value !== null) {
    navigator.clipboard.writeText(jsonPathResult.value).then(() => {
      ElMessage.success('复制成功')
    }).catch(() => {
      ElMessage.error('复制失败')
    })
  }
}

// 监听响应变化，更新原始内容
watch(() => props.response, (newResp) => {
  if (newResp?.body) {
    rawBodyContent.value = newResp.body
  }
}, { immediate: true })
</script>
