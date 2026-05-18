<template>
  <div class="requirement-analysis">
    <div class="page-header">
      <h1>{{ $t('requirementAnalysis.title') }}</h1>
      <p>{{ $t('requirementAnalysis.subtitle') }}</p>
    </div>

    <!-- 配置引导弹出窗口 -->
    <div v-if="showConfigGuide && !checkingConfig" class="modal-overlay" @click.self="showConfigGuide = false" :key="modalKey">
      <div class="guide-config-modal">
      <div class="guide-header">
        <svg class="guide-icon" viewBox="0 0 1024 1024" xmlns="http://www.w3.org/2000/svg">
          <path d="M512 64C264.6 64 64 264.6 64 512s200.6 448 448 448 448-200.6 448-448S759.4 64 512 64zm0 820c-205.4 0-372-166.6-372-372s166.6-372 372-372 372 166.6 372 372-166.6 372-372 372z" fill="currentColor"/>
          <path d="M464 336a48 48 0 1 0 96 0 48 48 0 1 0-96 0zm72 112h-48c-4.4 0-8 3.6-8 8v272c0 4.4 3.6 8 8 8h48c4.4 0 8-3.6 8-8V456c0-4.4-3.6-8-8-8z" fill="currentColor"/>
        </svg>
        <div class="guide-title">
          <h2>{{ $t('configGuide.title') }}</h2>
          <p>{{ $t('configGuide.subtitle') }}</p>
        </div>
      </div>

      <div class="config-groups">
        <!-- 模型配置行 -->
        <div class="config-group">
          <div class="group-label">{{ $t('configGuide.modelConfig') }}</div>
          <div class="config-items-row">
            <div class="config-item-inline" :class="getConfigItemClass('writer_model')">
              <span class="status-symbol" v-html="getStatusSymbol('writer_model')"></span>
              <span class="config-label">{{ $t('configGuide.caseWriter') }}</span>
              <span class="config-name" v-if="configStatus.writer_model.name">{{ configStatus.writer_model.name }}</span>
              <span class="status-text" v-if="!configStatus.writer_model.configured">{{ $t('configGuide.unconfigured') }}</span>
              <span class="status-text warning" v-else-if="!configStatus.writer_model.enabled">{{ $t('configGuide.disabled') }}</span>
            </div>

            <div class="config-item-inline" :class="getConfigItemClass('reviewer_model')">
              <span class="status-symbol" v-html="getStatusSymbol('reviewer_model')"></span>
              <span class="config-label">{{ $t('configGuide.caseReviewer') }}</span>
              <span class="config-name" v-if="configStatus.reviewer_model.name">{{ configStatus.reviewer_model.name }}</span>
              <span class="status-text" v-if="!configStatus.reviewer_model.configured">{{ $t('configGuide.unconfigured') }}</span>
              <span class="status-text warning" v-else-if="!configStatus.reviewer_model.enabled">{{ $t('configGuide.disabled') }}</span>
            </div>
          </div>
        </div>

        <!-- 提示词配置行 -->
        <div class="config-group">
          <div class="group-label">{{ $t('configGuide.promptConfig') }}</div>
          <div class="config-items-row">
            <div class="config-item-inline" :class="getConfigItemClass('writer_prompt')">
              <span class="status-symbol" v-html="getStatusSymbol('writer_prompt')"></span>
              <span class="config-label">{{ $t('configGuide.caseWriter') }}</span>
              <span class="config-name" v-if="configStatus.writer_prompt.name">{{ configStatus.writer_prompt.name }}</span>
              <span class="status-text" v-if="!configStatus.writer_prompt.configured">{{ $t('configGuide.unconfigured') }}</span>
              <span class="status-text warning" v-else-if="!configStatus.writer_prompt.enabled">{{ $t('configGuide.disabled') }}</span>
            </div>

            <div class="config-item-inline" :class="getConfigItemClass('reviewer_prompt')">
              <span class="status-symbol" v-html="getStatusSymbol('reviewer_prompt')"></span>
              <span class="config-label">{{ $t('configGuide.caseReviewer') }}</span>
              <span class="config-name" v-if="configStatus.reviewer_prompt.name">{{ configStatus.reviewer_prompt.name }}</span>
              <span class="status-text" v-if="!configStatus.reviewer_prompt.configured">{{ $t('configGuide.unconfigured') }}</span>
              <span class="status-text warning" v-else-if="!configStatus.reviewer_prompt.enabled">{{ $t('configGuide.disabled') }}</span>
            </div>
          </div>
        </div>

        <!-- 生成行为配置行 -->
        <div class="config-group">
          <div class="group-label">{{ $t('configGuide.generationConfig') }}</div>
          <div class="config-items-row">
            <div class="config-item-inline" :class="getConfigItemClass('generation_config')">
              <span class="status-symbol" v-html="getStatusSymbol('generation_config')"></span>
              <span class="config-label">{{ $t('configGuide.generationSettings') }}</span>
              <span class="config-name" v-if="configStatus.generation_config && configStatus.generation_config.name">{{ configStatus.generation_config.name }}</span>
              <span class="status-text" v-if="!configStatus.generation_config || !configStatus.generation_config.configured">{{ $t('configGuide.unconfigured') }}</span>
            </div>
          </div>
        </div>
      </div>

        <div class="guide-actions">
          <button class="generate-manual-btn" @click="goToConfig">
            {{ $t('configGuide.goToConfig') }}
          </button>
          <div class="skip-action" @click="showConfigGuide = false">
            {{ $t('configGuide.configureLater') }}
          </div>
        </div>
      </div>
    </div>

    <!-- 输出模式选择器 - 全局设置 -->
    <div class="output-mode-section" v-if="!isGenerating && !showResults">
      <div class="output-mode-card">
        <h3>{{ $t('requirementAnalysis.outputModeTitle') }}</h3>
        <p class="mode-section-desc">{{ $t('requirementAnalysis.outputModeDesc') }}</p>
        <div class="output-mode-selector">
          <label class="mode-option" :class="{ active: globalOutputMode === 'stream' }">
            <input type="radio" v-model="globalOutputMode" value="stream">
            <div class="mode-content">
              <div class="mode-title">{{ $t('requirementAnalysis.realtimeStream') }}</div>
              <div class="mode-desc">{{ $t('requirementAnalysis.realtimeStreamDesc') }}</div>
            </div>
          </label>
          <label class="mode-option" :class="{ active: globalOutputMode === 'complete' }">
            <input type="radio" v-model="globalOutputMode" value="complete">
            <div class="mode-content">
              <div class="mode-title">{{ $t('requirementAnalysis.completeOutput') }}</div>
              <div class="mode-desc">{{ $t('requirementAnalysis.completeOutputDesc') }}</div>
            </div>
          </label>
        </div>
      </div>
    </div>

    <div class="main-content">
      <!-- 手动输入需求描述区域 -->
      <div class="manual-input-section" v-if="!isGenerating && !showResults">
        <div class="manual-input-card">
          <h2>{{ $t('requirementAnalysis.manualInputTitle') }}</h2>
          <div class="input-form">
            <div class="form-group">
              <label>{{ $t('requirementAnalysis.requirementTitle') }} <span class="required">*</span></label>
              <input
                v-model="manualInput.title"
                type="text"
                class="form-input"
                :placeholder="$t('requirementAnalysis.titlePlaceholder')">
            </div>

            <div class="form-group">
              <label>{{ $t('requirementAnalysis.requirementDescription') }} <span class="required">*</span></label>
              <textarea
                v-model="manualInput.description"
                class="form-textarea"
                rows="8"
                :placeholder="$t('requirementAnalysis.descriptionPlaceholder')"></textarea>
              <div class="char-count">{{ manualInput.description.length }}/2000</div>
            </div>

            <div class="form-group">
              <label>{{ $t('requirementAnalysis.associatedProject') }}</label>
              <select v-model="manualInput.selectedProject" class="form-select">
                <option value="">{{ $t('requirementAnalysis.selectProject') }}</option>
                <option v-for="project in projects" :key="project.id" :value="project.id">
                  {{ project.name }}
                </option>
              </select>
            </div>

            <div class="form-group">
              <label>{{ $t('requirementAnalysis.testCaseCount') }}</label>
              <select v-model="manualInput.testCaseCount" class="form-select">
                <option :value="null">{{ $t('requirementAnalysis.testCaseCountAuto') }}</option>
                <option :value="10">{{ $t('requirementAnalysis.testCaseCountApprox') }} 10 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
                <option :value="20">{{ $t('requirementAnalysis.testCaseCountApprox') }} 20 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
                <option :value="30">{{ $t('requirementAnalysis.testCaseCountApprox') }} 30 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
                <option :value="50">{{ $t('requirementAnalysis.testCaseCountApprox') }} 50 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
                <option :value="80">{{ $t('requirementAnalysis.testCaseCountApprox') }} 80 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
                <option :value="100">{{ $t('requirementAnalysis.testCaseCountApprox') }} 100 {{ $t('requirementAnalysis.testCaseCountUnit') }}</option>
              </select>
            </div>

            <button
              class="generate-manual-btn"
              @click="generateFromManualInput"
              :disabled="!canGenerateManual || isGenerating">
              <span v-if="isGenerating">{{ $t('requirementAnalysis.generating') }}</span>
              <span v-else>{{ $t('requirementAnalysis.generateButton') }}</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 分隔线 -->
      <div class="divider" v-if="!isGenerating && !showResults">
        <span>{{ $t('requirementAnalysis.dividerOr') }}</span>
      </div>

      <!-- 文档上传区域 -->
      <div class="upload-section" v-if="!isGenerating && !showResults">
        <div class="upload-card">
          <h2>{{ $t('requirementAnalysis.uploadTitle') }}</h2>
          <div class="upload-area"
               @dragover.prevent
               @drop="handleDrop"
               :class="{ 'drag-over': isDragOver }"
               @dragenter="isDragOver = true"
               @dragleave="isDragOver = false">
            <div v-if="!selectedFile" class="upload-placeholder">
              <i class="upload-icon">
                <svg xmlns="http://www.w3.org/2000/svg" width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                  <path d="M22 19a2 2 0 01-2 2H4a2 2 0 01-2-2V5a2 2 0 012-2h5l2 3h9a2 2 0 012 2z"/>
                </svg>
              </i>
              <p>{{ $t('requirementAnalysis.dragDropText') }}</p>
              <p class="upload-hint">{{ $t('requirementAnalysis.supportedFormats') }}</p>
              <input
                type="file"
                ref="fileInput"
                @change="handleFileSelect"
                accept=".pdf,.doc,.docx,.txt,.md"
                style="display: none;">
              <button class="select-file-btn" @click="$refs.fileInput.click()">
                {{ $t('requirementAnalysis.selectFile') }}
              </button>
            </div>

            <div v-else class="file-selected">
              <div class="file-info">
                <i class="file-icon">
                  <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                    <polyline points="14 2 14 8 20 8"/>
                  </svg>
                </i>
                <div class="file-details">
                  <p class="file-name">{{ selectedFile.name }}</p>
                  <p class="file-size">{{ formatFileSize(selectedFile.size) }}</p>
                </div>
                <button class="remove-file" @click="removeFile">
                  <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="15" y1="9" x2="9" y2="15"/>
                    <line x1="9" y1="9" x2="15" y2="15"/>
                  </svg>
                </button>
              </div>
            </div>
          </div>

          <div v-if="selectedFile" class="document-info">
            <div class="form-group">
              <label>{{ $t('requirementAnalysis.documentTitle') }}</label>
              <input
                v-model="documentTitle"
                type="text"
                class="form-input"
                :placeholder="$t('requirementAnalysis.documentPlaceholder')">
            </div>

            <div class="form-group">
              <label>{{ $t('requirementAnalysis.associatedProject') }}</label>
              <select v-model="selectedProject" class="form-select">
                <option value="">{{ $t('requirementAnalysis.selectProject') }}</option>
                <option v-for="project in projects" :key="project.id" :value="project.id">
                  {{ project.name }}
                </option>
              </select>
            </div>

            <button
              class="generate-btn"
              @click="generateFromDocument"
              :disabled="!documentTitle || isGenerating">
              <span v-if="isGenerating">{{ $t('requirementAnalysis.generating') }}</span>
              <span v-else>{{ $t('requirementAnalysis.generateButton') }}</span>
            </button>
          </div>
        </div>
      </div>

      <!-- 生成进度和结果 -->
      <div v-if="isGenerating || showResults" class="generation-progress">
        <div class="progress-card">
          <h3>
            {{ $t('requirementAnalysis.aiGeneratingTitle') }}
            <span class="current-mode-badge">
              ({{ globalOutputMode === 'stream' ? $t('requirementAnalysis.realtimeStream') : $t('requirementAnalysis.completeOutput') }})
            </span>
          </h3>
          <div class="progress-info">
            <div class="progress-item">
              <span class="label">{{ $t('requirementAnalysis.taskId') }}</span>
              <span class="value">{{ currentTaskId || $t('requirementAnalysis.preparing') }}</span>
            </div>
            <div class="progress-item">
              <span class="label">{{ $t('requirementAnalysis.currentStatus') }}</span>
              <span class="value">{{ showResults ? $t('requirementAnalysis.generationComplete') : progressText }}</span>
            </div>
          </div>

          <!-- 流式内容实时显示区域 -->
          <div v-if="streamedContent" class="stream-content-display">
            <div class="stream-header">
              <span class="stream-title">{{ $t('requirementAnalysis.realtimeGeneratedContent') }}</span>
              <span class="stream-status">{{ $t('requirementAnalysis.characters', { count: streamedContent.length }) }}</span>
            </div>
            <div class="stream-content" v-html="renderTestCaseContent(streamedContent)"></div>
          </div>

          <!-- 评审内容显示区域 -->
          <div v-if="streamedReviewContent" class="stream-content-display" style="margin-top: 15px;">
            <div class="stream-header">
              <span class="stream-title">{{ $t('requirementAnalysis.aiReviewComments') }}</span>
              <span class="stream-status">{{ $t('requirementAnalysis.characters', { count: streamedReviewContent.length }) }}</span>
            </div>
            <div class="stream-content" v-html="formatMarkdown(streamedReviewContent)"></div>
          </div>

          <!-- 最终版用例显示区域 -->
          <div v-if="finalTestCases" class="stream-content-display" style="margin-top: 15px;">
            <div class="stream-header">
              <span class="stream-title">
                {{ $t('requirementAnalysis.finalVersionTestCases') }}
                <span v-if="isGenerating" class="streaming-indicator">{{ $t('requirementAnalysis.generating') }}</span>
              </span>
              <span class="stream-status">{{ $t('requirementAnalysis.characters', { count: finalTestCases.length }) }}</span>
            </div>
            <div class="stream-content final-testcases" v-html="renderTestCaseContent(finalTestCases)"></div>
          </div>

          <div class="progress-steps">
            <div class="step" :class="{ active: currentStep >= 1 }">
              <span class="step-number">1</span>
              <span class="step-text">{{ $t('requirementAnalysis.stepAnalysis') }}</span>
            </div>
            <div class="step" :class="{ active: currentStep >= 2 }">
              <span class="step-number">2</span>
              <span class="step-text">{{ $t('requirementAnalysis.stepWriting') }}</span>
            </div>
            <div v-if="showReviewStep" class="step" :class="{ active: currentStep >= 3 }">
              <span class="step-number">3</span>
              <span class="step-text">{{ $t('requirementAnalysis.stepReview') }}</span>
            </div>
            <div class="step" :class="{ active: currentStep >= (showReviewStep ? 4 : 3) }">
              <span class="step-number">{{ showReviewStep ? 4 : 3 }}</span>
              <span class="step-text">{{ $t('requirementAnalysis.stepComplete') }}</span>
            </div>
          </div>

          <!-- 任务完成后的操作按钮 -->
          <div v-if="showResults" class="completion-actions">
            <button class="download-btn" @click="downloadTestCases">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 01-2 2H5a2 2 0 01-2-2v-4"/>
                <polyline points="7 10 12 15 17 10"/>
                <line x1="12" y1="15" x2="12" y2="3"/>
              </svg>
              <span>{{ $t('requirementAnalysis.downloadExcel') }}</span>
            </button>
            <button class="save-btn" @click="saveToTestCaseRecords">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z"/>
                <polyline points="17 21 17 13 7 13 7 21"/>
                <polyline points="7 3 7 8 15 8"/>
              </svg>
              <span>{{ $t('requirementAnalysis.saveToRecords') }}</span>
            </button>
            <button class="new-generation-btn" @click="resetGeneration">
              <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M14 2H6a2 2 0 00-2 2v16a2 2 0 002 2h12a2 2 0 002-2V8z"/>
                <polyline points="14 2 14 8 20 8"/>
                <line x1="16" y1="13" x2="8" y2="13"/>
                <line x1="16" y1="17" x2="8" y2="17"/>
              </svg>
              <span>{{ $t('requirementAnalysis.newGeneration') }}</span>
            </button>
          </div>
          <button v-else class="cancel-generation-btn" @click="cancelGeneration">
            {{ $t('requirementAnalysis.cancelGeneration') }}
          </button>
        </div>
      </div>

      <!-- 旧的生成结果区域已废弃，保留用于兼容 -->
      <!-- 现在使用流式显示区域 + 最终版用例区域 -->
      <div v-if="false && showResults && generationResult" class="generation-result">
        <div class="result-header">
          <h2>{{ $t('requirementAnalysis.generationComplete') }}</h2>
          <div class="result-summary">
            <span class="summary-item">
              {{ $t('requirementAnalysis.summaryTaskId', { taskId: generationResult.task_id }) }}
            </span>
            <span class="summary-item">
              {{ $t('requirementAnalysis.summaryGenerationTime', { time: formatDateTime(generationResult.completed_at) }) }}
            </span>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import api from '@/utils/api'
import { ElMessage } from 'element-plus'
import * as XLSX from 'xlsx'
import { useUserStore } from '@/stores/user'

export default {
  name: 'RequirementAnalysisView',
  data() {
    return {
      // 全局输出模式设置
      globalOutputMode: 'stream',  // 默认使用流式输出

      // 手动输入需求
      manualInput: {
        title: '',
        description: '',
        selectedProject: '',
        testCaseCount: null  // 期望用例数量，null表示自动
      },

      // 文件上传
      selectedFile: null,
      documentTitle: '',
      selectedProject: '',
      projects: [],
      isDragOver: false,

      // 生成状态
      isGenerating: false,
      currentTaskId: null,
      progressText: '',
      currentStep: 0,
      pollInterval: null,
      eventSource: null,  // SSE连接
      streamedContent: '',  // 流式接收的内容
      streamedReviewContent: '',  // 流式接收的评审内容
      finalTestCases: '',  // 最终版用例
      hasShownCompletionMessage: false,  // 是否已经显示过完成消息
      _sseReconnectCount: 0,  // SSE重连次数
      _fetchingFinalResult: false,  // 防止fetchFinalResult重复调用
      showReviewStep: true,  // 是否显示评审步骤（根据生成配置决定）

      // 生成结果
      showResults: false,
      generationResult: null,

      // AI配置状态
      configStatus: {
        overall_status: 'unknown',
        message: '',
        writer_model: {
          configured: false,
          enabled: false,
          name: null,
          provider: null,
          id: null,
          required: true
        },
        writer_prompt: {
          configured: false,
          enabled: false,
          name: null,
          id: null,
          required: true
        },
        reviewer_model: {
          configured: false,
          enabled: false,
          name: null,
          id: null,
          required: true
        },
        reviewer_prompt: {
          configured: false,
          enabled: false,
          name: null,
          id: null,
          required: true
        },
        generation_config: {
          configured: false,
          enabled: false,
          name: null,
          id: null,
          required: true,
          default_output_mode: null
        }
      },
      showConfigGuide: false,
      checkingConfig: true,
      modalKey: 0  // 用于强制重新渲染弹窗
    }
  },

  computed: {
    canGenerateManual() {
      return this.manualInput.title.trim() &&
             this.manualInput.description.trim() &&
             this.manualInput.description.length <= 2000
    }
  },

  mounted() {
    this.progressText = this.$t('requirementAnalysis.preparing')
    this.loadProjects()
    this.checkConfigStatus()
  },

  activated() {
    // 当从其他页面返回时，重新检查配置状态
    // 立即隐藏弹窗和遮罩层，强制重新渲染
    this.showConfigGuide = false
    this.checkingConfig = true
    this.modalKey += 1  // 改变key值，强制重新渲染弹窗

    // 延迟检查配置，确保页面完全加载后再显示弹窗
    setTimeout(async () => {
      await this.checkConfigStatus()
    }, 200)
  },

  beforeUnmount() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval)
    }
    // 停止token自动刷新定时器
    const userStore = useUserStore()
    userStore.stopAutoRefresh()
  },

  methods: {
    async loadProjects() {
      try {
        const response = await api.get('/projects')
        this.projects = response.data.results || response.data
      } catch (error) {
        console.error(this.$t('requirementAnalysis.loadProjectsFailed'), error)
      }
    },

    async checkConfigStatus() {
      try {
        this.checkingConfig = true
        const response = await api.get('/requirement-analysis/config/check')
        this.configStatus = response.data

        // 判断逻辑：只有当"用例编写模型"、"用例评审模型"、"用例编写提示词"和"用例评审提示词"都配置且启用时，才不显示弹框
        const writerModelReady = response.data.writer_model &&
                                response.data.writer_model.configured &&
                                response.data.writer_model.enabled

        const reviewerModelReady = response.data.reviewer_model &&
                                  response.data.reviewer_model.configured &&
                                  response.data.reviewer_model.enabled

        const writerPromptReady = response.data.writer_prompt &&
                                 response.data.writer_prompt.configured &&
                                 response.data.writer_prompt.enabled

        const reviewerPromptReady = response.data.reviewer_prompt &&
                                   response.data.reviewer_prompt.configured &&
                                   response.data.reviewer_prompt.enabled

        // 检查生成行为配置
        const generationConfigReady = response.data.generation_config &&
                                      response.data.generation_config.configured

        // 只有五项都准备好时才不显示引导弹框
        if (writerModelReady && reviewerModelReady && writerPromptReady && reviewerPromptReady && generationConfigReady) {
          this.showConfigGuide = false

          // 如果生成配置允许用户修改，则使用配置的默认输出模式
          if (response.data.generation_config && response.data.generation_config.default_output_mode) {
            this.globalOutputMode = response.data.generation_config.default_output_mode
          }

          // 根据生成配置的enable_auto_review决定是否显示评审步骤
          if (response.data.generation_config && response.data.generation_config.enable_auto_review !== null) {
            this.showReviewStep = response.data.generation_config.enable_auto_review
          } else {
            this.showReviewStep = true  // 默认显示
          }
        } else {
          this.showConfigGuide = true
        }
      } catch (error) {
        console.error('Failed to check config status:', error)
        // 如果检查失败，默认不显示引导，避免影响正常使用
        this.showConfigGuide = false
        this.checkingConfig = false
      } finally {
        this.checkingConfig = false
      }
    },

    goToConfig() {
      // 智能判断跳转目标：优先跳转到未配置/未启用的页面
      // 优先级：必需配置 > 可选配置，提示词 > 模型

      // 0. 首先检查生成行为配置（generation_config）
      if (!this.configStatus.generation_config || !this.configStatus.generation_config.configured) {
        this.$router.push('/configuration/generation-config')
        return
      }

      // 1. 优先检查必需的提示词配置（writer_prompt）
      if (!this.configStatus.writer_prompt.configured || !this.configStatus.writer_prompt.enabled) {
        this.$router.push('/configuration/prompt-config')
        return
      }

      // 2. 检查必需的模型配置（writer_model）
      if (!this.configStatus.writer_model.configured || !this.configStatus.writer_model.enabled) {
        this.$router.push('/configuration/ai-model')
        return
      }

      // 3. 检查可选的评审提示词（reviewer_prompt）
      if (!this.configStatus.reviewer_prompt.configured || !this.configStatus.reviewer_prompt.enabled) {
        this.$router.push('/configuration/prompt-config')
        return
      }

      // 4. 检查可选的评审模型（reviewer_model）
      if (!this.configStatus.reviewer_model.configured || !this.configStatus.reviewer_model.enabled) {
        this.$router.push('/configuration/ai-model')
        return
      }

      // 默认跳转到生成行为配置
      this.$router.push('/configuration/generation-config')
    },

    goToPromptConfig() {
      this.$router.push('/configuration/prompt-config')
    },

    getConfigItemClass(configKey) {
      const config = this.configStatus[configKey]
      if (config.enabled) {
        return 'status-enabled'
      } else if (config.configured) {
        return 'status-disabled'
      } else {
        return 'status-unconfigured'
      }
    },

    getStatusIcon(configKey) {
      const config = this.configStatus[configKey]
      if (config.enabled) {
        // 绿色对号
        return '<path d="M512 64C264.6 64 64 264.6 64 512s200.6 448 448 448 448-200.6 448-448S759.4 64 512 64zm193.5 301.7l-210.6 292c-12.7 17.7-39 17.7-51.7 0L318.5 484.9c-3.8-5.3 0-12.7 6.5-12.7h46.9c10.2 0 19.9 4.9 25.9 13.3l71.2 98.8 157.2-218c6-8.3 15.6-13.3 25.9-13.3H699c6.5 0 10.3 7.4 6.5 12.7z" fill="#27ae60"/>'
      } else if (config.configured) {
        // 禁用图标（灰色圆圈和斜线）
        return '<path d="M512 64C264.6 64 64 264.6 64 512s200.6 448 448 448 448-200.6 448-448S759.4 64 512 64zm0 820c-205.4 0-372-166.6-372-372s166.6-372 372-372 372 166.6 372 372-166.6 372-372 372zm128-412c0 4.4-3.6 8-8 8H392c-4.4 0-8-3.6-8-8v-48c0-4.4 3.6-8 8-8h240c4.4 0 8 3.6 8 8v48z" fill="#95a5a6"/>'
      } else {
        // 红色叉号
        return '<path d="M512 64C264.6 64 64 264.6 64 512s200.6 448 448 448 448-200.6 448-448S759.4 64 512 64zm165.4 618.2l-66-70.7c-10.6-10.1-28.1-10.1-38.8 0l-66.7 71.5-66.7-71.5c-10.6-10.1-28.1-10.1-38.8 0l-66 70.7c-9.9 10.6-9.9 27.4 0 38l66 70.7c10.6 10.1 28.1 10.1 38.8 0l66.7-71.5 66.7 71.5c10.6 10.1 28.1 10.1 38.8 0l66-70.7c9.9-10.6 9.9-27.4 0-38z" fill="#e74c3c"/>'
      }
    },

    getStatusSymbol(configKey) {
      const config = this.configStatus[configKey]
      if (config.enabled) {
        return '<span style="color: var(--th-success, #22c55e); font-size: 18px;">✓</span>'
      } else if (config.configured) {
        return '<span style="color: var(--th-text-disabled, #ccc); font-size: 18px;">○</span>'
      } else {
        return '<span style="color: var(--th-danger, #ef4444); font-size: 18px;">✗</span>'
      }
    },

    handleDrop(event) {
      event.preventDefault()
      this.isDragOver = false
      const files = event.dataTransfer.files
      if (files.length > 0) {
        this.handleFileSelect({ target: { files } })
      }
    },

    handleFileSelect(event) {
      const file = event.target.files[0]
      if (file) {
        const allowedTypes = [
          'application/pdf',
          'application/msword',
          'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          'text/plain',
          'text/markdown',
          'text/x-markdown'
        ]

        if (allowedTypes.includes(file.type) ||
            file.name.match(/\.(pdf|doc|docx|txt|md)$/i)) {
          this.selectedFile = file
          this.documentTitle = file.name.replace(/\.[^/.]+$/, "")
        } else {
          ElMessage.error(this.$t('requirementAnalysis.invalidFileFormatDetail'))
        }
      }
    },

    removeFile() {
      this.selectedFile = null
      this.documentTitle = ''
      this.$refs.fileInput.value = ''
    },

    formatFileSize(bytes) {
      if (bytes === 0) return '0 Bytes'
      const k = 1024
      const sizes = ['Bytes', 'KB', 'MB', 'GB']
      const i = Math.floor(Math.log(bytes) / Math.log(k))
      return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i]
    },

    async generateFromManualInput() {
      if (!this.canGenerateManual) {
        ElMessage.error(this.$t('requirementAnalysis.fillRequiredInfo'))
        return
      }

      const requirementText = `${this.$t('requirementAnalysis.requirementTitle')}: ${this.manualInput.title}\n\n${this.$t('requirementAnalysis.requirementDescription')}:\n${this.manualInput.description}`

      await this.startGeneration(
        this.manualInput.title,
        requirementText,
        this.manualInput.selectedProject,
        this.globalOutputMode,  // 使用全局输出模式
        this.manualInput.testCaseCount  // 期望用例数量
      )
    },

    async generateFromDocument() {
      if (!this.selectedFile || !this.documentTitle) {
        ElMessage.error(this.$t('requirementAnalysis.selectFileAndTitle'))
        return
      }

      try {
        // 首先上传并提取文档内容
        const formData = new FormData()
        formData.append('title', this.documentTitle)
        formData.append('file', this.selectedFile)
        if (this.selectedProject) {
          formData.append('project', this.selectedProject)
        }

        ElMessage.info(this.$t('requirementAnalysis.extractingContent'))
        const uploadResponse = await api.post('/requirement-analysis/documents/', formData, {
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        })

        // 提取文档内容
        const extractResponse = await api.get(`/requirement-analysis/documents/${uploadResponse.data.id}/extract_text/`)
        const extractedText = extractResponse.data.extracted_text

        if (!extractedText || extractedText.trim().length === 0) {
          ElMessage.error(this.$t('requirementAnalysis.extractionFailed'))
          return
        }

        const requirementText = `${this.$t('requirementAnalysis.documentTitle')}: ${this.documentTitle}\n\n${this.$t('requirementAnalysis.documentContent')}:\n${extractedText}`

        await this.startGeneration(
          this.documentTitle,
          requirementText,
          this.selectedProject,
          this.globalOutputMode  // 使用全局输出模式
        )

      } catch (error) {
        console.error(this.$t('requirementAnalysis.documentProcessingFailed'), error)
        ElMessage.error(this.$t('requirementAnalysis.documentProcessingFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    async startGeneration(title, requirementText, projectId, outputMode = 'stream', testCaseCount = null) {
      // 在开始生成前，主动刷新token确保生成过程中不会过期
      try {
        const userStore = useUserStore()
        if (userStore.isTokenExpiringSoon && userStore.refreshToken) {
          console.log('Refreshing token before generation...')
          await userStore.refreshAccessToken()
          console.log('Token refreshed successfully, safe to start generation')
        } else if (userStore.accessToken) {
          console.log('Token status is good, no refresh needed')
        }
      } catch (error) {
        console.error('Token refresh failed:', error)
        ElMessage.error(this.$t('requirementAnalysis.tokenRefreshFailed'))
        return
      }

      this.isGenerating = true
      this.currentStep = 1
      this.progressText = this.$t('requirementAnalysis.creatingTask')
      this.streamedContent = ''  // 清空流式内容
      this.finalTestCases = ''  // 清空最终版用例
      this.streamedReviewContent = ''  // 清空评审内容
      this.hasShownCompletionMessage = false  // 重置完成消息标志位
      this._fetchingFinalResult = false  // 重置fetchFinalResult锁
      this._sseReconnectCount = 0  // 重置SSE重连计数
      this.showResults = false  // 隐藏上一次的结果

      try {
        // 调用新的生成API
        const requestData = {
          title: title,
          requirement_text: requirementText,
          use_writer_model: true,
          use_reviewer_model: true,
          output_mode: outputMode  // 添加输出模式参数
        }

        // 如果选择了项目，添加到请求中
        if (projectId) {
          requestData.project = projectId
        }

        // 如果指定了用例数量，添加到请求中
        if (testCaseCount) {
          requestData.test_case_count = testCaseCount
        }

        const response = await api.post('/requirement-analysis/testcase-generation/generate', requestData)

        this.currentTaskId = response.data.task_id
        this.progressText = this.$t('requirementAnalysis.taskCreated')

        ElMessage.success(this.$t('requirementAnalysis.generateSuccess'))

        // 根据输出模式选择不同的进度获取方式
        if (outputMode === 'stream') {
          this.startStreamingProgress()
        } else {
          this.startPolling()
        }

      } catch (error) {
        console.error(this.$t('requirementAnalysis.createTaskFailed'), error)
        ElMessage.error(this.$t('requirementAnalysis.createTaskFailed') + ': ' + (error.response?.data?.error || error.message))
        this.isGenerating = false
      }
    },

    startStreamingProgress() {
      // 使用SSE进行流式进度获取
      // EventSource 不支持自定义 headers，通过 query 参数传递 token

      // 重连时清除缓冲区（新连接会从头发送所有数据，避免重复）
      if (this.streamedContent || this.streamedReviewContent || this.finalTestCases) {
        console.log('[SSE] 重连模式，清除已有缓冲区内容')
        this.streamedContent = ''
        this.streamedReviewContent = ''
        this.finalTestCases = ''
      }

      const currentOrigin = window.location.origin
      const token = localStorage.getItem('access_token') || ''
      const apiUrl = `${currentOrigin}/api/requirement-analysis/testcase-generation/${this.currentTaskId}/stream_progress?token=${encodeURIComponent(token)}`

      console.log('SSE连接URL:', apiUrl)

      this.eventSource = new EventSource(apiUrl)

      // 监听连接打开事件
      this.eventSource.onopen = (event) => {
        console.log('SSE连接已打开', event)
      }

      this.eventSource.onmessage = (event) => {
        console.log('[SSE] 收到消息:', event.data)

        try {
          const data = JSON.parse(event.data)
          console.log('[SSE] 解析后的数据:', data)

          if (data.type === 'progress') {
            // Update progress status
            if (data.status === 'generating') {
              this.currentStep = 2
              this.progressText = `${this.$t('requirementAnalysis.statusGenerating')} ${data.progress}%`
            } else if (data.status === 'reviewing') {
              this.currentStep = 3
              this.progressText = `${this.$t('requirementAnalysis.statusReviewing')} ${data.progress}%`
            } else if (data.status === 'revising') {
              this.currentStep = 3
              this.progressText = `${this.$t('requirementAnalysis.statusRevising')} ${data.progress}%`
            }
          } else if (data.type === 'content') {
            // Real-time streaming content (case generation)
            console.log('[SSE] 收到流式内容:', data.content.length, '字符')
            this.streamedContent += data.content
            this.currentStep = 2
            this.progressText = this.$t('requirementAnalysis.statusGenerating')
          } else if (data.type === 'review_content') {
            // Real-time review content
            console.log('[SSE] 收到审核内容:', data.content.length, '字符', '总长度:', this.streamedReviewContent.length + data.content.length)
            this.streamedReviewContent += data.content
            this.currentStep = 3
            this.progressText = this.$t('requirementAnalysis.statusReviewing')
          } else if (data.type === 'final_content') {
            // Real-time final test cases content
            console.log('[SSE] 收到最终用例内容:', data.content.length, '字符', '总长度:', this.finalTestCases.length + data.content.length)
            this.finalTestCases += data.content
            this.currentStep = 3
            this.progressText = this.$t('requirementAnalysis.statusRevising')
          } else if (data.type === 'status') {
            // Final status
            console.log('[SSE] 收到状态更新:', data.status)
            if (data.status === 'completed') {
              this.currentStep = 4
              this.progressText = this.$t('requirementAnalysis.statusCompleted')
              // Fetch final result
              this.fetchFinalResult()
            } else if (data.status === 'failed') {
              this.currentStep = 4
              this.progressText = this.$t('requirementAnalysis.statusFailed')
              this.handleGenerationError(data.error_message)
            }
          } else if (data.type === 'done') {
            // 流式结束，立即关闭EventSource，获取最终结果
            console.log('流式传输完成')
            if (this.eventSource) {
              console.log('关闭SSE连接')
              this.eventSource.close()
              this.eventSource = null
            }
            this.fetchFinalResult()
          }
        } catch (e) {
          console.error('解析SSE数据失败:', e, '原始数据:', event.data)
        }
      }

      this.eventSource.onerror = (error) => {
        console.log('SSE连接事件:', error)

        // 如果EventSource已经被关闭（在onmessage中关闭的），不做任何处理
        if (!this.eventSource) {
          console.log('[SSE] EventSource已关闭，忽略错误事件')
          return
        }

        console.log('EventSource状态:', {
          readyState: this.eventSource.readyState,
          url: this.eventSource.url
        })

        // 如果任务已经完成或不在生成中，不要重连
        if (this.showResults || !this.isGenerating) {
          console.log('[SSE] 任务已完成或不在生成中，关闭连接')
          if (this.eventSource) {
            this.eventSource.close()
            this.eventSource = null
          }
          return
        }

        // 关闭旧连接，手动重连（刷新token）
        // 浏览器自动重连会使用相同的URL（含过期token），导致401
        if (this.eventSource) {
          this.eventSource.close()
          this.eventSource = null
        }

        this._sseReconnectCount++
        console.log(`[SSE] 连接断开 (第${this._sseReconnectCount}次)，刷新token后重连...`)

        // 超过3次重连失败，降级到轮询
        if (this._sseReconnectCount > 3) {
          console.error('[SSE] 重连次数过多，降级到轮询模式')
          ElMessage.warning(this.$t('requirementAnalysis.streamConnectionInterrupted'))
          this.startPolling()
          return
        }

        const userStore = useUserStore()
        if (userStore.isTokenExpired && userStore.refreshToken) {
          userStore.refreshAccessToken().then(() => {
            console.log('[SSE] Token刷新成功，重新建立SSE连接')
            if (this.isGenerating && !this.showResults) {
              this.startStreamingProgress()
            }
          }).catch((err) => {
            console.error('[SSE] Token刷新失败，降级到轮询:', err)
            ElMessage.warning(this.$t('requirementAnalysis.streamConnectionInterrupted'))
            this.startPolling()
          })
        } else {
          // Token未过期，可能是网络问题，直接重连
          if (this.isGenerating && !this.showResults) {
            this.startStreamingProgress()
          }
        }
      }
    },

    async fetchFinalResult() {
      // 防止重复调用
      if (this._fetchingFinalResult) {
        console.log('[fetchFinalResult] 已在执行中，跳过')
        return
      }
      this._fetchingFinalResult = true

      try {
        // api.js拦截器会自动处理401并刷新token，这里直接调用即可
        const response = await api.get(`/requirement-analysis/testcase-generation/${this.currentTaskId}/progress`)
        const task = response.data

        this.generationResult = task
        this.showResults = true
        this.isGenerating = false

        // 设置第4步为完成状态
        this.currentStep = 4

        // 设置最终版用例（如果还没有通过流式接收完整）
        if (task.final_test_cases) {
          console.log('[Task] 从task对象获取最终用例')
          this.finalTestCases = task.final_test_cases
        }

        // 如果评审内容为空，从task对象中获取
        if (!this.streamedReviewContent && task.review_feedback) {
          console.log('[Task] 从task对象获取审核内容')
          this.streamedReviewContent = task.review_feedback
        }

        // 如果生成内容为空，从task对象中获取
        if (!this.streamedContent && task.generated_test_cases) {
          console.log('[Task] 从task对象获取生成内容')
          this.streamedContent = task.generated_test_cases
        }

        if (this.eventSource) {
          this.eventSource.close()
          this.eventSource = null
        }

        // Only show completion message once
        if (!this.hasShownCompletionMessage) {
          ElMessage.success(this.$t('requirementAnalysis.generateCompleteSuccess'))
          this.hasShownCompletionMessage = true
        }
      } catch (error) {
        console.error('Failed to fetch final result:', error)
        // API获取失败（如token过期），但SSE数据已收到，仍然展示结果
        // 不要回到输入表单页面
        this.showResults = true
        this.isGenerating = false
        this.currentStep = 4
        if (!this.generationResult) {
          // 构造一个最小的generationResult用于展示
          this.generationResult = {
            task_id: this.currentTaskId,
            status: 'completed',
            progress: 100,
            final_test_cases: this.finalTestCases,
            review_feedback: this.streamedReviewContent,
            generated_test_cases: this.streamedContent
          }
        }
        if (!this.hasShownCompletionMessage) {
          ElMessage.warning(this.$t('requirementAnalysis.fetchResultFailed') || '获取完整结果失败，已展示流式接收的内容')
          this.hasShownCompletionMessage = true
        }
      } finally {
        this._fetchingFinalResult = false
      }
    },

    handleGenerationError(errorMessage) {
      this.isGenerating = false
      if (this.eventSource) {
        this.eventSource.close()
        this.eventSource = null
      }
      if (this.pollInterval) {
        clearInterval(this.pollInterval)
        this.pollInterval = null
      }
      // 展示友好的错误提示
      const msg = errorMessage || this.$t('requirementAnalysis.unknownError') || '未知错误'
      ElMessage.error(this.$t('requirementAnalysis.generateFailed') + ': ' + msg)
    },

    startPolling() {
      this.pollInterval = setInterval(async () => {
        try {
          // 修复URL：去掉多余的/api/前缀（axios baseURL已经包含/api）
          const response = await api.get(`/requirement-analysis/testcase-generation/${this.currentTaskId}/progress`)
          const task = response.data

          console.log(`${this.$t('requirementAnalysis.taskStatus')}: ${task.status}, ${this.$t('requirementAnalysis.progress')}: ${task.progress}%`)

          // 更新进度显示
          if (task.status === 'generating') {
            this.currentStep = 2
            this.progressText = this.$t('requirementAnalysis.statusGenerating')
          } else if (task.status === 'reviewing') {
            this.currentStep = 3
            this.progressText = this.$t('requirementAnalysis.statusReviewing')
          } else if (task.status === 'completed') {
            this.currentStep = 4
            this.progressText = this.$t('requirementAnalysis.statusCompleted')

            // 任务完成，显示结果
            this.generationResult = task
            this.showResults = true
            this.isGenerating = false

            // 设置显示内容（完整输出模式下需要）
            if (task.generated_test_cases) {
              console.log('[Polling] 设置生成内容')
              this.streamedContent = task.generated_test_cases
            }
            if (task.review_feedback) {
              console.log('[Polling] 设置审核内容')
              this.streamedReviewContent = task.review_feedback
            }
            if (task.final_test_cases) {
              console.log('[Polling] 设置最终用例')
              this.finalTestCases = task.final_test_cases
            }

            clearInterval(this.pollInterval)
            this.pollInterval = null

            // 只显示一次完成消息
            if (!this.hasShownCompletionMessage) {
              ElMessage.success(this.$t('requirementAnalysis.generateCompleteSuccess'))
              this.hasShownCompletionMessage = true
            }
            return
          } else if (task.status === 'failed') {
            this.progressText = this.$t('requirementAnalysis.statusFailed')
            this.isGenerating = false

            clearInterval(this.pollInterval)
            this.pollInterval = null

            ElMessage.error(this.$t('requirementAnalysis.generateFailed') + ': ' + (task.error_message || this.$t('requirementAnalysis.unknownError')))
            return
          }

        } catch (error) {
          console.error(this.$t('requirementAnalysis.checkProgressFailed'), error)
          // 继续轮询，不中断
        }
      }, 3000) // 每3秒检查一次
    },

    cancelGeneration() {
      if (this.pollInterval) {
        clearInterval(this.pollInterval)
        this.pollInterval = null
      }
      this.isGenerating = false
      this.currentTaskId = null
      ElMessage.info(this.$t('requirementAnalysis.generationCancelled'))
    },

    // 下载测试用例为xlsx文件
    async downloadTestCases() {
      try {
        // 解析最终测试用例内容
        const finalTestCases = this.generationResult.final_test_cases;
        const taskId = this.generationResult.task_id;

        // 创建工作簿
        const workbook = XLSX.utils.book_new();

        // 过滤掉总结和建议部分，只保留测试用例内容
        const filteredContent = this.filterTestCasesOnly(finalTestCases);

        let worksheetData = [];

        // 优先尝试解析JSON格式
        const jsonCases = this.parseJsonTestCases(filteredContent);
        if (jsonCases && jsonCases.length > 0) {
          worksheetData.push([
            this.$t('requirementAnalysis.excelTestCaseNumber'),
            this.$t('requirementAnalysis.excelTestScenario'),
            this.$t('requirementAnalysis.excelPriority'),
            this.$t('requirementAnalysis.excelPrecondition'),
            this.$t('requirementAnalysis.excelTestSteps'),
            this.$t('requirementAnalysis.excelExpectedResult')
          ]);
          jsonCases.forEach((tc, index) => {
            worksheetData.push([
              tc.case_id || tc.caseid || tc.caseId || tc.id || `TC${index + 1}`,
              tc.title || tc.name || '',
              tc.priority || 'P1',
              tc.precondition || tc.pre_conditions || '',
              tc.test_steps || tc.steps || tc.testSteps || '',
              tc.expected_result || tc.expected || tc.expectedResult || ''
            ]);
          });
        } else {
          // 尝试解析表格格式的测试用例
          const tableFormat = this.parseTableFormat(filteredContent);

          if (tableFormat.length > 0) {
            worksheetData = tableFormat;

            // 检查并修正表头
            if (worksheetData.length > 0) {
              const header = worksheetData[0];
              for (let i = 0; i < header.length; i++) {
                if (header[i] && header[i].includes('测试步骤')) {
                  header[i] = header[i].replace('测试步骤', '操作步骤');
                }
                if (header[i] && header[i].includes('Test Steps')) {
                  header[i] = header[i].replace('Test Steps', '操作步骤');
                }
              }
            }
          } else {
            // 否则尝试解析结构化格式
            worksheetData = this.parseStructuredFormat(filteredContent);
          }
        }

        // 将所有单元格中的<br>标签转换为换行符
        worksheetData = worksheetData.map(row =>
          row.map(cell => this.convertBrToNewline(cell))
        );

        // 创建工作表
        const worksheet = XLSX.utils.aoa_to_sheet(worksheetData);

        // 设置列宽
        const colWidths = [
          { wch: 15 }, // 测试用例编号
          { wch: 30 }, // 测试场景
          { wch: 25 }, // 前置条件
          { wch: 40 }, // 操作步骤
          { wch: 30 }, // 预期结果
          { wch: 10 }  // 优先级
        ];
        worksheet['!cols'] = colWidths;

        // 设置表头样式（加粗）
        if (worksheetData.length > 1) {
          for (let col = 0; col < Math.min(6, worksheetData[0].length); col++) {
            const cellAddress = XLSX.utils.encode_cell({ r: 0, c: col });
            if (!worksheet[cellAddress]) continue;
            worksheet[cellAddress].s = {
              font: { bold: true },
              alignment: { horizontal: 'center', vertical: 'center', wrapText: true }
            };
          }

          // 设置自动换行
          for (let row = 1; row < worksheetData.length; row++) {
            for (let col = 0; col < Math.min(6, worksheetData[row].length); col++) {
              const cellAddress = XLSX.utils.encode_cell({ r: row, c: col });
              if (worksheet[cellAddress]) {
                worksheet[cellAddress].s = {
                  alignment: { vertical: 'top', wrapText: true }
                };
              }
            }
          }
        }

        // 将工作表添加到工作簿
        XLSX.utils.book_append_sheet(workbook, worksheet, this.$t('requirementAnalysis.testCaseSheetName'));

        // 生成文件名（包含任务ID和日期）
        const fileName = this.$t('requirementAnalysis.excelFileName', { taskId: taskId, date: new Date().toISOString().slice(0, 10) });

        // 导出文件
        XLSX.writeFile(workbook, fileName);

        ElMessage.success(this.$t('requirementAnalysis.downloadSuccess'));
      } catch (error) {
        console.error(this.$t('requirementAnalysis.downloadFailed'), error);
        ElMessage.error(this.$t('requirementAnalysis.downloadFailed') + ': ' + (error.message || this.$t('requirementAnalysis.unknownError')));
      }
    },

    // 保存到用例记录
    async saveToTestCaseRecords() {
      try {
        // 调用后端API保存到记录
        const response = await api.post(`/requirement-analysis/testcase-generation/${this.generationResult.task_id}/save_to_records`)

        if (response.data.already_saved) {
          ElMessage.info(this.$t('requirementAnalysis.alreadySaved'))
        } else {
          const importedCount = response.data.imported_count || 0
          ElMessage.success(`测试用例已保存！已导入 ${importedCount} 条测试用例到测试用例管理系统`)
        }

        // 不跳转，留在当前页面
        // this.$router.push('/generated-testcases')
      } catch (error) {
        console.error(this.$t('requirementAnalysis.saveFailed'), error)
        ElMessage.error(this.$t('requirementAnalysis.saveFailed') + ': ' + (error.response?.data?.error || error.message))
      }
    },

    resetGeneration() {
      // 重置生成状态
      this.isGenerating = false;
      this.currentTaskId = null;
      this.progressText = this.$t('requirementAnalysis.preparing');
      this.currentStep = 0;
      this.showResults = false;
      this.generationResult = null;

      // 清空流式内容和最终版用例
      this.streamedContent = '';
      this.streamedReviewContent = '';
      this.finalTestCases = '';

      if (this.pollInterval) {
        clearInterval(this.pollInterval);
        this.pollInterval = null;
      }

      // 刷新页面以获取最新的配置
      window.location.reload();
    },

    // 格式化日期时间
    formatDateTime(dateTimeString) {
      if (!dateTimeString) return '';
      const date = new Date(dateTimeString);
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      const hours = String(date.getHours()).padStart(2, '0');
      const minutes = String(date.getMinutes()).padStart(2, '0');
      return `${year}-${month}-${day} ${hours}:${minutes}`;
    },

    // 格式化Markdown为HTML（简化版）
    formatMarkdown(content) {
      if (!content) return '';

      // 先去除"新增"标记，在markdown转换之前处理
      // 这样可以避免markdown转换后无法匹配的问题
      let html = content
          .replace(/\*\*新增\*\*-/g, '')  // **新增**-xxx -> xxx (保留xxx的原有格式)
          .replace(/新增-/g, '');  // 新增-xxx -> xxx (保留xxx的原有格式)

      // 转义HTML特殊字符
      html = html
          .replace(/&/g, '&amp;')
          .replace(/</g, '&lt;')
          .replace(/>/g, '&gt;');

      // 转换Markdown语法
      // 标题 #
      html = html.replace(/^#{6}\s+(.+)$/gm, '<h6>$1</h6>');
      html = html.replace(/^#{5}\s+(.+)$/gm, '<h5>$1</h5>');
      html = html.replace(/^#{4}\s+(.+)$/gm, '<h4>$1</h4>');
      html = html.replace(/^#{3}\s+(.+)$/gm, '<h3>$1</h3>');
      html = html.replace(/^#{2}\s+(.+)$/gm, '<h2>$1</h2>');
      html = html.replace(/^#{1}\s+(.+)$/gm, '<h1>$1</h1>');

      // 粗体 **text** 或 __text__
      html = html.replace(/\*\*(.+?)\*\*/g, '<strong>$1</strong>');
      html = html.replace(/__(.+?)__/g, '<strong>$1</strong>');

      // 斜体 *text* 或 _text_
      html = html.replace(/\*(.+?)\*/g, '<em>$1</em>');
      html = html.replace(/_(.+?)_/g, '<em>$1</em>');

      // 代码块 ```code```
      html = html.replace(/```([\s\S]+?)```/g, '<pre><code>$1</code></pre>');

      // 行内代码 `code`
      html = html.replace(/`([^`]+)`/g, '<code>$1</code>');

      // 换行符转换为<br>
      html = html.replace(/\n/g, '<br>');

      return html;
    },

    // 从内容中解析JSON测试用例数组（支持多个代码块合并，自动去重）
    parseJsonTestCases(content) {
      if (!content) return null;

      const allCases = [];
      const seenIds = new Set();

      const addUnique = (cases) => {
        cases.forEach(tc => {
          const id = tc.case_id || tc.caseid || tc.caseId || tc.id;
          if (id && seenIds.has(id)) return;
          if (id) seenIds.add(id);
          allCases.push(tc);
        });
      };

      // 尝试1: 从 ```json ... ``` 代码块中提取
      // 使用贪婪匹配 [\s\S]*? 但在代码块内不会有 ``` 所以是安全的
      const codeBlockRegex = /```json\s*([\s\S]*?)```/g;
      let codeMatch;
      while ((codeMatch = codeBlockRegex.exec(content)) !== null) {
        try {
          const parsed = JSON.parse(codeMatch[1].trim());
          if (Array.isArray(parsed)) {
            addUnique(parsed);
          }
        } catch (e) { /* 该代码块JSON不完整，跳过 */ }
      }
      if (allCases.length > 0) return allCases;

      // 尝试2: 用括号计数算法提取JSON数组（处理大型嵌套JSON）
      const findJsonArrays = (text) => {
        const results = [];
        let i = 0;
        while (i < text.length) {
          if (text[i] === '[') {
            let depth = 0;
            let inString = false;
            let escaped = false;
            let start = i;
            for (let j = i; j < text.length; j++) {
              const c = text[j];
              if (escaped) { escaped = false; continue; }
              if (c === '\\') { escaped = true; continue; }
              if (c === '"') { inString = !inString; continue; }
              if (inString) continue;
              if (c === '[') depth++;
              else if (c === ']') {
                depth--;
                if (depth === 0) {
                  results.push(text.substring(start, j + 1));
                  i = j + 1;
                  break;
                }
              }
            }
            if (depth !== 0) i++;
          } else {
            i++;
          }
        }
        return results;
      };

      const arrays = findJsonArrays(content);
      for (const arr of arrays) {
        try {
          const parsed = JSON.parse(arr);
          if (Array.isArray(parsed) && parsed.length > 0 && typeof parsed[0] === 'object') {
            addUnique(parsed);
          }
        } catch (e) { /* JSON不完整，跳过 */ }
      }
      if (allCases.length > 0) return allCases;

      return null;
    },

    // 将测试用例数组渲染为HTML表格
    renderTestCaseTable(testCases) {
      if (!testCases || testCases.length === 0) return '';

      const priorityColors = {
        'P0': '#e74c3c', 'P1': '#e67e22', 'P2': '#f1c40f', 'P3': '#95a5a6',
        'High': '#e74c3c', 'Medium': '#e67e22', 'Low': '#f1c40f'
      };

      let html = '<div class="tc-table-wrapper"><table class="tc-table">';
      html += `<thead><tr>
        <th class="tc-col-id">用例编号</th>
        <th class="tc-col-title">标题</th>
        <th class="tc-col-priority">优先级</th>
        <th class="tc-col-precondition">前置条件</th>
        <th class="tc-col-steps">测试步骤</th>
        <th class="tc-col-expected">预期结果</th>
      </tr></thead><tbody>`;

      testCases.forEach((tc, index) => {
        const caseId = tc.case_id || tc.caseid || tc.caseId || tc.id || `TC${index + 1}`;
        const title = tc.title || tc.name || '';
        const priority = tc.priority || 'P1';
        const precondition = tc.precondition || tc.pre_conditions || '';
        const steps = tc.test_steps || tc.steps || tc.testSteps || '';
        const expected = tc.expected_result || tc.expected || tc.expectedResult || '';

        const pColor = priorityColors[priority] || '#95a5a6';

        html += `<tr>
          <td class="tc-col-id">${this.escapeHtml(caseId)}</td>
          <td class="tc-col-title">${this.escapeHtml(title)}</td>
          <td class="tc-col-priority"><span class="tc-priority-badge" style="background:${pColor}">${this.escapeHtml(priority)}</span></td>
          <td class="tc-col-precondition">${this.formatCellContent(precondition)}</td>
          <td class="tc-col-steps">${this.formatCellContent(steps)}</td>
          <td class="tc-col-expected">${this.formatCellContent(expected)}</td>
        </tr>`;
      });

      html += '</tbody></table></div>';
      html += `<div class="tc-table-footer">共 ${testCases.length} 条测试用例</div>`;
      return html;
    },

    // 格化单元格内容（换行转<br>）
    formatCellContent(text) {
      if (!text) return '';
      return this.escapeHtml(text).replace(/\n/g, '<br>');
    },

    // HTML转义
    escapeHtml(text) {
      if (!text) return '';
      const div = document.createElement('div');
      div.textContent = text;
      return div.innerHTML;
    },

    // 渲染测试用例内容（优先表格，降级为markdown）
    renderTestCaseContent(content) {
      if (!content) return '';

      // 尝试解析为JSON表格
      const testCases = this.parseJsonTestCases(content);
      if (testCases) {
        return this.renderTestCaseTable(testCases);
      }

      // 降级：使用markdown渲染
      return this.formatMarkdown(content);
    },

    // 将HTML的<br>标签转换为换行符（用于Excel导出）
    convertBrToNewline(text) {
      if (text == null) return '';
      // 确保是字符串类型
      const str = String(text);
      return str.replace(/<br\s*\/?>/gi, '\n');
    },

    // 过滤掉总结和建议部分，只保留测试用例内容
    filterTestCasesOnly(content) {
      if (!content) return '';

      const lines = content.split('\n');
      const filteredLines = [];
      let inTestCaseSection = true;

      for (let line of lines) {
        const trimmedLine = line.trim();

        // 检查是否到了总结或建议部分
        if (trimmedLine.includes('总结') ||
            trimmedLine.includes('建议') ||
            trimmedLine.includes('Summary') ||
            trimmedLine.includes('Recommendation') ||
            trimmedLine.includes('最后') ||
            trimmedLine.includes('补充说明')) {
          inTestCaseSection = false;
          break;
        }

        if (inTestCaseSection) {
          filteredLines.push(line);
        }
      }

      return filteredLines.join('\n');
    },

    // 解析表格格式的测试用例（参考AutoGenTestCase的做法）
    parseTableFormat(content) {
      if (!content) return [];

      const lines = content.split('\n').filter(line => line.trim());
      const worksheetData = [];

      for (let line of lines) {
        const trimmedLine = line.trim();

        // 检查是否是表格行（包含|分隔符，且不是分隔线）
        if (trimmedLine.includes('|') && !trimmedLine.includes('--------')) {
          const cells = trimmedLine.split('|').map(cell => cell.trim()).filter(cell => cell);
          if (cells.length > 1) {
            worksheetData.push(cells);
          }
        }
      }

      return worksheetData;
    },

    // 解析结构化格式的测试用例
    parseStructuredFormat(content) {
      if (!content) return [];

      const lines = content.split('\n').filter(line => line.trim());
      const worksheetData = [];

      // 添加表头
      worksheetData.push([
        this.$t('requirementAnalysis.excelTestCaseNumber'),
        this.$t('requirementAnalysis.excelTestScenario'),
        this.$t('requirementAnalysis.excelPrecondition'),
        this.$t('requirementAnalysis.excelTestSteps'),
        this.$t('requirementAnalysis.excelExpectedResult'),
        this.$t('requirementAnalysis.excelPriority')
      ]);

      let currentTestCase = {};
      let testCaseNumber = 1;
      let i = 0;

      while (i < lines.length) {
        const line = lines[i].trim();

        // 识别测试用例开始标志
        if (line.includes('测试用例') || line.includes('Test Case') ||
            line.match(/^(\d+\.|\*|\-|\d+、)/)) {

          // 如果之前有测试用例数据，先保存
          if (Object.keys(currentTestCase).length > 0) {
            worksheetData.push([
              currentTestCase.number || `TC${testCaseNumber}`,
              currentTestCase.scenario || '',
              currentTestCase.precondition || '',
              currentTestCase.steps || '',
              currentTestCase.expected || '',
              currentTestCase.priority || '中'
            ]);
            testCaseNumber++;
          }

          // 开始新的测试用例
          currentTestCase = {
            number: `TC${testCaseNumber}`,
            scenario: line.replace(/^(\d+\.|\*|\-|\d+、)\s*/, '').replace(/测试用例\d*[:：]?\s*/, ''),
            precondition: '',
            steps: '',
            expected: '',
            priority: '中'
          };
          i++;
        }
        // 识别前置条件
        else if (line.includes('前置条件') || line.includes('前提') ||
            line.includes('Precondition')) {
          let precondition = line.replace(/.*?[:：]\s*/, '');
          // 收集后续的前置条件行
          i++;
          while (i < lines.length) {
            const nextLine = lines[i].trim();
            if (nextLine.includes('测试步骤') || nextLine.includes('操作步骤') ||
                nextLine.includes('Test Steps') || nextLine.includes('步骤') ||
                nextLine.includes('预期结果') || nextLine.includes('Expected') ||
                nextLine.includes('优先级') || nextLine.includes('Priority') ||
                nextLine.includes('测试用例') || nextLine.includes('Test Case') ||
                nextLine.match(/^(\d+\.|\*|\-|\d+、)/)) {
              break;
            }
            if (nextLine) {
              precondition += '\n' + nextLine;
            }
            i++;
          }
          currentTestCase.precondition = precondition;
        }
        // 识别测试步骤
        else if (line.includes('测试步骤') || line.includes('操作步骤') ||
            line.includes('Test Steps') || line.includes('步骤')) {
          let steps = line.replace(/.*?[:：]\s*/, '');
          // 收集后续的步骤行
          i++;
          while (i < lines.length) {
            const nextLine = lines[i].trim();
            if (nextLine.includes('预期结果') || nextLine.includes('Expected') ||
                nextLine.includes('优先级') || nextLine.includes('Priority') ||
                nextLine.includes('测试用例') || nextLine.includes('Test Case') ||
                nextLine.match(/^(\d+\.|\*|\-|\d+、)/)) {
              break;
            }
            if (nextLine) {
              steps += '\n' + nextLine;
            }
            i++;
          }
          currentTestCase.steps = steps;
        }
        // 识别预期结果
        else if (line.includes('预期结果') || line.includes('Expected') ||
            line.includes('期望')) {
          let expected = line.replace(/.*?[:：]\s*/, '');
          // 收集后续的结果行
          i++;
          while (i < lines.length) {
            const nextLine = lines[i].trim();
            if (nextLine.includes('优先级') || nextLine.includes('Priority') ||
                nextLine.includes('测试用例') || nextLine.includes('Test Case') ||
                nextLine.match(/^(\d+\.|\*|\-|\d+、)/)) {
              break;
            }
            if (nextLine) {
              expected += '\n' + nextLine;
            }
            i++;
          }
          currentTestCase.expected = expected;
        }
        // 识别优先级
        else if (line.includes('优先级') || line.includes('Priority')) {
          currentTestCase.priority = line.replace(/.*?[:：]\s*/, '');
          i++;
        }
        // 如果是没有明确标识的行，可能是场景描述的延续
        else if (Object.keys(currentTestCase).length > 0 &&
            !currentTestCase.steps && !currentTestCase.expected &&
            !currentTestCase.precondition) {
          if (currentTestCase.scenario && line.length > 5) {
            currentTestCase.scenario += '\n' + line;
          }
          i++;
        } else {
          i++;
        }
      }

      // 保存最后一个测试用例
      if (Object.keys(currentTestCase).length > 0) {
        worksheetData.push([
          currentTestCase.number || `TC${testCaseNumber}`,
          currentTestCase.scenario || '',
          currentTestCase.precondition || '',
          currentTestCase.steps || '',
          currentTestCase.expected || '',
          currentTestCase.priority || '中'
        ]);
      }

      // 如果没有解析到结构化数据，则按原格式输出
      if (worksheetData.length <= 1) {
        worksheetData.length = 0; // 清空
        worksheetData.push([this.$t('requirementAnalysis.testCaseContent')]);
        content.split('\n').forEach((line, index) => {
          if (line.trim()) {
            worksheetData.push([line.trim()]);
          }
        });
      }

      return worksheetData;
    }
  }
}
</script>

<style scoped>
.requirement-analysis {
  padding: 20px;
  max-width: 1200px;
  margin: 0 auto;
  position: relative;
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

.output-mode-section {
  margin-bottom: 30px;
}

.output-mode-card {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 24px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  transition: border-color var(--th-transition-base, 0.2s ease), box-shadow var(--th-transition-base, 0.2s ease);
}

.output-mode-card:hover {
  border-color: var(--th-border-hover, #d0d0d0);
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
}

.output-mode-card h3 {
  font-size: var(--th-font-size-xl, 18px);
  color: var(--th-text-primary, #1a1a1a);
  margin: 0 0 8px 0;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 8px;
}

.mode-section-desc {
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-sm, 13px);
  margin: 0 0 16px 0;
  line-height: 1.5;
}

.modal-overlay {
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  background: rgba(0, 0, 0, 0.45) !important;
  backdrop-filter: blur(4px);
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  z-index: 9999 !important;
  padding: 20px;
  margin: 0 !important;
  opacity: 1 !important;
}

.guide-config-modal {
  background: var(--th-bg-primary, #fff) !important;
  border-radius: var(--th-radius-xl, 12px);
  padding: 32px;
  max-width: 850px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
  border: 1px solid var(--th-border, #e5e5e5);
  position: relative;
  flex-shrink: 0;
  margin: auto;
  opacity: 1 !important;
}

.guide-config-modal::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--th-accent, #1a1a1a);
  border-radius: var(--th-radius-xl, 12px) var(--th-radius-xl, 12px) 0 0;
}

.guide-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 28px;
}

.guide-icon {
  width: 48px;
  height: 48px;
  flex-shrink: 0;
  color: var(--th-text-tertiary, #999);
}

.guide-title h2 {
  font-size: 1.35rem;
  color: var(--th-text-primary, #1a1a1a);
  margin: 0 0 6px 0;
  font-weight: 600;
  letter-spacing: -0.02em;
}

.guide-title p {
  color: var(--th-text-secondary, #666);
  font-size: 0.9rem;
  margin: 0;
  font-weight: 400;
}

.config-groups {
  margin-bottom: 24px;
}

.config-group {
  margin-bottom: 20px;
}

.group-label {
  font-size: 0.8rem;
  color: var(--th-text-tertiary, #999);
  margin-bottom: 12px;
  font-weight: 500;
  text-transform: uppercase;
  letter-spacing: 0.06em;
}

.config-items-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
  gap: 16px;
}

.config-item-inline {
  flex: 1;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 14px 18px;
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
  position: relative;
  overflow: hidden;
  font-weight: 500;
  background: var(--th-bg-secondary, #fafafa);
}

.config-item-inline::before {
  content: '';
  position: absolute;
  left: 0;
  top: 0;
  bottom: 0;
  width: 3px;
  border-radius: var(--th-radius-lg, 8px) 0 0 var(--th-radius-lg, 8px);
}

.config-item-inline.optional {
  opacity: 0.75;
}

.config-item-inline.status-enabled {
  background: var(--th-bg-secondary, #fafafa);
  border-color: var(--th-border, #e5e5e5);
  box-shadow: none;
}

.config-item-inline.status-enabled::before {
  background: var(--th-success, #22c55e);
}

.config-item-inline.status-disabled {
  background: var(--th-bg-secondary, #fafafa);
  border-color: var(--th-border, #e5e5e5);
  box-shadow: none;
}

.config-item-inline.status-disabled::before {
  background: var(--th-warning, #eab308);
}

.config-item-inline.status-unconfigured {
  background: var(--th-bg-secondary, #fafafa);
  border-color: var(--th-border, #e5e5e5);
  box-shadow: none;
}

.config-item-inline.status-unconfigured::before {
  background: var(--th-danger, #ef4444);
}

.status-symbol {
  flex-shrink: 0;
  display: flex;
  align-items: center;
  font-size: 20px;
}

.config-label {
  font-size: 0.9rem;
  color: var(--th-text-primary, #1a1a1a);
  font-weight: 500;
  flex-shrink: 0;
}

.config-name {
  font-size: 0.8rem;
  color: var(--th-text-secondary, #666);
  margin-left: 4px;
  font-weight: 400;
}

.status-text {
  margin-left: auto;
  padding: 4px 10px;
  border-radius: 20px;
  font-size: 0.72rem;
  font-weight: 600;
  background: rgba(239, 68, 68, 0.12);
  color: var(--th-danger, #ef4444);
  white-space: nowrap;
  box-shadow: none;
}

.status-text.warning {
  background: rgba(234, 179, 8, 0.15);
  color: var(--th-warning, #ca8a04);
  box-shadow: none;
}

.guide-actions {
  display: flex !important;
  flex-direction: column !important;
  align-items: center !important;
  gap: 12px;
  margin-top: 30px;
  width: 100%;
}

.guide-actions button {
  flex: none !important;
  width: 240px !important;
  height: 50px !important;
  padding: 0 24px !important;
  border-radius: var(--th-radius-lg, 8px);
  font-size: 0.95rem;
  font-weight: 600;
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  text-align: center;
  white-space: nowrap;
  opacity: 1 !important;
  cursor: pointer;
  box-sizing: border-box !important;
}

.guide-actions .generate-manual-btn {
  background: var(--th-accent, #1a1a1a) !important;
  color: #fff !important;
  border: 1px solid var(--th-accent, #1a1a1a) !important;
  box-shadow: none;
  transition: background 0.2s ease, border-color 0.2s ease;
}

.guide-actions .generate-manual-btn:hover {
  background: var(--th-accent-light, #333) !important;
  border-color: var(--th-accent-light, #333) !important;
}

.guide-actions .skip-action {
  font-size: 0.85rem;
  color: var(--th-text-tertiary, #999);
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  transition: color 0.2s ease;
}

.guide-actions .skip-action:hover {
  color: var(--th-text-primary, #1a1a1a);
  text-decoration: underline;
}

.manual-input-card,
.upload-card {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 24px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  margin-bottom: 30px;
}

.manual-input-card h2,
.upload-card h2 {
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 16px;
  font-size: var(--th-font-size-xl, 18px);
  font-weight: 600;
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

.output-mode-selector {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 12px;
  align-items: stretch;
}

.mode-option {
  position: relative;
  cursor: pointer;
  display: flex;
}

.mode-option input[type="radio"] {
  position: absolute;
  opacity: 0;
  width: 0;
  height: 0;
}

.mode-content {
  border: 2px solid var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-xl, 12px);
  padding: 16px;
  transition: border-color var(--th-transition-base, 0.2s ease), box-shadow var(--th-transition-base, 0.2s ease), background var(--th-transition-base, 0.2s ease);
  background: var(--th-bg-primary, #fff);
  display: flex;
  flex-direction: column;
  justify-content: center;
  width: 100%;
  box-sizing: border-box;
}

.mode-option:hover .mode-content {
  border-color: var(--th-accent, #1a1a1a);
  box-shadow: 0 4px 12px rgba(26, 26, 26, 0.06);
}

.mode-option.active .mode-content {
  border-color: var(--th-accent, #1a1a1a);
  background: var(--th-bg-hover, #f0f0f0);
  box-shadow: none;
}

.mode-title {
  font-size: var(--th-font-size-base, 14px);
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 6px;
}

.mode-desc {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-secondary, #666);
  line-height: 1.4;
}

.mode-option.active .mode-title {
  color: var(--th-text-primary, #1a1a1a);
}

.mode-option.active .mode-desc {
  color: var(--th-text-secondary, #666);
}

.form-input,
.form-select,
.form-textarea {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-md, 6px);
  font-size: var(--th-font-size-sm, 13px);
  background: var(--th-bg-primary, #fff);
  transition: border-color var(--th-transition-base, 0.2s ease);
}

.form-input:focus,
.form-select:focus,
.form-textarea:focus {
  outline: none;
  border-color: var(--th-accent, #1a1a1a);
  box-shadow: 0 0 0 2px rgba(26, 26, 26, 0.08);
}

.form-textarea {
  resize: vertical;
  font-family: inherit;
}

.char-count {
  text-align: right;
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-tertiary, #999);
  margin-top: 5px;
}

.required {
  color: var(--th-danger, #ef4444);
}

.generate-manual-btn,
.generate-btn {
  background: var(--th-success, #22c55e);
  color: #fff;
  border: 1px solid var(--th-success, #22c55e);
  padding: 14px 24px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
  width: 100%;
  margin-top: 10px;
}

.generate-manual-btn:hover:not(:disabled),
.generate-btn:hover:not(:disabled) {
  background: #1a9e4a;
  border-color: #1a9e4a;
}

.generate-manual-btn:disabled,
.generate-btn:disabled {
  opacity: 0.55;
  cursor: not-allowed;
}

.divider {
  text-align: center;
  margin: 40px 0;
  position: relative;
}

.divider::before {
  content: '';
  position: absolute;
  top: 50%;
  left: 0;
  right: 0;
  height: 1px;
  background: var(--th-border, #e5e5e5);
}

.divider span {
  background: var(--th-bg-primary, #fff);
  padding: 0 20px;
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-base, 14px);
}

.upload-area {
  border: 2px dashed var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-lg, 8px);
  padding: 40px;
  text-align: center;
  transition: border-color var(--th-transition-base, 0.2s ease), background var(--th-transition-base, 0.2s ease);
  margin-bottom: 20px;
}

.upload-area.drag-over {
  border-color: var(--th-accent, #1a1a1a);
  background: var(--th-bg-hover, #f5f5f5);
}

.upload-placeholder {
  color: var(--th-text-secondary, #666);
}

.upload-icon {
  font-size: 3rem;
  margin-bottom: 15px;
  display: block;
}

.upload-hint {
  color: var(--th-text-tertiary, #999);
  font-size: var(--th-font-size-sm, 13px);
  margin-top: 5px;
}

.select-file-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  margin-top: 15px;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.select-file-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.file-selected {
  padding: 16px;
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.file-info {
  display: flex;
  align-items: center;
  gap: 15px;
}

.file-icon {
  font-size: 2rem;
}

.file-details {
  flex: 1;
}

.file-name {
  font-weight: 600;
  margin: 0;
  color: var(--th-text-primary, #1a1a1a);
}

.file-size {
  color: var(--th-text-tertiary, #999);
  font-size: var(--th-font-size-sm, 13px);
  margin: 5px 0 0 0;
}

.remove-file {
  background: none;
  border: none;
  cursor: pointer;
  font-size: 1.2rem;
  color: var(--th-text-tertiary, #999);
  padding: 4px;
  border-radius: var(--th-radius-md, 6px);
  transition: color var(--th-transition-base, 0.2s ease);
}

.remove-file:hover {
  color: var(--th-danger, #ef4444);
}

.generation-progress {
  margin: 40px 0;
}

.progress-card {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 24px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  text-align: center;
}

.progress-card h3 {
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  flex-wrap: wrap;
  font-size: var(--th-font-size-lg, 16px);
  font-weight: 600;
}

.current-mode-badge {
  display: inline-block;
  background: var(--th-bg-secondary, #fafafa);
  color: var(--th-text-secondary, #666);
  padding: 4px 12px;
  border-radius: 20px;
  font-size: var(--th-font-size-xs, 12px);
  font-weight: 500;
  margin-left: 8px;
  border: 1px solid var(--th-border, #e5e5e5);
}

.progress-info {
  display: flex;
  justify-content: center;
  gap: 30px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.progress-item {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.progress-item .label {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-secondary, #666);
}

.progress-item .value {
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-base, 14px);
}

.stream-content-display {
  margin: 20px 0;
  border: 1px solid var(--th-border, #e5e5e5);
  border-radius: var(--th-radius-lg, 8px);
  overflow: hidden;
  background: var(--th-bg-primary, #fff);
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
}

.stream-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 16px;
  background: var(--th-bg-secondary, #fafafa);
  border-bottom: 1px solid var(--th-border, #e5e5e5);
}

.stream-title {
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  font-size: var(--th-font-size-sm, 13px);
}

.stream-status {
  font-size: var(--th-font-size-xs, 12px);
  color: var(--th-text-secondary, #666);
  background: var(--th-bg-primary, #fff);
  padding: 4px 10px;
  border-radius: 12px;
  border: 1px solid var(--th-border, #e5e5e5);
}

.stream-content {
  max-height: 400px;
  overflow-y: auto;
  padding: 16px;
  text-align: left;
  background: var(--th-bg-primary, #fff);
  font-size: var(--th-font-size-sm, 13px);
  line-height: 1.6;
  color: var(--th-text-primary, #1a1a1a);
  white-space: pre-wrap;
  word-wrap: break-word;
}

.stream-content::-webkit-scrollbar {
  width: 8px;
}

.stream-content::-webkit-scrollbar-track {
  background: var(--th-bg-secondary, #fafafa);
  border-radius: 4px;
}

.stream-content::-webkit-scrollbar-thumb {
  background: var(--th-border-hover, #d0d0d0);
  border-radius: 4px;
}

.stream-content::-webkit-scrollbar-thumb:hover {
  background: var(--th-text-tertiary, #999);
}

.stream-content.final-testcases {
  background: rgba(26, 26, 26, 0.02);
  border-left: 3px solid var(--th-accent, #1a1a1a);
}

.stream-content.final-testcases::before {
  content: '最终版本';
  display: block;
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 12px;
  padding-bottom: 8px;
  border-bottom: 1px solid var(--th-border, #e5e5e5);
  font-size: var(--th-font-size-sm, 13px);
}

.streaming-indicator {
  font-size: 0.85em;
  margin-left: 8px;
  color: var(--th-success, #22c55e);
  animation: pulse 1.5s ease-in-out infinite;
}

@keyframes pulse {
  0%,
  100% {
    opacity: 1;
  }
  50% {
    opacity: 0.5;
  }
}

.stream-content h1,
.stream-content h2,
.stream-content h3,
.stream-content h4,
.stream-content h5,
.stream-content h6 {
  margin-top: 1em;
  margin-bottom: 0.5em;
  color: var(--th-text-primary, #1a1a1a);
  font-weight: 600;
}

.stream-content code {
  background: var(--th-bg-secondary, #fafafa);
  padding: 2px 6px;
  border-radius: var(--th-radius-md, 6px);
  font-family: 'Courier New', monospace;
  font-size: 0.85em;
  border: 1px solid var(--th-border, #e5e5e5);
}

.stream-content pre {
  background: var(--th-bg-secondary, #fafafa);
  padding: 12px;
  border-radius: var(--th-radius-lg, 8px);
  overflow-x: auto;
  margin: 10px 0;
  border: 1px solid var(--th-border, #e5e5e5);
}

.stream-content pre code {
  background: none;
  padding: 0;
  border: none;
}

/* 测试用例表格样式 */
.tc-table-wrapper {
  overflow-x: auto;
  margin: 8px 0;
  border-radius: var(--th-radius-lg, 8px);
  border: 1px solid var(--th-border, #e5e5e5);
}

.tc-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 13px;
  line-height: 1.5;
}

.tc-table thead {
  background: var(--th-bg-secondary, #f7f7f8);
  position: sticky;
  top: 0;
  z-index: 1;
}

.tc-table th {
  padding: 10px 12px;
  text-align: left;
  font-weight: 600;
  color: var(--th-text-primary, #1a1a1a);
  border-bottom: 2px solid var(--th-border, #e5e5e5);
  white-space: nowrap;
  font-size: 12px;
  text-transform: uppercase;
  letter-spacing: 0.3px;
}

.tc-table td {
  padding: 10px 12px;
  border-bottom: 1px solid var(--th-border-light, #f0f0f0);
  color: var(--th-text-secondary, #666);
  vertical-align: top;
}

.tc-table tbody tr:hover {
  background: var(--th-bg-hover, #fafafa);
}

.tc-table tbody tr:last-child td {
  border-bottom: none;
}

.tc-col-id {
  width: 100px;
  font-family: 'Courier New', monospace;
  font-weight: 500;
  color: var(--th-accent, #1a1a1a);
}

.tc-col-title {
  min-width: 160px;
  font-weight: 500;
  color: var(--th-text-primary, #1a1a1a);
}

.tc-col-priority {
  width: 70px;
  text-align: center;
}

.tc-priority-badge {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 10px;
  color: #fff;
  font-size: 11px;
  font-weight: 600;
  letter-spacing: 0.5px;
}

.tc-col-precondition {
  min-width: 140px;
  font-size: 12px;
}

.tc-col-steps {
  min-width: 200px;
  font-size: 12px;
}

.tc-col-expected {
  min-width: 180px;
  font-size: 12px;
}

.tc-table-footer {
  text-align: right;
  padding: 8px 4px;
  font-size: 12px;
  color: var(--th-text-tertiary, #999);
}

.progress-steps {
  display: flex;
  justify-content: center;
  gap: 20px;
  margin-bottom: 30px;
  flex-wrap: wrap;
}

.step {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 10px;
  opacity: 0.4;
  transition: opacity var(--th-transition-base, 0.2s ease);
}

.step.active {
  opacity: 1;
}

.step-number {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  background: var(--th-bg-tertiary, #f5f5f5);
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  color: var(--th-text-tertiary, #999);
  border: 1px solid var(--th-border, #e5e5e5);
}

.step.active .step-number {
  background: var(--th-accent, #1a1a1a);
  color: #fff;
  border-color: var(--th-accent, #1a1a1a);
}

.step-text {
  font-size: var(--th-font-size-sm, 13px);
  color: var(--th-text-secondary, #666);
}

.cancel-generation-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-danger, #ef4444);
  border: 1px solid var(--th-border, #e5e5e5);
  padding: 10px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease);
}

.cancel-generation-btn:hover {
  background: rgba(239, 68, 68, 0.08);
  border-color: rgba(239, 68, 68, 0.35);
}

.completion-actions {
  display: flex;
  gap: 12px;
  margin-top: 20px;
  flex-wrap: wrap;
}

.completion-actions button {
  flex: 1;
  min-width: 150px;
  padding: 12px 20px;
  border-radius: var(--th-radius-lg, 8px);
  cursor: pointer;
  font-weight: 500;
  font-size: var(--th-font-size-base, 14px);
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease), transform var(--th-transition-base, 0.2s ease);
  display: flex;
  align-items: center;
  justify-content: center;
  border: 1px solid transparent;
}

.completion-actions .download-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border-color: var(--th-border, #e5e5e5);
}

.completion-actions .download-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
  transform: translateY(-1px);
}

.completion-actions .save-btn {
  background: var(--th-success, #22c55e);
  color: #fff;
  border-color: var(--th-success, #22c55e);
}

.completion-actions .save-btn:hover {
  background: #1a9e4a;
  border-color: #1a9e4a;
  transform: translateY(-1px);
}

.completion-actions .new-generation-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-secondary, #666);
  border-color: var(--th-border, #e5e5e5);
}

.completion-actions .new-generation-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
  transform: translateY(-1px);
}

.generation-result {
  margin: 40px 0;
}

.result-header {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 24px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  margin-bottom: 20px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  flex-wrap: wrap;
  gap: 20px;
}

.result-header h2 {
  color: var(--th-success, #22c55e);
  margin: 0;
  font-size: var(--th-font-size-xl, 18px);
  font-weight: 600;
}

.result-summary {
  display: flex;
  gap: 20px;
  flex-wrap: wrap;
}

.summary-item {
  color: var(--th-text-secondary, #666);
  font-size: var(--th-font-size-sm, 13px);
}

.new-generation-btn {
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

.new-generation-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
}

.generated-testcases-section,
.review-feedback-section,
.final-testcases-section {
  background: var(--th-bg-primary, #fff);
  border-radius: var(--th-radius-xl, 12px);
  padding: 24px;
  box-shadow: var(--th-shadow-md, 0 2px 8px rgba(0, 0, 0, 0.06));
  border: 1px solid var(--th-border, #e5e5e5);
  margin-bottom: 20px;
}

.generated-testcases-section h3,
.review-feedback-section h3,
.final-testcases-section h3 {
  color: var(--th-text-primary, #1a1a1a);
  margin-bottom: 16px;
  font-size: var(--th-font-size-lg, 16px);
  font-weight: 600;
}

.testcase-content,
.review-content {
  background: var(--th-bg-secondary, #fafafa);
  border-radius: var(--th-radius-lg, 8px);
  padding: 16px;
  border: 1px solid var(--th-border, #e5e5e5);
  font-size: var(--th-font-size-sm, 13px);
}

.testcase-content pre,
.review-content pre {
  white-space: pre-wrap;
  word-wrap: break-word;
  margin: 0;
  font-family: 'Monaco', 'Menlo', 'Consolas', monospace;
  font-size: var(--th-font-size-sm, 13px);
  line-height: 1.6;
  color: var(--th-text-primary, #1a1a1a);
}

@media (max-width: 768px) {
  .result-header {
    flex-direction: column;
    align-items: flex-start;
  }

  .progress-info,
  .result-summary {
    flex-direction: column;
    gap: 10px;
  }

  .progress-steps {
    gap: 10px;
  }
}

.actions-section {
  display: flex;
  gap: 20px;
  justify-content: center;
  margin-top: 30px;
  flex-wrap: wrap;
}

.download-btn,
.save-btn {
  padding: 12px 24px;
  border-radius: var(--th-radius-lg, 8px);
  font-size: var(--th-font-size-base, 14px);
  font-weight: 500;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  transition: background var(--th-transition-base, 0.2s ease), border-color var(--th-transition-base, 0.2s ease), transform var(--th-transition-base, 0.2s ease);
  border: 1px solid transparent;
}

.download-btn {
  background: var(--th-bg-primary, #fff);
  color: var(--th-text-primary, #1a1a1a);
  border-color: var(--th-border, #e5e5e5);
}

.download-btn:hover {
  background: var(--th-bg-hover, #f0f0f0);
  border-color: var(--th-border-hover, #d0d0d0);
  transform: translateY(-1px);
}

.save-btn {
  background: var(--th-accent, #1a1a1a);
  color: #fff;
  border-color: var(--th-accent, #1a1a1a);
}

.save-btn:hover {
  background: var(--th-accent-light, #333);
  border-color: var(--th-accent-light, #333);
  transform: translateY(-1px);
}

@media (max-width: 768px) {
  .actions-section {
    flex-direction: column;
    align-items: center;
  }

  .download-btn,
  .save-btn {
    width: 100%;
    max-width: 300px;
    justify-content: center;
  }
}
</style>

<style>
/* 全局样式：确保弹窗不受任何容器限制（与 scoped 段视觉一致） */
.modal-overlay {
  position: fixed !important;
  top: 0 !important;
  left: 0 !important;
  right: 0 !important;
  bottom: 0 !important;
  width: 100vw !important;
  height: 100vh !important;
  max-width: none !important;
  max-height: none !important;
  background: rgba(0, 0, 0, 0.45) !important;
  backdrop-filter: blur(4px);
  display: flex !important;
  align-items: center !important;
  justify-content: center !important;
  z-index: 9999 !important;
  padding: 20px;
  margin: 0 !important;
  opacity: 1 !important;
  box-sizing: border-box !important;
}

.guide-config-modal {
  background: var(--th-bg-primary, #fff) !important;
  border-radius: var(--th-radius-xl, 12px);
  padding: 32px;
  max-width: 850px !important;
  width: 100% !important;
  min-width: 300px !important;
  max-height: 90vh;
  overflow-y: auto;
  box-shadow: var(--th-shadow-lg, 0 4px 16px rgba(0, 0, 0, 0.08));
  border: 1px solid var(--th-border, #e5e5e5);
  position: relative;
  flex-shrink: 0;
  margin: auto;
  opacity: 1 !important;
  box-sizing: border-box !important;
}

.guide-config-modal::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  background: var(--th-accent, #1a1a1a);
  border-radius: var(--th-radius-xl, 12px) var(--th-radius-xl, 12px) 0 0;
}

/* 全局按钮样式（与 scoped 段一致，覆盖 Teleport 弹窗） */
.guide-actions {
  display: flex !important;
  flex-direction: column !important;
  align-items: center !important;
  gap: 12px;
  margin-top: 30px;
  width: 100%;
}

.guide-actions button {
  flex: none !important;
  width: 240px !important;
  height: 50px !important;
  padding: 0 24px !important;
  border-radius: var(--th-radius-lg, 8px);
  font-size: 0.95rem;
  font-weight: 600;
  display: inline-flex !important;
  align-items: center !important;
  justify-content: center !important;
  text-align: center;
  white-space: nowrap;
  opacity: 1 !important;
  box-sizing: border-box !important;
  cursor: pointer;
}

.guide-actions .generate-manual-btn {
  background: var(--th-accent, #1a1a1a) !important;
  color: #fff !important;
  border: 1px solid var(--th-accent, #1a1a1a) !important;
  box-shadow: none;
  transition: background 0.2s ease, border-color 0.2s ease;
}

.guide-actions .generate-manual-btn:hover {
  background: var(--th-accent-light, #333) !important;
  border-color: var(--th-accent-light, #333) !important;
}

.guide-actions .skip-action {
  font-size: 0.85rem;
  color: var(--th-text-tertiary, #999);
  cursor: pointer;
  text-decoration: none;
  padding: 4px 8px;
  transition: color 0.2s ease;
}

.guide-actions .skip-action:hover {
  color: var(--th-text-primary, #1a1a1a);
  text-decoration: underline;
}
</style>