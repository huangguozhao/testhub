<template>
  <el-dialog
    :close-on-press-escape="false"
    :modal="true"
    :destroy-on-close="false"
    v-model="dialogVisible"
    :title="$t('apiTesting.interface.variableHelper') + ' (点击插入)'"
    :close-on-click-modal="false"
    width="900px"
  >
    <div v-if="variableCategories.length === 0" style="padding: 20px; text-align: center; color: #999;">
      <p>{{ $t('apiTesting.interface.variableCategoriesLoading') }}</p>
      <p>{{ $t('apiTesting.interface.variableCategoriesCount', { count: variableCategories.length }) }}</p>
    </div>
    <el-tabs v-else tab-position="left" style="height: 450px">
      <el-tab-pane
        v-for="(category, index) in variableCategories"
        :key="index"
        :label="category.label"
      >
        <div style="height: 450px; overflow-y: auto; padding: 10px;">
          <el-table :data="category.variables" style="width: 100%" @row-click="handleRowClick" highlight-current-row>
            <el-table-column prop="name" :label="$t('apiTesting.interface.functionName')" width="150">
              <template #default="{ row }">
                <el-tag size="small">{{ row.name }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="desc" :label="$t('apiTesting.interface.description')" min-width="150" />
            <el-table-column prop="syntax" :label="$t('apiTesting.interface.syntax')" min-width="200" show-overflow-tooltip />
            <el-table-column prop="example" :label="$t('apiTesting.interface.example')" min-width="200" show-overflow-tooltip />
            <el-table-column :label="$t('apiTesting.interface.operation')" width="80" fixed="right">
              <template #default="{ row }">
                <el-button link type="primary" size="small">{{ $t('apiTesting.interface.insert') }}</el-button>
              </template>
            </el-table-column>
          </el-table>
        </div>
      </el-tab-pane>
    </el-tabs>
  </el-dialog>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  modelValue: {
    type: Boolean,
    default: false
  },
  variableCategories: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:modelValue', 'select'])

const dialogVisible = ref(false)

watch(() => props.modelValue, (newVal) => {
  dialogVisible.value = newVal
})

watch(dialogVisible, (newVal) => {
  emit('update:modelValue', newVal)
})

const handleRowClick = (row) => {
  emit('select', row)
}
</script>
