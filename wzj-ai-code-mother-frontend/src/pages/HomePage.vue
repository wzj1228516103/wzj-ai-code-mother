<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { useLoginUserStore } from '@/stores/loginUser'
import { addApp, listMyAppVoByPage, listGoodAppVoByPage } from '@/api/appController'
import { getDeployUrl } from '@/config/env'
import AppCard from '@/components/AppCard.vue'
import { RocketOutlined, ThunderboltOutlined } from '@ant-design/icons-vue'

const router = useRouter()
const loginUserStore = useLoginUserStore()

// 用户提示词
const userPrompt = ref('')
const creating = ref(false)

// 我的应用数据
const myApps = ref<API.AppVO[]>([])
const myAppsPage = reactive({
  current: 1,
  pageSize: 6,
  total: 0,
})

// 精选应用数据
const featuredApps = ref<API.AppVO[]>([])
const featuredAppsPage = reactive({
  current: 1,
  pageSize: 6,
  total: 0,
})

// 设置提示词
const setPrompt = (prompt: string) => {
  userPrompt.value = prompt
}

// 创建应用
const createApp = async () => {
  if (!userPrompt.value.trim()) {
    message.warning('请输入应用描述')
    return
  }

  if (!loginUserStore.loginUser.id) {
    message.warning('请先登录')
    await router.push('/user/login')
    return
  }

  creating.value = true
  try {
    const res = await addApp({
      initPrompt: userPrompt.value.trim(),
    })

    if (res.data.code === 0 && res.data.data) {
      message.success('应用创建成功')
      // 跳转到对话页面，确保ID是字符串类型
      const appId = String(res.data.data)
      await router.push(`/app/chat/${appId}`)
    } else {
      message.error('创建失败：' + res.data.message)
    }
  } catch (error) {
    console.error('创建应用失败：', error)
    message.error('创建失败，请重试')
  } finally {
    creating.value = false
  }
}

// 加载我的应用
const loadMyApps = async () => {
  if (!loginUserStore.loginUser.id) {
    return
  }

  try {
    const res = await listMyAppVoByPage({
      pageNum: myAppsPage.current,
      pageSize: myAppsPage.pageSize,
      sortField: 'createTime',
      sortOrder: 'desc',
    })

    if (res.data.code === 0 && res.data.data) {
      myApps.value = res.data.data.records || []
      myAppsPage.total = res.data.data.totalRow || 0
    }
  } catch (error) {
    console.error('加载我的应用失败：', error)
  }
}

// 加载精选应用
const loadFeaturedApps = async () => {
  try {
    const res = await listGoodAppVoByPage({
      pageNum: featuredAppsPage.current,
      pageSize: featuredAppsPage.pageSize,
      sortField: 'createTime',
      sortOrder: 'desc',
    })

    if (res.data.code === 0 && res.data.data) {
      featuredApps.value = res.data.data.records || []
      featuredAppsPage.total = res.data.data.totalRow || 0
    }
  } catch (error) {
    console.error('加载精选应用失败：', error)
  }
}

// 查看对话
const viewChat = (appId: string | number | undefined) => {
  if (appId) {
    router.push(`/app/chat/${appId}?view=1`)
  }
}

// 查看作品
const viewWork = (app: API.AppVO) => {
  if (app.deployKey) {
    const url = getDeployUrl(app.deployKey)
    window.open(url, '_blank')
  }
}

// 页面加载时获取数据
onMounted(() => {
  loadMyApps()
  loadFeaturedApps()

  // 鼠标跟随光效
  const handleMouseMove = (e: MouseEvent) => {
    const { clientX, clientY } = e
    const { innerWidth, innerHeight } = window
    const x = (clientX / innerWidth) * 100
    const y = (clientY / innerHeight) * 100

    document.documentElement.style.setProperty('--mouse-x', `${x}%`)
    document.documentElement.style.setProperty('--mouse-y', `${y}%`)
  }

  document.addEventListener('mousemove', handleMouseMove)

  // 清理事件监听器
  return () => {
    document.removeEventListener('mousemove', handleMouseMove)
  }
})
</script>

<template>
  <div class="tech-home-page">
    <!-- 网格背景 -->
    <div class="tech-grid-bg"></div>
    
    <!-- 装饰光效 -->
    <div class="glow-orb glow-orb-1"></div>
    <div class="glow-orb glow-orb-2"></div>
    <div class="glow-orb glow-orb-3"></div>
    
    <!-- 扫描线效果 -->
    <div class="scan-line"></div>

    <div class="container">
      <!-- 网站标题和描述 -->
      <div class="hero-section">
        <div class="tech-badge">
          <ThunderboltOutlined />
          AI POWERED
        </div>
        <h1 class="hero-title">
          <span class="gradient-text">子杰 AI</span>
          <span class="title-divider">|</span>
          应用生成平台
        </h1>
        <p class="hero-description">
          <span class="code-bracket">&lt;</span>
          一句话轻松创建网站应用
          <span class="code-bracket">/&gt;</span>
        </p>
        <div class="tech-stats">
          <div class="stat-item">
            <span class="stat-value">10K+</span>
            <span class="stat-label">应用生成</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-value">99%</span>
            <span class="stat-label">成功率</span>
          </div>
          <div class="stat-divider"></div>
          <div class="stat-item">
            <span class="stat-value">&lt;1min</span>
            <span class="stat-label">生成时间</span>
          </div>
        </div>
      </div>

      <!-- 用户提示词输入框 -->
      <div class="input-section">
        <div class="input-wrapper">
          <div class="input-corner input-corner-tl"></div>
          <div class="input-corner input-corner-tr"></div>
          <div class="input-corner input-corner-bl"></div>
          <div class="input-corner input-corner-br"></div>
          <a-textarea
            v-model:value="userPrompt"
            placeholder="帮我创建个人博客网站..."
            :rows="4"
            :maxlength="1000"
            class="tech-textarea"
          />
          <div class="input-actions">
            <a-button 
              type="primary" 
              size="large" 
              @click="createApp" 
              :loading="creating"
              class="create-btn"
            >
              <RocketOutlined />
              生成应用
            </a-button>
          </div>
        </div>
      </div>

      <!-- 快捷按钮 -->
      <div class="quick-actions">
        <a-button
          class="tech-quick-btn"
          @click="
            setPrompt(
              '创建一个现代化的个人博客网站，包含文章列表、详情页、分类标签、搜索功能、评论系统和个人简介页面。采用简洁的设计风格，支持响应式布局，文章支持Markdown格式，首页展示最新文章和热门推荐。',
            )
          "
        >
          <span class="btn-icon">📝</span>
          个人博客网站
        </a-button>
        <a-button
          class="tech-quick-btn"
          @click="
            setPrompt(
              '设计一个专业的企业官网，包含公司介绍、产品服务展示、新闻资讯、联系我们等页面。采用商务风格的设计，包含轮播图、产品展示卡片、团队介绍、客户案例展示，支持多语言切换和在线客服功能。',
            )
          "
        >
          <span class="btn-icon">🏢</span>
          企业官网
        </a-button>
        <a-button
          class="tech-quick-btn"
          @click="
            setPrompt(
              '构建一个功能完整的在线商城，包含商品展示、购物车、用户注册登录、订单管理、支付结算等功能。设计现代化的商品卡片布局，支持商品搜索筛选、用户评价、优惠券系统和会员积分功能。',
            )
          "
        >
          <span class="btn-icon">🛒</span>
          在线商城
        </a-button>
        <a-button
          class="tech-quick-btn"
          @click="
            setPrompt(
              '制作一个精美的作品展示网站，适合设计师、摄影师、艺术家等创作者。包含作品画廊、项目详情页、个人简历、联系方式等模块。采用瀑布流或网格布局展示作品，支持图片放大预览和作品分类筛选。',
            )
          "
        >
          <span class="btn-icon">🎨</span>
          作品展示网站
        </a-button>
      </div>

      <!-- 我的作品 -->
      <div class="section" v-if="loginUserStore.loginUser.id">
        <div class="section-header">
          <div class="section-title-wrapper">
            <div class="title-line"></div>
            <h2 class="section-title">我的作品</h2>
            <div class="title-line"></div>
          </div>
          <span class="section-subtitle">MY PROJECTS</span>
        </div>
        <div class="app-grid">
          <AppCard
            v-for="app in myApps"
            :key="app.id"
            :app="app"
            @view-chat="viewChat"
            @view-work="viewWork"
          />
        </div>
        <div class="pagination-wrapper" v-if="myAppsPage.total > 0">
          <a-pagination
            v-model:current="myAppsPage.current"
            v-model:page-size="myAppsPage.pageSize"
            :total="myAppsPage.total"
            :show-size-changer="false"
            :show-total="(total: number) => `共 ${total} 个应用`"
            @change="loadMyApps"
            class="tech-pagination"
          />
        </div>
      </div>

      <!-- 精选案例 -->
      <div class="section">
        <div class="section-header">
          <div class="section-title-wrapper">
            <div class="title-line"></div>
            <h2 class="section-title">精选案例</h2>
            <div class="title-line"></div>
          </div>
          <span class="section-subtitle">FEATURED CASES</span>
        </div>
        <div class="featured-grid">
          <AppCard
            v-for="app in featuredApps"
            :key="app.id"
            :app="app"
            :featured="true"
            @view-chat="viewChat"
            @view-work="viewWork"
          />
        </div>
        <div class="pagination-wrapper" v-if="featuredAppsPage.total > 0">
          <a-pagination
            v-model:current="featuredAppsPage.current"
            v-model:page-size="featuredAppsPage.pageSize"
            :total="featuredAppsPage.total"
            :show-size-changer="false"
            :show-total="(total: number) => `共 ${total} 个案例`"
            @change="loadFeaturedApps"
            class="tech-pagination"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
/* 科技风首页 */
.tech-home-page {
  width: 100%;
  margin: 0;
  padding: 0;
  min-height: 100vh;
  background: linear-gradient(135deg, #0a0a0f 0%, #12121a 50%, #1a1a25 100%);
  position: relative;
  overflow: hidden;
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
  background-size: 60px 60px;
  animation: gridMove 20s linear infinite;
}

@keyframes gridMove {
  0% { transform: translate(0, 0); }
  100% { transform: translate(60px, 60px); }
}

/* 发光球体装饰 */
.glow-orb {
  position: fixed;
  border-radius: 50%;
  filter: blur(100px);
  pointer-events: none;
  z-index: 0;
}

.glow-orb-1 {
  width: 500px;
  height: 500px;
  background: rgba(0, 240, 255, 0.1);
  top: -150px;
  right: -100px;
  animation: float-orb 12s ease-in-out infinite;
}

.glow-orb-2 {
  width: 400px;
  height: 400px;
  background: rgba(124, 58, 237, 0.1);
  bottom: 20%;
  left: -100px;
  animation: float-orb 15s ease-in-out infinite reverse;
}

.glow-orb-3 {
  width: 300px;
  height: 300px;
  background: rgba(236, 72, 153, 0.08);
  top: 40%;
  right: 10%;
  animation: float-orb 10s ease-in-out infinite;
}

@keyframes float-orb {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(30px, -30px) scale(1.1); }
}

/* 扫描线效果 */
.scan-line {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, rgba(0, 240, 255, 0.5), transparent);
  animation: scan 8s linear infinite;
  pointer-events: none;
  z-index: 1;
}

@keyframes scan {
  0% { transform: translateY(-100vh); }
  100% { transform: translateY(100vh); }
}

.container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
  position: relative;
  z-index: 2;
  width: 100%;
  box-sizing: border-box;
}

/* 英雄区域 */
.hero-section {
  text-align: center;
  padding: 80px 0 40px;
  margin-bottom: 40px;
  position: relative;
}

.tech-badge {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  background: rgba(0, 240, 255, 0.1);
  border: 1px solid rgba(0, 240, 255, 0.3);
  border-radius: 20px;
  padding: 6px 16px;
  font-size: 12px;
  color: #00f0ff;
  font-family: 'JetBrains Mono', monospace;
  letter-spacing: 1px;
  margin-bottom: 24px;
}

.hero-title {
  font-size: 48px;
  font-weight: 700;
  margin: 0 0 16px;
  line-height: 1.2;
  color: #fff;
  letter-spacing: -1px;
}

.gradient-text {
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 50%, #ec4899 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
  animation: gradientShift 5s ease infinite;
  background-size: 200% 200%;
}

@keyframes gradientShift {
  0%, 100% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
}

.title-divider {
  color: rgba(255, 255, 255, 0.3);
  margin: 0 12px;
}

.hero-description {
  font-size: 18px;
  margin: 0 0 32px;
  color: rgba(255, 255, 255, 0.6);
}

.code-bracket {
  color: #00f0ff;
  font-family: 'JetBrains Mono', monospace;
  margin: 0 8px;
}

/* 统计数据 */
.tech-stats {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 32px;
  margin-top: 32px;
}

.stat-item {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.stat-value {
  font-size: 24px;
  font-weight: 700;
  color: #00f0ff;
  font-family: 'JetBrains Mono', monospace;
}

.stat-label {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.5);
  letter-spacing: 1px;
}

.stat-divider {
  width: 1px;
  height: 40px;
  background: linear-gradient(180deg, transparent, rgba(0, 240, 255, 0.3), transparent);
}

/* 输入区域 */
.input-section {
  position: relative;
  margin: 0 auto 40px;
  max-width: 800px;
}

.input-wrapper {
  position: relative;
  background: rgba(18, 18, 26, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(0, 240, 255, 0.2);
  border-radius: 16px;
  padding: 24px;
  box-shadow: 
    0 20px 60px rgba(0, 0, 0, 0.5),
    0 0 40px rgba(0, 240, 255, 0.1);
}

.input-corner {
  position: absolute;
  width: 12px;
  height: 12px;
  border: 2px solid rgba(0, 240, 255, 0.5);
}

.input-corner-tl {
  top: -1px;
  left: -1px;
  border-right: none;
  border-bottom: none;
  border-radius: 16px 0 0 0;
}

.input-corner-tr {
  top: -1px;
  right: -1px;
  border-left: none;
  border-bottom: none;
  border-radius: 0 16px 0 0;
}

.input-corner-bl {
  bottom: -1px;
  left: -1px;
  border-right: none;
  border-top: none;
  border-radius: 0 0 0 16px;
}

.input-corner-br {
  bottom: -1px;
  right: -1px;
  border-left: none;
  border-top: none;
  border-radius: 0 0 16px 0;
}

.tech-textarea {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 12px !important;
  font-size: 16px;
  padding: 16px;
  color: #fff !important;
  resize: none;
}

.tech-textarea::placeholder {
  color: rgba(255, 255, 255, 0.4);
}

.tech-textarea:hover {
  border-color: rgba(0, 240, 255, 0.3) !important;
}

.tech-textarea:focus {
  border-color: rgba(0, 240, 255, 0.5) !important;
  box-shadow: 0 0 20px rgba(0, 240, 255, 0.1) !important;
}

.input-actions {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.create-btn {
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 100%) !important;
  border: none !important;
  border-radius: 8px !important;
  padding: 0 24px !important;
  height: 44px !important;
  font-size: 15px;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(0, 240, 255, 0.3) !important;
  transition: all 0.3s ease !important;
}

.create-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(0, 240, 255, 0.5) !important;
}

/* 快捷按钮 */
.quick-actions {
  display: flex;
  gap: 16px;
  justify-content: center;
  margin-bottom: 60px;
  flex-wrap: wrap;
}

.tech-quick-btn {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 25px !important;
  padding: 10px 20px !important;
  height: auto !important;
  color: rgba(255, 255, 255, 0.8) !important;
  font-size: 14px;
  transition: all 0.3s ease !important;
  display: flex;
  align-items: center;
  gap: 8px;
}

.tech-quick-btn:hover {
  background: rgba(0, 240, 255, 0.1) !important;
  border-color: rgba(0, 240, 255, 0.3) !important;
  color: #00f0ff !important;
  transform: translateY(-2px);
  box-shadow: 0 8px 25px rgba(0, 240, 255, 0.2);
}

.btn-icon {
  font-size: 16px;
}

/* 区域标题 */
.section {
  margin-bottom: 60px;
}

.section-header {
  text-align: center;
  margin-bottom: 32px;
}

.section-title-wrapper {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 16px;
  margin-bottom: 8px;
}

.title-line {
  width: 60px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(0, 240, 255, 0.5), transparent);
}

.section-title {
  font-size: 28px;
  font-weight: 600;
  color: #fff;
  margin: 0;
}

.section-subtitle {
  font-size: 12px;
  color: rgba(255, 255, 255, 0.4);
  letter-spacing: 3px;
  font-family: 'JetBrains Mono', monospace;
}

/* 我的作品网格 */
.app-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

/* 精选案例网格 */
.featured-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));
  gap: 24px;
  margin-bottom: 32px;
}

/* 分页 */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 32px;
}

.tech-pagination :deep(.ant-pagination-item) {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.tech-pagination :deep(.ant-pagination-item a) {
  color: rgba(255, 255, 255, 0.6);
}

.tech-pagination :deep(.ant-pagination-item-active) {
  background: rgba(0, 240, 255, 0.2);
  border-color: rgba(0, 240, 255, 0.5);
}

.tech-pagination :deep(.ant-pagination-item-active a) {
  color: #00f0ff;
}

.tech-pagination :deep(.ant-pagination-prev),
.tech-pagination :deep(.ant-pagination-next) {
  background: rgba(255, 255, 255, 0.05);
  border: 1px solid rgba(255, 255, 255, 0.1);
}

.tech-pagination :deep(.ant-pagination-prev button),
.tech-pagination :deep(.ant-pagination-next button) {
  color: rgba(255, 255, 255, 0.6);
}

/* 响应式设计 */
@media (max-width: 768px) {
  .hero-title {
    font-size: 32px;
  }

  .hero-description {
    font-size: 16px;
  }

  .tech-stats {
    gap: 16px;
  }

  .stat-value {
    font-size: 18px;
  }

  .app-grid,
  .featured-grid {
    grid-template-columns: 1fr;
  }

  .quick-actions {
    justify-content: center;
  }

  .input-wrapper {
    padding: 16px;
  }
}
</style>
