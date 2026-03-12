<template>
  <div class="tech-login-page">
    <!-- 网格背景 -->
    <div class="tech-grid-bg"></div>
    
    <!-- 装饰光效 -->
    <div class="glow-orb glow-orb-1"></div>
    <div class="glow-orb glow-orb-2"></div>
    
    <!-- 登录卡片 -->
    <div class="login-card">
      <!-- 角落装饰 -->
      <div class="corner corner-tl"></div>
      <div class="corner corner-tr"></div>
      <div class="corner corner-bl"></div>
      <div class="corner corner-br"></div>
      
      <div class="card-header">
        <div class="logo-container">
          <img class="logo" src="@/assets/logo.jpg" alt="Logo" />
          <div class="logo-glow"></div>
        </div>
        <h2 class="title">
          <span class="title-highlight">子杰 AI</span> 应用生成
        </h2>
        <p class="subtitle">用户登录</p>
      </div>
      
      <div class="desc">
        <span class="code-tag">&lt;/&gt;</span>
        不写一行代码，生成完整应用
        <span class="code-tag">&lt;/&gt;</span>
      </div>
      
      <a-form 
        :model="formState" 
        name="login" 
        autocomplete="off" 
        @finish="handleSubmit"
        class="login-form"
      >
        <a-form-item name="userAccount" :rules="[{ required: true, message: '请输入账号' }]">
          <a-input 
            v-model:value="formState.userAccount" 
            placeholder="请输入账号"
            class="tech-input"
            size="large"
          >
            <template #prefix>
              <UserOutlined class="input-icon" />
            </template>
          </a-input>
        </a-form-item>
        
        <a-form-item
          name="userPassword"
          :rules="[
            { required: true, message: '请输入密码' },
            { min: 8, message: '密码长度不能小于 8 位' },
          ]"
        >
          <a-input-password 
            v-model:value="formState.userPassword" 
            placeholder="请输入密码"
            class="tech-input"
            size="large"
          >
            <template #prefix>
              <LockOutlined class="input-icon" />
            </template>
          </a-input-password>
        </a-form-item>
        
        <div class="tips">
          <span class="tip-text">没有账号？</span>
          <RouterLink to="/user/register" class="register-link">
            立即注册
            <ArrowRightOutlined class="link-arrow" />
          </RouterLink>
        </div>
        
        <a-form-item>
          <a-button 
            type="primary" 
            html-type="submit" 
            class="login-btn"
            size="large"
            :loading="loading"
          >
            <LoginOutlined />
            登录
          </a-button>
        </a-form-item>
      </a-form>
      
      <!-- 底部装饰线 -->
      <div class="card-footer-line">
        <span class="line-segment"></span>
        <span class="line-dot"></span>
        <span class="line-segment"></span>
      </div>
    </div>
    
    <!-- 底部技术信息 -->
    <div class="tech-footer-info">
      <span class="tech-text">SECURE CONNECTION</span>
      <span class="tech-divider">|</span>
      <span class="tech-text">SSL ENCRYPTED</span>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { reactive, ref } from 'vue'
import { userLogin } from '@/api/userController.ts'
import { useLoginUserStore } from '@/stores/loginUser.ts'
import { useRouter } from 'vue-router'
import { message } from 'ant-design-vue'
import { 
  UserOutlined, 
  LockOutlined, 
  ArrowRightOutlined,
  LoginOutlined 
} from '@ant-design/icons-vue'

const formState = reactive<API.UserLoginRequest>({
  userAccount: '',
  userPassword: '',
})

const loading = ref(false)
const router = useRouter()
const loginUserStore = useLoginUserStore()

/**
 * 提交表单
 * @param values
 */
const handleSubmit = async (values: any) => {
  loading.value = true
  try {
    const res = await userLogin(values)
    // 登录成功，把登录态保存到全局状态中
    if (res.data.code === 0 && res.data.data) {
      await loginUserStore.fetchLoginUser()
      message.success('登录成功')
      router.push({
        path: '/',
        replace: true,
      })
    } else {
      message.error('登录失败，' + res.data.message)
    }
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
/* 科技风登录页面 */
.tech-login-page {
  min-height: 100vh;
  background: linear-gradient(135deg, #0a0a0f 0%, #12121a 50%, #1a1a25 100%);
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  padding: 20px;
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
  background: rgba(0, 240, 255, 0.15);
  top: -100px;
  right: -100px;
  animation: float-orb 8s ease-in-out infinite;
}

.glow-orb-2 {
  width: 300px;
  height: 300px;
  background: rgba(124, 58, 237, 0.15);
  bottom: -50px;
  left: -50px;
  animation: float-orb 10s ease-in-out infinite reverse;
}

@keyframes float-orb {
  0%, 100% { transform: translate(0, 0) scale(1); }
  50% { transform: translate(30px, -30px) scale(1.1); }
}

/* 登录卡片 */
.login-card {
  background: rgba(18, 18, 26, 0.9);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(0, 240, 255, 0.2);
  border-radius: 16px;
  padding: 40px;
  width: 100%;
  max-width: 420px;
  position: relative;
  z-index: 1;
  box-shadow: 
    0 20px 60px rgba(0, 0, 0, 0.5),
    0 0 40px rgba(0, 240, 255, 0.1);
}

/* 角落装饰 */
.corner {
  position: absolute;
  width: 20px;
  height: 20px;
  border: 2px solid rgba(0, 240, 255, 0.5);
}

.corner-tl {
  top: -1px;
  left: -1px;
  border-right: none;
  border-bottom: none;
  border-radius: 16px 0 0 0;
}

.corner-tr {
  top: -1px;
  right: -1px;
  border-left: none;
  border-bottom: none;
  border-radius: 0 16px 0 0;
}

.corner-bl {
  bottom: -1px;
  left: -1px;
  border-right: none;
  border-top: none;
  border-radius: 0 0 0 16px;
}

.corner-br {
  bottom: -1px;
  right: -1px;
  border-left: none;
  border-top: none;
  border-radius: 0 0 16px 0;
}

/* 卡片头部 */
.card-header {
  text-align: center;
  margin-bottom: 24px;
}

.logo-container {
  position: relative;
  width: 64px;
  height: 64px;
  margin: 0 auto 16px;
}

.logo {
  width: 64px;
  height: 64px;
  border-radius: 50%;
  border: 2px solid rgba(0, 240, 255, 0.3);
  position: relative;
  z-index: 2;
}

.logo-glow {
  position: absolute;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
  width: 80px;
  height: 80px;
  background: radial-gradient(circle, rgba(0, 240, 255, 0.3) 0%, transparent 70%);
  border-radius: 50%;
  animation: pulse-glow 3s ease-in-out infinite;
}

@keyframes pulse-glow {
  0%, 100% { opacity: 0.6; transform: translate(-50%, -50%) scale(1); }
  50% { opacity: 0.9; transform: translate(-50%, -50%) scale(1.1); }
}

.title {
  font-size: 24px;
  font-weight: 700;
  color: #fff;
  margin: 0 0 8px 0;
}

.title-highlight {
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 100%);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  background-clip: text;
}

.subtitle {
  font-size: 14px;
  color: rgba(255, 255, 255, 0.5);
  margin: 0;
  letter-spacing: 2px;
}

/* 描述文字 */
.desc {
  text-align: center;
  color: rgba(255, 255, 255, 0.6);
  margin-bottom: 32px;
  font-size: 14px;
}

.code-tag {
  color: #00f0ff;
  font-family: 'JetBrains Mono', monospace;
  margin: 0 8px;
}

/* 表单样式 */
.login-form :deep(.ant-form-item) {
  margin-bottom: 20px;
}

.tech-input {
  background: rgba(255, 255, 255, 0.05) !important;
  border: 1px solid rgba(255, 255, 255, 0.1) !important;
  border-radius: 8px !important;
  color: #fff !important;
}

.tech-input:hover {
  border-color: rgba(0, 240, 255, 0.5) !important;
}

.tech-input:focus {
  border-color: #00f0ff !important;
  box-shadow: 0 0 0 2px rgba(0, 240, 255, 0.2) !important;
}

.input-icon {
  color: rgba(0, 240, 255, 0.7);
  font-size: 16px;
}

/* 提示文字 */
.tips {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.tip-text {
  color: rgba(255, 255, 255, 0.5);
  font-size: 13px;
}

.register-link {
  color: #00f0ff;
  text-decoration: none;
  font-size: 13px;
  display: flex;
  align-items: center;
  gap: 4px;
  transition: all 0.3s ease;
}

.register-link:hover {
  color: #7c3aed;
  text-shadow: 0 0 10px rgba(0, 240, 255, 0.5);
}

.link-arrow {
  font-size: 12px;
  transition: transform 0.3s ease;
}

.register-link:hover .link-arrow {
  transform: translateX(4px);
}

/* 登录按钮 */
.login-btn {
  width: 100%;
  height: 44px;
  background: linear-gradient(135deg, #00f0ff 0%, #7c3aed 100%) !important;
  border: none !important;
  border-radius: 8px !important;
  font-size: 16px;
  font-weight: 600;
  box-shadow: 0 4px 15px rgba(0, 240, 255, 0.3) !important;
  transition: all 0.3s ease !important;
}

.login-btn:hover {
  transform: translateY(-2px);
  box-shadow: 0 6px 25px rgba(0, 240, 255, 0.5) !important;
}

/* 卡片底部装饰线 */
.card-footer-line {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 8px;
  margin-top: 24px;
  padding-top: 24px;
  border-top: 1px solid rgba(255, 255, 255, 0.1);
}

.line-segment {
  width: 40px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(0, 240, 255, 0.5), transparent);
}

.line-dot {
  width: 6px;
  height: 6px;
  background: #00f0ff;
  border-radius: 50%;
  box-shadow: 0 0 10px rgba(0, 240, 255, 0.8);
}

/* 底部技术信息 */
.tech-footer-info {
  margin-top: 32px;
  display: flex;
  align-items: center;
  gap: 16px;
  font-family: 'JetBrains Mono', monospace;
  font-size: 11px;
  color: rgba(255, 255, 255, 0.3);
  letter-spacing: 1px;
}

.tech-divider {
  color: rgba(0, 240, 255, 0.3);
}

/* 响应式 */
@media (max-width: 480px) {
  .login-card {
    padding: 32px 24px;
  }
  
  .title {
    font-size: 20px;
  }
}
</style>
