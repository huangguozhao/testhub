<template>
  <div class="app-automation-dashboard">
    <!-- 统计卡片 -->
    <div class="stats-section">
      <el-row :gutter="20">
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon bg-blue">
                <el-icon><Cellphone /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.devices.total }}</div>
                <div class="stat-label">总设备数</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon bg-green">
                <el-icon><CircleCheck /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.devices.online }}</div>
                <div class="stat-label">在线设备</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon bg-orange">
                <el-icon><Lock /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.devices.locked }}</div>
                <div class="stat-label">已锁定设备</div>
              </div>
            </div>
          </el-card>
        </el-col>
        
        <el-col :span="6">
          <el-card shadow="hover" class="stat-card">
            <div class="stat-content">
              <div class="stat-icon bg-purple">
                <el-icon><Document /></el-icon>
              </div>
              <div class="stat-info">
                <div class="stat-value">{{ statistics.test_cases.total }}</div>
                <div class="stat-label">测试用例</div>
              </div>
            </div>
          </el-card>
        </el-col>
      </el-row>
    </div>
    
    <!-- 执行统计和最近执行 -->
    <el-row :gutter="20" class="content-section">
      <!-- 执行统计 -->
      <el-col :span="12">
        <el-card class="stat-chart" shadow="hover">
          <template #header>
            <div class="card-header">
              <span>执行统计</span>
            </div>
          </template>
          <div class="chart-container">
            <div class="stat-item">
              <div class="stat-label">总执行次数</div>
              <div class="stat-value large">{{ statistics.executions.total }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">成功次数</div>
              <div class="stat-value success">{{ statistics.executions.success }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">失败次数</div>
              <div class="stat-value danger">{{ statistics.executions.failed }}</div>
            </div>
            <div class="stat-item">
              <div class="stat-label">通过率</div>
              <div class="stat-value" :class="getPassRateClass(statistics.executions.pass_rate)">
                {{ statistics.executions.pass_rate }}%
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      
      <!-- 最近执行记录 -->
      <el-col :span="12">
        <el-card class="recent-executions" shadow="hover">
          <template #header>
            <div class="card-header">
              <span>最近执行记录</span>
              <el-button type="primary" size="small" @click="$router.push('/app-automation/executions')">
                查看全部
              </el-button>
            </div>
          </template>
          <div v-if="loading" class="loading-container">
            <el-empty description="加载中..." />
          </div>
          <div v-else-if="statistics.recent_executions.length === 0" class="empty-container">
            <el-empty description="暂无执行记录" />
          </div>
          <div v-else class="executions-list">
            <div v-for="execution in statistics.recent_executions" :key="execution.id" class="execution-item">
              <div class="execution-info">
                <div class="execution-name">{{ execution.case_name }}</div>
                <div class="execution-meta">
                  <el-tag :type="getStatusType(execution.status)" size="small">
                    {{ getStatusText(execution.status) }}
                  </el-tag>
                  <span class="device-name">设备: {{ execution.device_name }}</span>
                  <span class="execution-time">{{ formatTime(execution.created_at) }}</span>
                </div>
              </div>
              <div class="execution-actions">
                <el-button 
                  type="primary" 
                  size="small" 
                  text
                  @click="viewExecution(execution.id)"
                >
                  查看
                </el-button>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
    
    <!-- 快速操作 -->
    <el-row :gutter="20" class="quick-actions-section">
      <el-col :span="24">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>快速操作</span>
            </div>
          </template>
          <div class="actions-grid">
            <div class="action-item" @click="$router.push('/app-automation/devices')">
              <div class="action-icon bg-blue">
                <el-icon><Cellphone /></el-icon>
              </div>
              <div class="action-label">设备管理</div>
            </div>
            <div class="action-item" @click="$router.push('/app-automation/elements')">
              <div class="action-icon bg-green">
                <el-icon><Picture /></el-icon>
              </div>
              <div class="action-label">元素管理</div>
            </div>
            <div class="action-item" @click="$router.push('/app-automation/test-cases')">
              <div class="action-icon bg-purple">
                <el-icon><Document /></el-icon>
              </div>
              <div class="action-label">测试用例</div>
            </div>
            <div class="action-item" @click="$router.push('/app-automation/executions')">
              <div class="action-icon bg-orange">
                <el-icon><Aim /></el-icon>
              </div>
              <div class="action-label">执行记录</div>
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getDashboardStatistics } from '@/api/app-automation'
import { getExecutionStatusType, getExecutionStatusText, formatRelativeTime } from '@/utils/app-automation-helpers'
import { 
  Cellphone, 
  CircleCheck, 
  Lock, 
  Document, 
  Picture,
  Aim
} from '@element-plus/icons-vue'

const loading = ref(false)
const statistics = ref({
  devices: {
    total: 0,
    online: 0,
    locked: 0,
    available: 0
  },
  test_cases: {
    total: 0
  },
  executions: {
    total: 0,
    success: 0,
    failed: 0,
    pass_rate: 0
  },
  recent_executions: []
})

const loadStatistics = async () => {
  loading.value = true
  try {
    const res = await getDashboardStatistics()
    if (res.data.success) {
      statistics.value = res.data.data
    }
  } catch (error) {
    ElMessage.error('加载统计数据失败: ' + (error.message || '未知错误'))
  } finally {
    loading.value = false
  }
}

const getStatusType = getExecutionStatusType
const getStatusText = getExecutionStatusText
const formatTime = formatRelativeTime

const getPassRateClass = (rate) => {
  if (rate >= 90) return 'success'
  if (rate >= 70) return 'warning'
  return 'danger'
}

const viewExecution = (id) => {
  // 跳转到执行详情页
  // TODO: 后续实现执行详情页
  ElMessage.info('执行详情页待开发')
}

let refreshTimer = null

onMounted(() => {
  loadStatistics()
  // 每30秒刷新一次统计数据
  refreshTimer = setInterval(loadStatistics, 30000)
})

onUnmounted(() => {
  if (refreshTimer) {
    clearInterval(refreshTimer)
    refreshTimer = null
  }
})
</script>

<style scoped lang="scss">
.app-automation-dashboard {
  padding: var(--th-space-2xl, 24px);
  background: var(--th-bg-secondary, #fafafa);
  min-height: 100%;
}

.stats-section {
  margin-bottom: var(--th-space-xl, 20px);
}

.stat-card {
  height: 100%;
  cursor: pointer;

  .stat-content {
    display: flex;
    align-items: center;
    height: 100px;

    .stat-icon {
      width: 60px;
      height: 60px;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-right: 20px;
      color: white;
      font-size: 24px;

      &.bg-blue { background-color: #1890ff; }
      &.bg-green { background-color: #52c41a; }
      &.bg-orange { background-color: #fa8c16; }
      &.bg-purple { background-color: #722ed1; }
    }

    .stat-info {
      flex: 1;

      .stat-value {
        font-size: 28px;
        font-weight: bold;
        color: var(--th-text-primary, #1a1a1a);
        margin-bottom: 5px;
      }

      .stat-label {
        font-size: 14px;
        color: var(--th-text-secondary, #666);
      }
    }
  }
}

.content-section {
  margin-bottom: var(--th-space-xl, 20px);
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.stat-chart {
  .chart-container {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: var(--th-space-xl, 20px);

    .stat-item {
      text-align: center;
      padding: var(--th-space-lg, 16px);
      border-radius: var(--th-radius-lg, 8px);
      background: var(--th-bg-secondary, #fafafa);

      .stat-label {
        font-size: 14px;
        color: var(--th-text-secondary, #666);
        margin-bottom: var(--th-space-sm, 8px);
      }

      .stat-value {
        font-size: 24px;
        font-weight: bold;

        &.large { font-size: 32px; color: var(--th-info, #3b82f6); }
        &.success { color: var(--th-success, #22c55e); }
        &.warning { color: var(--th-warning, #eab308); }
        &.danger { color: var(--th-danger, #ef4444); }
      }
    }
  }
}

.recent-executions {
  .executions-list {
    .execution-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid var(--th-border, #e5e5e5);

      &:last-child {
        border-bottom: none;
      }

      .execution-info {
        flex: 1;

        .execution-name {
          font-size: 14px;
          font-weight: 500;
          color: var(--th-text-primary, #1a1a1a);
          margin-bottom: var(--th-space-sm, 8px);
        }

        .execution-meta {
          display: flex;
          gap: var(--th-space-md, 12px);
          align-items: center;
          font-size: 12px;
          color: var(--th-text-tertiary, #999);

          .device-name {
            display: flex;
            align-items: center;
            gap: 4px;
          }
        }
      }
    }
  }
}

.quick-actions-section {
  .actions-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: var(--th-space-xl, 20px);

    .action-item {
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: var(--th-space-md, 12px);
      padding: var(--th-space-xl, 20px);
      border-radius: var(--th-radius-lg, 8px);
      cursor: pointer;
      transition: all var(--th-transition-base, 0.2s ease);
      background: var(--th-bg-secondary, #fafafa);

      &:hover {
        background: var(--th-bg-hover, #f0f0f0);
      }

      .action-icon {
        width: 50px;
        height: 50px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 24px;
        color: white;

        &.bg-blue { background-color: #1890ff; }
        &.bg-green { background-color: #52c41a; }
        &.bg-orange { background-color: #fa8c16; }
        &.bg-purple { background-color: #722ed1; }
      }

      .action-label {
        font-size: 14px;
        font-weight: 500;
        color: var(--th-text-primary, #1a1a1a);
      }
    }
  }
}

.loading-container,
.empty-container {
  padding: 40px 0;
}

@media screen and (max-width: 1920px) {
  .stats-section { margin-bottom: 36px; }
  .stat-content { height: 90px; }
  .stat-icon { width: 55px; height: 55px; font-size: 22px; }
  .stat-value { font-size: 26px; }
  .content-section { margin-bottom: 36px; }
}

@media screen and (max-width: 1600px) {
  .stats-section { margin-bottom: 32px; }
  .stat-content { height: 85px; }
  .stat-icon { width: 50px; height: 50px; font-size: 20px; }
  .stat-value { font-size: 24px; }
  .content-section { margin-bottom: 32px; }
}

@media screen and (max-width: 1440px) {
  .stats-section { margin-bottom: 28px; }
  .stat-content { height: 80px; }
  .stat-icon { width: 48px; height: 48px; font-size: 18px; }
  .stat-value { font-size: 22px; }
  .content-section { margin-bottom: 28px; }
  .actions-grid { gap: var(--th-space-lg, 16px); }
  .action-item { padding: var(--th-space-lg, 16px); }
  .action-icon { width: 45px; height: 45px; font-size: 22px; }
}

@media screen and (max-width: 1366px) {
  .stats-section { margin-bottom: 24px; }
  .stat-content { height: 75px; }
  .stat-icon { width: 45px; height: 45px; font-size: 18px; }
  .stat-value { font-size: 20px; }
  .stat-label { font-size: 13px; }
  .content-section { margin-bottom: 24px; }
  .chart-container { gap: var(--th-space-lg, 16px); }
  .actions-grid { gap: var(--th-space-md, 12px); }
  .action-item { padding: var(--th-space-md, 12px); }
  .action-icon { width: 40px; height: 40px; font-size: 20px; }
}

@media screen and (max-width: 1280px) {
  .stats-section { margin-bottom: 20px; }
  .stat-content { height: 70px; }
  .stat-icon { width: 42px; height: 42px; font-size: 16px; }
  .stat-value { font-size: 18px; }
  .stat-label { font-size: 12px; }
  .content-section { margin-bottom: 20px; }
  .chart-container { gap: var(--th-space-md, 12px); }
  .action-item { padding: var(--th-space-md, 12px); }
  .action-icon { width: 38px; height: 38px; font-size: 18px; }
}

@media screen and (max-width: 1024px) {
  .stats-section { margin-bottom: 18px; }
  .stat-content { height: 65px; }
  .stat-icon { width: 40px; height: 40px; font-size: 16px; }
  .stat-value { font-size: 16px; }
  .content-section { margin-bottom: 18px; }
  .actions-grid { grid-template-columns: repeat(2, 1fr); gap: var(--th-space-md, 12px); }
  .action-item { padding: var(--th-space-md, 12px); }
  .action-label { font-size: 13px; }
}

@media screen and (max-width: 768px) {
  .app-automation-dashboard { padding: var(--th-space-lg, 16px); }
  .stats-section { margin-bottom: 15px; }
  .stat-content { height: 60px; }
  .stat-icon { width: 35px; height: 35px; font-size: 14px; }
  .stat-value { font-size: 14px; }
  .stat-label { font-size: 11px; }
  .content-section { margin-bottom: 15px; }
  .actions-grid { grid-template-columns: repeat(2, 1fr); gap: var(--th-space-sm, 8px); }
  .action-item { padding: var(--th-space-sm, 8px); }
  .action-icon { width: 35px; height: 35px; font-size: 16px; }
  .action-label { font-size: 12px; }
}

@media screen and (max-width: 480px) {
  .stats-section { margin-bottom: 12px; }
  .stat-content { height: 55px; }
  .stat-icon { width: 30px; height: 30px; font-size: 12px; }
  .stat-value { font-size: 13px; }
  .stat-label { font-size: 10px; }
  .content-section { margin-bottom: 12px; }
  .chart-container { gap: var(--th-space-sm, 8px); }
  .stat-item { padding: var(--th-space-sm, 8px); }
  .actions-grid { grid-template-columns: repeat(2, 1fr); gap: 6px; }
  .action-item { padding: 6px 3px; }
  .action-icon { width: 30px; height: 30px; font-size: 14px; }
  .action-label { font-size: 11px; }
}
</style>
