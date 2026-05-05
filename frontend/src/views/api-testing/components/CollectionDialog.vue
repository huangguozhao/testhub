<template>
  <!-- 创建集合对话框 -->
  <el-dialog
    v-if="mode === 'create'"
    v-model="dialogVisible"
    :title="$t('apiTesting.interface.createCollection')"
    :close-on-click-modal="false"
    :close-on-press-escape="false"
    :modal="true"
    :destroy-on-close="false"
    width="500px"
  >
    <el-form ref="collectionFormRef" :model="formData" :rules="rules" label-width="100px">
      <el-form-item :label="$t('apiTesting.interface.collectionName')" prop="name">
        <el-input v-model="formData.name" :placeholder="$t('apiTesting.interface.inputCollectionName')" />
      </el-form-item>
      <el-form-item :label="$t('apiTesting.common.description')" prop="description">
        <el-input
          v-model="formData.description"
          type="textarea"
          :rows="3"
          :placeholder="`${$t('apiTesting.common.pleaseInput')}${$t('apiTesting.common.description')}`"
        />
      </el-form-item>
      <el-form-item :label="$t('apiTesting.interface.parentCollection')" prop="parent">
        <el-select v-model="formData.parent" :placeholder="$t('apiTesting.interface.selectParentCollection')" clearable>
          <el-option
            v-for="collection in collections"
            :key="collection.id"
            :label="collection.name"
            :value="collection.id"
          />
        </el-select>
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="handleCancel">{{ $t('apiTesting.common.cancel') }}</el-button>
      <el-button type="primary" @click="handleConfirm">{{ $t('apiTesting.common.create') }}</el-button>
    </template>
  </el-dialog>

  <!-- 编辑集合对话框 -->
  <el-dialog
    v-else-if="mode === 'edit'"
    v-model="dialogVisible"
    :title="$t('apiTesting.interface.editCollection')"
    :close-on-click-modal="false"
    width="500px"
  >
    <el-form ref="editCollectionFormRef" :model="formData" :rules="rules" label-width="100px">
      <el-form-item :label="$t('apiTesting.interface.collectionName')" prop="name">
        <el-input v-model="formData.name" :placeholder="$t('apiTesting.interface.inputCollectionName')" />
      </el-form-item>
      <el-form-item :label="$t('apiTesting.common.description')" prop="description">
        <el-input
          v-model="formData.description"
          type="textarea"
          :rows="3"
          :placeholder="`${$t('apiTesting.common.pleaseInput')}${$t('apiTesting.common.description')}`"
        />
      </el-form-item>
      <el-form-item :label="$t('apiTesting.interface.parentCollection')" prop="parent">
        <el-select v-model="formData.parent" :placeholder="$t('apiTesting.interface.selectParentCollection')" clearable>
          <el-option
            v-for="collection in collections.filter(c => c.id !== formData.id)"
            :key="collection.id"
            :label="collection.name"
            :value="collection.id"
          />
        </el-select>
      </el-form-item>
    </el-form>

    <template #footer>
      <el-button @click="handleCancel">{{ $t('apiTesting.common.cancel') }}</el-button>
      <el-button type="primary" @click="handleConfirm">{{ $t('apiTesting.common.save') }}</el-button>
    </template>
  </el-dialog>
</template>

<script setup>
import { ref, reactive, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  mode: {
    type: String,
    default: 'create', // 'create' or 'edit'
    validator: (value) => ['create', 'edit'].includes(value)
  },
  collections: {
    type: Array,
    default: () => []
  },
  collection: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['update:modelValue', 'confirm', 'cancel'])

// 表单引用
const collectionFormRef = ref(null)
const editCollectionFormRef = ref(null)

// 对话框可见性
const dialogVisible = ref(false)

// 表单数据
const formData = reactive({
  id: null,
  name: '',
  description: '',
  parent: null
})

// 表单验证规则
const rules = {
  name: [
    { required: true, message: '集合名称不能为空', trigger: 'blur' }
  ]
}

// 监听 modelValue 变化
watch(() => props.modelValue, (newVal) => {
  dialogVisible.value = newVal
  if (newVal) {
    resetForm()
  }
}, { immediate: true })

// 监听 dialogVisible 变化
watch(dialogVisible, (newVal) => {
  emit('update:modelValue', newVal)
})

// 重置表单
const resetForm = () => {
  if (props.mode === 'edit' && props.collection) {
    formData.id = props.collection.id
    formData.name = props.collection.name || ''
    formData.description = props.collection.description || ''
    formData.parent = props.collection.parent_id || null
  } else {
    formData.id = null
    formData.name = ''
    formData.description = ''
    formData.parent = null
  }
}

// 取消
const handleCancel = () => {
  dialogVisible.value = false
  emit('cancel')
}

// 确认
const handleConfirm = async () => {
  const formRef = props.mode === 'edit' ? editCollectionFormRef.value : collectionFormRef.value
  if (!formRef) {
    emit('confirm', { ...formData })
    return
  }

  try {
    await formRef.validate()
    emit('confirm', { ...formData })
    dialogVisible.value = false
  } catch (error) {
    // 验证失败，不关闭对话框
  }
}
</script>
