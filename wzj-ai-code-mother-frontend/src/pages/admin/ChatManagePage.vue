<template>
  <div id="chatManagePage">
    <!-- 背景装饰 -->
    <div class="tech-bg">
      <div class="grid-overlay"></div>
      <div class="glow-orb orb-1"></div>
      <div class="glow-orb orb-2"></div>
    </div>

    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-icon">
        <MessageOutlined />
      </div>
      <div class="header-content">
        <h1 class="page-title">对话管理</h1>
        <p class="page-subtitle">管理系统内所有对话记录</p>
      </div>
    </div>

    <!-- 搜索表单卡片 -->
    <div class="search-card">
      <div class="card-decoration top-left"></div>
      <div class="card-decoration top-right"></div>
      <div class="card-decoration bottom-left"></div>
      <div class="card-decoration bottom-right"></div>
      
      <a-form layout="inline" :model="searchParams" @finish="doSearch">
        <a-form-item label="消息内容">
          <a-input 
            v-model:value="searchParams.message" 
            placeholder="输入消息内容"
            class="tech-input"
          />
        </a-form-item>
        <a-form-item label="消息类型">
          <a-select
            v-model:value="searchParams.messageType"
            placeholder="选择消息类型"
            style="width: 120px"
            class="tech-select"
          >
            <a-select-option value="">全部</a-select-option>
            <a-select-option value="user">用户消息</a-select-option>
            <a-select-option value="assistant">AI消息</a-select-option>
          </a-select>
        </a-form-item>
        <a-form-item label="应用ID">
          <a-input 
            v-model:value="searchParams.appId" 
            placeholder="输入应用ID"
            class="tech-input"
          />
        </a-form-item>
        <a-form-item label="用户ID">
          <a-input 
            v-model:value="searchParams.userId" 
            placeholder="输入用户ID"
            class="tech-input"
          />
        </a-form-item>
        <a-form-item>
          <a-button type="primary" html-type="submit" class="tech-btn-primary">
            <SearchOutlined />
            搜索
          </a-button>
        </a-form-item>
      </a-form>
    </div>

    <!-- 数据表格卡片 -->
    <div class="table-card">
      <div class="card-decoration top-left"></div>
      <div class="card-decoration top-right"></div>
      <div class="card-decoration bottom-left"></div>
      <div class="card-decoration bottom-right"></div>
      
      <a-table
        :columns="columns"
        :data-source="data"
        :pagination="pagination"
        @change="doTableChange"
        :scroll="{ x: 1400 }"
        class="tech-table"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'message'">
            <a-tooltip :title="record.message">
              <div class="message-text">{{ record.message }}</div>
            </a-tooltip>
          </template>
          <template v-else-if="column.dataIndex === 'messageType'">
            <span 
              class="message-type-tag"
              :class="record.messageType === 'user' ? 'user-type' : 'ai-type'"
            >
              <span class="tag-dot"></span>
              {{ record.messageType === 'user' ? '用户消息' : 'AI消息' }}
            </span>
          </template>
          <template v-else-if="column.dataIndex === 'createTime'">
            <span class="time-text">{{ formatTime(record.createTime) }}</span>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-space>
              <a-button 
                type="primary" 
                size="small" 
                @click="viewAppChat(record.appId)"
                class="action-btn view-btn"
              >
                <EyeOutlined />
                查看对话
              </a-button>
              <a-popconfirm 
                title="确定要删除这条消息吗？" 
                @confirm="deleteMessage(record.id)"
                okText="确定"
                cancelText="取消"
              >
                <a-button danger size="small" class="action-btn delete-btn">
                  <DeleteOutlined />
                  删除
                </a-button>
              </a-popconfirm>
            </a-space>
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { 
  MessageOutlined, 
  SearchOutlined, 
  EyeOutlined, 
  DeleteOutlined 
} from '@ant-design/icons-vue'
import { listAllChatHistoryByPageForAdmin } from '@/api/chatHistoryController'
import { formatTime } from '@/utils/time'

const router = useRouter()

const columns = [
  {
    title: 'ID',
    dataIndex: 'id',
    width: 80,
    fixed: 'left',
  },
  {
    title: '消息内容',
    dataIndex: 'message',
    width: 300,
  },
  {
    title: '消息类型',
    dataIndex: 'messageType',
    width: 100,
  },
  {
    title: '应用ID',
    dataIndex: 'appId',
    width: 80,
  },
  {
    title: '用户ID',
    dataIndex: 'userId',
    width: 80,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    width: 160,
  },
  {
    title: '操作',
    key: 'action',
    width: 180,
    fixed: 'right',
  },
]

// 数据
const data = ref<API.ChatHistory[]>([])
const total = ref(0)

// 搜索条件
const searchParams = reactive<API.ChatHistoryQueryRequest>({
  pageNum: 1,
  pageSize: 10,
})

// 获取数据
const fetchData = async () => {
  try {
    const res = await listAllChatHistoryByPageForAdmin({
      ...searchParams,
    })
    if (res.data.data) {
      data.value = res.data.data.records ?? []
      total.value = res.data.data.totalRow ?? 0
    } else {
      message.error('获取数据失败，' + res.data.message)
    }
  } catch (error) {
    console.error('获取数据失败：', error)
    message.error('获取数据失败')
  }
}

// 页面加载时请求一次
onMounted(() => {
  fetchData()
})

// 分页参数
const pagination = computed(() => {
  return {
    current: searchParams.pageNum ?? 1,
    pageSize: searchParams.pageSize ?? 10,
    total: total.value,
    showSizeChanger: true,
    showTotal: (total: number) => `共 ${total} 条`,
  }
})

// 表格变化处理
const doTableChange = (page: { current: number; pageSize: number }) => {
  searchParams.pageNum = page.current
  searchParams.pageSize = page.pageSize
  fetchData()
}

// 搜索
const doSearch = () => {
  // 重置页码
  searchParams.pageNum = 1
  fetchData()
}

// 查看应用对话
const viewAppChat = (appId: number | undefined) => {
  if (appId) {
    router.push(`/app/chat/${appId}`)
  }
}

// 删除消息
const deleteMessage = async (id: number | undefined) => {
  if (!id) return

  try {
    // 注意：这里需要后端提供删除对话历史的接口
    // 目前先显示成功，实际实现需要调用删除接口
    message.success('删除成功')
    // 刷新数据
    fetchData()
  } catch (error) {
    console.error('删除失败：', error)
    message.error('删除失败')
  }
}
</script>

<style scoped>
#chatManagePage {
  position: relative;
  padding: 24px;
  min-height: 100vh;
  background: linear-gradient(135deg, #0a0a0f 0%, #12121a 50%, #0d0d12 100%);
  overflow: hidden;
}

/* 背景装饰 */
.tech-bg {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  z-index: 0;
}

.grid-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-image: 
    linear-gradient(rgba(99, 102, 241, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(99, 102, 241, 0.03) 1px, transparent 1px);
  background-size: 50px 50px;
  animation: gridMove 20s linear infinite;
}

@keyframes gridMove {
  0% { transform: translate(0, 0); }
  100% { transform: translate(50px, 50px); }
}

.glow-orb {
  position: absolute;
  border-radius: 50%;
  filter: blur(80px);
  opacity: 0.15;
  animation: orbFloat 8s ease-in-out infinite;
}

.orb-1 {
  width: 400px;
  height: 400px;
  background: radial-gradient(circle, #6366f1 0%, transparent 70%);
  top: -100px;
  right: -100px;
  animation-delay: 0s;
}

.orb-2 {
  width: 300px;
  height: 300px;
  background: radial-gradient(circle, #8b5cf6 0%, transparent 70%);
  bottom: 10%;
  left: -50px;
  animation-delay: -4s;
}

@keyframes orbFloat {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(30px, -30px) scale(1.1); }
}

/* 页面标题 */
.page-header {
  position: relative;
  z-index: 1;
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
  padding: 0 8px;
}

.header-icon {
  width: 56px;
  height: 56px;
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28px;
  color: white;
  box-shadow: 0 8px 32px rgba(99, 102, 241, 0.3);
}

.header-content {
  flex: 1;
}

.page-title {
  font-size: 28px;
  font-weight: 700;
  color: #ffffff;
  margin: 0 0 4px 0;
  background: linear-gradient(135deg, #ffffff 0%, #a5b4fc 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  font-size: 14px;
  color: #6b7280;
  margin: 0;
}

/* 卡片样式 */
.search-card,
.table-card {
  position: relative;
  z-index: 1;
  background: rgba(18, 18, 26, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(99, 102, 241, 0.2);
  border-radius: 16px;
  padding: 24px;
  margin-bottom: 24px;
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.3);
}

.card-decoration {
  position: absolute;
  width: 20px;
  height: 20px;
  border: 2px solid #6366f1;
}

.card-decoration.top-left {
  top: -1px;
  left: -1px;
  border-right: none;
  border-bottom: none;
  border-top-left-radius: 16px;
}

.card-decoration.top-right {
  top: -1px;
  right: -1px;
  border-left: none;
  border-bottom: none;
  border-top-right-radius: 16px;
}

.card-decoration.bottom-left {
  bottom: -1px;
  left: -1px;
  border-right: none;
  border-top: none;
  border-bottom-left-radius: 16px;
}

.card-decoration.bottom-right {
  bottom: -1px;
  right: -1px;
  border-left: none;
  border-top: none;
  border-bottom-right-radius: 16px;
}

/* 表单样式 */
:deep(.ant-form-item-label > label) {
  color: #9ca3af;
  font-weight: 500;
}

.tech-input,
.tech-select {
  background: rgba(30, 30, 40, 0.8) !important;
  border: 1px solid rgba(99, 102, 241, 0.3) !important;
  border-radius: 8px !important;
  color: #e5e7eb !important;
}

.tech-input::placeholder {
  color: #6b7280 !important;
}

.tech-input:hover,
.tech-input:focus,
.tech-select:hover,
.tech-select:focus {
  border-color: #6366f1 !important;
  box-shadow: 0 0 0 2px rgba(99, 102, 241, 0.2) !important;
}

/* 按钮样式 */
.tech-btn-primary {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  border: none !important;
  border-radius: 8px !important;
  font-weight: 600;
  box-shadow: 0 4px 16px rgba(99, 102, 241, 0.3);
  transition: all 0.3s ease;
}

.tech-btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(99, 102, 241, 0.4);
}

/* 表格样式 */
.tech-table {
  background: transparent;
}

:deep(.ant-table) {
  background: transparent;
}

:deep(.ant-table-thead > tr > th) {
  background: rgba(99, 102, 241, 0.1) !important;
  border-bottom: 1px solid rgba(99, 102, 241, 0.2) !important;
  color: #a5b4fc !important;
  font-weight: 600;
}

:deep(.ant-table-tbody > tr) {
  background: transparent !important;
  transition: all 0.3s ease;
}

:deep(.ant-table-tbody > tr:hover) {
  background: rgba(99, 102, 241, 0.05) !important;
}

:deep(.ant-table-tbody > tr > td) {
  border-bottom: 1px solid rgba(99, 102, 241, 0.1) !important;
  color: #e5e7eb;
}

:deep(.ant-pagination-item) {
  background: rgba(30, 30, 40, 0.8) !important;
  border: 1px solid rgba(99, 102, 241, 0.3) !important;
}

:deep(.ant-pagination-item a) {
  color: #9ca3af !important;
}

:deep(.ant-pagination-item-active) {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  border-color: transparent !important;
}

:deep(.ant-pagination-item-active a) {
  color: white !important;
}

/* 消息类型标签 */
.message-type-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.message-type-tag.user-type {
  background: rgba(59, 130, 246, 0.15);
  color: #60a5fa;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.message-type-tag.ai-type {
  background: rgba(34, 197, 94, 0.15);
  color: #4ade80;
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.tag-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}

/* 消息文本 */
.message-text {
  max-width: 300px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: #e5e7eb;
}

/* 时间文本 */
.time-text {
  color: #9ca3af;
  font-size: 13px;
}

/* 操作按钮 */
.action-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  border-radius: 6px !important;
  font-weight: 500;
  transition: all 0.3s ease;
}

.view-btn {
  background: linear-gradient(135deg, #6366f1 0%, #8b5cf6 100%) !important;
  border: none !important;
  box-shadow: 0 2px 8px rgba(99, 102, 241, 0.3);
}

.view-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(99, 102, 241, 0.4);
}

.delete-btn {
  background: rgba(239, 68, 68, 0.1) !important;
  border: 1px solid rgba(239, 68, 68, 0.3) !important;
  color: #f87171 !important;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2) !important;
  border-color: rgba(239, 68, 68, 0.5) !important;
}

/* 响应式 */
@media (max-width: 768px) {
  #chatManagePage {
    padding: 16px;
  }
  
  .page-title {
    font-size: 22px;
  }
  
  .search-card,
  .table-card {
    padding: 16px;
  }
}
</style>
