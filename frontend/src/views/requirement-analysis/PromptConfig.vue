<template>
  <div class="prompt-config">
    <div class="page-header">
      <h1>{{ $t('promptConfig.title') }}</h1>
      <p>{{ $t('promptConfig.subtitle') }}</p>
    </div>

    <div class="main-content">
      <!-- 配置列表 -->
      <div class="configs-section">
        <div class="section-header">
          <h2>{{ $t('promptConfig.configListTitle') }}</h2>
          <div class="header-actions">
            <button class="load-defaults-btn" @click="loadDefaultPrompts">
              {{ $t('promptConfig.loadDefaults') }}
            </button>
            <button class="add-config-btn" @click="openAddModal">
              {{ $t('promptConfig.addConfig') }}
            </button>
          </div>
        </div>

        <div class="configs-grid">
          <div v-for="config in configs" :key="config.id" class="config-card">
            <div class="config-header">
              <div class="config-title">
                <h3>{{ config.name }}</h3>
                <div class="config-badges">
                  <span class="type-badge" :class="config.prompt_type">
                    {{ config.prompt_type === 'writer' ? $t('promptConfig.writerPrompt') : $t('promptConfig.reviewerPrompt') }}
                  </span>
                  <span class="status-badge" :class="{ active: config.is_active }">
                    {{ config.is_active ? $t('promptConfig.enabled') : $t('promptConfig.disabled') }}
                  </span>
                </div>
              </div>
              <div class="config-actions">
                <button class="preview-btn" @click="previewPrompt(config)">{{ $t('promptConfig.preview') }}</button>
                <button class="edit-btn" @click="editConfig(config)">{{ $t('promptConfig.edit') }}</button>
                <button class="delete-btn" @click="deleteConfig(config.id)">{{ $t('promptConfig.delete') }}</button>
              </div>
            </div>

            <div class="config-details">
              <div class="prompt-preview">
                <label>{{ $t('promptConfig.contentPreview') }}</label>
                <div class="content-preview">
                  {{ truncateContent(config.content, 200) }}
                </div>
              </div>
              <div class="config-meta">
                <div class="meta-item">
                  <label>{{ $t('promptConfig.createdAt') }}</label>
                  <span>{{ formatDateTime(config.created_at) }}</span>
                </div>
                <div class="meta-item">
                  <label>{{ $t('promptConfig.updatedAt') }}</label>
                  <span>{{ formatDateTime(config.updated_at) }}</span>
                </div>
                <div class="meta-item">
                  <label>{{ $t('promptConfig.createdBy') }}</label>
                  <span>{{ config.created_by_name || $t('promptConfig.unknown') }}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div v-if="configs.length === 0" class="empty-state">
          <div class="empty-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
              <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
              <polyline points="14 2 14 8 20 8"/>
              <line x1="16" y1="13" x2="8" y2="13"/>
              <line x1="16" y1="17" x2="8" y2="17"/>
              <polyline points="10 9 9 9 8 9"/>
            </svg>
          </div>
          <h3>{{ $t('promptConfig.noConfigs') }}</h3>
          <p>{{ $t('promptConfig.emptyHint') }}</p>
          <div class="empty-actions">
            <button class="add-first-config-btn" @click="openAddModal">
              {{ $t('promptConfig.addFirstConfig') }}
            </button>
            <button class="load-defaults-first-btn" @click="loadDefaultPrompts">
              {{ $t('promptConfig.loadDefaults') }}
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- 添加/编辑配置弹窗 -->
    <div v-if="showAddModal || showEditModal" class="config-modal">
      <div class="modal-content large" @click.stop>
        <div class="modal-header">
          <h3>{{ isEditing ? $t('promptConfig.editConfig') : $t('promptConfig.addConfig') }}</h3>
          <button class="close-btn" @click="closeModals">×</button>
        </div>
        <div class="modal-body">
          <form @submit.prevent="saveConfig">
            <div class="form-group">
              <label>{{ $t('promptConfig.configName') }} <span class="required">*</span></label>
              <input
                v-model="configForm.name"
                type="text"
                class="form-input"
                :placeholder="$t('promptConfig.configNamePlaceholder')"
                required>
            </div>

            <div class="form-group">
              <label>{{ $t('promptConfig.promptType') }} <span class="required">*</span></label>
              <select v-model="configForm.prompt_type" class="form-select" required>
                <option value="">{{ $t('promptConfig.selectPromptType') }}</option>
                <option value="writer">{{ $t('promptConfig.writerPrompt') }}</option>
                <option value="reviewer">{{ $t('promptConfig.reviewerPrompt') }}</option>
              </select>
            </div>

            <div class="form-group">
              <label>{{ $t('promptConfig.promptContent') }} <span class="required">*</span></label>
              <div class="textarea-container">
                <textarea
                  v-model="configForm.content"
                  class="form-textarea large"
                  rows="20"
                  :placeholder="$t('promptConfig.contentPlaceholder')"
                  required></textarea>
                <div class="char-count">{{ $t('promptConfig.charCount', { count: configForm.content.length }) }}</div>
              </div>
              <div class="textarea-tips">
                <p><strong>{{ $t('promptConfig.writingTipsTitle') }}</strong></p>
                <ul>
                  <li>{{ $t('promptConfig.tip1') }}</li>
                  <li>{{ $t('promptConfig.tip2') }}</li>
                  <li>{{ $t('promptConfig.tip3') }}</li>
                  <li>{{ $t('promptConfig.tip4') }}</li>
                </ul>
              </div>
            </div>

            <div class="form-group">
              <label class="checkbox-label">
                <input
                  v-model="configForm.is_active"
                  type="checkbox">
                <span class="checkmark"></span>
                {{ $t('promptConfig.enableConfig') }}
              </label>
              <div class="checkbox-hint">
                {{ $t('promptConfig.enableHint') }}
              </div>
            </div>

            <div class="modal-actions">
              <button type="button" class="cancel-btn" @click="closeModals">{{ $t('promptConfig.cancel') }}</button>
              <button
                type="submit"
                class="confirm-btn"
                :disabled="isSaving">
                <span v-if="isSaving">{{ $t('promptConfig.saving') }}</span>
                <span v-else>{{ $t('promptConfig.saveConfig') }}</span>
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>

    <!-- 预览弹窗 -->
    <div v-if="showPreviewModal" class="preview-modal" @click="closePreview">
      <div class="modal-content large" @click.stop>
        <div class="modal-header">
          <h3>{{ $t('promptConfig.previewTitle', { name: previewConfig.name }) }}</h3>
          <button class="close-btn" @click="closePreview">×</button>
        </div>
        <div class="modal-body">
          <div class="preview-content">
            <div class="preview-meta">
              <div class="meta-item">
                <label>{{ $t('promptConfig.type') }}</label>
                <span class="type-badge" :class="previewConfig.prompt_type">
                  {{ previewConfig.prompt_type === 'writer' ? $t('promptConfig.writerPrompt') : $t('promptConfig.reviewerPrompt') }}
                </span>
              </div>
              <div class="meta-item">
                <label>{{ $t('promptConfig.status') }}</label>
                <span class="status-badge" :class="{ active: previewConfig.is_active }">
                  {{ previewConfig.is_active ? $t('promptConfig.enabled') : $t('promptConfig.disabled') }}
                </span>
              </div>
            </div>
            <div class="content-display">
              <label>{{ $t('promptConfig.promptContent') }}</label>
              <div class="content-text">{{ previewConfig.content }}</div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- 默认提示词预览弹窗 -->
    <div v-if="showDefaultsModal" class="defaults-modal" @click="closeDefaultsModal">
      <div class="modal-content large" @click.stop>
        <div class="modal-header">
          <h3>{{ $t('promptConfig.defaultPromptsPreview') }}</h3>
          <button class="close-btn" @click="closeDefaultsModal">×</button>
        </div>
        <div class="modal-body">
          <div class="defaults-content">
            <div class="tabs">
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'writer' }"
                @click="activeTab = 'writer'">
                {{ $t('promptConfig.writerTab') }}
              </button>
              <button
                class="tab-btn"
                :class="{ active: activeTab === 'reviewer' }"
                @click="activeTab = 'reviewer'">
                {{ $t('promptConfig.reviewerTab') }}
              </button>
            </div>

            <div class="tab-content">
              <div class="content-display">
                <div class="content-text">{{ defaultPrompts[activeTab] || $t('promptConfig.noContent') }}</div>
              </div>
            </div>
          </div>

          <div class="modal-actions">
            <button class="cancel-btn" @click="closeDefaultsModal">{{ $t('promptConfig.cancel') }}</button>
            <button
              class="confirm-btn"
              @click="confirmLoadDefaults"
              :disabled="isLoadingDefaults">
              <span v-if="isLoadingDefaults">{{ $t('promptConfig.loading') }}</span>
              <span v-else>{{ $t('promptConfig.confirmLoad') }}</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/utils/api'
import { ElMessage } from 'element-plus'

export default {
  name: 'PromptConfig',
  data() {
    return {
      configs: [],
      showAddModal: false,
      showEditModal: false,
      showPreviewModal: false,
      showDefaultsModal: false,
      isEditing: false,
      isSaving: false,
      isLoadingDefaults: false,
      editingConfigId: null,
      previewConfig: {},
      defaultPrompts: {
        writer: '',
        reviewer: ''
      },
      activeTab: 'writer',
      configForm: {
        name: '',
        prompt_type: '',
        content: '',
        is_active: true
      }
    }
  },

  mounted() {
    this.loadConfigs()
  },

  methods: {
    openAddModal() {
      console.log('openAddModal clicked')
      this.resetForm()
      this.isEditing = false
      this.showAddModal = true
      console.log('showAddModal set to:', this.showAddModal)
    },

    async loadConfigs() {
      try {
        console.log('Loading prompt configs...')
        const response = await api.get('/requirement-analysis/prompts')
        console.log('Prompts API response:', response.data)
        
        // 处理分页API响应格式
        if (response.data && response.data.results && Array.isArray(response.data.results)) {
          this.configs = response.data.results
          console.log('Loaded configs from results:', this.configs)
        } else if (response.data && Array.isArray(response.data)) {
          // 直接数组格式的fallback
          this.configs = response.data
          console.log('Loaded configs from direct array:', this.configs)
        } else {
          console.warn('Unexpected API response format:', response.data)
          this.configs = []
        }
        
        console.log('Final configs count:', this.configs.length)
      } catch (error) {
        console.error(this.$t('promptConfig.loadConfigsFailed'), error)
        this.configs = [] // 确保configs始终是数组

        if (error.response?.status === 401) {
          ElMessage.error(this.$t('promptConfig.pleaseLogin'))
        } else {
          ElMessage.error(this.$t('promptConfig.loadConfigsFailed') + ': ' + (error.response?.data?.error || error.message))
        }
      }
    },

    async loadDefaultPrompts() {
      console.log('loadDefaultPrompts clicked')
      try {
        const response = await api.get('/requirement-analysis/prompts/load-defaults')
        console.log('Default prompts response:', response.data)
        this.defaultPrompts = response.data.defaults
        this.showDefaultsModal = true
        console.log('showDefaultsModal set to:', this.showDefaultsModal)
      } catch (error) {
        console.error(this.$t('promptConfig.loadDefaultsFailed'), error)
        ElMessage.error(this.$t('promptConfig.loadDefaultsFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    async confirmLoadDefaults() {
      this.isLoadingDefaults = true
      
      try {
        // 创建编写提示词配置
        if (this.defaultPrompts.writer) {
          await api.post('/requirement-analysis/prompts', {
            name: this.$t('promptConfig.defaultWriterName'),
            prompt_type: 'writer',
            content: this.defaultPrompts.writer,
            is_active: true
          })
        }

        // 创建评审提示词配置
        if (this.defaultPrompts.reviewer) {
          await api.post('/requirement-analysis/prompts', {
            name: this.$t('promptConfig.defaultReviewerName'),
            prompt_type: 'reviewer',
            content: this.defaultPrompts.reviewer,
            is_active: true
          })
        }

        ElMessage.success(this.$t('promptConfig.defaultsLoadSuccess'))
        this.closeDefaultsModal()
        this.loadConfigs()
      } catch (error) {
        console.error(this.$t('promptConfig.loadDefaultsFailed'), error)
        ElMessage.error(this.$t('promptConfig.loadFailed') + ': ' + (error.response?.data?.error || error.message))
      } finally{
        this.isLoadingDefaults = false
      }
    },

    resetForm() {
      this.configForm = {
        name: '',
        prompt_type: '',
        content: '',
        is_active: true
      }
    },

    editConfig(config) {
      this.isEditing = true
      this.editingConfigId = config.id
      this.configForm = {
        name: config.name,
        prompt_type: config.prompt_type,
        content: config.content,
        is_active: config.is_active
      }
      this.showEditModal = true
    },

    previewPrompt(config) {
      this.previewConfig = config
      this.showPreviewModal = true
    },

    async saveConfig() {
      this.isSaving = true
      
      try {
        if (this.isEditing) {
          await api.patch(`/requirement-analysis/prompts/${this.editingConfigId}`, this.configForm)
          ElMessage.success(this.$t('promptConfig.updateSuccess'))
        } else {
          await api.post('/requirement-analysis/prompts', this.configForm)
          ElMessage.success(this.$t('promptConfig.addSuccess'))
        }

        this.closeModals()
        this.loadConfigs()
      } catch (error) {
        console.error(this.$t('promptConfig.saveConfigFailed'), error)
        ElMessage.error(this.$t('promptConfig.saveFailed') + ': ' + (error.response?.data?.error || error.message))
      } finally {
        this.isSaving = false
      }
    },

    async deleteConfig(configId) {
      if (!confirm(this.$t('promptConfig.deleteConfirm'))) {
        return
      }

      try {
        await api.delete(`/requirement-analysis/prompts/${configId}`)
        ElMessage.success(this.$t('promptConfig.deleteSuccess'))
        this.loadConfigs()
      } catch (error) {
        console.error(this.$t('promptConfig.deleteConfigFailed'), error)
        ElMessage.error(this.$t('promptConfig.deleteFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    closeModals() {
      this.showAddModal = false
      this.showEditModal = false
      this.isEditing = false
      this.editingConfigId = null
      this.resetForm()
    },

    closePreview() {
      this.showPreviewModal = false
      this.previewConfig = {}
    },

    closeDefaultsModal() {
      this.showDefaultsModal = false
      this.defaultPrompts = { writer: '', reviewer: '' }
      this.activeTab = 'writer'
    },

    truncateContent(content, maxLength) {
      if (!content) return ''
      if (content.length <= maxLength) return content
      return content.substring(0, maxLength) + '...'
    },

    formatDateTime(dateString) {
      if (!dateString) return ''
      const date = new Date(dateString)
      return date.toLocaleString('zh-CN', {
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
.prompt-config {
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

.header-actions {
  display: flex;
  gap: 10px;
}

.load-defaults-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.load-defaults-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
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
  grid-template-columns: repeat(auto-fill, minmax(600px, 1fr));
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

.type-badge,
.status-badge {
  padding: 3px 10px;
  border-radius: var(--th-radius-md, 6px);
  font-size: var(--th-font-size-xs, 12px);
  font-weight: 500;
  border: 1px solid transparent;
}

.type-badge.writer,
.type-badge.reviewer {
  background: var(--th-bg-secondary, #fafafa);
  color: var(--th-text-secondary, #666);
}

.status-badge {
  background: var(--th-bg-tertiary, #f5f5f5);
  color: var(--th-text-tertiary, #999);
}

.status-badge.active {
  background: rgba(34, 197, 94, 0.1);
  color: var(--th-success, #22c55e);
}

.config-actions {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
}

.preview-btn,
.edit-btn,
.delete-btn {
  padding: 6px 12px;
  border-radius: var(--th-radius-md, 6px);
  cursor: pointer;
  font-size: var(--th-font-size-sm, 13px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease), color var(--th-transition-base, 0.2s ease);
}

.preview-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
}

.preview-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
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
  margin-top: 16px;
}

.prompt-preview {
  margin-bottom: 12px;
}

.prompt-preview label {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-tertiary, #999);
  font-weight: 500;
  display: block;
  margin-bottom: 6px;
}

.content-preview {
  background: var(--th-bg-secondary, #fafafa);
  padding: 12px;
  border-radius: var(--th-radius-lg, 8px);
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-sm, 13px);
  line-height: 1.5;
  border: 1px solid var(--th-border, #e5e5e5);
}

.config-meta {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 12px;
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

.empty-actions {
  display: flex;
  gap: 15px;
  justify-content: center;
  margin-top: 20px;
  flex-wrap: wrap;
}

.add-first-config-btn,
.load-defaults-first-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 12px 24px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.add-first-config-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.load-defaults-first-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.config-modal,
.preview-modal,
.defaults-modal {
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
  max-width: 600px;
  width: 90%;
  max-height: 90vh;
  overflow-y: auto;
  border: 1px solid var(--th-border, #e5e5e5);
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
}

.modal-content.large {
  max-width: 900px;
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

.form-group {
  margin-bottom: 20px;
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

.textarea-container {
  position: relative;
}

.form-textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-md, 6px);
  font-size: var(--th-font-size-sm, 13px);
  font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
  resize: vertical;
  min-height: 200px;
  background: var(--th-bg-primary, #fff);
  transition: border-color var(--th-transition-base, 0.2s ease);
}

.form-textarea.large {
  min-height: 400px;
}

.form-textarea:focus {
  outline: none;
  border-color: var(--th-accent, #1a1a1a);
  box-shadow: 0 0 0 2px rgba(26, 26, 26, 0.08);
}

.char-count {
  text-align: right;
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  margin-top: 5px;
}

.textarea-tips {
  margin-top: 10px;
  padding: 12px 14px;
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.textarea-tips p {
  margin: 0 0 8px 0;
  color: var(--th-text-primary, #1a1a1a);
  font-weight: 600;
  font-size: var(--th-font-size-sm, 13px);
}

.textarea-tips ul {
  margin: 0;
  padding-left: 20px;
}

.textarea-tips li {
  color: var(--th-text-secondary, #666);
  margin-bottom: 4px;
  line-height: 1.4;
  font-size: var(--th-font-size-sm, 13px);
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

.preview-content,
.defaults-content {
  margin-bottom: 20px;
}

.preview-meta {
  display: flex;
  gap: 20px;
  margin-bottom: 20px;
  padding: 12px 14px;
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.preview-meta .meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
}

.content-display {
  margin-bottom: 20px;
}

.content-display label {
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 8px;
  display: block;
  font-size: var(--th-font-size-sm, 13px);
}

.content-text {
  background: var(--th-bg-secondary, #fafafa);
  padding: 16px;
  border-radius: var(--th-radius-lg, 8px);
  color: var(--th-text-primary, #1a1a1a);
  line-height: 1.6;
  white-space: pre-wrap;
  font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
  font-size: var(--th-font-size-sm, 13px);
  border: 1px solid var(--th-border, #e5e5e5);
  max-height: 400px;
  overflow-y: auto;
}

.tabs {
  display: flex;
  gap: 2px;
  margin-bottom: 20px;
  border-bottom: 1px solid var(--th-border, #e5e5e5);
}

.tab-btn {
  background: none;
  border: none;
  padding: 10px 16px;
  cursor: pointer;
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  border-bottom: 2px solid transparent;
  transition: color var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease), background var(--th-transition-base, 0.2s ease);
  border-radius: var(--th-radius-md, 6px) var(--th-radius-md, 6px) 0 0;
}

.tab-btn.active {
  color: var(--th-text-primary, #1a1a1a);
  border-bottom-color: var(--th-accent, #1a1a1a);
  background: var(--th-bg-hover, #f0f0f0);
}

.tab-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
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

  .header-actions {
    flex-direction: column;
    width: 100%;
  }

  .empty-actions {
    flex-direction: column;
    align-items: center;
  }

  .preview-meta {
    flex-direction: column;
    gap: 10px;
  }
}
</style>