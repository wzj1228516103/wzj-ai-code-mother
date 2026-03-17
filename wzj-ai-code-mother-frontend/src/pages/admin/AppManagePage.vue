<template>
  <div class="tech-admin-page">
    <!-- 网格背景 -->
    <div class="tech-grid-bg"></div>
    
    <!-- 装饰光效 -->
    <div class="glow-orb glow-orb-1"></div>
    <div class="glow-orb glow-orb-2"></div>
    
    <!-- 页面内容 -->
    <div class="page-content">
      <!-- 页面标题 -->
      <div class="page-header">
        <div class="header-icon">
          <AppstoreOutlined />
        </div>
        <div class="header-text">
          <h2 class="page-title">
            <span class="title-highlight">应用</span>管理
          </h2>
          <p class="page-subtitle">管理系统中的所有应用</p>
        </div>
      </div>
      
      <!-- 搜索表单卡片 -->
      <div class="search-card">
        <div class="card-corner corner-tl"></div>
        <div class="card-corner corner-tr"></div>
        <div class="card-corner corner-bl"></div>
        <div class="card-corner corner-br"></div>
        
        <a-form layout="inline" :model="searchParams" @finish="doSearch" class="tech-search-form">
          <a-form-item label="应用名称">
            <a-input 
              v-model:value="searchParams.appName" 
              placeholder="输入应用名称"
              class="tech-input"
            />
          </a-form-item>
          <a-form-item label="创建者">
            <a-input 
              v-model:value="searchParams.userId" 
              placeholder="输入用户ID"
              class="tech-input"
            />
          </a-form-item>
          <a-form-item label="生成类型">
            <a-select
              v-model:value="searchParams.codeGenType"
              placeholder="选择生成类型"
              style="width: 150px"
              class="tech-select"
            >
              <a-select-option value="">全部</a-select-option>
              <a-select-option
                v-for="option in CODE_GEN_TYPE_OPTIONS"
                :key="option.value"
                :value="option.value"
              >
                {{ option.label }}
              </a-select-option>
            </a-select>
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
        <div class="card-corner corner-tl"></div>
        <div class="card-corner corner-tr"></div>
        <div class="card-corner corner-bl"></div>
        <div class="card-corner corner-br"></div>
        
        <a-table
          :columns="columns"
          :data-source="data"
          :pagination="pagination"
          @change="doTableChange"
          :scroll="{ x: 1200 }"
          class="tech-table"
        >
          <template #bodyCell="{ column, record }">
            <template v-if="column.dataIndex === 'cover'">
              <a-image v-if="record.cover" :src="record.cover" :width="80" :height="60" class="cover-image" />
              <div v-else class="no-cover">无封面</div>
            </template>
            <template v-else-if="column.dataIndex === 'initPrompt'">
              <a-tooltip :title="record.initPrompt">
                <div class="prompt-text">{{ record.initPrompt }}</div>
              </a-tooltip>
            </template>
            <template v-else-if="column.dataIndex === 'codeGenType'">
              <span class="code-type-tag">{{ formatCodeGenType(record.codeGenType) }}</span>
            </template>
            <template v-else-if="column.dataIndex === 'priority'">
              <a-tag v-if="record.priority === 99" class="featured-tag">精选</a-tag>
              <span v-else class="priority-text">{{ record.priority || 0 }}</span>
            </template>
            <template v-else-if="column.dataIndex === 'deployedTime'">
              <span v-if="record.deployedTime" class="time-text">
                {{ formatTime(record.deployedTime) }}
              </span>
              <span v-else class="text-gray">未部署</span>
            </template>
            <template v-else-if="column.dataIndex === 'createTime'">
              <span class="time-text">{{ formatTime(record.createTime) }}</span>
            </template>
            <template v-else-if="column.dataIndex === 'user'">
              <UserInfo :user="record.user" size="small" />
            </template>
            <template v-else-if="column.key === 'action'">
              <a-space>
                <a-button type="primary" size="small" @click="editApp(record)" class="action-btn edit-btn">
                  <EditOutlined />
                  编辑
                </a-button>
                <a-button
                  type="default"
                  size="small"
                  @click="toggleFeatured(record)"
                  :class="['action-btn', record.priority === 99 ? 'unfeatured-btn' : 'featured-btn']"
                >
                  <StarOutlined v-if="record.priority !== 99" />
                  <StarFilled v-else />
                  {{ record.priority === 99 ? '取消精选' : '精选' }}
                </a-button>
                <a-popconfirm title="确定要删除这个应用吗？" @confirm="deleteApp(record.id)">
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
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { listAppVoByPageByAdmin, deleteAppByAdmin, updateAppByAdmin } from '@/api/appController'
import { CODE_GEN_TYPE_OPTIONS, formatCodeGenType } from '@/utils/codeGenTypes'
import { formatTime } from '@/utils/time'
import UserInfo from '@/components/UserInfo.vue'
import { 
  AppstoreOutlined, 
  SearchOutlined, 
  EditOutlined, 
  StarOutlined, 
  StarFilled, 
  DeleteOutlined 
} from '@ant-design/icons-vue'

const router = useRouter()

const columns = [
  {
    title: 'ID',
    dataIndex: 'id',
    width: 80,
    fixed: 'left',
  },
  {
    title: '应用名称',
    dataIndex: 'appName',
    width: 150,
  },
  {
    title: '封面',
    dataIndex: 'cover',
    width: 100,
  },
  {
    title: '初始提示词',
    dataIndex: 'initPrompt',
    width: 200,
  },
  {
    title: '生成类型',
    dataIndex: 'codeGenType',
    width: 100,
  },
  {
    title: '优先级',
    dataIndex: 'priority',
    width: 80,
  },
  {
    title: '部署时间',
    dataIndex: 'deployedTime',
    width: 160,
  },
  {
    title: '创建者',
    dataIndex: 'user',
    width: 120,
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    width: 160,
  },
  {
    title: '操作',
    key: 'action',
    width: 200,
    fixed: 'right',
  },
]

// 数据
const data = ref<API.AppVO[]>([])
const total = ref(0)

// 搜索条件
const searchParams = reactive<API.AppQueryRequest>({
  pageNum: 1,
  pageSize: 10,
})

// 获取数据
const fetchData = async () => {
  try {
    const res = await listAppVoByPageByAdmin({
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

// 编辑应用
const editApp = (app: API.AppVO) => {
  router.push(`/app/edit/${app.id}`)
}

// 切换精选状态
const toggleFeatured = async (app: API.AppVO) => {
  if (!app.id) return

  const newPriority = app.priority === 99 ? 0 : 99

  try {
    const res = await updateAppByAdmin({
      id: app.id,
      priority: newPriority,
    })

    if (res.data.code === 0) {
      message.success(newPriority === 99 ? '已设为精选' : '已取消精选')
      // 刷新数据
      fetchData()
    } else {
      message.error('操作失败：' + res.data.message)
    }
  } catch (error) {
    console.error('操作失败：', error)
    message.error('操作失败')
  }
}

// 删除应用
const deleteApp = async (id: number | undefined) => {
  if (!id) return

  try {
    const res = await deleteAppByAdmin({ id })
    if (res.data.code === 0) {
      message.success('删除成功')
      // 刷新数据
      fetchData()
    } else {
      message.error('删除失败：' + res.data.message)
    }
  } catch (error) {
    console.error('删除失败：', error)
    message.error('删除失败')
  }
}
</script>

<style scoped>
/* 科技风管理页面 */
.tech-admin-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #0a0a0f 0%, #12121a 50%, #1a1a25 100%);
  position: relative;
  overflow: hidden;
  padding: 24px;
}

/* 网格背景 */
.tech-grid-bg {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  background-image: 
    linear-gradient(rgba(0, 240, 255, 0.03) 1px, transparent 1px),
    linear-gradient(90deg, rgba(0, 240, 255, 0.03) 1px, transparent 1px);
  background-size: 50px 50px;
}

/* 发光球体装饰 */
.glow-orb {
  position: fixed;
  border-radius: 50%;
  filter: blur(80px);
  pointer-events: none;
  z-index: 0;
}

.glow-orb-1 {
  width: 400px;
  height: 400px;
  background: rgba(124, 58, 237, 0.1);
  top: -100px;
  right: -100px;
  animation: float-orb 8s ease-in-out infinite;
}

.glow-orb-2 {
  width: 300px;
  height: 300px;
  background: rgba(0, 240, 255, 0.1);
  bottom: -50px;
  left: -50px;
  animation: float-orb 10s ease-in-out infinite reverse;
}

@keyframes float-orb {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(30px, -30px) scale(1.1); }
}

/* 页面内容 */
.page-content {
  position: relative;
  z-index: 1;
  max-width: 1400px;
  margin: 0 auto;
}

/* 页面头部 */
.page-header {
  display: flex;
  align-items: center;
  gap: 16px;
  margin-bottom: 24px;
}

.header-icon {
  width: 48px;
  height: 48px;
  background: linear-gradient(135deg, #7c3aed 0%, #00f0ff 100%);
  border-radius: 12px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  color: white;
  box-shadow: 0 4px 15px rgba(124, 58, 237, 0.3);
}

.page-title {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  margin: 0;
}

.title-highlight {
  background: linear-gradient(135deg, #7c3aed 0%, #00f0ff 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.page-subtitle {
  font-size: 13px;
  color: rgba(255, 255, 255, 0.5);
  margin: 4px 0 0 0;
}

/* 卡片样式 */
.search-card,
.table-card {
  background: rgba(18, 18, 26, 0.9);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(124, 58, 237, 0.2);
  border-radius: 16px;
  padding: 24px;
  position: relative;
  margin-bottom: 24px;
  box-shadow: 
    0 20px 60px rgba(0, 0, 0, 0.5),
    0 0 40px rgba(124, 58, 237, 0.1);
}

/* 角落装饰 */
.card-corner {
  position: absolute;
  width: 20px;
  height: 20px;
  border: 2px solid rgba(124, 58, 237, 0.5);
}

.card-corner.corner-tl {
  top: -1px;
  left: -1px;
  border-right: none;
  border-bottom: none;
  border-radius: 16px 0 0 0;
}

.card-corner.corner-tr {
  top: -1px;
  right: -1px;
  border-left: none;
  border-bottom: none;
  border-radius: 0 16px 0 0;
}

.card-corner.corner-bl {
  bottom: -1px;
  left: -1px;
  border-right: none;
  border-top: none;
  border-radius: 0 0 0 16px;
}

.card-corner.corner-br {
  bottom: -1px;
  right: -1px;
  border-left: none;
  border-top: none;
  border-radius: 0 0 16px 0;
}

/* 搜索表单 */
.tech-search-form :deep(.ant-form-item-label) {
  color: rgba(255, 255, 255, 0.7);
}

.tech-input {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 8px !important;
  color: #fff !important;
}

.tech-input:hover {
  border-color: rgba(124, 58, 237, 0.5) !important;
}

.tech-input:focus {
  border-color: #7c3aed !important;
  box-shadow: 0 0 0 2px rgba(124, 58, 237, 0.2) !important;
}

:deep(.tech-select .ant-select-selector) {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 8px !important;
  color: #fff !important;
}

:deep(.tech-select .ant-select-arrow) {
  color: rgba(255, 255, 255, 0.5);
}

/* 按钮样式 */
.tech-btn-primary {
  background: linear-gradient(135deg, #7c3aed 0%, #00f0ff 100%) !important;
  border: none !important;
  border-radius: 8px !important;
  box-shadow: 0 4px 15px rgba(124, 58, 237, 0.3) !important;
  transition: all 0.3s ease !important;
}

.tech-btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(124, 58, 237, 0.5) !important;
}

/* 表格样式 */
.tech-table :deep(.ant-table) {
  background: transparent;
}

.tech-table :deep(.ant-table-thead > tr > th) {
  background: rgba(124, 58, 237, 0.1);
  color: #fff;
  border-bottom: 1px solid rgba(124, 58, 237, 0.2);
  font-weight: 600;
}

.tech-table :deep(.ant-table-tbody > tr > td) {
  background: transparent;
  color: rgba(255, 255, 255, 0.8);
  border-bottom: 1px solid rgba(255, 255, 255, 0.05);
}

.tech-table :deep(.ant-table-tbody > tr:hover > td) {
  background: rgba(124, 58, 237, 0.1);
}

/* 封面图片 */
.cover-image {
  border-radius: 8px;
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.no-cover {
  width: 80px;
  height: 60px;
  background: rgba(255, 255, 255, 0.05);
  display: flex;
  align-items: center;
  justify-content: center;
  color: rgba(255, 255, 255, 0.4);
  font-size: 12px;
  border-radius: 8px;
  border: 1px dashed rgba(255, 255, 255, 0.1);
}

/* 提示词文本 */
.prompt-text {
  max-width: 200px;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  color: rgba(255, 255, 255, 0.7);
}

/* 代码类型标签 */
.code-type-tag {
  background: rgba(0, 240, 255, 0.1);
  color: #00f0ff;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-family: 'JetBrains Mono', monospace;
}

/* 精选标签 */
.featured-tag {
  background: linear-gradient(135deg, #faad14 0%, #ffc53d 100%);
  color: #000;
  border: none;
  font-weight: 600;
}

.priority-text {
  color: rgba(255, 255, 255, 0.6);
}

/* 时间文本 */
.time-text {
  color: rgba(255, 255, 255, 0.6);
  font-family: 'JetBrains Mono', monospace;
  font-size: 12px;
}

.text-gray {
  color: rgba(255, 255, 255, 0.4);
}

/* 操作按钮 */
.action-btn {
  border-radius: 6px;
  transition: all 0.3s ease;
}

.action-btn:hover {
  transform: translateY(-1px);
}

.edit-btn {
  background: linear-gradient(135deg, #7c3aed 0%, #00f0ff 100%) !important;
  border: none !important;
}

.featured-btn {
  background: linear-gradient(135deg, #faad14 0%, #ffc53d 100%) !important;
  border: none !important;
  color: #000 !important;
}

.unfeatured-btn {
  background: rgba(255, 255, 255, 0.1) !important;
  border: 1px solid rgba(255, 255, 255, 0.2) !important;
  color: rgba(255, 255, 255, 0.7) !important;
}

.delete-btn {
  background: rgba(255, 77, 79, 0.2) !important;
  border: 1px solid rgba(255, 77, 79, 0.3) !important;
}

.delete-btn:hover {
  background: rgba(255, 77, 79, 0.3) !important;
}

/* 分页样式 */
.tech-table :deep(.ant-pagination-item) {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.tech-table :deep(.ant-pagination-item a) {
  color: rgba(255, 255, 255, 0.7);
}

.tech-table :deep(.ant-pagination-item-active) {
  background: linear-gradient(135deg, #7c3aed 0%, #00f0ff 100%);
  border: none;
}

.tech-table :deep(.ant-pagination-item-active a) {
  color: #fff;
}

.tech-table :deep(.ant-pagination-prev .ant-pagination-item-link,
.ant-pagination-next .ant-pagination-item-link) {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
  color: rgba(255, 255, 255, 0.7);
}

/* 响应式 */
@media (max-width: 768px) {
  .tech-admin-page {
    padding: 16px;
  }
  
  .page-header {
    flex-direction: column;
    align-items: flex-start;
  }
  
  .search-card,
  .table-card {
    padding: 16px;
  }
}
</style>
