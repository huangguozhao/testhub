<template>
  <div class="generation-config">
    <div class="page-header">
      <h1>{{ $t('generationConfig.title') }}</h1>
      <p>{{ $t('generationConfig.subtitle') }}</p>
    </div>

    <div class="main-content">
      <!-- 配置列表 -->
      <div class="configs-section">
        <div class="section-header">
          <h2>{{ $t('generationConfig.configList') }}</h2>
          <button class="add-config-btn" @click="openAddModal">
            {{ $t('generationConfig.addConfig') }}
          </button>
        </div>

        <div class="configs-grid">
          <div v-for="config in configs" :key="config.id" class="config-card">
            <div class="config-header">
              <div class="config-title">
                <h3>{{ config.name }}</h3>
                <div class="config-badges">
                  <span class="status-badge" :class="{ active: config.is_active }">
                    {{ config.is_active ? $t('generationConfig.enabled') : $t('generationConfig.disabled') }}
                  </span>
                  <span class="mode-badge">
                    {{ config.default_output_mode === 'stream' ? $t('generationConfig.streamMode') : $t('generationConfig.completeMode') }}
                  </span>
                </div>
              </div>
              <div class="config-actions">
                <button v-if="!config.is_active" class="enable-btn" @click="enableConfig(config.id)">
                  {{ $t('generationConfig.enable') }}
                </button>
                <button class="edit-btn" @click="editConfig(config)">{{ $t('generationConfig.edit') }}</button>
                <button class="delete-btn" @click="deleteConfig(config.id)">{{ $t('generationConfig.delete') }}</button>
              </div>
            </div>

            <div class="config-details">
              <div class="detail-section">
                <h4>{{ $t('generationConfig.outputMode') }}</h4>
                <div class="detail-item">
                  <label>{{ $t('generationConfig.defaultMode') }}</label>
                  <span>{{ config.default_output_mode === 'stream' ? $t('generationConfig.realtimeStream') : $t('generationConfig.completeOutput') }}</span>
                </div>
              </div>

              <div class="detail-section">
                <h4>{{ $t('generationConfig.automationProcess') }}</h4>
                <div class="detail-item">
                  <label>{{ $t('generationConfig.aiReview') }}</label>
                  <span :class="{ enabled: config.enable_auto_review, disabled: !config.enable_auto_review }">
                    {{ config.enable_auto_review ? $t('generationConfig.enabled') : $t('generationConfig.disabled') }}
                  </span>
                </div>
              </div>

              <div class="detail-section">
                <h4>{{ $t('generationConfig.timeoutSettings') }}</h4>
                <div class="detail-item">
                  <label>{{ $t('generationConfig.reviewTimeout') }}</label>
                  <span>{{ config.review_timeout }} {{ $t('generationConfig.seconds') }}</span>
                </div>
              </div>

              <div class="config-meta">
                <div class="meta-item">
                  <label>{{ $t('generationConfig.createdAt') }}</label>
                  <span>{{ formatDateTime(config.created_at) }}</span>
                </div>
                <div class="meta-item">
                  <label>{{ $t('generationConfig.updatedAt') }}</label>
                  <span>{{ formatDateTime(config.updated_at) }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="configs.length === 0" class="empty-state">
          <div class="empty-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="12" cy="12" r="3"/>
              <path d="M19.4 15a1.65 1.65 0 00.33 1.82l.06.06a2 2 0 010 2.83 2 2 0 01-2.83 0l-.06-.06a1.65 1.65 0 00-1.82-.33 1.65 1.65 0 00-1 1.51V21a2 2 0 01-2 2 2 2 0 01-2-2v-.09A1.65 1.65 0 009 19.4a1.65 1.65 0 00-1.82.33l-.06.06a2 2 0 01-2.83 0 2 2 0 010-2.83l.06-.06A1.65 1.65 0 004.68 15a1.65 1.65 0 00-1.51-1H3a2 2 0 01-2-2 2 2 0 012-2h.09A1.65 1.65 0 004.6 9a1.65 1.65 0 00-.33-1.82l-.06-.06a2 2 0 010-2.83 2 2 0 012.83 0l.06.06A1.65 1.65 0 009 4.68a1.65 1.65 0 001-1.51V3a2 2 0 012-2 2 2 0 012 2v.09a1.65 1.65 0 001 1.51 1.65 1.65 0 001.82-.33l.06-.06a2 2 0 012.83 0 2 2 0 010 2.83l-.06.06A1.65 1.65 0 0019.4 9a1.65 1.65 0 001.51 1H21a2 2 0 012 2 2 2 0 01-2 2h-.09a1.65 1.65 0 00-1.51 1z"/>
            </svg>
          </div>
          <h3>{{ $t('generationConfig.emptyTitle') }}</h3>
          <p>{{ $t('generationConfig.emptyDescription') }}</p>
          <button class="add-first-config-btn" @click="openAddModal">
            {{ $t('generationConfig.addFirstConfig') }}
          </button>
        </div>
      </div>
    </div>

    <!-- 添加/编辑配置弹窗 -->
    <div v-if="showAddModal || showEditModal" class="config-modal">
      <div class="modal-content" @click.stop>
        <div class="modal-header">
          <h3>{{ isEditing ? $t('generationConfig.editTitle') : $t('generationConfig.addTitle') }}{{ $t('generationConfig.formTitle') }}</h3>
          <button class="close-btn" @click="closeModals">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveConfig">
            <div class="form-section">
              <h4>{{ $t('generationConfig.basicInfo') }}</h4>
              <div class="form-group">
                <label>{{ $t('generationConfig.configName') }} <span class="required">*</span></label>
                <input
                  v-model="configForm.name"
                  type="text"
                  class="form-input"
                  :placeholder="$t('generationConfig.configNamePlaceholder')"
                  required>
              </div>

              <div class="form-group">
                <label class="checkbox-label">
                  <input v-model="configForm.is_active" type="checkbox">
                  <span class="checkmark"></span>
                  {{ $t('generationConfig.enableThisConfig') }}
                </label>
                <div class="checkbox-hint">
                  {{ $t('generationConfig.enableHint') }}
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>{{ $t('generationConfig.outputModeSettings') }}</h4>
              <div class="form-group">
                <label>{{ $t('generationConfig.defaultOutputMode') }} <span class="required">*</span></label>
                <select v-model="configForm.default_output_mode" class="form-select" required>
                  <option value="stream">{{ $t('generationConfig.realtimeStream') }}</option>
                  <option value="complete">{{ $t('generationConfig.completeOutput') }}</option>
                </select>
                <div class="field-hint">
                  {{ $t('generationConfig.outputModeHint') }}
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>{{ $t('generationConfig.automationSettings') }}</h4>
              <div class="form-group">
                <label class="checkbox-label">
                  <input v-model="configForm.enable_auto_review" type="checkbox">
                  <span class="checkmark"></span>
                  {{ $t('generationConfig.enableAutoReview') }}
                </label>
                <div class="checkbox-hint">
                  {{ $t('generationConfig.autoReviewHint') }}
                </div>
              </div>
            </div>

            <div class="form-section">
              <h4>{{ $t('generationConfig.timeoutSettingsLabel') }}</h4>
              <div class="form-group">
                <label>{{ $t('generationConfig.reviewTimeoutLabel') }}</label>
                <input
                  v-model.number="configForm.review_timeout"
                  type="number"
                  class="form-input"
                  min="10"
                  max="3600">
                <div class="field-hint">{{ $t('generationConfig.timeoutHint') }}</div>
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="cancel-btn" @click="closeModals">{{ $t('generationConfig.cancel') }}</button>
              <button
                type="submit"
                class="confirm-btn"
                :disabled="isSaving">
                <span v-if="isSaving">{{ $t('generationConfig.saving') }}</span>
                <span v-else>{{ $t('generationConfig.saveConfig') }}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getGenerationConfigs, createGenerationConfig, updateGenerationConfig, deleteGenerationConfig } from '@/api/requirement-analysis'
import api from '@/utils/api'
import { ElMessage } from 'element-plus'
import { useI18n } from 'vue-i18n'

export default {
  name: 'GenerationConfigView',
  setup() {
    const { t, locale } = useI18n()
    return { t, locale }
  },
  data() {
    return {
      configs: [],
      showAddModal: false,
      showEditModal: false,
      isEditing: false,
      isSaving: false,
      editingConfigId: null,
      configForm: {
        name: '',
        default_output_mode: 'stream',
        enable_auto_review: true,
        review_timeout: 1500,
        is_active: true
      }
    }
  },

  mounted() {
    this.configForm.name = this.t('generationConfig.defaultConfigName')
    this.loadConfigs()
  },

  methods: {
    openAddModal() {
      this.resetForm()
      this.isEditing = false
      this.showAddModal = true
    },

    async loadConfigs() {
      try {
        console.log('Loading generation configs...')
        const response = await getGenerationConfigs()
        console.log('Generation configs API response:', response.data)

        // 处理分页API响应格式
        if (response.data && response.data.results && Array.isArray(response.data.results)) {
          this.configs = response.data.results
        } else if (response.data && Array.isArray(response.data)) {
          this.configs = response.data
        } else {
          console.warn('Unexpected API response format:', response.data)
          this.configs = []
        }

        console.log('Final configs count:', this.configs.length)
      } catch (error) {
        console.error('Failed to load config:', error)
        this.configs = []

        if (error.response?.status === 401) {
          ElMessage.error(this.t('generationConfig.pleaseLogin'))
        } else {
          ElMessage.error(this.t('generationConfig.loadFailed') + ': ' + (error.response?.data?.error || error.message))
        }
      }
    },

    resetForm() {
      this.configForm = {
        name: this.t('generationConfig.defaultConfigName'),
        default_output_mode: 'stream',
        enable_auto_review: true,
        review_timeout: 1500,
        is_active: true
      }
    },

    editConfig(config) {
      this.isEditing = true
      this.editingConfigId = config.id
      this.configForm = {
        name: config.name,
        default_output_mode: config.default_output_mode,
        enable_auto_review: config.enable_auto_review,
        review_timeout: config.review_timeout,
        is_active: config.is_active
      }
      this.showEditModal = true
    },

    async saveConfig() {
      this.isSaving = true

      try {
        if (this.isEditing) {
          await updateGenerationConfig(this.editingConfigId, this.configForm)
          ElMessage.success(this.t('generationConfig.updateSuccess'))
        } else {
          await createGenerationConfig(this.configForm)
          ElMessage.success(this.t('generationConfig.saveSuccess'))
        }

        this.closeModals()
        this.loadConfigs()
      } catch (error) {
        console.error('Failed to save config:', error)
        ElMessage.error(this.t('generationConfig.saveFailed') + ': ' + (error.response?.data?.error || error.message))
      } finally {
        this.isSaving = false
      }
    },

    async enableConfig(configId) {
      try {
        await api.post(`/requirement-analysis/generation-config/${configId}/enable`)
        ElMessage.success(this.t('generationConfig.enableSuccess'))
        this.loadConfigs()
      } catch (error) {
        console.error('Failed to enable config:', error)
        ElMessage.error(this.t('generationConfig.enableFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    async deleteConfig(configId) {
      if (!confirm(this.t('generationConfig.deleteConfirm'))) {
        return
      }

      try {
        await deleteGenerationConfig(configId)
        ElMessage.success(this.t('generationConfig.deleteSuccess'))
        this.loadConfigs()
      } catch (error) {
        console.error('Failed to delete config:', error)
        ElMessage.error(this.t('generationConfig.deleteFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    closeModals() {
      this.showAddModal = false
      this.showEditModal = false
      this.isEditing = false
      this.editingConfigId = null
      this.resetForm()
    },

    formatDateTime(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleString(this.locale === 'zh-cn' ? 'zh-CN' : 'en-US', {
        year: 'numeric',
        month: '2-digit',
        day: '2-digit',
        hour: '2-digit',
        minute: '2-digit'
      })
    }
  }
}
</script>

<style scoped>
.generation-config {
  padding: 20px;
  max-width: 1400px;
  margin: 0 auto;
}

.page-header {
  text-align: center;
  margin-bottom: 32px;
}

.page-header h1 {
  font-size: var(--th-font-size-3xl, 24px);
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 8px;
  font-weight: 600;
  letter-spacing: -0.02em;
}

.page-header p {
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-base, 14px);
  margin: 0;
}

.section-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
  flex-wrap: wrap;
  gap: 15px;
}

.section-header h2 {
  color: var(--th-text-primary, #1a1a1a);
  margin: 0;
  font-size: var(--th-font-size-xl, 18px);
  font-weight: 600;
}

.add-config-btn {
  background: var(--th-accent, #1a1a1a);
  color: #fff;
  border: 1px solid var(--th-accent, #1a1a1a);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.add-config-btn:hover {
  background: var(--th-accent-light, #333);
  border-color: var(--th-accent-light, #333);
}

.configs-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(650px, 1fr));
  gap: 20px;
}

.config-card {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 20px 22px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  transition: border-color var(--th-transition-base, 0.2s ease), box-shadow var(--th-transition-base, 0.2s ease);
}

.config-card:hover {
  border-color: var(--th-border-hover, #d0d0d0);
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
}

.config-header {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  margin-bottom: 16px;
  padding-bottom: 12px;
  border-bottom: 1px solid var(--th-border, #e5e5e5);
}

.config-title h3 {
  color: var(--th-text-primary, #1a1a1a);
  margin: 0 0 8px 0;
  font-size: var(--th-font-size-lg, 16px);
  font-weight: 600;
}

.config-badges {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.status-badge,
.mode-badge {
  padding: 3px 10px;
  border-radius: var(--th-radius-md, 6px);
  font-size: var(--th-font-size-xs, 12px);
  font-weight: 500;
  border: 1px solid transparent;
}

.status-badge {
  background: var(--th-bg-tertiary, #f5f5f5);
  color: var(--th-text-tertiary, #999);
}

.status-badge.active {
  background: rgba(34, 197, 94, 0.1);
  color: var(--th-success, #22c55e);
}

.mode-badge {
  background: var(--th-bg-secondary, #fafafa);
  color: var(--th-text-secondary, #666);
}

.config-actions {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.enable-btn,
.edit-btn,
.delete-btn {
  padding: 6px 12px;
  border-radius: var(--th-radius-md, 6px);
  cursor: pointer;
  font-size: var(--th-font-size-sm, 13px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease), color var(--th-transition-base, 0.2s ease);
}

.enable-btn {
  background: var(--th-success, #22c55e);
  color: #fff;
  border: 1px solid var(--th-success, #22c55e);
}

.enable-btn:hover {
  background: #1a9e4a;
  border-color: #1a9e4a;
}

.edit-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
}

.edit-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.delete-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-danger, #ef4444);
  border: 1px solid var(--th-border, #e5e5e5);
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.08);
  border-color: rgba(239, 68, 68, 0.35);
}

.config-details {
  margin-top: 12px;
}

.detail-section {
  margin-bottom: 12px;
  padding: 12px;
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.detail-section h4 {
  margin: 0 0 8px 0;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-base, 14px);
  font-weight: 600;
}

.detail-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 5px 0;
  font-size: var(--th-font-size-sm, 13px);
}

.detail-item label {
  color: var(--th-text-secondary, #666);
  font-weight: 500;
}

.detail-item span {
  color: var(--th-text-primary, #1a1a1a);
  font-weight: 600;
}

.detail-item span.enabled {
  color: var(--th-success, #22c55e);
}

.detail-item span.disabled {
  color: var(--th-danger, #ef4444);
}

.config-meta {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid var(--th-border, #e5e5e5);
}

.meta-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.meta-item label {
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  font-weight: 500;
}

.meta-item span {
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-sm, 13px);
}

.empty-state {
  text-align: center;
  padding: 64px 20px;
  color: var(--th-text-secondary, #666);
}

.empty-icon {
  font-size: 4rem;
  margin-bottom: 20px;
}

.empty-state h3 {
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 10px;
  font-weight: 600;
}

.add-first-config-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 12px 24px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
  margin-top: 20px;
}

.add-first-config-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.config-modal {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.45);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 0;
  max-width: 700px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid var(--th-border, #e5e5e5);
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px;
  border-bottom: 1px solid var(--th-border, #e5e5e5);
}

.modal-header h3 {
  margin: 0;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-lg, 16px);
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 1.35rem;
  cursor: pointer;
  color: var(--th-text-tertiary, #999);
  padding: 4px 8px;
  border-radius: var(--th-radius-md, 6px);
  line-height: 1;
  transition: color var(--th-transition-base, 0.2s ease), background var(--th-transition-base, 0.2s ease);
}

.close-btn:hover {
  color: var(--th-text-primary, #1a1a1a);
  background: var(--th-bg-hover, #f0f0f0);
}

.modal-body {
  padding: 24px 20px;
}

.form-section {
  margin-bottom: 20px;
  padding: 16px;
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.form-section h4 {
  margin: 0 0 12px 0;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-base, 14px);
  font-weight: 600;
}

.form-group {
  margin-bottom: 16px;
}

.form-row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 15px;
}

.form-group label {
  display: block;
  margin-bottom: 6px;
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-sm, 13px);
}

.form-input,
.form-select {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-md, 6px);
  font-size: var(--th-font-size-sm, 13px);
  background: var(--th-bg-primary, #fff);
  transition: border-color var(--th-transition-base, 0.2s ease);
}

.form-input:focus,
.form-select:focus {
  outline: none;
  border-color: var(--th-accent, #1a1a1a);
  box-shadow: 0 0 0 2px rgba(26, 26, 26, 0.08);
}

.field-hint {
  margin-top: 5px;
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  font-style: italic;
}

.checkbox-label {
  display: flex;
  align-items: center;
  gap: 10px;
  cursor: pointer;
  user-select: none;
}

.checkbox-label input[type="checkbox"] {
  width: auto;
}

.checkbox-hint {
  margin-top: 5px;
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  font-style: italic;
}

.required {
  color: var(--th-danger, #ef4444);
}

.modal-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 24px;
}

.cancel-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-secondary, #666);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.cancel-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
}

.confirm-btn {
  background: var(--th-success, #22c55e);
  color: #fff;
  border: 1px solid var(--th-success, #22c55e);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.confirm-btn:hover:not(:disabled) {
  background: #1a9e4a;
  border-color: #1a9e4a;
}

.confirm-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

@media (max-width: 768px) {
  .configs-grid {
    grid-template-columns: 1fr;
  }

  .config-header {
    flex-direction: column;
    gap: 15px;
    align-items: flex-start;
  }

  .form-row {
    grid-template-columns: 1fr;
  }

  .detail-item {
    flex-direction: column;
    align-items: flex-start;
    gap: 5px;
  }
}
</style>
