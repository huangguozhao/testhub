<template>
  <el-dialog
    v-model="dialogVisible"
    :title="$t('apiTesting.interface.importCurlCommand')"
    width="800px"
    :close-on-click-modal="false"
  >
    <el-input
      :model-value="command"
      type="textarea"
      :rows="15"
      :placeholder="$t('apiTesting.interface.pasteCurlCommand')"
      @input="emit('update:command', $event)"
    />
    <template #footer>
      <el-button @click="handleCancel">{{ $t('apiTesting.common.cancel') }}</el-button>
      <el-button type="primary" @click="handleConfirm">{{ $t('apiTesting.interface.parseAndImport') }}</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  command: {
    type: String,
    default: ''
  }
})

const emit = defineEmits(['update:modelValue', 'update:command', 'confirm', 'cancel'])

const dialogVisible = ref(false)

watch(() => props.modelValue, (newVal) => {
  dialogVisible.value = newVal
})

watch(dialogVisible, (newVal) => {
  emit('update:modelValue', newVal)
})

watch(() => props.command, (newVal) => {
  emit('update:command', newVal)
})

const handleCancel = () => {
  dialogVisible.value = false
  emit('cancel')
}

const handleConfirm = () => {
  emit('confirm', props.command)
  dialogVisible.value = false
}
</script>
