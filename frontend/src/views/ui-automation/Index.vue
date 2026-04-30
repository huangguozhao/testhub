<template>
  <div class="ui-automation-container">
    <!-- 页面头部 -->
    <div class="page-header">
      <h1 class="page-title">{{ $t('uiAutomation.nav.title') }}</h1>
      <p class="page-subtitle">{{ $t('uiAutomation.nav.subtitle') }}</p>
    </div>

    <!-- 子路由内容显示区域 -->
    <router-view></router-view>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'

// 初始化国际化
const { t } = useI18n()

// 主页面仅包含布局和router-view，所有具体内容已移至各个子页面
</script>

<style scoped>
.ui-automation-container {
  padding: 20px;
  height: 100%;
  overflow-y: auto;
}

.page-header {
  text-align: center;
  margin-bottom: 40px;
}

.page-title {
  font-size: var(--th-font-size-2xl, 22px);
  font-weight: bold;
  margin: 0 0 10px 0;
  color: var(--th-text-primary, #1a1a1a);
}

.page-subtitle {
  font-size: var(--th-font-size-base, 14px);
  color: var(--th-text-secondary, #666);
  margin: 0;
}

.stats-section {
  margin-bottom: 40px;
}

.stat-card {
  height: 100%;
}

.stat-content {
  display: flex;
  align-items: center;
  height: 100px;
}

.stat-icon {
  width: 60px;
  height: 60px;
  border-radius: var(--th-radius-lg, 8px);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 20px;
  color: white;
  font-size: 24px;
}

.stat-icon.bg-blue {
  background-color: var(--th-primary, #1890ff);
}

.stat-icon.bg-green {
  background-color: var(--th-success, #22c55e);
}

.stat-icon.bg-purple {
  background-color: #722ed1;
}

.stat-icon.bg-orange {
  background-color: #fa8c16;
}

.stat-icon.bg-red {
  background-color: #f5222d;
}

.stat-icon.bg-cyan {
  background-color: #13c2c2;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: var(--th-font-size-2xl, 22px);
  font-weight: bold;
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 5px;
}

.stat-label {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-secondary, #666);
}

.content-section {
  margin-bottom: 40px;
}

.recent-activities {
  height: 100%;
}

.activities-list {
  max-height: 400px;
  overflow-y: auto;
}

.activity-item {
  display: flex;
  padding: 15px 0;
  border-bottom: 1px solid var(--th-border, #e5e5e5);
}

.activity-item:last-child {
  border-bottom: none;
}

.activity-icon {
  width: 40px;
  height: 40px;
  border-radius: var(--th-radius-lg, 8px);
  background-color: var(--th-bg-hover, #f0f0f0);
  display: flex;
  align-items: center;
  justify-content: center;
  margin-right: 15px;
  color: var(--th-text-secondary, #666);
}

.activity-content {
  flex: 1;
}

.activity-text {
  font-size: var(--th-font-size-base, 14px);
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 5px;
}

.activity-time {
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
}

.quick-actions {
  height: 100%;
}

.actions-grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 20px;
}

.action-item {
  text-align: center;
  padding: 20px;
  border-radius: var(--th-radius-lg, 8px);
  background-color: var(--th-bg-secondary, #fafafa);
  cursor: pointer;
  transition: background var(--th-transition-base, 0.2s ease), transform 0.3s ease;
}

.action-item:hover {
  background-color: var(--th-bg-hover, #f0f0f0);
  transform: translateY(-2px);
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0,0,0,0.06));
}

.action-item .action-icon {
  margin: 0 auto 15px;
}

.action-label {
  font-size: var(--th-font-size-lg, 16px);
  color: var(--th-text-primary, #1a1a1a);
  font-weight: 500;
}

.features-section {
  margin-bottom: 40px;
}

.section-title {
  font-size: var(--th-font-size-xl, 18px);
  font-weight: bold;
  margin-bottom: 20px;
  color: var(--th-text-primary, #1a1a1a);
}

.feature-card {
  height: 100%;
  padding: 30px;
  text-align: center;
}

.feature-icon {
  width: 80px;
  height: 80px;
  border-radius: var(--th-radius-lg, 8px);
  background-color: var(--th-bg-hover, #f0f0f0);
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 20px;
  font-size: 36px;
  color: var(--th-primary, #1890ff);
}

.feature-title {
  font-size: var(--th-font-size-lg, 16px);
  font-weight: bold;
  margin-bottom: 10px;
  color: var(--th-text-primary, #1a1a1a);
}

.feature-description {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-secondary, #666);
  line-height: 1.6;
}

.loading-container,
.empty-container {
  padding: 40px 0;
}
</style>