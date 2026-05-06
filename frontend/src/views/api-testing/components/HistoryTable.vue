<template>
  <div class="history-table">
    <el-table
      :data="data"
      v-loading="loading"
      style="width: 100%"
      @selection-change="$emit('selection-change', $event)"
    >
      <el-table-column type="selection" width="55" align="center" />
      <el-table-column prop="url" :label="$t('apiTesting.component.historyTable.requestName')" min-width="200" show-overflow-tooltip>
        <template #default="scope">
          {{ scope.row.url || scope.row.request?.name || '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="method" :label="$t('apiTesting.component.historyTable.method')" width="80">
        <template #default="scope">
          <el-tag :type="getMethodType(scope.row.method)" size="small">
            {{ scope.row.method || 'GET' }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column prop="url" :label="$t('apiTesting.component.historyTable.url')" min-width="300" show-overflow-tooltip />
      <el-table-column prop="response_status_code" :label="$t('apiTesting.component.historyTable.statusCode')" width="100">
        <template #default="scope">
          <el-tag
            v-if="scope.row.response_status_code"
            :type="getStatusType(scope.row.response_status_code)"
            size="small"
          >
            {{ scope.row.response_status_code }}
          </el-tag>
          <el-tag v-else-if="scope.row.error_message" type="danger" size="small">{{ $t('apiTesting.component.historyTable.error') }}</el-tag>
          <span v-else>-</span>
        </template>
      </el-table-column>
      <el-table-column prop="response_time" :label="$t('apiTesting.component.historyTable.responseTime')" width="100">
        <template #default="scope">
          {{ scope.row.response_time ? scope.row.response_time.toFixed(0) + 'ms' : '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="executed_by" :label="$t('apiTesting.component.historyTable.executor')" width="120">
        <template #default="scope">
          {{ scope.row.executed_by?.username || scope.row.executed_by || '-' }}
        </template>
      </el-table-column>
      <el-table-column prop="executed_at" :label="$t('apiTesting.component.historyTable.executionTime')" width="160">
        <template #default="scope">
          {{ formatDate(scope.row.executed_at) }}
        </template>
      </el-table-column>
      <el-table-column :label="$t('apiTesting.common.operation')" width="200" fixed="right">
        <template #default="scope">
          <el-button link type="primary" @click="$emit('view-detail', scope.row)" size="small">
            {{ $t('apiTesting.component.historyTable.viewDetail') }}
          </el-button>
          <el-button link type="primary" @click="$emit('retry-request', scope.row)" size="small">
            {{ $t('apiTesting.component.historyTable.retryRequest') }}
          </el-button>
          <el-button link type="danger" @click="$emit('delete-item', scope.row)" size="small">
            {{ $t('apiTesting.component.historyTable.delete') }}
          </el-button>
        </template>
      </el-table-column>
    </el-table>
  </div>
</template>

<script setup>
import dayjs from 'dayjs'

defineProps({
  data: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  }
})

defineEmits(['view-detail', 'retry-request', 'selection-change', 'delete-item'])

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
  if (status >= 200 && status < 300) return 'success'
  if (status >= 300 && status < 400) return 'warning'
  if (status >= 400) return 'danger'
  return 'info'
}

const formatDate = (dateString) => {
  return dayjs(dateString).format('MM-DD HH:mm')
}
</script>

<style scoped>
.history-table {
  height: 100%;
}

:deep(.el-button--primary) {
  color: #fff !important;
}

:deep(.el-button--danger) {
  color: #fff !important;
}

:deep(.el-button.is-link) {
  background: transparent;
  border: none;
  padding: 4px 8px;
}

:deep(.el-button.is-link:hover) {
  opacity: 0.8;
}
</style>