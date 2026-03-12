<template>
  <div id="userManagePage">
    <!-- 背景装饰 -->
    <div class="tech-bg">
      <div class="grid-overlay"></div>
      <div class="glow-orb orb-1"></div>
      <div class="glow-orb orb-2"></div>
    </div>

    <!-- 页面标题 -->
    <div class="page-header">
      <div class="header-icon">
        <TeamOutlined />
      </div>
      <div class="header-content">
        <h1 class="page-title">用户管理</h1>
        <p class="page-subtitle">管理系统内所有用户信息</p>
      </div>
    </div>

    <!-- 搜索表单卡片 -->
    <div class="search-card">
      <div class="card-decoration top-left"></div>
      <div class="card-decoration top-right"></div>
      <div class="card-decoration bottom-left"></div>
      <div class="card-decoration bottom-right"></div>
      
      <a-form layout="inline" :model="searchParams" @finish="doSearch">
        <a-form-item label="账号">
          <a-input 
            v-model:value="searchParams.userAccount" 
            placeholder="输入账号"
            class="tech-input"
          />
        </a-form-item>
        <a-form-item label="用户名">
          <a-input 
            v-model:value="searchParams.userName" 
            placeholder="输入用户名"
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
        class="tech-table"
      >
        <template #bodyCell="{ column, record }">
          <template v-if="column.dataIndex === 'userAvatar'">
            <div class="avatar-wrapper">
              <a-image 
                :src="record.userAvatar" 
                :width="48"
                :height="48"
                class="user-avatar"
              />
            </div>
          </template>
          <template v-else-if="column.dataIndex === 'userRole'">
            <span 
              class="role-tag"
              :class="record.userRole === 'admin' ? 'admin-role' : 'user-role'"
            >
              <span class="role-dot"></span>
              {{ record.userRole === 'admin' ? '管理员' : '普通用户' }}
            </span>
          </template>
          <template v-else-if="column.dataIndex === 'createTime'">
            <span class="time-text">{{ dayjs(record.createTime).format('YYYY-MM-DD HH:mm:ss') }}</span>
          </template>
          <template v-else-if="column.key === 'action'">
            <a-popconfirm
              title="确定要删除该用户吗？"
              @confirm="doDelete(record.id)"
              okText="确定"
              cancelText="取消"
            >
              <a-button danger class="delete-btn">
                <DeleteOutlined />
                删除
              </a-button>
            </a-popconfirm>
          </template>
        </template>
      </a-table>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { computed, onMounted, reactive, ref } from 'vue'
import { deleteUser, listUserVoByPage } from '@/api/userController.ts'
import { message } from 'ant-design-vue'
import dayjs from 'dayjs'
import { TeamOutlined, SearchOutlined, DeleteOutlined } from '@ant-design/icons-vue'

const columns = [
  {
    title: 'ID',
    dataIndex: 'id',
    width: 80,
  },
  {
    title: '账号',
    dataIndex: 'userAccount',
    width: 150,
  },
  {
    title: '用户名',
    dataIndex: 'userName',
    width: 150,
  },
  {
    title: '头像',
    dataIndex: 'userAvatar',
    width: 100,
    align: 'center',
  },
  {
    title: '简介',
    dataIndex: 'userProfile',
    width: 200,
    ellipsis: true,
  },
  {
    title: '用户角色',
    dataIndex: 'userRole',
    width: 120,
    align: 'center',
  },
  {
    title: '创建时间',
    dataIndex: 'createTime',
    width: 180,
  },
  {
    title: '操作',
    key: 'action',
    width: 120,
    align: 'center',
  },
]

// 展示的数据
const data = ref<API.UserVO[]>([])
const total = ref(0)

// 搜索条件
const searchParams = reactive<API.UserQueryRequest>({
  pageNum: 1,
  pageSize: 10,
})

// 获取数据
const fetchData = async () => {
  const res = await listUserVoByPage({
    ...searchParams,
  })
  if (res.data.data) {
    data.value = res.data.data.records ?? []
    total.value = res.data.data.totalRow ?? 0
  } else {
    message.error('获取数据失败，' + res.data.message)
  }
}

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

// 表格分页变化时的操作
const doTableChange = (page: { current: number; pageSize: number }) => {
  searchParams.pageNum = page.current
  searchParams.pageSize = page.pageSize
  fetchData()
}

// 搜索数据
const doSearch = () => {
  // 重置页码
  searchParams.pageNum = 1
  fetchData()
}

// 删除数据
const doDelete = async (id: string) => {
  if (!id) {
    return
  }
  const res = await deleteUser({ id })
  if (res.data.code === 0) {
    message.success('删除成功')
    // 刷新数据
    fetchData()
  } else {
    message.error('删除失败')
  }
}

// 页面加载时请求一次
onMounted(() => {
  fetchData()
})
</script>

<style scoped>
#userManagePage {
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

.tech-input {
  background: rgba(30, 30, 40, 0.8) !important;
  border: 1px solid rgba(99, 102, 241, 0.3) !important;
  border-radius: 8px !important;
  color: #e5e7eb !important;
}

.tech-input::placeholder {
  color: #6b7280 !important;
}

.tech-input:hover,
.tech-input:focus {
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

/* 头像样式 */
.avatar-wrapper {
  display: flex;
  justify-content: center;
}

.user-avatar {
  border-radius: 50%;
  border: 2px solid rgba(99, 102, 241, 0.3);
  overflow: hidden;
}

:deep(.user-avatar img) {
  border-radius: 50%;
}

/* 角色标签 */
.role-tag {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  padding: 4px 12px;
  border-radius: 20px;
  font-size: 12px;
  font-weight: 500;
}

.role-tag.admin-role {
  background: rgba(34, 197, 94, 0.15);
  color: #4ade80;
  border: 1px solid rgba(34, 197, 94, 0.3);
}

.role-tag.user-role {
  background: rgba(59, 130, 246, 0.15);
  color: #60a5fa;
  border: 1px solid rgba(59, 130, 246, 0.3);
}

.role-dot {
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: currentColor;
}

/* 时间文本 */
.time-text {
  color: #9ca3af;
  font-size: 13px;
}

/* 删除按钮 */
.delete-btn {
  display: inline-flex;
  align-items: center;
  gap: 4px;
  background: rgba(239, 68, 68, 0.1) !important;
  border: 1px solid rgba(239, 68, 68, 0.3) !important;
  color: #f87171 !important;
  border-radius: 6px !important;
  font-weight: 500;
  transition: all 0.3s ease;
}

.delete-btn:hover {
  background: rgba(239, 68, 68, 0.2) !important;
  border-color: rgba(239, 68, 68, 0.5) !important;
  transform: translateY(-1px);
}

/* 响应式 */
@media (max-width: 768px) {
  #userManagePage {
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
