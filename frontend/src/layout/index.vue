<template>
  <div class="th-layout">
    <el-container>
      <!-- 侧边栏 -->
      <el-aside width="220px">
        <div class="th-logo" @click="router.push('/home')" role="button" tabindex="0">
          <span class="th-logo-text">TestHub</span>
          <span class="th-logo-ai">.ai</span>
        </div>

        <nav class="th-nav">
          <el-menu
            :default-active="$route.path"
            router
            class="th-menu"
          >
            <!-- AI用例生成模块菜单 -->
            <template v-if="currentModule === 'ai-generation'">
              <el-sub-menu index="requirement">
                <template #title>
                  <el-icon><MagicStick /></el-icon>
                  <span>{{ $t('menu.intelligentCaseGeneration') }}</span>
                </template>
                <el-menu-item index="/ai-generation/requirement-analysis">{{ $t('menu.aiCaseGeneration') }}</el-menu-item>
                <el-menu-item index="/ai-generation/generated-testcases">{{ $t('menu.aiGeneratedTestcases') }}</el-menu-item>
              </el-sub-menu>
              <el-menu-item index="/ai-generation/projects">
                <el-icon><Folder /></el-icon>
                <span>{{ $t('menu.projectManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ai-generation/testcases">
                <el-icon><Document /></el-icon>
                <span>{{ $t('menu.testCases') }}</span>
              </el-menu-item>
              <el-menu-item index="/ai-generation/versions">
                <el-icon><Flag /></el-icon>
                <span>{{ $t('menu.versionManagement') }}</span>
              </el-menu-item>
              <el-sub-menu index="reviews">
                <template #title>
                  <el-icon><Check /></el-icon>
                  <span>{{ $t('menu.reviewManagement') }}</span>
                </template>
                <el-menu-item index="/ai-generation/reviews">{{ $t('menu.reviewList') }}</el-menu-item>
                <el-menu-item index="/ai-generation/review-templates">{{ $t('menu.reviewTemplates') }}</el-menu-item>
              </el-sub-menu>
              <el-menu-item index="/ai-generation/executions">
                <el-icon><VideoPlay /></el-icon>
                <span>{{ $t('menu.testPlan') }}</span>
              </el-menu-item>
              <el-menu-item index="/ai-generation/reports">
                <el-icon><DataAnalysis /></el-icon>
                <span>{{ $t('menu.testReport') }}</span>
              </el-menu-item>
            </template>

            <!-- 接口测试模块菜单 -->
            <template v-else-if="currentModule === 'api-testing'">
              <el-menu-item index="/api-testing/dashboard">
                <el-icon><Odometer /></el-icon>
                <span>{{ $t('menu.dashboard') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/projects">
                <el-icon><Folder /></el-icon>
                <span>{{ $t('menu.projectManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/interfaces">
                <el-icon><Link /></el-icon>
                <span>{{ $t('menu.interfaceManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/automation">
                <el-icon><VideoPlay /></el-icon>
                <span>{{ $t('menu.automationTesting') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/history">
                <el-icon><Timer /></el-icon>
                <span>{{ $t('menu.requestHistory') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/environments">
                <el-icon><Setting /></el-icon>
                <span>{{ $t('menu.environmentManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/reports">
                <el-icon><DataAnalysis /></el-icon>
                <span>{{ $t('menu.testReport') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/scheduled-tasks">
                <el-icon><AlarmClock /></el-icon>
                <span>{{ $t('menu.scheduledTasks') }}</span>
              </el-menu-item>
              <el-menu-item index="/api-testing/notification-logs">
                <el-icon><Bell /></el-icon>
                <span>{{ $t('menu.notificationList') }}</span>
              </el-menu-item>
            </template>

            <!-- UI自动化测试模块菜单 -->
            <template v-else-if="currentModule === 'ui-automation'">
              <el-menu-item index="/ui-automation/dashboard">
                <el-icon><Odometer /></el-icon>
                <span>{{ $t('menu.dashboard') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/projects">
                <el-icon><Folder /></el-icon>
                <span>{{ $t('menu.projectManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/elements-enhanced">
                <el-icon><Aim /></el-icon>
                <span>{{ $t('menu.elementManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/test-cases">
                <el-icon><Document /></el-icon>
                <span>{{ $t('menu.caseManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/scripts-enhanced">
                <el-icon><Edit /></el-icon>
                <span>{{ $t('menu.scriptGeneration') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/scripts">
                <el-icon><DocumentCopy /></el-icon>
                <span>{{ $t('menu.scriptList') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/suites">
                <el-icon><Collection /></el-icon>
                <span>{{ $t('menu.suiteManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/executions">
                <el-icon><VideoPlay /></el-icon>
                <span>{{ $t('menu.executionRecords') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/reports">
                <el-icon><DataAnalysis /></el-icon>
                <span>{{ $t('menu.testReport') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/scheduled-tasks">
                <el-icon><AlarmClock /></el-icon>
                <span>{{ $t('menu.scheduledTasks') }}</span>
              </el-menu-item>
              <el-menu-item index="/ui-automation/notification-logs">
                <el-icon><Bell /></el-icon>
                <span>{{ $t('menu.notificationList') }}</span>
              </el-menu-item>
            </template>

            <!-- APP自动化测试模块菜单 -->
            <template v-else-if="currentModule === 'app-automation'">
              <el-menu-item index="/app-automation/dashboard">
                <el-icon><Odometer /></el-icon>
                <span>Dashboard</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/projects">
                <el-icon><Folder /></el-icon>
                <span>项目管理</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/devices">
                <el-icon><Cellphone /></el-icon>
                <span>设备管理</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/packages">
                <el-icon><Collection /></el-icon>
                <span>包名管理</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/elements">
                <el-icon><Aim /></el-icon>
                <span>元素管理</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/scene-builder">
                <el-icon><Connection /></el-icon>
                <span>用例编排</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/test-cases">
                <el-icon><Document /></el-icon>
                <span>测试用例</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/test-suites">
                <el-icon><FolderOpened /></el-icon>
                <span>测试套件</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/executions">
                <el-icon><VideoPlay /></el-icon>
                <span>执行记录</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/reports">
                <el-icon><DataAnalysis /></el-icon>
                <span>测试报告</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/scheduled-tasks">
                <el-icon><AlarmClock /></el-icon>
                <span>定时任务</span>
              </el-menu-item>
              <el-menu-item index="/app-automation/notification-logs">
                <el-icon><Bell /></el-icon>
                <span>通知列表</span>
              </el-menu-item>
            </template>

            <!-- AI 智能模式模块菜单 -->
            <template v-else-if="currentModule === 'ai-intelligent-mode'">
              <el-menu-item index="/ai-intelligent-mode/testing">
                <el-icon><VideoPlay /></el-icon>
                <span>{{ $t('menu.aiIntelligentTesting') }}</span>
              </el-menu-item>
              <el-menu-item index="/ai-intelligent-mode/cases">
                <el-icon><Document /></el-icon>
                <span>{{ $t('menu.aiCaseManagement') }}</span>
              </el-menu-item>
              <el-menu-item index="/ai-intelligent-mode/execution-records">
                <el-icon><Timer /></el-icon>
                <span>{{ $t('menu.aiExecutionRecords') }}</span>
              </el-menu-item>
            </template>

            <!-- 配置中心模块菜单 -->
            <template v-else-if="currentModule === 'configuration'">
              <el-sub-menu index="ai-case-generation">
                <template #title>
                  <el-icon><MagicStick /></el-icon>
                  <span>{{ $t('menu.aiCaseGenerationConfig') }}</span>
                </template>
                <el-menu-item index="/configuration/ai-model">
                  <el-icon><Cpu /></el-icon>
                  <span>{{ $t('menu.aiModelConfig') }}</span>
                </el-menu-item>
                <el-menu-item index="/configuration/prompt-config">
                  <el-icon><Edit /></el-icon>
                  <span>{{ $t('menu.promptConfig') }}</span>
                </el-menu-item>
                <el-menu-item index="/configuration/generation-config">
                  <el-icon><Setting /></el-icon>
                  <span>{{ $t('menu.generationConfig') }}</span>
                </el-menu-item>
              </el-sub-menu>
              <el-menu-item index="/configuration/ui-env">
                <el-icon><Monitor /></el-icon>
                <span>{{ $t('menu.uiEnvConfig') }}</span>
              </el-menu-item>
              <el-menu-item index="/configuration/app-env">
                <el-icon><Cellphone /></el-icon>
                <span>APP环境配置</span>
              </el-menu-item>
              <el-menu-item index="/configuration/ai-mode">
                <el-icon><MagicStick /></el-icon>
                <span>{{ $t('menu.aiModeConfig') }}</span>
              </el-menu-item>
              <el-menu-item index="/configuration/scheduled-task">
                <el-icon><Timer /></el-icon>
                <span>{{ $t('menu.scheduledTaskConfig') }}</span>
              </el-menu-item>
              <el-menu-item index="/configuration/dify">
                <el-icon><ChatDotRound /></el-icon>
                <span>{{ $t('menu.difyConfig') }}</span>
              </el-menu-item>
            </template>
          </el-menu>
        </nav>
      </el-aside>

      <!-- 主体内容 -->
      <el-container>
        <!-- 顶部导航 -->
        <el-header height="60px">
          <div class="th-header">
            <div class="th-header-left">
              <el-breadcrumb separator="/" class="th-breadcrumb">
                <el-breadcrumb-item :to="{ path: '/home' }">{{ $t('nav.home') }}</el-breadcrumb-item>
                <el-breadcrumb-item v-if="moduleName">{{ moduleName }}</el-breadcrumb-item>
                <el-breadcrumb-item>{{ breadcrumbTitle }}</el-breadcrumb-item>
              </el-breadcrumb>
            </div>
            <div class="th-header-right">
              <!-- 语言切换 -->
              <el-dropdown @command="handleLanguageChange" trigger="click">
                <button class="th-lang-btn">
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

              <!-- 用户信息 -->
              <el-dropdown @command="handleCommand" trigger="click">
                <button class="th-user-btn">
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
        </el-header>

        <!-- 页面内容 -->
        <el-main class="th-main">
          <router-view />
        </el-main>
      </el-container>
    </el-container>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'
import { ElMessage } from 'element-plus'
import { useI18n } from 'vue-i18n'
import {
  Monitor, Folder, Document, Flag, Check, Collection, VideoPlay,
  DataAnalysis, ChatDotRound, DocumentCopy, Link, MagicStick,
  Odometer, Timer, Setting, AlarmClock, Bell, Aim, Edit, Cpu, Cellphone, Connection, FolderOpened
} from '@element-plus/icons-vue'

const router = useRouter()
const route = useRoute()
const userStore = useUserStore()
const appStore = useAppStore()
const { t } = useI18n()

// 切换语言（无需刷新页面）
const handleLanguageChange = (lang) => {
  appStore.setLanguage(lang)
  ElMessage.success(lang === 'zh-cn' ? '语言已切换为中文' : 'Language switched to English')
}

const currentModule = computed(() => {
  if (route.path.startsWith('/ai-generation')) return 'ai-generation'
  if (route.path.startsWith('/api-testing')) return 'api-testing'
  if (route.path.startsWith('/ui-automation')) return 'ui-automation'
  if (route.path.startsWith('/app-automation')) return 'app-automation'
  if (route.path.startsWith('/ai-intelligent-mode')) return 'ai-intelligent-mode'
  if (route.path.startsWith('/configuration')) return 'configuration'
  return ''
})

const moduleName = computed(() => {
  const map = {
    'ai-generation': t('modules.aiGeneration'),
    'api-testing': t('modules.apiTesting'),
    'ui-automation': t('modules.uiAutomation'),
    'app-automation': 'APP自动化测试',
    'ai-intelligent-mode': t('modules.aiIntelligentMode'),
    'configuration': t('modules.configuration')
  }
  return map[currentModule.value] || ''
})

const breadcrumbTitle = computed(() => {
  const routeMap = {
    // AI用例生成
    '/ai-generation/requirement-analysis': t('menu.aiCaseGeneration'),
    '/ai-generation/generated-testcases': t('menu.aiGeneratedTestcases'),
    '/ai-generation/projects': t('menu.projectManagement'),
    '/ai-generation/testcases': t('menu.testCases'),
    '/ai-generation/versions': t('menu.versionManagement'),
    '/ai-generation/reviews': t('menu.reviewList'),
    '/ai-generation/review-templates': t('menu.reviewTemplates'),
    '/ai-generation/testsuites': t('menu.suiteManagement'),
    '/ai-generation/executions': t('menu.executionRecords'),
    '/ai-generation/reports': t('menu.testReport'),

    // 接口测试
    '/api-testing/dashboard': t('menu.dashboard'),
    '/api-testing/projects': t('menu.projectManagement'),
    '/api-testing/interfaces': t('menu.interfaceManagement'),
    '/api-testing/automation': t('menu.automationTesting'),
    '/api-testing/history': t('menu.requestHistory'),
    '/api-testing/environments': t('menu.environmentManagement'),
    '/api-testing/reports': t('menu.testReport'),
    '/api-testing/scheduled-tasks': t('menu.scheduledTasks'),
    '/api-testing/notification-logs': t('menu.notificationList'),

    // UI自动化测试
    '/ui-automation/dashboard': t('menu.dashboard'),
    '/ui-automation/projects': t('menu.projectManagement'),
    '/ui-automation/elements-enhanced': t('menu.elementManagement'),
    '/ui-automation/test-cases': t('menu.caseManagement'),
    '/ui-automation/scripts-enhanced': t('menu.scriptGeneration'),
    '/ui-automation/scripts': t('menu.scriptList'),
    '/ui-automation/suites': t('menu.suiteManagement'),
    '/ui-automation/executions': t('menu.executionRecords'),
    '/ui-automation/reports': t('menu.testReport'),
    '/ui-automation/scheduled-tasks': t('menu.scheduledTasks'),
    '/ui-automation/notification-logs': t('menu.notificationList'),

    // APP自动化测试
    '/app-automation/dashboard': 'Dashboard',
    '/app-automation/projects': '项目管理',
    '/app-automation/devices': '设备管理',
    '/app-automation/packages': '包名管理',
    '/app-automation/elements': '元素管理',
    '/app-automation/scene-builder': '用例编排',
    '/app-automation/test-cases': '测试用例',
    '/app-automation/test-suites': '测试套件',
    '/app-automation/scheduled-tasks': '定时任务',
    '/app-automation/notification-logs': '通知列表',
    '/app-automation/executions': '执行记录',
    '/app-automation/reports': '测试报告',

    // AI 智能模式
    '/ai-intelligent-mode/testing': t('menu.aiIntelligentTesting'),
    '/ai-intelligent-mode/cases': t('menu.aiCaseManagement'),
    '/ai-intelligent-mode/execution-records': t('menu.aiExecutionRecords'),

    // 配置中心
    '/configuration/ai-model': t('menu.aiModelConfig'),
    '/configuration/prompt-config': t('menu.promptConfig'),
    '/configuration/generation-config': t('menu.generationConfig'),
    '/configuration/ui-env': t('menu.uiEnvConfig'),
    '/configuration/ai-mode': t('menu.aiModeConfig'),
    '/configuration/scheduled-task': t('menu.scheduledTaskConfig'),
    '/configuration/dify': t('menu.difyConfig'),

    '/profile': t('nav.profile')
  }
  return routeMap[route.path] || route.meta.title || ''
})

const handleCommand = (command) => {
  if (command === 'logout') {
    userStore.logout()
    ElMessage.success('退出登录成功')
    router.push('/login')
  } else if (command === 'profile') {
    router.push('/ai-generation/profile')
  }
}
</script>

<style lang="scss" scoped>
// ============================================
// Layout 容器
// ============================================
.th-layout {
  height: 100vh;
  width: 100vw;
  overflow: hidden;
  background: var(--th-bg-primary);
}

.th-layout > .el-container {
  height: 100%;
  overflow: hidden;
}

// ============================================
// 侧边栏
// ============================================
.el-aside {
  background: var(--th-bg-primary);
  border-right: 1px solid var(--th-border);
  height: 100%;
  display: flex;
  flex-direction: column;
  overflow: hidden;
  transition: width 0.2s ease;
}

// Logo 区域
.th-logo {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid var(--th-border);
  cursor: pointer;
  flex-shrink: 0;
  transition: background var(--th-transition-fast);

  &:hover {
    background: var(--th-bg-secondary);
  }

  .th-logo-text {
    font-size: 20px;
    font-weight: 600;
    letter-spacing: -0.5px;
    color: var(--th-text-primary);
  }

  .th-logo-ai {
    font-size: 20px;
    font-weight: 300;
    color: var(--th-text-tertiary);
  }
}

// 导航菜单
.th-nav {
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
  padding: 12px 0;

  &::-webkit-scrollbar {
    width: 0;
  }
}

// 菜单样式覆盖
.th-menu {
  border-right: none;
  background: transparent;

  :deep(.el-menu-item),
  :deep(.el-sub-menu__title) {
    height: 44px;
    line-height: 44px;
    font-size: 14px;
    color: var(--th-text-secondary);
    transition: all var(--th-transition-fast);
    margin: 0 12px;
    padding-left: 16px !important;
    padding-right: 16px;
    border-radius: var(--th-radius-md);

    .el-icon {
      color: var(--th-text-tertiary);
      transition: color var(--th-transition-fast);
    }

    &:hover {
      color: var(--th-text-primary);
      background: var(--th-bg-secondary);

      .el-icon {
        color: var(--th-text-primary);
      }
    }

    &.is-active {
      color: var(--th-text-primary);
      background: var(--th-bg-tertiary);
      font-weight: 500;

      .el-icon {
        color: var(--th-text-primary);
      }
    }
  }

  :deep(.el-sub-menu) {
    .el-menu-item {
      padding-left: 48px !important;
      height: 40px;
      line-height: 40px;
    }
  }
}

// ============================================
// 头部导航
// ============================================
.el-header {
  background: var(--th-bg-primary);
  border-bottom: 1px solid var(--th-border);
  padding: 0;
  flex-shrink: 0;
  height: 60px !important;
}

.th-header {
  height: 100%;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 24px;
}

.th-header-left {
  flex: 1;
  overflow: hidden;
}

.th-breadcrumb {
  :deep(.el-breadcrumb__item) {
    font-size: 14px;

    .el-breadcrumb__inner {
      color: var(--th-text-tertiary);
      transition: color var(--th-transition-fast);

      &:hover {
        color: var(--th-text-primary);
      }

      &.is-link {
        color: var(--th-text-secondary);
      }
    }

    &:last-child .el-breadcrumb__inner {
      color: var(--th-text-primary);
      font-weight: 500;
    }
  }

  :deep(.el-breadcrumb__separator) {
    color: var(--th-text-tertiary);
  }
}

.th-header-right {
  display: flex;
  align-items: center;
  gap: 8px;
}

// 语言切换按钮
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

  .th-lang-flag {
    letter-spacing: 0;
  }
}

// 用户按钮
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

// ============================================
// 主内容区
// ============================================
.th-main {
  background: var(--th-bg-secondary);
  padding: 24px;
  flex: 1;
  overflow-y: auto;
  overflow-x: hidden;
}

// ============================================
// 响应式设计
// ============================================
@media screen and (max-width: 1600px) {
  .el-aside {
    width: 200px !important;
  }

  .th-main {
    padding: 20px;
  }

  .th-menu {
    :deep(.el-menu-item),
    :deep(.el-sub-menu__title) {
      font-size: 13px;
    }
  }
}

@media screen and (max-width: 1440px) {
  .el-aside {
    width: 180px !important;
  }

  .th-main {
    padding: 18px;
  }

  .th-menu {
    :deep(.el-menu-item),
    :deep(.el-sub-menu__title) {
      font-size: 13px;
      margin: 0 8px;
      padding-left: 12px !important;
    }

    :deep(.el-sub-menu) .el-menu-item {
      padding-left: 36px !important;
    }
  }
}

@media screen and (max-width: 1280px) {
  .el-aside {
    width: 160px !important;
  }

  .th-main {
    padding: 16px;
  }

  .th-header {
    padding: 0 16px;
  }

  .th-menu {
    :deep(.el-menu-item),
    :deep(.el-sub-menu__title) {
      font-size: 12px;
      padding-left: 10px !important;

      .el-icon {
        font-size: 14px;
      }
    }
  }

  .th-user-btn .th-user-name {
    display: none;
  }
}

@media screen and (max-width: 1024px) {
  .el-aside {
    position: fixed;
    left: 0;
    top: 0;
    z-index: 1000;
    width: 220px !important;
    transform: translateX(-100%);
    transition: transform 0.2s ease;
    box-shadow: var(--th-shadow-lg);

    &.mobile-open {
      transform: translateX(0);
    }
  }

  .th-main {
    padding: 12px;
  }
}

@media screen and (max-width: 768px) {
  .th-header {
    padding: 0 12px;
  }

  .th-breadcrumb {
    :deep(.el-breadcrumb__item) {
      &:not(:last-child) {
        display: none;
      }
    }
  }

  .th-main {
    padding: 10px;
  }
}

@media screen and (max-width: 480px) {
  .th-header {
    padding: 0 8px;
  }

  .th-lang-btn {
    padding: 4px 8px;
    font-size: 11px;
  }

  .th-user-btn {
    padding: 2px 8px 2px 2px;
  }

  .th-user-btn .th-user-avatar {
    width: 24px;
    height: 24px;
    font-size: 11px;
  }
}
</style>
