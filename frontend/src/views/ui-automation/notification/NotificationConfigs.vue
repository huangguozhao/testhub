<template>
  <div class="notification-configs-container">
    <div class="page-header">
      <div class="page-header__row">
        <span class="page-header__icon" aria-hidden="true">
          <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
            <path d="M12.22 2h-.44a2 2 0 00-2 2v.18a2 2 0 01-1 1.73l-.43.25a2 2 0 01-2 0l-.15-.08a2 2 0 00-2.73.73l-.22.38a2 2 0 00.73 2.73l.15.1a2 2 0 011 1.72v.51a2 2 0 01-1 1.74l-.15.09a2 2 0 00-.73 2.73l.22.38a2 2 0 002.73.73l.15-.08a2 2 0 012 0l.43.25a2 2 0 011 1.73V20a2 2 0 002 2h.44a2 2 0 002-2v-.18a2 2 0 011-1.73l.43-.25a2 2 0 012 0l.15.08a2 2 0 002.73-.73l.22-.39a2 2 0 00-.73-2.73l-.15-.08a2 2 0 01-1-1.74v-.5a2 2 0 011-1.74l.15-.09a2 2 0 00.73-2.73l-.22-.38a2 2 0 00-2.73-.73l-.15.08a2 2 0 01-2 0l-.43-.25a2 2 0 01-1-1.73V4a2 2 0 00-2-2z"/>
            <circle cx="12" cy="12" r="3"/>
          </svg>
        </span>
        <div class="page-header__text">
          <h1>{{ $t('uiAutomation.notification.configs.pageTitle') }}</h1>
          <p>{{ $t('uiAutomation.notification.configs.pageDesc') }}</p>
        </div>
      </div>
    </div>

    <!-- Tab切换 -->
    <div class="content-wrapper">
      <el-tabs v-model="activeTab" class="notification-tabs">

        <!-- 飞书机器人Tab -->
        <el-tab-pane :label="$t('uiAutomation.notification.configs.feishuBot')" name="feishu">
          <div class="tab-content">
            <div class="config-section">
              <el-form
                  ref="feishuFormRef"
                  :model="webhookBots.feishu"
                  label-position="top"
                  class="config-form"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.botName')">
                      <el-input
                          v-model="webhookBots.feishu.name"
                          :placeholder="$t('uiAutomation.notification.configs.feishuBotNamePlaceholder')"
                      />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.enable')">
                      <el-switch v-model="webhookBots.feishu.enabled"/>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.webhookUrl')">
                      <el-input
                          v-model="webhookBots.feishu.webhook_url"
                          :placeholder="$t('uiAutomation.notification.configs.webhookPlaceholder')"
                      />
                      <div class="form-item-hint">
                        {{ $t('uiAutomation.notification.configs.feishuUrlHint') }}
                      </div>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.businessType')">
                      <el-checkbox v-model="webhookBots.feishu.enable_ui_automation">{{ $t('uiAutomation.notification.configs.uiAutomationTest') }}</el-checkbox>
                      <el-checkbox v-model="webhookBots.feishu.enable_api_testing">{{ $t('uiAutomation.notification.configs.apiTest') }}</el-checkbox>
                    </el-form-item>
                  </el-col>
                </el-row>

                <div class="form-actions">
                  <el-button @click="testWebhookBot('feishu')" :loading="testingBot === 'feishu'">
                    测试连接
                  </el-button>
                  <el-button type="primary" @click="saveWebhookBot('feishu')">
                    {{ $t('uiAutomation.notification.configs.saveFeishuConfig') }}
                  </el-button>
                </div>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <!-- 企业微信机器人Tab -->
        <el-tab-pane :label="$t('uiAutomation.notification.configs.wechatBot')" name="wechat">
          <div class="tab-content">
            <div class="config-section">
              <el-form
                  ref="wechatFormRef"
                  :model="webhookBots.wechat"
                  label-position="top"
                  class="config-form"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.botName')">
                      <el-input
                          v-model="webhookBots.wechat.name"
                          :placeholder="$t('uiAutomation.notification.configs.wechatBotNamePlaceholder')"
                      />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.enable')">
                      <el-switch v-model="webhookBots.wechat.enabled"/>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.webhookUrl')">
                      <el-input
                          v-model="webhookBots.wechat.webhook_url"
                          :placeholder="$t('uiAutomation.notification.configs.webhookPlaceholder')"
                      />
                      <div class="form-item-hint">
                        {{ $t('uiAutomation.notification.configs.wechatUrlHint') }}
                      </div>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.businessType')">
                      <el-checkbox v-model="webhookBots.wechat.enable_ui_automation">{{ $t('uiAutomation.notification.configs.uiAutomationTest') }}</el-checkbox>
                      <el-checkbox v-model="webhookBots.wechat.enable_api_testing">{{ $t('uiAutomation.notification.configs.apiTest') }}</el-checkbox>
                    </el-form-item>
                  </el-col>
                </el-row>

                <div class="form-actions">
                  <el-button @click="testWebhookBot('wechat')" :loading="testingBot === 'wechat'">
                    测试连接
                  </el-button>
                  <el-button type="primary" @click="saveWebhookBot('wechat')">
                    {{ $t('uiAutomation.notification.configs.saveWechatConfig') }}
                  </el-button>
                </div>
              </el-form>
            </div>
          </div>
        </el-tab-pane>

        <!-- 钉钉机器人Tab -->
        <el-tab-pane :label="$t('uiAutomation.notification.configs.dingtalkBot')" name="dingtalk">
          <div class="tab-content">
            <div class="config-section">
              <el-form
                  ref="dingtalkFormRef"
                  :model="webhookBots.dingtalk"
                  label-position="top"
                  class="config-form"
              >
                <el-row :gutter="20">
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.botName')">
                      <el-input
                          v-model="webhookBots.dingtalk.name"
                          :placeholder="$t('uiAutomation.notification.configs.dingtalkBotNamePlaceholder')"
                      />
                    </el-form-item>
                  </el-col>
                  <el-col :span="12">
                    <el-form-item :label="$t('uiAutomation.notification.configs.enable')">
                      <el-switch v-model="webhookBots.dingtalk.enabled"/>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.webhookUrl')">
                      <el-input
                          v-model="webhookBots.dingtalk.webhook_url"
                          :placeholder="$t('uiAutomation.notification.configs.webhookPlaceholder')"
                      />
                      <div class="form-item-hint">
                        {{ $t('uiAutomation.notification.configs.dingtalkUrlHint') }}
                      </div>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.signatureSecret')">
                      <el-input
                          v-model="webhookBots.dingtalk.secret"
                          :placeholder="$t('uiAutomation.notification.configs.signatureSecretPlaceholder')"
                          type="password"
                          show-password
                      />
                      <div class="form-item-hint">
                        {{ $t('uiAutomation.notification.configs.signatureSecretHint') }}
                      </div>
                    </el-form-item>
                  </el-col>
                  <el-col :span="24">
                    <el-form-item :label="$t('uiAutomation.notification.configs.businessType')">
                      <el-checkbox v-model="webhookBots.dingtalk.enable_ui_automation">{{ $t('uiAutomation.notification.configs.uiAutomationTest') }}</el-checkbox>
                      <el-checkbox v-model="webhookBots.dingtalk.enable_api_testing">{{ $t('uiAutomation.notification.configs.apiTest') }}</el-checkbox>
                    </el-form-item>
                  </el-col>
                </el-row>

                <div class="form-actions">
                  <el-button @click="testWebhookBot('dingtalk')" :loading="testingBot === 'dingtalk'">
                    测试连接
                  </el-button>
                  <el-button type="primary" @click="saveWebhookBot('dingtalk')">
                    {{ $t('uiAutomation.notification.configs.saveDingtalkConfig') }}
                  </el-button>
                </div>
              </el-form>
            </div>
          </div>
        </el-tab-pane>
      </el-tabs>
    </div>
  </div>
</template>

<script>
import {ref, reactive, onMounted} from 'vue'
import {ElMessage} from 'element-plus'
import {
  getUnifiedNotificationConfigs,
  createUnifiedNotificationConfig,
  updateUnifiedNotificationConfig,
  testNotificationWebhook
} from '@/api/core.js'
import { useI18n } from 'vue-i18n'

export default {
  name: 'NotificationConfigs',
  setup() {
    const { t } = useI18n()

    // 数据状态
    const feishuFormRef = ref(null)
    const wechatFormRef = ref(null)
    const dingtalkFormRef = ref(null)
    const activeTab = ref('feishu')
    const testingBot = ref(null)

    // Webhook机器人配置
    const webhookBots = reactive({
      feishu: {
        name: '',
        webhook_url: '',
        enabled: true,
        enable_ui_automation: true,
        enable_api_testing: true
      },
      wechat: {
        name: '',
        webhook_url: '',
        enabled: true,
        enable_ui_automation: true,
        enable_api_testing: true
      },
      dingtalk: {
        name: '',
        webhook_url: '',
        secret: '',
        enabled: true,
        enable_ui_automation: true,
        enable_api_testing: true
      }
    })

    // 获取config_type映射
    const getConfigType = (botType) => {
      const configTypeMap = {
        'feishu': 'webhook_feishu',
        'wechat': 'webhook_wechat',
        'dingtalk': 'webhook_dingtalk'
      }
      return configTypeMap[botType]
    }

    // 获取机器人显示名称
    const getBotDisplayName = (botType) => {
      const displayNameMap = {
        'feishu': t('uiAutomation.notification.configs.platforms.feishu'),
        'wechat': t('uiAutomation.notification.configs.platforms.wechatWork'),
        'dingtalk': t('uiAutomation.notification.configs.platforms.dingtalk')
      }
      return displayNameMap[botType] || botType
    }

    // 保存Webhook机器人配置
    const saveWebhookBot = async (botType) => {
      const formRef = botType === 'feishu' ? feishuFormRef.value :
          botType === 'wechat' ? wechatFormRef.value :
              dingtalkFormRef.value

      if (!formRef) return

      try {
        const configType = getConfigType(botType)
        const botDisplayName = getBotDisplayName(botType)

        // 检查是否已存在对应类型的机器人配置
        let webhookConfigId = null
        try {
          const response = await getUnifiedNotificationConfigs({ configType: configType })
          if (response.data.records && response.data.records.length > 0) {
            webhookConfigId = response.data.records[0].id
          }
        } catch (error) {
          console.log(t('uiAutomation.notification.configs.messages.noExistingConfig'))
        }

        const botConfig = webhookBots[botType]
        let requestData

        if (webhookConfigId) {
          // 更新现有配置 - 需要先获取现有配置，然后更新webhook_bots
          const configResponse = await getUnifiedNotificationConfigs({ configType: configType })
          const existingConfig = configResponse.data.records[0]

          // 合并现有的webhook_bots和其他字段
          const updatedWebhookBots = existingConfig.webhook_bots || {}
          const botData = {
            name: botConfig.name || `${botType}机器人`,
            webhook_url: botConfig.webhook_url,
            enabled: botConfig.enabled,
            enable_ui_automation: botConfig.enable_ui_automation,
            enable_api_testing: botConfig.enable_api_testing
          }

          // 钉钉机器人需要额外保存secret字段
          if (botType === 'dingtalk' && botConfig.secret) {
            botData.secret = botConfig.secret
          }

          updatedWebhookBots[botType] = botData

          requestData = {
            name: existingConfig.name || `${botDisplayName}${t('uiAutomation.notification.configs.title')}`,
            config_type: configType,
            webhook_bots: updatedWebhookBots,
            is_active: true
          }

          // 更新现有配置
          await updateUnifiedNotificationConfig(webhookConfigId, requestData)
          const successMsgKey = botType === 'feishu' ? 'feishuUpdateSuccess' :
              botType === 'wechat' ? 'wechatUpdateSuccess' : 'dingtalkUpdateSuccess'
          ElMessage.success(t(`uiAutomation.notification.configs.messages.${successMsgKey}`))
        } else {
          // 创建新配置
          const botData = {
            name: botConfig.name || `${botType}机器人`,
            webhook_url: botConfig.webhook_url,
            enabled: botConfig.enabled,
            enable_ui_automation: botConfig.enable_ui_automation,
            enable_api_testing: botConfig.enable_api_testing
          }

          // 钉钉机器人需要额外保存secret字段
          if (botType === 'dingtalk' && botConfig.secret) {
            botData.secret = botConfig.secret
          }

          requestData = {
            name: `${botDisplayName}${t('uiAutomation.notification.configs.title')}`,
            config_type: configType,
            webhook_bots: {
              [botType]: botData
            },
            is_active: true
          }

          await createUnifiedNotificationConfig(requestData)
          const successMsgKey = botType === 'feishu' ? 'feishuCreateSuccess' :
              botType === 'wechat' ? 'wechatCreateSuccess' : 'dingtalkCreateSuccess'
          ElMessage.success(t(`uiAutomation.notification.configs.messages.${successMsgKey}`))
        }

        // 重新加载数据以确保状态同步
        fetchWebhookConfig(botType)
      } catch (error) {
        console.error('保存Webhook机器人配置失败:', error)
        const failedMsgKey = botType === 'feishu' ? 'feishuSaveFailed' :
            botType === 'wechat' ? 'wechatSaveFailed' : 'dingtalkSaveFailed'
        ElMessage.error(t(`uiAutomation.notification.configs.messages.${failedMsgKey}`) + ': ' + (error.response?.data?.detail || error.message))
      }
    }

    // 测试Webhook连接
    const testWebhookBot = async (botType) => {
      testingBot.value = botType
      try {
        const configType = getConfigType(botType)
        const response = await getUnifiedNotificationConfigs({ configType: configType })
        if (!response.data.records || response.data.records.length === 0) {
          ElMessage.warning('请先保存配置再测试')
          return
        }
        const configId = response.data.records[0].id
        const res = await testNotificationWebhook(configId, botType)
        if (res.data.success) {
          ElMessage.success(res.data.message)
        } else {
          ElMessage.error(res.data.message)
        }
      } catch (error) {
        console.error('测试Webhook连接失败:', error)
        ElMessage.error('测试失败: ' + (error.response?.data?.message || error.message))
      } finally {
        testingBot.value = null
      }
    }

    // 获取Webhook机器人配置
    const fetchWebhookConfig = async (botType) => {
      try {
        const configType = getConfigType(botType)
        const response = await getUnifiedNotificationConfigs({ configType: configType })
        if (response.data.records && response.data.records.length > 0) {
          const config = response.data.records[0]

          if (config.webhook_bots && config.webhook_bots[botType]) {
            const bot = config.webhook_bots[botType]
            webhookBots[botType].name = bot.name || ''
            webhookBots[botType].webhook_url = bot.webhook_url || ''
            webhookBots[botType].enabled = bot.enabled !== false
            webhookBots[botType].enable_ui_automation = bot.enable_ui_automation !== false
            webhookBots[botType].enable_api_testing = bot.enable_api_testing !== false
            // 钉钉机器人需要额外读取secret字段
            if (botType === 'dingtalk' && bot.secret) {
              webhookBots[botType].secret = bot.secret
            }
          }
        }
      } catch (error) {
        console.error(t('uiAutomation.notification.configs.messages.getConfigFailed'), error)
      }
    }

    // 获取所有Webhook机器人配置
    const fetchAllWebhookConfigs = async () => {
      try {
        // 遍历所有机器人类型，分别获取配置
        for (const botType of Object.keys(webhookBots)) {
          await fetchWebhookConfig(botType)
        }
      } catch (error) {
        console.error(t('uiAutomation.notification.configs.messages.getAllConfigFailed'), error)
      }
    }

    // 组件挂载时获取数据
    onMounted(async () => {
      try {
        console.log('NotificationConfigs 组件开始初始化')
        await fetchAllWebhookConfigs()
        console.log('NotificationConfigs 组件初始化完成')
      } catch (error) {
        console.error('NotificationConfigs 组件初始化失败:', error)
      }
    })

    return {
      feishuFormRef,
      wechatFormRef,
      dingtalkFormRef,
      activeTab,
      webhookBots,
      testingBot,
      saveWebhookBot,
      testWebhookBot,
      fetchWebhookConfig,
      fetchAllWebhookConfigs
    }
  }
}
</script>

<style scoped>
.notification-configs-container {
  padding: var(--th-space-2xl, 24px);
  background: var(--th-bg-secondary, #fafafa);
  min-height: 100%;
}

.page-header {
  margin-bottom: var(--th-space-2xl, 24px);
}

.page-header__row {
  display: flex;
  align-items: flex-start;
  gap: var(--th-space-md, 12px);
}

.page-header__icon {
  flex-shrink: 0;
  width: 36px;
  height: 36px;
  color: var(--th-text-tertiary, #999);
}

.page-header__icon svg {
  width: 100%;
  height: 100%;
  display: block;
}

.page-header__text {
  min-width: 0;
}

.page-header h1 {
  font-size: var(--th-font-size-3xl, 24px);
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  margin: 0 0 var(--th-space-sm, 8px) 0;
  letter-spacing: -0.02em;
}

.page-header p {
  margin: 0;
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-base, 14px);
  line-height: 1.5;
}

.content-wrapper {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  border: 1px solid var(--th-border, #e5e5e5);
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
}

.notification-tabs :deep(.el-tabs__header) {
  margin: 0;
}

.notification-tabs :deep(.el-tabs__nav-wrap) {
  background: var(--th-bg-secondary, #fafafa);
  border-bottom: 1px solid var(--th-border, #e5e5e5);
  overflow: visible;
}

.notification-tabs :deep(.el-tabs__nav-scroll) {
  padding: 0 var(--th-space-xl, 20px);
}

.notification-tabs :deep(.el-tabs__nav) {
  display: flex;
  width: 100%;
  background: var(--th-bg-secondary, #fafafa);
}

.notification-tabs :deep(.el-tabs__item) {
  flex: 1;
  text-align: center;
  padding: 14px 16px;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  color: var(--th-text-secondary, #666);
  border: none;
  position: relative;
  transition: color var(--th-transition-base, 0.2s ease), background var(--th-transition-base, 0.2s ease);
}

.notification-tabs :deep(.el-tabs__item:hover) {
  color: var(--th-text-primary, #1a1a1a);
  background: var(--th-bg-hover, #f0f0f0);
}

.notification-tabs :deep(.el-tabs__item.is-active) {
  color: var(--th-accent, #1a1a1a);
  background: var(--th-bg-primary, #fff);
  border-bottom: 2px solid var(--th-accent, #1a1a1a);
}

.notification-tabs :deep(.el-tabs__active-bar) {
  background-color: var(--th-accent, #1a1a1a);
  height: 2px;
}

.notification-tabs :deep(.el-tabs__content) {
  padding: 0;
}

.tab-content {
  min-height: 400px;
  padding: var(--th-space-2xl, 24px);
}

.config-section {
  padding: var(--th-space-lg, 16px) 0;
}

.config-section h3 {
  margin: 0 0 var(--th-space-xl, 20px) 0;
  font-size: var(--th-font-size-lg, 16px);
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
}

.form-item-hint {
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  margin-top: var(--th-space-xs, 4px);
}

.form-actions {
  margin-top: var(--th-space-xl, 20px);
  padding-top: var(--th-space-xl, 20px);
  border-top: 1px solid var(--th-border, #e5e5e5);
  text-align: right;
}

@media (max-width: 768px) {
  .notification-configs-container {
    padding: var(--th-space-lg, 16px);
  }

  .page-header h1 {
    font-size: var(--th-font-size-2xl, 20px);
  }

  .notification-tabs :deep(.el-tabs__item) {
    padding: var(--th-space-md, 12px) var(--th-space-xl, 20px);
    font-size: var(--th-font-size-sm, 13px);
  }

  .tab-content {
    padding: var(--th-space-lg, 16px);
  }
}
</style>
