<template>
  <a-layout-footer class="tech-footer">
    <div class="footer-content">
      <div class="footer-decoration">
        <div class="tech-line"></div>
        <div class="tech-dot"></div>
        <div class="tech-line"></div>
      </div>
      <p class="copyright">
        <a
          href="https://wzj-coolbi.xin/"
          target="_blank"
          rel="noopener noreferrer"
          class="author-link"
        >
          <span class="link-icon">⚡</span>
          AI生成平台原创项目 by 程序员子杰
          <span class="link-icon">⚡</span>
        </a>
      </p>
      <div class="footer-tech-elements">
        <span class="tech-code">// SYSTEM ONLINE</span>
        <span class="tech-divider">|</span>
        <span class="tech-version">v2.0.0</span>
      </div>
    </div>
  </a-layout-footer>
</template>

<script setup lang="ts">
// 无需额外的响应式数据
</script>

<style scoped>
/* 科技风底部样式 */
.tech-footer {
  background: linear-gradient(180deg, rgba(10, 10, 15, 0.95) 0%, rgba(18, 18, 26, 0.98) 100%);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  text-align: center;
  padding: 30px 20px;
  margin-top: 60px;
  border-top: 1px solid rgba(0, 240, 255, 0.2);
  position: relative;
}

.tech-footer::before {
  content: '';
  position: absolute;
  top: -1px;
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

.footer-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 16px;
}

/* 装饰元素 */
.footer-decoration {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 8px;
}

.tech-line {
  width: 60px;
  height: 1px;
  background: linear-gradient(90deg, transparent, rgba(0, 240, 255, 0.5), transparent);
}

.tech-dot {
  width: 8px;
  height: 8px;
  background: #00f0ff;
  border-radius: 50%;
  box-shadow: 0 0 10px rgba(0, 240, 255, 0.8);
  animation: pulse-dot 2s ease-in-out infinite;
}

@keyframes pulse-dot {
  0%, 100% { 
    opacity: 0.6; 
    transform: scale(1);
    box-shadow: 0 0 10px rgba(0, 240, 255, 0.5);
  }
  50% { 
    opacity: 1; 
    transform: scale(1.2);
    box-shadow: 0 0 20px rgba(0, 240, 255, 0.8);
  }
}

/* 版权链接 */
.copyright {
  margin: 0;
  font-size: 14px;
}

.author-link {
  color: rgba(255, 255, 255, 0.7);
  text-decoration: none;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.author-link:hover {
  color: #00f0ff;
  text-shadow: 0 0 10px rgba(0, 240, 255, 0.5);
}

.link-icon {
  font-size: 12px;
  opacity: 0.7;
  animation: icon-pulse 2s ease-in-out infinite;
}

@keyframes icon-pulse {
  0%, 100% { opacity: 0.5; }
  50% { opacity: 1; }
}

/* 底部技术元素 */
.footer-tech-elements {
  display: flex;
  align-items: center;
  gap: 16px;
  font-family: 'JetBrains Mono', 'Fira Code', monospace;
  font-size: 12px;
}

.tech-code {
  color: rgba(0, 240, 255, 0.6);
  letter-spacing: 1px;
}

.tech-divider {
  color: rgba(124, 58, 237, 0.6);
}

.tech-version {
  color: rgba(244, 114, 182, 0.6);
}
</style>
