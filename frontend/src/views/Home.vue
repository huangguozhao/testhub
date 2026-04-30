<template>
  <div class="th-home-page">
    <!-- 全宽顶栏：与 Layout 内页 header 同高、同贴顶方式 -->
    <header class="th-home-header-bar">
      <div class="th-home-header-inner">
        <div class="th-home-brand" @click="router.push('/home')" role="button" tabindex="0">
          <span class="th-brand-text">TestHub</span>
          <span class="th-brand-ai">.ai</span>
        </div>

        <div class="th-home-breadcrumb-wrap">
          <el-breadcrumb separator="/" class="th-home-breadcrumb">
            <el-breadcrumb-item>{{ $t('nav.home') }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>

        <div class="th-home-header-right">
          <el-dropdown @command="handleLanguageChange" trigger="click">
            <button type="button" class="th-lang-btn">
              <span class="th-lang-flag">{{ appStore.language === 'zh-cn' ? 'CN' : 'EN' }}</span>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="zh-cn" :disabled="appStore.language === 'zh-cn'">
                  简体中文
                </el-dropdown-item>
                <el-dropdown-item command="en" :disabled="appStore.language === 'en'">
                  English
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>

          <el-dropdown @command="handleCommand" trigger="click">
            <button type="button" class="th-user-btn">
              <span class="th-user-avatar">{{ userStore.user?.username?.charAt(0).toUpperCase() }}</span>
              <span class="th-user-name">{{ userStore.user?.username }}</span>
            </button>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="profile">{{ $t('nav.profile') }}</el-dropdown-item>
                <el-dropdown-item divided command="logout">{{ $t('nav.logout') }}</el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </div>
    </header>

    <div class="th-home-content">
      <section class="th-hero">
        <h1 class="th-hero-title">
          {{ $t('home.title') }}
        </h1>
        <p class="th-hero-subtitle">{{ $t('home.subtitle') }}</p>
      </section>

      <section class="th-modules">
        <div class="th-module-grid">
          <div class="th-module-card" @click="handleNavigate('ai')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><MagicStick /></el-icon>
            </div>
            <h3>{{ $t('home.aiCaseGeneration') }}</h3>
            <p>{{ $t('home.aiCaseGenerationDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('api')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><Link /></el-icon>
            </div>
            <h3>{{ $t('home.apiTesting') }}</h3>
            <p>{{ $t('home.apiTestingDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('ui')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><Monitor /></el-icon>
            </div>
            <h3>{{ $t('home.uiAutomation') }}</h3>
            <p>{{ $t('home.uiAutomationDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('data')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><DataLine /></el-icon>
            </div>
            <h3>{{ $t('home.dataFactory') }}</h3>
            <p>{{ $t('home.dataFactoryDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('app')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><Cellphone /></el-icon>
            </div>
            <h3>APP自动化测试</h3>
            <p>基于Airtest的Android APP自动化测试</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('ai-intelligent')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><Cpu /></el-icon>
            </div>
            <h3>{{ $t('home.aiIntelligentMode') }}</h3>
            <p>{{ $t('home.aiIntelligentModeDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('assistant')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><ChatDotRound /></el-icon>
            </div>
            <h3>{{ $t('home.aiEvaluator') }}</h3>
            <p>{{ $t('home.aiEvaluatorDesc') }}</p>
          </div>

          <div class="th-module-card" @click="handleNavigate('config')" role="button" tabindex="0">
            <div class="th-module-icon">
              <el-icon><Setting /></el-icon>
            </div>
            <h3>{{ $t('home.configCenter') }}</h3>
            <p>{{ $t('home.configCenterDesc') }}</p>
          </div>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup>
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'
import { MagicStick, Link, Monitor, DataLine, Cpu, Setting, ChatDotRound, Cellphone } from '@element-plus/icons-vue'

const router = useRouter()
const { t } = useI18n()
const userStore = useUserStore()
const appStore = useAppStore()

const handleLanguageChange = (lang) => {
  appStore.setLanguage(lang)
  ElMessage.success(lang === 'zh-cn' ? '语言已切换为中文' : 'Language switched to English')
}

const handleCommand = (command) => {
  if (command === 'logout') {
    userStore.logout()
    ElMessage.success(t('home.logoutSuccess'))
    router.push('/login')
  } else if (command === 'profile') {
    router.push('/ai-generation/profile')
  }
}

const handleNavigate = (type) => {
  const routes = {
    ai: '/ai-generation/requirement-analysis',
    api: '/api-testing/dashboard',
    ui: '/ui-automation/dashboard',
    app: '/app-automation/dashboard',
    'ai-intelligent': '/ai-intelligent-mode/testing',
    assistant: '/ai-generation/assistant',
    config: '/configuration/ai-model',
    data: '/data-factory'
  }

  if (routes[type]) {
    const routeData = router.resolve({ path: routes[type] })
    window.open(routeData.href, '_blank')
  }
}
</script>

<style scoped lang="scss">
// 整页：全宽贴边，与 Layout 主区域背景一致
.th-home-page {
  width: 100%;
  min-height: 100vh;
  margin: 0;
  padding: 0;
  box-sizing: border-box;
  background: var(--th-bg-secondary);
}

// 顶栏：与 layout .el-header 一致 60px、白底、底边框、贴顶可吸顶
.th-home-header-bar {
  position: sticky;
  top: 0;
  z-index: 100;
  width: 100%;
  height: 60px;
  min-height: 60px;
  flex-shrink: 0;
  background: var(--th-bg-primary);
  border-bottom: 1px solid var(--th-border);
  box-sizing: border-box;
}

.th-home-header-inner {
  height: 100%;
  max-width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 24px;
  padding: 0 24px;
  box-sizing: border-box;
}

.th-home-brand {
  display: flex;
  align-items: baseline;
  flex-shrink: 0;
  cursor: pointer;
  user-select: none;

  .th-brand-text {
    font-size: 20px;
    font-weight: 600;
    letter-spacing: -0.5px;
    color: var(--th-text-primary);
  }

  .th-brand-ai {
    font-size: 20px;
    font-weight: 300;
    color: var(--th-text-tertiary);
  }
}

.th-home-breadcrumb-wrap {
  flex: 1;
  min-width: 0;
  overflow: hidden;
}

.th-home-breadcrumb {
  :deep(.el-breadcrumb__item) {
    font-size: 14px;

    .el-breadcrumb__inner {
      color: var(--th-text-primary);
      font-weight: 500;
    }
  }
}

.th-home-header-right {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-shrink: 0;
}

.th-lang-btn {
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 6px 12px;
  background: transparent;
  border: 1px solid var(--th-border);
  border-radius: var(--th-radius-md);
  cursor: pointer;
  transition: all var(--th-transition-fast);
  font-size: 12px;
  font-weight: 500;
  color: var(--th-text-secondary);

  &:hover {
    border-color: var(--th-border-hover);
    color: var(--th-text-primary);
    background: var(--th-bg-secondary);
  }
}

.th-user-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 4px 12px 4px 4px;
  background: transparent;
  border: 1px solid var(--th-border);
  border-radius: var(--th-radius-md);
  cursor: pointer;
  transition: all var(--th-transition-fast);

  &:hover {
    border-color: var(--th-border-hover);
    background: var(--th-bg-secondary);
  }

  .th-user-avatar {
    width: 28px;
    height: 28px;
    background: var(--th-bg-tertiary);
    border-radius: var(--th-radius-sm);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 600;
    color: var(--th-text-primary);
  }

  .th-user-name {
    font-size: 13px;
    font-weight: 500;
    color: var(--th-text-primary);
  }
}

// 正文：限制最大宽度，与内页卡片区视觉对齐
.th-home-content {
  width: 100%;
  max-width: 1200px;
  margin: 0 auto;
  padding: 40px 24px 48px;
  box-sizing: border-box;
}

.th-hero {
  text-align: center;
  padding: 60px 0 80px;
}

.th-hero-title {
  font-size: 48px;
  font-weight: 600;
  letter-spacing: -1.5px;
  color: var(--th-text-primary);
  margin: 0 0 20px;
  line-height: 1.2;
}

.th-hero-subtitle {
  font-size: 18px;
  color: var(--th-text-secondary);
  max-width: 500px;
  margin: 0 auto;
  font-weight: 300;
  line-height: 1.6;
}

.th-modules {
  margin-top: 40px;
}

.th-module-grid {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: 24px;
}

.th-module-card {
  background: var(--th-bg-primary);
  border: 1px solid var(--th-border);
  border-radius: var(--th-radius-xl);
  padding: 28px;
  cursor: pointer;
  transition: all var(--th-transition-base);
  display: flex;
  flex-direction: column;
  align-items: flex-start;

  &:hover {
    border-color: var(--th-border-hover);
    transform: translateY(-2px);
  }

  h3 {
    font-size: 16px;
    font-weight: 500;
    color: var(--th-text-primary);
    margin: 16px 0 8px;
  }

  p {
    font-size: 14px;
    color: var(--th-text-secondary);
    font-weight: 300;
    line-height: 1.5;
    margin: 0;
  }
}

.th-module-icon {
  width: 40px;
  height: 40px;
  background: var(--th-bg-tertiary);
  border-radius: var(--th-radius-md);
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all var(--th-transition-fast);

  .el-icon {
    font-size: 20px;
    color: var(--th-text-secondary);
  }
}

.th-module-card:hover .th-module-icon {
  background: var(--th-bg-hover);

  .el-icon {
    color: var(--th-text-primary);
  }
}

@media screen and (max-width: 1600px) {
  .th-home-content {
    padding: 32px 24px 40px;
  }

  .th-hero {
    padding: 50px 0 70px;
  }

  .th-hero-title {
    font-size: 44px;
  }

  .th-module-grid {
    gap: 20px;
  }
}

@media screen and (max-width: 1440px) {
  .th-home-content {
    padding: 28px 20px 36px;
  }

  .th-hero {
    padding: 40px 0 60px;
  }

  .th-hero-title {
    font-size: 40px;
  }

  .th-hero-subtitle {
    font-size: 16px;
  }

  .th-module-grid {
    gap: 18px;
  }

  .th-module-card {
    padding: 24px;

    h3 {
      font-size: 15px;
    }

    p {
      font-size: 13px;
    }
  }
}

@media screen and (max-width: 1280px) {
  .th-home-content {
    padding: 24px 20px 32px;
  }

  .th-hero {
    padding: 32px 0 50px;
  }

  .th-hero-title {
    font-size: 36px;
  }

  .th-hero-subtitle {
    font-size: 15px;
  }

  .th-module-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 16px;
  }
}

@media screen and (max-width: 1024px) {
  .th-home-header-inner {
    padding: 0 16px;
    gap: 16px;
  }

  .th-home-content {
    padding: 20px 16px 28px;
  }

  .th-hero {
    padding: 28px 0 40px;
  }

  .th-hero-title {
    font-size: 32px;
  }

  .th-module-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
  }

  .th-module-card {
    padding: 20px;

    h3 {
      font-size: 14px;
      margin: 12px 0 6px;
    }

    p {
      font-size: 12px;
    }
  }

  .th-module-icon {
    width: 36px;
    height: 36px;

    .el-icon {
      font-size: 18px;
    }
  }
}

@media screen and (max-width: 768px) {
  .th-home-brand {
    .th-brand-text,
    .th-brand-ai {
      font-size: 18px;
    }
  }

  .th-home-breadcrumb-wrap {
    display: none;
  }

  .th-user-btn .th-user-name {
    display: none;
  }

  .th-home-content {
    padding: 16px 16px 24px;
  }

  .th-hero {
    padding: 24px 0 32px;
  }

  .th-hero-title {
    font-size: 28px;
    letter-spacing: -1px;
  }

  .th-hero-subtitle {
    font-size: 14px;
  }

  .th-module-grid {
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }

  .th-module-card {
    padding: 16px;

    h3 {
      font-size: 13px;
    }

    p {
      font-size: 11px;
      line-height: 1.4;
    }
  }

  .th-module-icon {
    width: 32px;
    height: 32px;

    .el-icon {
      font-size: 16px;
    }
  }
}

@media screen and (max-width: 480px) {
  .th-home-header-inner {
    padding: 0 12px;
  }

  .th-home-content {
    padding: 12px 12px 20px;
  }

  .th-hero {
    padding: 20px 0 28px;
  }

  .th-hero-title {
    font-size: 24px;
  }

  .th-hero-subtitle {
    font-size: 13px;
  }

  .th-modules {
    margin-top: 24px;
  }

  .th-module-grid {
    grid-template-columns: 1fr;
    gap: 10px;
  }

  .th-module-card {
    padding: 14px;
    flex-direction: row;
    align-items: center;

    h3 {
      margin: 0 0 0 12px;
      font-size: 14px;
    }

    p {
      display: none;
    }
  }

  .th-module-icon {
    width: 36px;
    height: 36px;
    flex-shrink: 0;
  }
}
</style>
