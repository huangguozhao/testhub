/**
 * 项目相关状态管理
 */
import { ref } from 'vue'
import api from '@/utils/api'

export function useProjects() {
  const projects = ref([])
  const selectedProject = ref(null)
  const loading = ref(false)

  const loadProjects = async () => {
    try {
      loading.value = true
      const response = await api.get('/api-projects')
      projects.value = response.data.records || response.data || []
      if (projects.value.length > 0 && !selectedProject.value) {
        selectedProject.value = projects.value[0].id
      }
    } catch (error) {
      console.error('加载项目失败:', error)
      throw error
    } finally {
      loading.value = false
    }
  }

  const selectProject = (projectId) => {
    selectedProject.value = projectId
  }

  return {
    projects,
    selectedProject,
    loading,
    loadProjects,
    selectProject
  }
}
