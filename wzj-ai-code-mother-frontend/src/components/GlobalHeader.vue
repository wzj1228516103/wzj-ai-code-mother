<template>
  <a-layout-header class="tech-header">
    <a-row :wrap="false">
      <!-- 左侧：Logo和标题 -->
      <a-col flex="200px">
        <RouterLink to="/">
          <div class="header-left">
            <div class="logo-container">
              <img class="logo" src="@/assets/logo.jpg" alt="Logo" />
              <div class="logo-glow"></div>
            </div>
            <h1 class="site-title">
              <span class="title-text">子杰应用生成</span>
            </h1>
          </div>
        </RouterLink>
      </a-col>
      <!-- 中间：导航菜单 -->
      <a-col flex="auto">
        <a-menu
          v-model:selectedKeys="selectedKeys"
          mode="horizontal"
          :items="menuItems"
          @click="handleMenuClick"
          class="tech-menu"
        />
      </a-col>
      <!-- 右侧：用户操作区域 -->
      <a-col>
        <div class="user-login-status">
          <div v-if="loginUserStore.loginUser.id">
            <a-dropdown>
              <a-space class="user-info">
                <a-avatar :src="loginUserStore.loginUser.userAvatar" class="user-avatar" />
                <span class="user-name">{{ loginUserStore.loginUser.userName ?? '无名' }}</span>
              </a-space>
              <template #overlay>
                <a-menu class="tech-dropdown-menu">
                  <a-menu-item @click="doLogout" class="tech-menu-item">
                    <LogoutOutlined />
                    退出登录
                  </a-menu-item>
                </a-menu>
              </template>
            </a-dropdown>
          </div>
          <div v-else>
            <a-button type="primary" href="/user/login" class="tech-login-btn">
              登录
            </a-button>
          </div>
        </div>
      </a-col>
    </a-row>
  </a-layout-header>
</template>

<script setup lang="ts">
import { computed, h, ref } from 'vue'
import { useRouter } from 'vue-router'
import { type MenuProps, message } from 'ant-design-vue'
import { useLoginUserStore } from '@/stores/loginUser.ts'
import { userLogout } from '@/api/userController.ts'
import { LogoutOutlined, HomeOutlined } from '@ant-design/icons-vue'

const loginUserStore = useLoginUserStore()
const router = useRouter()
// 当前选中菜单
const selectedKeys = ref<string[]>(['/'])
// 监听路由变化，更新当前选中菜单
router.afterEach((to, from, next) => {
  selectedKeys.value = [to.path]
})

// 菜单配置项
const originItems = [
  {
    key: '/',
    icon: () => h(HomeOutlined),
    label: '主页',
    title: '主页',
  },
  {
    key: '/admin/userManage',
    label: '用户管理',
    title: '用户管理',
  },
  {
    key: '/admin/appManage',
    label: '应用管理',
    title: '应用管理',
  },
  {
    key: 'others',
    label: h('a', { href: 'https://wzj-coolbi.xin/', target: '_blank' }, '子杰的个人博客'),
    title: '子杰的个人博客',
  },
  {
    key: 'others',
    label: h('a', { href: 'http://wzj-coolbi-ai.xyz/', target: '_blank' }, '江门五邑旅游助手'),
    title: '江门五邑旅游助手',
  },
]

// 过滤菜单项
const filterMenus = (menus = [] as MenuProps['items']) => {
  return menus?.filter((menu) => {
    const menuKey = menu?.key as string
    if (menuKey?.startsWith('/admin')) {
      const loginUser = loginUserStore.loginUser
      if (!loginUser || loginUser.userRole !== 'admin') {
        return false
      }
    }
    return true
  })
}

// 展示在菜单的路由数组
const menuItems = computed<MenuProps['items']>(() => filterMenus(originItems))

// 处理菜单点击
const handleMenuClick: MenuProps['onClick'] = (e) => {
  const key = e.key as string
  selectedKeys.value = [key]
  // 跳转到对应页面
  if (key.startsWith('/')) {
    router.push(key)
  }
}

// 退出登录
const doLogout = async () => {
  const res = await userLogout()
  if (res.data.code === 0) {
    loginUserStore.setLoginUser({
      userName: '未登录',
    })
    message.success('退出登录成功')
    await router.push('/user/login')
  } else {
    message.error('退出登录失败，' + res.data.message)
  }
}
</script>

<style scoped>
/* 科技风头部样式 */
.tech-header {
  background: linear-gradient(180deg, rgba(10, 10, 15, 0.98) 0%, rgba(18, 18, 26, 0.95) 100%);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border-bottom: 1px solid rgba(0, 240, 255, 0.2);
  padding: 0 24px;
  position: relative;
}

.tech-header::after {
  content: '';
  position: absolute;
  bottom: -1px;
  left: 0;
  right: 0;
  height: 1px;
  background: linear-gradient(90deg,
    transparent 0%,
    rgba(0, 240, 255, 0.5) 20%,
    rgba(124, 58, 237, 0.5) 50%,
    rgba(0, 240, 255, 0.5) 80%,
    transparent 100%
  );
}

.header-left {
  display: flex;
  align-items: center;
  gap: 12px;
}

/* Logo 容器 */
.logo-container {
  position: relative;
  width: 48px;
  height: 48px;
}

.logo {
  height: 48px;
  width: 48px;
  border-radius: 50%;
  position: relative;
  z-index: 2;
  border: 2px solid rgba(0, 240, 255, 0.3);
  transition: all 0.3s ease;
}

.logo-container:hover .logo {
  border-color: rgba(0, 240, 255, 0.8);
  box-shadow: 0 0 20px rgba(0, 240, 255, 0.5);
}

.logo-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 60px;
  height: 60px;
  background: radial-gradient(circle, rgba(0, 240, 255, 0.3) 0%, transparent 70%);
  border-radius: 50%;
  z-index: 1;
  opacity: 0.6;
  animation: pulse-glow 3s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { transform: translate(-50%, -50%) scale(1); opacity: 0.6; }
  50% { transform: translate(-50%, -50%) scale(1.1); opacity: 0.8; }
}

/* 网站标题 */
.site-title {
  margin: 0;
  font-size: 18px;
  font-weight: 700;
  position: relative;
}

.title-text {
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 50%, #f472b6 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  background-size: 200% 200%;
  animation: gradient-shift 5s ease infinite;
}

@keyframes gradient-shift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

/* 科技风菜单 */
.tech-menu {
  background: transparent !important;
  border-bottom: none !important;
}

.tech-menu :deep(.ant-menu-item) {
  color: rgba(255, 255, 255, 0.7) !important;
  transition: all 0.3s ease;
  position: relative;
}

.tech-menu :deep(.ant-menu-item:hover) {
  color: #00f0ff !important;
}

.tech-menu :deep(.ant-menu-item::after) {
  content: '';
  position: absolute;
  bottom: 0;
  left: 50%;
  width: 0;
  height: 2px;
  background: linear-gradient(90deg, #00f0ff, #7c3aed);
  transition: all 0.3s ease;
  transform: translateX(-50%);
}

.tech-menu :deep(.ant-menu-item:hover::after) {
  width: 80%;
}

.tech-menu :deep(.ant-menu-item-selected) {
  color: #00f0ff !important;
  background: rgba(0, 240, 255, 0.1) !important;
}

.tech-menu :deep(.ant-menu-item-selected::after) {
  width: 80%;
}

/* 用户信息 */
.user-info {
  cursor: pointer;
  padding: 8px 12px;
  border-radius: 8px;
  transition: all 0.3s ease;
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.user-info:hover {
  background: rgba(0, 240, 255, 0.1);
  border-color: rgba(0, 240, 255, 0.3);
  box-shadow: 0 0 15px rgba(0, 240, 255, 0.2);
}

.user-avatar {
  border: 2px solid rgba(0, 240, 255, 0.3);
  transition: all 0.3s ease;
}

.user-info:hover .user-avatar {
  border-color: rgba(0, 240, 255, 0.8);
  box-shadow: 0 0 10px rgba(0, 240, 255, 0.3);
}

.user-name {
  color: rgba(255, 255, 255, 0.9);
  font-weight: 500;
}

/* 登录按钮 */
.tech-login-btn {
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 100%) !important;
  border: none !important;
  border-radius: 8px !important;
  padding: 8px 24px !important;
  font-weight: 600 !important;
  box-shadow: 0 4px 15px rgba(0, 240, 255, 0.3) !important;
  transition: all 0.3s ease !important;
}

.tech-login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(0, 240, 255, 0.5) !important;
}

/* 下拉菜单 */
.tech-dropdown-menu {
  background: rgba(18, 18, 26, 0.95) !important;
  backdrop-filter: blur(20px);
  border: 1px solid rgba(0, 240, 255, 0.2);
  border-radius: 8px;
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.5), 0 0 20px rgba(0, 240, 255, 0.1);
}

.tech-menu-item {
  color: rgba(255, 255, 255, 0.8) !important;
  transition: all 0.3s ease;
}

.tech-menu-item:hover {
  background: rgba(0, 240, 255, 0.1) !important;
  color: #00f0ff !important;
}
</style>
