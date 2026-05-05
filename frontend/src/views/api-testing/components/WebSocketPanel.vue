<template>
  <div class="message-container">
    <div class="message-input-section">
      <el-select
        v-model="messageType"
        :placeholder="$t('apiTesting.interface.messageType')"
        style="width: 150px; margin-bottom: 15px;"
      >
        <el-option label="Text" value="text" />
        <el-option label="JSON" value="json" />
        <el-option label="Binary" value="binary" />
      </el-select>

      <div v-if="messageType === 'text' || messageType === 'json'">
        <el-input
          v-model="messageContent"
          type="textarea"
          :rows="6"
          :placeholder="$t('apiTesting.interface.inputWebSocketMessage')"
        />
      </div>

      <div v-else-if="messageType === 'binary'">
        <el-upload
          drag
          action="#"
          :auto-upload="false"
          :show-file-list="false"
          :on-change="handleFileUpload"
        >
          <el-icon class="el-icon--upload"><upload-filled /></el-icon>
          <div class="el-upload__text">
            {{ $t('apiTesting.interface.dragBinaryFile') }}<em>{{ $t('apiTesting.interface.clickUpload') }}</em>
          </div>
        </el-upload>
        <div v-if="binaryFile" class="uploaded-file">
          <span>{{ binaryFile.name }}</span>
          <el-button size="small" type="danger" @click="clearFile">{{ $t('apiTesting.interface.clear') }}</el-button>
        </div>
      </div>

      <div class="message-actions" style="margin-top: 15px;">
        <el-button type="primary" @click="handleSend">
          {{ $t('apiTesting.interface.sendMessage') }}
        </el-button>
        <el-button @click="handleClear">
          {{ $t('apiTesting.interface.clearMessage') }}
        </el-button>
      </div>
    </div>

    <!-- 消息历史记录 -->
    <div class="websocket-response-section" v-if="messages.length > 0">
      <h3>{{ $t('apiTesting.interface.messageHistory') }}</h3>
      <div class="websocket-messages">
        <div
          v-for="(msg, index) in messages.slice().reverse()"
          :key="index"
          class="websocket-message-item"
          :class="msg.type"
        >
          <div class="message-header">
            <span class="message-type" :class="msg.type">
              {{ getMessageTypeLabel(msg.type) }}
            </span>
            <span class="message-time">{{ msg.timestamp }}</span>
          </div>
          <div class="message-content">
            <pre v-if="msg.type === 'received' && isJson(msg.content)">{{ formatJsonContent(msg.content) }}</pre>
            <pre v-else>{{ msg.content }}</pre>
          </div>
        </div>
      </div>
      <div class="message-actions">
        <el-button size="small" @click="handleClearHistory">{{ $t('apiTesting.interface.clearHistory') }}</el-button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref } from 'vue'

const props = defineProps({
  connectionStatus: {
    type: String,
    default: 'disconnected'
  },
  messages: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['update:messages', 'send', 'clear', 'clear-history', 'file-upload', 'file-clear'])

const messageType = ref('text')
const messageContent = ref('')
const binaryFile = ref(null)

const handleSend = () => {
  emit('send', {
    type: messageType.value,
    content: messageContent.value,
    binary: binaryFile.value
  })
}

const handleClear = () => {
  messageContent.value = ''
  emit('clear')
}

const handleClearHistory = () => {
  emit('clear-history')
}

const handleFileUpload = (file) => {
  binaryFile.value = file
  emit('file-upload', file)
}

const clearFile = () => {
  binaryFile.value = null
  emit('file-clear')
}

const isJson = (str) => {
  try {
    JSON.parse(str)
    return true
  } catch {
    return false
  }
}

const formatJsonContent = (str) => {
  try {
    return JSON.stringify(JSON.parse(str), null, 2)
  } catch {
    return str
  }
}

const getMessageTypeLabel = (type) => {
  const labels = {
    sent: '已发送',
    connected: '已连接',
    info: '信息',
    error: '错误',
    received: '已接收'
  }
  return labels[type] || type
}
</script>
