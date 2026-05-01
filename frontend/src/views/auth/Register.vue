<template>
  <div class="th-login">
    <!-- 背景装饰 -->
    <div class="th-login-bg"></div>

    <!-- 主容器 -->
    <div class="th-login-container">
      <!-- 顶部 -->
      <header class="th-login-header">
        <div class="th-login-logo">
          <span class="th-logo-text">TestHub</span>
          <span class="th-logo-ai">.ai</span>
        </div>
        <el-dropdown @command="handleLanguageChange" trigger="click">
          <button class="th-lang-btn">
            <span>{{ appStore.language === 'zh-cn' ? '简体中文' : 'English' }}</span>
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
      </header>

      <!-- 注册表单区域 -->
      <main class="th-login-main">
        <div class="th-login-card">
          <div class="th-card-header">
            <h1 class="th-card-title">{{ $t('auth.registerTitle') }}</h1>
            <p class="th-card-subtitle">{{ $t('auth.registerSubtitle') }}</p>
          </div>

          <el-form
            ref="formRef"
            :model="form"
            :rules="rules"
            @submit.prevent="handleRegister"
            class="th-login-form"
          >
            <el-form-item prop="username">
              <el-input
                v-model="form.username"
                :placeholder="$t('auth.username')"
                size="large"
                :prefix-icon="User"
              />
            </el-form-item>

            <el-form-item prop="email">
              <el-input
                v-model="form.email"
                type="email"
                :placeholder="$t('auth.email')"
                size="large"
                :prefix-icon="Message"
              />
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item prop="first_name">
                  <el-input
                    v-model="form.first_name"
                    :placeholder="$t('auth.firstName')"
                    size="large"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item prop="last_name">
                  <el-input
                    v-model="form.last_name"
                    :placeholder="$t('auth.lastName')"
                    size="large"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item prop="password">
              <el-input
                v-model="form.password"
                type="password"
                :placeholder="$t('auth.password')"
                size="large"
                :prefix-icon="Lock"
                show-password
              />
            </el-form-item>

            <el-form-item prop="password_confirm">
              <el-input
                v-model="form.password_confirm"
                type="password"
                :placeholder="$t('auth.confirmPassword')"
                size="large"
                :prefix-icon="Lock"
                show-password
              />
            </el-form-item>

            <el-row :gutter="20">
              <el-col :span="12">
                <el-form-item prop="department">
                  <el-input
                    v-model="form.department"
                    :placeholder="$t('auth.department')"
                    size="large"
                  />
                </el-form-item>
              </el-col>
              <el-col :span="12">
                <el-form-item prop="position">
                  <el-input
                    v-model="form.position"
                    :placeholder="$t('auth.position')"
                    size="large"
                  />
                </el-form-item>
              </el-col>
            </el-row>

            <el-form-item>
              <button
                type="button"
                class="th-btn-primary"
                :disabled="loading"
                @click="handleRegister"
              >
                <span v-if="!loading">{{ $t('auth.register') }}</span>
                <span v-else>{{ $t('auth.registering') }}</span>
              </button>
            </el-form-item>

            <div class="th-form-footer">
              <router-link to="/login" class="th-register-link">
                {{ $t('auth.hasAccount') }}<span>{{ $t('auth.loginNow') }}</span>
              </router-link>
            </div>
          </el-form>
        </div>
      </main>

      <!-- 底部 -->
      <footer class="th-login-footer">
        <p>&copy; 2026 TestHub. AI驱动的测试管理平台</p>
      </footer>
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed } from 'vue'
import { useRouter } from 'vue-router'
import { useI18n } from 'vue-i18n'
import { ElMessage } from 'element-plus'
import { User, Lock, Message } from '@element-plus/icons-vue'
import { useUserStore } from '@/stores/user'
import { useAppStore } from '@/stores/app'

const router = useRouter()
const userStore = useUserStore()
const appStore = useAppStore()
const { t } = useI18n()

// 语言切换（无刷新）
const handleLanguageChange = (lang) => {
  appStore.setLanguage(lang)
}

const formRef = ref()
const loading = ref(false)

const form = reactive({
  username: '',
  email: '',
  first_name: '',
  last_name: '',
  password: '',
  password_confirm: '',
  department: '',
  position: ''
})

// 合并姓和名为真实姓名
const getRealName = () => {
  const first = form.first_name?.trim() || ''
  const last = form.last_name?.trim() || ''
  return [first, last].filter(Boolean).join(' ')
}

const rules = {
  username: [
    { required: true, message: computed(() => t('auth.usernameRequired')), trigger: 'blur' },
    { min: 3, max: 20, message: computed(() => t('auth.usernameLength')), trigger: 'blur' }
  ],
  email: [
    { required: true, message: computed(() => t('auth.emailRequired')), trigger: 'blur' },
    { type: 'email', message: computed(() => t('auth.emailFormat')), trigger: 'blur' }
  ],
  password: [
    { required: true, message: computed(() => t('auth.passwordRequired')), trigger: 'blur' },
    { min: 6, message: computed(() => t('auth.passwordLength')), trigger: 'blur' }
  ],
  password_confirm: [
    { required: true, message: computed(() => t('auth.confirmPasswordRequired')), trigger: 'blur' },
    {
      validator: (rule, value, callback) => {
        if (value !== form.password) {
          callback(new Error(t('auth.passwordMismatch')))
        } else {
          callback()
        }
      },
      trigger: 'blur'
    }
  ]
}

const handleRegister = async () => {
  if (!formRef.value) return

  await formRef.value.validate(async (valid) => {
    if (valid) {
      loading.value = true
      try {
        const registerData = {
          username: form.username,
          email: form.email,
          password: form.password,
          realName: getRealName()
        }
        await userStore.register(registerData)
        ElMessage.success(t('auth.registerSuccess'))
        router.push('/login')
      } catch (error) {
        ElMessage.error(error.response?.data?.message || error.response?.data?.error || t('auth.registerFailed'))
      } finally {
        loading.value = false
      }
    }
  })
}
</script>

<style lang="scss" scoped>
// ============================================
// 注册页容器
// ============================================
.th-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--th-bg-primary);
  position: relative;
  overflow: hidden;
}

// 背景装饰
.th-login-bg {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 40vh;
  background: linear-gradient(180deg, var(--th-bg-secondary) 0%, var(--th-bg-primary) 100%);

  &::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background:
      radial-gradient(circle at 20% 80%, rgba(0, 0, 0, 0.02) 0%, transparent 50%),
      radial-gradient(circle at 80% 20%, rgba(0, 0, 0, 0.02) 0%, transparent 50%);
  }
}

// 主容器
.th-login-container {
  width: 100%;
  max-width: 500px;
  padding: 40px 24px;
  position: relative;
  z-index: 1;
}

// ============================================
// 顶部
// ============================================
.th-login-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 60px;
}

.th-login-logo {
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

.th-lang-btn {
  padding: 6px 14px;
  background: transparent;
  border: 1px solid var(--th-border);
  border-radius: var(--th-radius-md);
  cursor: pointer;
  font-size: 13px;
  color: var(--th-text-secondary);
  transition: all var(--th-transition-fast);

  &:hover {
    border-color: var(--th-border-hover);
    color: var(--th-text-primary);
    background: var(--th-bg-secondary);
  }
}

// ============================================
// 注册卡片
// ============================================
.th-login-card {
  background: var(--th-bg-primary);
  border: 1px solid var(--th-border);
  border-radius: var(--th-radius-xl);
  padding: 40px;
  transition: border-color var(--th-transition-fast);

  &:hover {
    border-color: var(--th-border-hover);
  }
}

.th-card-header {
  text-align: center;
  margin-bottom: 32px;
}

.th-card-title {
  font-size: 24px;
  font-weight: 600;
  letter-spacing: -0.5px;
  color: var(--th-text-primary);
  margin: 0 0 8px;
}

.th-card-subtitle {
  font-size: 14px;
  color: var(--th-text-secondary);
  margin: 0;
  font-weight: 300;
}

// ============================================
// 表单
// ============================================
.th-login-form {
  :deep(.el-form-item) {
    margin-bottom: 20px;
  }
}

.th-btn-primary {
  width: 100%;
  height: 48px;
  background: var(--th-accent);
  color: white;
  border: none;
  border-radius: var(--th-radius-md);
  font-size: 15px;
  font-weight: 500;
  cursor: pointer;
  transition: all var(--th-transition-fast);

  &:hover:not(:disabled) {
    background: var(--th-accent-light);
  }

  &:active:not(:disabled) {
    transform: scale(0.98);
  }

  &:disabled {
    opacity: 0.6;
    cursor: not-allowed;
  }
}

.th-form-footer {
  text-align: center;
  margin-top: 24px;
}

.th-register-link {
  font-size: 14px;
  color: var(--th-text-secondary);
  text-decoration: none;
  transition: color var(--th-transition-fast);

  span {
    color: var(--th-text-primary);
    font-weight: 500;
    margin-left: 4px;

    &:hover {
      text-decoration: underline;
    }
  }

  &:hover {
    color: var(--th-text-primary);
  }
}

// ============================================
// 底部
// ============================================
.th-login-footer {
  text-align: center;
  margin-top: 40px;

  p {
    font-size: 13px;
    color: var(--th-text-tertiary);
    margin: 0;
  }
}

// ============================================
// 响应式设计
// ============================================
@media screen and (max-width: 480px) {
  .th-login-container {
    padding: 24px 16px;
  }

  .th-login-header {
    margin-bottom: 40px;
  }

  .th-login-card {
    padding: 32px 24px;
  }

  .th-card-header {
    margin-bottom: 24px;
  }

  .th-card-title {
    font-size: 22px;
  }
}
</style>