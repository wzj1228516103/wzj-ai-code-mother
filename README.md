# wzj-ai-code-mother — 企业级 AI 代码生成平台（详细说明）

> 基于 Spring Boot 3 + LangChain4j + Vue 3 的 AI 网页应用代码生成与管理平台。

---

## 一、任务接收与说明

本文档为项目 `wzj-ai-code-mother` 的详细 README，面向团队开发、运行维护与中期答辩准备，包含：项目概述、技术栈、目录结构、数据库表结构（字段说明）、已完成功能、未完成功能、运行与部署步骤以及答辩要点。

---

## 二、项目概述

`wzj-ai-code-mother` 的目标是：让用户通过自然语言或对话方式描述需求，系统能自动生成网页应用原型并支持实时流式展示、可视化编辑、部署、下载与后台管理。项目目前以单体版为主，并预留微服务拆分目录以便后续演进。

主要业务流程：
- 用户注册 / 登录
- 创建应用（应用包含初始化 prompt）
- 与 AI 进行对话式交互，AI 通过 LangChain4j 等实现代码生成并以 SSE 流式返回生成过程
- 前端边接收边渲染，用户可以预览或进入编辑模式针对 DOM 元素继续改进
- 支持部署、下载源码与生成截图/封面
- 管理端用于管理员对用户、应用、对话历史管理

---

## 三、技术栈

- 后端：Java 21、Spring Boot 3、MyBatis-Flex、LangChain4j、Reactor（SSE 流式支持）、Spring Session、Redis、MySQL
- 前端：Vue 3、TypeScript、Vite、Pinia、Vue Router、Ant Design Vue
- 缓存/会话：Caffeine、Redis
- 监控：Micrometer + Prometheus
- 自动化浏览器截图：Selenium + WebDriverManager
- 构建工具：Maven（mvnw 提供）

---

## 四、项目目录（关键说明）

工作区（绝对路径示例）: `D:\JavaProject\wzj-ai-code-mother`

主要目录与说明：

- `src/` — 单体后端源码
  - `src/main/java/` — Java 源代码（控制器、服务、实体、Mapper 等）
    - `com/...`、`dev/...`（按包组织）
  - `src/main/resources/` — 配置与静态资源
    - `application.yml`, `application-local.yml` 等环境配置
    - `mapper/` — MyBatis Mapper XML（SQL 映射）
    - `prompt/` — 系统级 prompt 文本
    - `static/` — 静态演示页面等

- `sql/` — 数据库初始化脚本
  - `create_table.sql` — 建表语句（包含 `user`, `app`, `chat_history`）

- `wzj-ai-code-mother-frontend/` — 前端工程（Vue 3 + TypeScript + Vite）
  - `src/` — 前端源码（api、components、pages、router、stores 等）
  - 运行命令示例：`npm install`、`npm run dev`

- `wzj-ai-code-mother-microservice/` — 预留微服务拆分模块
  - `wzj-ai-code-user`、`wzj-ai-code-app`、`wzj-ai-code-ai`、`wzj-ai-code-screenshot` 等模块骨架

- `pom.xml`, `mvnw`, `mvnw.cmd` — 后端构建与启动

- `target/` — 编译输出（构建后生成）
- `tmp/` — 运行时产物（例如自动化截图、部署输出等）

注：前端与后端项目是独立运行的两个进程；演示部署时会把后端作为 API 服务，前端通过环境配置指向对应 API 地址。

---

## 五、数据库表结构（来自 `sql/create_table.sql`）

说明：以下建表语句摘自 `sql/create_table.sql`，列出字段与注释，便于答辩与运维理解。

### 1) `user` — 用户表

```sql
create table if not exists user
(
    id           bigint auto_increment comment 'id' primary key,
    userAccount  varchar(256)                           not null comment '账号',
    userPassword varchar(512)                           not null comment '密码',
    userName     varchar(256)                           null comment '用户昵称',
    userAvatar   varchar(1024)                          null comment '用户头像',
    userProfile  varchar(512)                           null comment '用户简介',
    userRole     varchar(256) default 'user'            not null comment '用户角色：user/admin',
    editTime     datetime     default CURRENT_TIMESTAMP not null comment '编辑时间',
    createTime   datetime     default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime   datetime     default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint      default 0                 not null comment '是否删除',
    UNIQUE KEY uk_userAccount (userAccount),
    INDEX idx_userName (userName)
) comment '用户' collate = utf8mb4_unicode_ci;
```

字段说明要点：
- `userAccount` 唯一（登录账号）
- `userPassword` 存储经过加密/哈希的密码
- `userRole` 用于权限控制（默认 `user`，管理员为 `admin`）
- 软删除通过 `isDelete` 字段实现

---

### 2) `app` — 应用表（平台上每个用户创建的应用记录）

```sql
create table app
(
    id           bigint auto_increment comment 'id' primary key,
    appName      varchar(256)                       null comment '应用名称',
    cover        varchar(512)                       null comment '应用封面',
    initPrompt   text                               null comment '应用初始化的 prompt',
    codeGenType  varchar(64)                        null comment '代码生成类型（枚举）',
    deployKey    varchar(64)                        null comment '部署标识',
    deployedTime datetime                           null comment '部署时间',
    priority     int      default 0                 not null comment '优先级',
    userId       bigint                             not null comment '创建用户id',
    editTime     datetime default CURRENT_TIMESTAMP not null comment '编辑时间',
    createTime   datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime   datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete     tinyint  default 0                 not null comment '是否删除',
    UNIQUE KEY uk_deployKey (deployKey),
    INDEX idx_appName (appName),
    INDEX idx_userId (userId)
) comment '应用' collate = utf8mb4_unicode_ci;
```

要点：
- `initPrompt` 存放应用初始化的 prompt（AI 生成的起点）
- `codeGenType` 用于区分不同生成策略/模板
- `deployKey` 保证部署实例标识唯一，便于查找和回收
- `userId` 与 `user` 表关联（创建者）

---

### 3) `chat_history` — 对话历史表

```sql
create table chat_history
(
    id          bigint auto_increment comment 'id' primary key,
    message     text                               not null comment '消息',
    messageType varchar(32)                        not null comment 'user/ai',
    appId       bigint                             not null comment '应用id',
    userId      bigint                             not null comment '创建用户id',
    createTime  datetime default CURRENT_TIMESTAMP not null comment '创建时间',
    updateTime  datetime default CURRENT_TIMESTAMP not null on update CURRENT_TIMESTAMP comment '更新时间',
    isDelete    tinyint  default 0                 not null comment '是否删除',
    INDEX idx_appId (appId),
    INDEX idx_createTime (createTime),
    INDEX idx_appId_createTime (appId, createTime)
) comment '对话历史' collate = utf8mb4_unicode_ci;
```

要点：
- 以 `appId` 为主线保存多轮对话
- `messageType` 区分用户消息与 AI 回复
- `idx_appId_createTime` 支持基于游标的分片/分页查询

---

## 六、接口与重要流程（高层）

- 用户模块：注册、登录、退出、获取当前用户、管理员分页管理
- 应用模块：创建/修改/删除/查询应用、精选应用查询、我的应用列表
- AI 生成模块：接收用户 prompt → 后端路由到对应生成器 → 使用 LangChain4j 等与模型交互 → SSE 流式返回生成内容 → 前端边接收边渲染
- 聊天记录模块：消息入库（用户消息先存），AI 输出可边流式展示边补全入库
- 预览/部署模块：生成后的前端代码可以预览、打包并部署；部署后异步截图并回写应用封面

特别说明：系统采用 SSE（Server Sent Events）+ Reactor 实现流式输出，提升用户体验，避免长时间等待。

---

## 七、已完成功能（可在答辩直接展示）

- 用户注册、登录、角色权限（user / admin）
- 应用 CRUD（创建、查看、修改、删除）、我的应用、精选应用
- AI 对话式代码生成（流式输出，前端实时展示）
- 对话历史保存与分页查询（支持游标）
- 应用预览、源码下载、部署与部署地址生成
- 异步生成页面截图并回填为应用封面
- 基础监控（Actuator + Prometheus）、Redis 会话、Caffeine 缓存

---

## 八、尚未完成 / 后续计划

- 微服务完全联调（当前以单体运行为主，microservice 目录为拆分骨架）
- 可视化编辑闭环：从元素选中到自动生成修改指令并精准修改代码的完整闭环仍需打通
- 更丰富的自动化测试（单元测试、集成测试、AI 输出稳定性测试）
- 部署稳定性提升：失败回滚、构建日志、清理策略等
- 更细粒度的监控与告警（业务指标、AI 调用耗时、失败率等）

---

## 九、运行准备与快速启动（本地开发）

前提：已安装 JDK 21、Maven 3.9+、MySQL 8+、Redis、Node.js 18+（或更高）。

1. 克隆或切换到项目目录：

```powershell
cd D:\JavaProject\wzj-ai-code-mother
```

2. 创建数据库并执行建表脚本（示例）：

```powershell
# 登录 mysql 并运行 sql/create_table.sql，或用 mysql 客户端执行
mysql -u root -p < .\sql\create_table.sql
```

3. 修改后端配置（`src/main/resources/application.yml` 或 `application-local.yml`）
   - 配置 `spring.datasource`（URL、用户名、密码）
   - 配置 Redis 连接
   - 配置 LangChain4j / AI 模型相关的 key 与 endpoint（如使用云服务）

4. 启动后端（使用项目自带的 mvnw 命令）：

```powershell
# 在项目根目录
./mvnw spring-boot:run
# windows 环境下
mvnw.cmd spring-boot:run
```

5. 启动前端：

```powershell
cd wzj-ai-code-mother-frontend
npm install
npm run dev
```

6. 访问：前端默认 dev 服务地址（参见 vite 配置），后端 API 地址以 `application.yml` 配置为准。

---

## 十、答辩要点（简短回答）

Q1：目前完成了哪些功能？
- 已实现用户模块、应用模块、AI 对话式代码生成（SSE 流式）、会话历史、预览/部署/下载、后台管理等主流程。

Q2：还有哪些功能未完成？
- 微服务联调、可视化编辑完整闭环、自动化测试覆盖、部署回滚与更细粒度监控。

Q3：举一个后来实现的难点并说明思路？
- 流式生成（SSE）与对话历史落库的完整闭环：把 AI 生成过程流式推送给前端（提高体验），并在生成完成/中断时保证对话历史一致性。实现方式为：后端使用 Reactor Flux + SSE，前端逐段渲染，服务端在结束时补全持久化。

---

## 十一、常见问题与维护提示

- 如果需要重建 DB，请先删除数据库然后重新执行 `sql/create_table.sql`。
- 密码请务必使用加密/哈希存储，生产环境不要把明文配置放进 git。
- 部署时请配置合适的 CORS、限流与鉴权策略，避免模型调用滥用产生较高成本。

---

## 十二、贡献与沟通

欢迎提交 Issue 或 PR。答辩准备中如需演示脚本或特定场景的数据准备，我可以进一步补充 `docs/` 下的示例脚本与截图生成步骤。


---

## 十三、项目关键源码与包说明（更细致）

后端关键包及说明（基于 `src/main/java/com/wuzijie/wzjaicodemother`）：

- `controller` — 控制层，暴露 REST 接口：
  - `UserController.java`：用户注册/登录/登出、管理员用户管理接口
  - `AppController.java`：应用 CRUD、代码生成 SSE、部署、下载
  - `ChatHistoryController.java`：多轮对话历史分页/管理接口
  - `WorkflowSseController.java`：示例工作流的同步与流式执行（LangGraph4j 示范）
  - `StaticResourceController.java`：提供生成后静态资源访问（预览）
  - `HealthController.java`：健康检查

- `service` — 业务逻辑层（实现核心功能）：
  - `UserService`：用户鉴权、加密、会话管理
  - `AppService`：AI 交互、代码生成、部署、下载业务
  - `ChatHistoryService`：对话持久化与分页查询
  - `ProjectDownloadService`：把生成的源码打包并提供下载

- `model.entity` — 与数据库表对应的实体类：`User`, `App`, `ChatHistory`（使用 MyBatis-Flex 注解，支持雪花/生成器主键）

- `model.dto` — 请求与响应的 DTO（请求入参封装，示例：`AppAddRequest`, `UserLoginRequest` 等）

- `mapper`（resources 下的 XML）— 当前为空（项目采用 MyBatis-Flex 注解或自动映射），但保留 XML 以备复杂 SQL

- `langgraph4j` / `generator` / `core` — 与代码生成工作流、LangChain/LangGraph 集成相关的实现文件

- `ratelimter`、`monitor`、`aop`、`exception` — 辅助模块（限流、监控、切面日志、异常统一处理）

- 启动类：`WzjAiCodeMotherApplication.java` — Spring Boot 启动入口

数据库表与实体映射（概览）：
- 表 `user` <-> 实体 `User`
- 表 `app` <-> 实体 `App`
- 表 `chat_history` <-> 实体 `ChatHistory`

---

## 十四、主要 REST 接口清单（示例、含方法与权限）

说明：接口路径基于控制器上 `@RequestMapping` 的前缀，列出常用接口便于测试与答辩展示。

- 用户模块（`/user`）
  - POST /user/register — 注册（公开）
  - POST /user/login — 登录（公开）
  - GET /user/get/login — 获取当前登录用户（需登录）
  - POST /user/logout — 注销（需登录）
  - POST /user/add — 管理员创建用户（需 admin）
  - GET /user/get?id={id} — 管理员查询用户（需 admin）
  - GET /user/get/vo?id={id} — 查询用户 VO（需登录）
  - POST /user/delete — 管理员删除用户（需 admin）
  - POST /user/update — 管理员更新用户（需 admin）
  - POST /user/list/page/vo — 管理员分页查询用户（需 admin）

- 应用模块（`/app`）
  - GET /app/chat/gen/code?appId={appId}&message={text} — AI 对话式生成代码（SSE 流式返回）
  - POST /app/deploy — 部署应用（需登录，返回部署 URL）
  - GET /app/download/{appId} — 下载应用源码（仅创建者）
  - POST /app/add — 创建应用（需登录）
  - POST /app/update — 更新应用（仅创建者）
  - POST /app/delete — 删除应用（创建者或管理员）
  - GET /app/get/vo?id={id} — 获取应用详情（VO）
  - POST /app/my/list/page/vo — 分页获取当前用户的应用列表
  - POST /app/good/list/page/vo — 分页获取精选应用（带缓存）
  - POST /app/admin/delete — 管理员删除应用（需 admin）
  - POST /app/admin/update — 管理员更新应用（需 admin）
  - POST /app/admin/list/page/vo — 管理员分页查询应用（需 admin）
  - GET  /app/admin/get/vo?id={id} — 管理员查询应用详情（需 admin）

- 对话历史（`/chatHistory`）
  - GET /chatHistory/app/{appId}?pageSize={n}&lastCreateTime={time} — 分页（游标）读取某应用对话历史（需登录）
  - POST /chatHistory/admin/list/page/vo — 管理员分页查询所有对话历史（需 admin）

- 工作流与演示（`/workflow`）
  - POST /workflow/execute?prompt={text} — 同步执行工作流（返回完整上下文）
  - GET /workflow/execute-flux?prompt={text} — Flux 流式执行（返回 Flux）
  - GET /workflow/execute-sse?prompt={text} — SSE 流式执行（返回 SseEmitter）

- 静态资源访问（预览）
  - GET /static/{deployKey}/** — 访问部署后生成的静态文件（支持目录重定向）

- 健康检查
  - GET /health/ — 返回 "ok"

注：若系统部署在 API 网关下（例如：/api 前缀），请参考实际启动配置（前端 `request.ts` 中的 baseURL）调整路径。

---

## 十五、数据库常用查询与示例

示例 SQL（用于调试与答辩展示）：

- 查询某用户的所有应用：

```sql
SELECT * FROM `app` WHERE userId = 123 AND isDelete = 0 ORDER BY createTime DESC;
```

- 查询某应用最近 20 条对话（基于创建时间降序）：

```sql
SELECT * FROM `chat_history` WHERE appId = 456 AND isDelete = 0 ORDER BY createTime DESC LIMIT 20;
```

- 分页（游标）查询某应用对话（获取 createTime < :lastCreateTime 的下一页）：

```sql
SELECT * FROM `chat_history` WHERE appId = 456 AND createTime < '2026-04-01 12:00:00' AND isDelete = 0 ORDER BY createTime DESC LIMIT 20;
```

- 统计每天生成的应用数量（示例）：

```sql
SELECT DATE(createTime) AS day, COUNT(*) AS count
FROM `app`
WHERE isDelete = 0
GROUP BY DATE(createTime)
ORDER BY day DESC;
```

- 通过 deployKey 获取部署目录（用于预览调试）：

```sql
SELECT deployKey, appName, userId FROM `app` WHERE deployKey = 'some-key' AND isDelete = 0;
```

注意：生产环境不要直接在日志或错误响应中打印 SQL 或敏感字段（如 userPassword）。

---

## 十六、环境变量与配置项（重要）

在 `src/main/resources/application-local.yml` 存在示例配置，常用可覆盖的环境变量：
- MYSQL_HOST（默认见 application-local.yml）
- MYSQL_PORT（默认 3306）
- MYSQL_DATABASE（默认见文件）
- MYSQL_USERNAME
- MYSQL_PASSWORD
- REDIS_HOST
- REDIS_PORT
- REDIS_DATABASE
- REDIS_PASSWORD

此外，AI 模型/云服务相关的密钥与 endpoint 也需要通过配置（或环境变量）注入，通常位于 `application.yml` 的自定义字段或系统凭证管理中（例如：LangChain4j 的 key、模型 endpoint 等）。请在生产环境使用密钥管理服务，不要把明文密钥提交到仓库。

---

## 十七、调试与排错指南（常见问题）

1. 服务无法连接数据库：
   - 检查环境变量或 `application-*.yml` 的 datasource 配置
   - 使用 MySQL 客户端手动连接验证
   - 检查网络/防火墙与数据库用户权限

2. 前端无法访问 API：
   - 检查后端端口与前端的 baseURL（`wzj-ai-code-mother-frontend/src/request.ts`）
   - 若跨域问题，检查 CORS 配置

3. SSE/流式输出中断或不返回：
   - 使用 `curl -N` 或浏览器查看事件是否逐段到达
   - 检查反向代理（nginx）是否对长连接或 chunked 传输做了限制
   - 确认服务端没有在生成中途抛出异常（查看日志）

4. 代码生成后的文件权限/找不到文件：
   - 检查 `AppConstant.CODE_OUTPUT_ROOT_DIR` 配置（文件系统路径是否存在、权限）
   - 确认生成流程完成后会写入对应目录并刷新磁盘

5. 登录/会话问题：
   - 如果使用 Redis 会话，确认 Redis 可访问且 `spring.session` 配置正确
   - 清除浏览器 cookie 或使用 Postman 重新进行登录验证

6. 日志与 SQL 查看：
   - `mybatis-flex.configuration.log-impl` 在 `application-local.yml` 中可设置为输出 SQL
   - 使用项目的日志文件（或控制台）排查异常堆栈

---

## 十八、前端关键结构（更细致）

前端工程：`wzj-ai-code-mother-frontend/`

- `src/api/` — 与后端交互的 API 封装（对应后端 controller）
- `src/request.ts` — 封装 HTTP 客户端（axios 或 fetch）、拦截器、baseURL 配置
- `src/main.ts` — 应用入口（挂载路由、状态管理）
- `src/router/` — 页面路由定义
- `src/stores/` — Pinia 状态管理（用户信息、应用列表等）
- `src/pages/`、`src/components/` — 视图与可复用组件
- `src/assets/` — 静态资源（图片、样式等）

调试要点：
- 若前端请求返回 401/403，请先在浏览器开发者工具 -> Network 中查看请求头与 cookie 是否带上会话或 token
- 前端 SSE：在 `src` 中搜 `EventSource` 或 `.onmessage` 使用位置以定位流式消费代码

---

## 十九、常用 curl / Postman 请求示例

1. 注册（JSON）：

```powershell
curl -X POST "http://localhost:8123/user/register" -H "Content-Type: application/json" -d '{"userAccount":"test1","userPassword":"Pass1234","checkPassword":"Pass1234"}'
```

2. 登录并保留 Cookie（PowerShell 示例）：

```powershell
curl -c cookie.txt -X POST "http://localhost:8123/user/login" -H "Content-Type: application/json" -d '{"userAccount":"test1","userPassword":"Pass1234"}'
```

3. 使用 Cookie 发起 SSE 流式生成（示例，PowerShell）：

```powershell
# 注意：Windows PowerShell 中 curl 是 alias，使用 Invoke-WebRequest 或 curl.exe，示例使用 curl.exe -N
curl.exe -N "http://localhost:8123/app/chat/gen/code?appId=1&message=生成一个响应式首页" -b cookie.txt
```

4. 下载应用代码（需登录并为创建者）：

```powershell
curl.exe -L -b cookie.txt "http://localhost:8123/app/download/1" -o app_1.zip
```

5. 查询某应用对话历史（游标示例）：

```powershell
curl "http://localhost:8123/chatHistory/app/1?pageSize=20&lastCreateTime=2026-04-01T12:00:00"
```

提示：对于复杂交互建议使用 Postman 或 HTTPie 来更好地管理 cookie、环境与断点测试。

---

## 二十、下一步建议（可选交付物）

如果你希望我继续完善，我可以为你做：

告诉我你想先做哪一项，我会继续自动实现并提交到仓库中。

---

## 二十一、已生成的补充文档（仓库文件）

为便于阅读与展示，我已在仓库中新增以下文档与迁移脚本：

- `docs/er.puml` — PlantUML 源文件（ER 图）
- `docs/ERD.md` — ERD 渲染说明
- `docs/entity-field-mappings.md` — 实体字段到数据库列的映射说明
- `docs/dtos.md` — DTO 列表与字段说明
- `docs/api-examples.md` — 关键 API 的请求/响应示例
- `docs/testing.md` — 测试说明与常用 mvn 命令
- `sql/migrations/V1__create_core_tables.sql` — MySQL DDL 迁移脚本及示例种子数据

渲染 ER 图（本地）：

```powershell
# 需要安装 plantuml 与 Graphviz
plantuml docs/er.puml
# 生成后会产出 docs/er.png
```

迁移脚本使用说明：

```powershell
# 在有权限的 MySQL 环境中执行：
mysql -u root -p < .\sql\migrations\V1__create_core_tables.sql
```

如果你希望我继续：
- 为 `docs/er.puml` 生成 PNG 并提交（如果 CI/环境允许）
- 自动生成 Postman collection 或 OpenAPI 描述
- 从控制器自动生成 Markdown 接口文档并包含示例

选择其中一项我即可继续自动完成并提交到仓库。
