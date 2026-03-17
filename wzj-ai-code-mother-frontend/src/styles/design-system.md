# 炫酷未来科技风 Design System

## 1. 设计理念

### 整体风格
- **主题**: Futuristic / Cyber Tech Style（未来科技风）
- **核心元素**: 霓虹光效、渐变色、玻璃拟态（Glassmorphism）、科技感线条
- **氛围**: 深色背景 + 发光元素，营造沉浸式科技体验

### 设计原则
1. **一致性**: 所有页面保持统一的设计语言
2. **可读性**: 在炫酷效果中保持良好的文字可读性
3. **层次感**: 通过光影、透明度、模糊效果创造深度
4. **交互反馈**: 悬停、点击等操作有明确的光效反馈

---

## 2. 颜色规范

### 主色调
```css
--tech-primary: #00f0ff;        /* 霓虹青 - 主品牌色 */
--tech-secondary: #7c3aed;      /* 霓虹紫 - 辅助色 */
--tech-accent: #f472b6;         /* 霓虹粉 - 强调色 */
```

### 背景色
```css
--bg-primary: #0a0a0f;          /* 主背景 - 深邃黑 */
--bg-secondary: #12121a;        /* 次级背景 - 暗灰蓝 */
--bg-card: rgba(18, 18, 26, 0.8); /* 卡片背景 - 玻璃拟态 */
--bg-glass: rgba(255, 255, 255, 0.05); /* 玻璃效果背景 */
```

### 文字色
```css
--text-primary: #ffffff;        /* 主文字 - 纯白 */
--text-secondary: #a1a1aa;      /* 次级文字 - 灰白 */
--text-muted: #71717a;          /* 弱化文字 - 深灰 */
--text-glow: #00f0ff;           /* 发光文字 */
```

### 功能色
```css
--success: #10b981;             /* 成功 - 翠绿 */
--warning: #f59e0b;             /* 警告 - 琥珀 */
--error: #ef4444;               /* 错误 - 红 */
--info: #3b82f6;                /* 信息 - 蓝 */
```

### 渐变定义
```css
--gradient-primary: linear-gradient(135deg, #00f0ff 0%, #7c3aed 100%);
--gradient-glow: linear-gradient(135deg, rgba(0, 240, 255, 0.3) 0%, rgba(124, 58, 237, 0.3) 100%);
--gradient-border: linear-gradient(135deg, #00f0ff, #7c3aed, #f472b6);
--gradient-dark: linear-gradient(180deg, #12121a 0%, #0a0a0f 100%);
```

---

## 3. 字体规范

### 字体族
```css
--font-primary: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
--font-mono: 'JetBrains Mono', 'Fira Code', monospace;  /* 代码/科技感的文字 */
```

### 字体层级
| 层级 | 大小 | 字重 | 用途 |
|------|------|------|------|
| H1 | 32px | 700 | 页面大标题 |
| H2 | 24px | 600 | 区块标题 |
| H3 | 18px | 600 | 卡片标题 |
| Body | 14px | 400 | 正文内容 |
| Small | 12px | 400 | 辅助说明 |
| Caption | 11px | 500 | 标签文字 |

### 行高
```css
--leading-tight: 1.25;
--leading-normal: 1.5;
--leading-relaxed: 1.75;
```

---

## 4. 间距规范

### 基础单位: 4px
```css
--space-1: 4px;
--space-2: 8px;
--space-3: 12px;
--space-4: 16px;
--space-5: 20px;
--space-6: 24px;
--space-8: 32px;
--space-10: 40px;
--space-12: 48px;
```

### 组件间距
- 卡片内边距: 24px
- 按钮内边距: 12px 24px
- 表单字段间距: 16px
- 页面水平边距: 24px (移动端 16px)

---

## 5. 圆角规范

```css
--radius-sm: 4px;       /* 小元素: 标签、徽章 */
--radius-md: 8px;       /* 按钮、输入框 */
--radius-lg: 12px;      /* 卡片、模态框 */
--radius-xl: 16px;      /* 大卡片、容器 */
--radius-full: 9999px;  /* 圆形、胶囊 */
```

---

## 6. 阴影与光效

### 发光效果
```css
--glow-primary: 0 0 20px rgba(0, 240, 255, 0.5);
--glow-secondary: 0 0 20px rgba(124, 58, 237, 0.5);
--glow-accent: 0 0 20px rgba(244, 114, 182, 0.5);
--glow-subtle: 0 0 10px rgba(0, 240, 255, 0.2);
```

### 阴影
```css
--shadow-sm: 0 1px 2px rgba(0, 0, 0, 0.3);
--shadow-md: 0 4px 6px rgba(0, 0, 0, 0.4);
--shadow-lg: 0 10px 15px rgba(0, 0, 0, 0.5);
--shadow-glow: 0 0 30px rgba(0, 240, 255, 0.3);
```

---

## 7. 组件样式规范

### 按钮 (Button)

#### 主要按钮 (Primary)
- 背景: 渐变 `gradient-primary`
- 文字: 白色，字重 600
- 圆角: 8px
- 内边距: 12px 24px
- 阴影: `glow-primary` (悬停时)
- 过渡: all 0.3s ease

#### 次要按钮 (Secondary)
- 背景: 透明
- 边框: 1px solid `tech-primary`
- 文字: `tech-primary`
- 悬停: 背景 `rgba(0, 240, 255, 0.1)`

#### 幽灵按钮 (Ghost)
- 背景: `bg-glass`
- 边框: 1px solid `rgba(255, 255, 255, 0.1)`
- 文字: `text-secondary`
- 悬停: 边框颜色变为 `tech-primary`

### 卡片 (Card)

#### 标准卡片
- 背景: `bg-card` + backdrop-filter: blur(20px)
- 边框: 1px solid `rgba(255, 255, 255, 0.1)`
- 圆角: 12px
- 内边距: 24px
- 阴影: `shadow-md`
- 悬停: 边框颜色变为 `rgba(0, 240, 255, 0.3)` + `glow-subtle`

#### 发光卡片
- 在标准卡片基础上
- 添加渐变边框效果 (伪元素实现)
- 悬停时发光增强

### 输入框 (Input)

- 背景: `bg-secondary`
- 边框: 1px solid `rgba(255, 255, 255, 0.1)`
- 圆角: 8px
- 文字: `text-primary`
- placeholder: `text-muted`
- 聚焦: 边框颜色变为 `tech-primary` + `glow-subtle`

### 模态框 (Modal)

- 背景: `bg-card` + backdrop-filter: blur(30px)
- 边框: 1px solid `rgba(255, 255, 255, 0.1)`
- 圆角: 16px
- 阴影: `shadow-lg` + `glow-primary`
- 遮罩: `rgba(0, 0, 0, 0.8)` + backdrop-filter: blur(5px)

### 导航 (Navigation)

#### 顶部导航
- 背景: `bg-card` + backdrop-filter: blur(20px)
- 边框底部: 1px solid `rgba(255, 255, 255, 0.05)`
- 固定定位，z-index: 100

#### 导航项
- 默认: `text-secondary`
- 悬停: `text-primary` + `glow-subtle`
- 激活: `tech-primary` + 下划线发光效果

---

## 8. 动效规范

### 过渡时间
```css
--duration-fast: 150ms;
--duration-normal: 300ms;
--duration-slow: 500ms;
```

### 缓动函数
```css
--ease-default: cubic-bezier(0.4, 0, 0.2, 1);
--ease-in: cubic-bezier(0.4, 0, 1, 1);
--ease-out: cubic-bezier(0, 0, 0.2, 1);
--ease-bounce: cubic-bezier(0.68, -0.55, 0.265, 1.55);
```

### 常用动画

#### 悬停发光
```css
transition: all 0.3s ease;
&:hover {
  box-shadow: 0 0 20px rgba(0, 240, 255, 0.5);
  border-color: rgba(0, 240, 255, 0.5);
}
```

#### 渐变边框流动
使用伪元素 + 背景渐变旋转实现

#### 文字发光脉冲
```css
@keyframes text-glow {
  0%, 100% { text-shadow: 0 0 10px rgba(0, 240, 255, 0.5); }
  50% { text-shadow: 0 0 20px rgba(0, 240, 255, 0.8), 0 0 30px rgba(0, 240, 255, 0.4); }
}
```

#### 卡片浮起
```css
transition: transform 0.3s ease, box-shadow 0.3s ease;
&:hover {
  transform: translateY(-4px);
  box-shadow: 0 10px 30px rgba(0, 240, 255, 0.2);
}
```

---

## 9. 特殊效果

### 网格背景
```css
background-image: 
  linear-gradient(rgba(0, 240, 255, 0.03) 1px, transparent 1px),
  linear-gradient(90deg, rgba(0, 240, 255, 0.03) 1px, transparent 1px);
background-size: 50px 50px;
```

### 扫描线效果
```css
&::after {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 2px;
  background: linear-gradient(90deg, transparent, var(--tech-primary), transparent);
  animation: scan 3s linear infinite;
}
```

### 角落装饰
在卡片四角添加科技感装饰线条

---

## 10. 响应式断点

```css
--breakpoint-sm: 640px;   /* 手机 */
--breakpoint-md: 768px;   /* 平板 */
--breakpoint-lg: 1024px;  /* 小桌面 */
--breakpoint-xl: 1280px;  /* 大桌面 */
```

---

## 11. 使用示例

### 页面结构
```vue
<template>
  <div class="tech-page">
    <!-- 网格背景 -->
    <div class="grid-background"></div>
    
    <!-- 内容区域 -->
    <div class="content">
      <h1 class="tech-title">页面标题</h1>
      
      <div class="tech-card">
        <p class="tech-text">卡片内容</p>
        <button class="tech-btn-primary">主要按钮</button>
      </div>
    </div>
  </div>
</template>
```

### 类名规范
- `.tech-*`: 科技风基础组件
- `.glow-*`: 发光效果
- `.glass`: 玻璃拟态
- `.gradient-*`: 渐变效果