<template>
  <el-dialog
    v-model="dialogVisible"
    :title="$t('apiTesting.interface.generateCode')"
    width="900px"
    :close-on-click-modal="false"
  >
    <el-select
        :model-value="language"
        :placeholder="$t('apiTesting.interface.selectLanguage')"
        style="width: 150px; margin-bottom: 10px"
        @change="handleLanguageChange"
      >
      <el-option label="JavaScript" value="javascript" />
      <el-option label="Python" value="python" />
      <el-option label="Java" value="java" />
      <el-option label="Node.js" value="node" />
      <el-option label="cURL" value="curl" />
      <el-option label="PHP" value="php" />
      <el-option label="Go" value="go" />
      <el-option label="C#" value="csharp" />
      <el-option label="Ruby" value="ruby" />
      <el-option label="Swift" value="swift" />
      <el-option label="Kotlin" value="kotlin" />
      <el-option label="Rust" value="rust" />
      <el-option label="Dart" value="dart" />
      <el-option label="Objective-C" value="objc" />
      <el-option label="PowerShell" value="powershell" />
      <el-option label="MATLAB" value="matlab" />
      <el-option label="R" value="r" />
      <el-option label="Ansible" value="ansible" />
      <el-option label="C" value="c" />
      <el-option label="CFML" value="cfml" />
      <el-option label="Clojure" value="clojure" />
      <el-option label="Elixir" value="elixir" />
      <el-option label="HTTP" value="http" />
      <el-option label="HTTPie" value="httpie" />
      <el-option label="Julia" value="julia" />
      <el-option label="Lua" value="lua" />
      <el-option label="OCaml" value="ocaml" />
      <el-option label="Perl" value="perl" />
      <el-option label="Wget" value="wget" />
    </el-select>
    <el-input
      :model-value="code"
      type="textarea"
      :rows="20"
      readonly
      class="code-generate"
      @input="emit('update:code', $event)"
    />
    <template #footer>
      <el-button @click="handleCancel">{{ $t('apiTesting.common.cancel') }}</el-button>
      <el-button type="primary" @click="handleCopy">{{ $t('apiTesting.common.copy') }}</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'
import { ElMessage } from 'element-plus'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  language: {
    type: String,
    default: 'javascript'
  },
  code: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'update:language', 'update:code', 'generate', 'cancel', 'copy'])

const dialogVisible = ref(false)

watch(() => props.modelValue, (newVal) => {
  dialogVisible.value = newVal
})

watch(dialogVisible, (newVal) => {
  emit('update:modelValue', newVal)
})

watch(() => props.language, (newVal) => {
  emit('update:language', newVal)
})

watch(() => props.code, (newVal) => {
  emit('update:code', newVal)
})

const handleLanguageChange = (lang) => {
  emit('generate', lang)
}

const handleCancel = () => {
  dialogVisible.value = false
  emit('cancel')
}

const handleCopy = () => {
  emit('copy', props.code)
  ElMessage.success('复制成功')
}
</script>

<style scoped>
.code-generate {
  font-family: 'SFMono-Regular', Consolas, 'Liberation Mono', Menlo, monospace;
  font-size: 14px;
  line-height: 1.6;
  background: #f8f9fa;
  border: 1px solid #e9ecef;
  border-radius: 8px;
  padding: 16px;
  min-height: 300px;
  resize: vertical;
}
</style>
