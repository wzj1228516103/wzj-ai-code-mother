# API 文档（详细）

本文档基于 `src/main/java/com/wuzijie/wzjaicodemother/controller` 下的控制器实现自动整理，包含接口、方法、参数、请求 DTO、返回数据结构、权限与示例请求。

注意：所有响应均以 `BaseResponse` 包裹（结构：{ code, data, message }），分页使用 MyBatis-Flex 的 `Page<T>` 作为 data。

---

## 目录

- /user
- /app
- /chatHistory
- /workflow
- /static
- /health

---

## /user 模块

1) POST /user/register
- 描述：用户注册
- 请求体：`UserRegisterRequest`
  - userAccount (String)
  - userPassword (String)
  - checkPassword (String)
- 返回：BaseResponse<Long>（data = 新用户 id）
- 权限：公开
- 示例：

```powershell
curl -X POST "http://localhost:8123/user/register" -H "Content-Type: application/json" -d '{"userAccount":"test1","userPassword":"Pass1234","checkPassword":"Pass1234"}'
```

2) POST /user/login
- 描述：用户登录（创建会话 / 返回 LoginUserVO）
- 请求体：`UserLoginRequest`
  - userAccount (String)
  - userPassword (String)
- 返回：BaseResponse<LoginUserVO>
- 权限：公开

3) GET /user/get/login
- 描述：获取当前登录用户信息（脱敏）
- 参数：无（需通过 Cookie / session）
- 返回：BaseResponse<LoginUserVO>
- 权限：需登录

4) POST /user/logout
- 描述：注销（清理会话）
- 返回：BaseResponse<Boolean>
- 权限：需登录

5) POST /user/add
- 描述：管理员创建用户（默认密码 12345678，会加密）
- 请求体：`UserAddRequest`
  - userName, userAccount, userAvatar, userProfile, userRole
- 返回：BaseResponse<Long>（新用户 id）
- 权限：需要 admin（@AuthCheck）

6) GET /user/get?id={id}
- 描述：按 id 获取用户实体（仅管理员）
- 返回：BaseResponse<User>
- 权限：admin

7) GET /user/get/vo?id={id}
- 描述：获取用户 VO（包装后的安全字段）
- 返回：BaseResponse<UserVO>
- 权限：需登录或公开（取决于控制器）

8) POST /user/delete
- 描述：管理员删除用户
- 请求体：`DeleteRequest`（{ id: Long }）
- 返回：BaseResponse<Boolean>
- 权限：admin

9) POST /user/update
- 描述：管理员更新用户（字段在 UserUpdateRequest）
- 请求体：`UserUpdateRequest`（含 id）
- 返回：BaseResponse<Boolean>
- 权限：admin

10) POST /user/list/page/vo
- 描述：管理员分页查询用户（返回 UserVO 的 Page）
- 请求体：`UserQueryRequest`（继承 PageRequest，包含 pageNum, pageSize 等）
- 返回：BaseResponse<Page<UserVO>>
- 权限：admin

---

## /app 模块

1) GET /app/chat/gen/code?appId={appId}&message={text}
- 描述：基于应用 appId 与用户输入 message 向 AI 发起对话并流式返回生成的代码片段
- 返回：Flux<ServerSentEvent<String>>（SSE 流，data 字段为 JSON 字符串如 {"d":"chunk"}，结束后会发送 event="done"）
- 权限：需登录（通过 userService.getLoginUser(request) 获取）
- 速率限制：@RateLimit(limitType=USER, rate=5, rateInterval=60)
- 示例（PowerShell, curl.exe）：

```powershell
curl.exe -N "http://localhost:8123/app/chat/gen/code?appId=1&message=生成一个响应式首页" -b cookie.txt
```

2) POST /app/deploy
- 描述：部署应用（触发异步构建/部署并返回部署 URL）
- 请求体：`AppDeployRequest`（{ appId: Long }）
- 返回：BaseResponse<String>（部署 URL）
- 权限：需登录

3) GET /app/download/{appId}
- 描述：下载应用源码 ZIP（只允许创建者下载）
- 返回：文件流（attachment）
- 权限：需登录且为应用创建者

4) POST /app/add
- 描述：创建新应用（initPrompt 为必填项）
- 请求体：`AppAddRequest`（{ initPrompt: String }）
- 返回：BaseResponse<Long>（新应用 id）
- 权限：需登录

5) POST /app/update
- 描述：用户更新应用名称（只能更新自己的应用）
- 请求体：`AppUpdateRequest`（{ id: Long, appName: String }）
- 返回：BaseResponse<Boolean>
- 权限：需登录且为创建者

6) POST /app/delete
- 描述：删除应用（创建者或管理员）
- 请求体：`DeleteRequest`（{ id: Long }）
- 返回：BaseResponse<Boolean>
- 权限：创建者或 admin

7) GET /app/get/vo?id={id}
- 描述：获取应用详情（AppVO，包含作者信息等）
- 返回：BaseResponse<AppVO>
- 权限：公开/需登录（视业务）

8) POST /app/my/list/page/vo
- 描述：分页获取当前用户的应用列表（每页最多 20 条）
- 请求体：`AppQueryRequest`（继承 PageRequest）
- 返回：BaseResponse<Page<AppVO>>
- 权限：需登录

9) POST /app/good/list/page/vo
- 描述：分页获取精选应用（priority = GOOD_APP_PRIORITY），带缓存注解 `@Cacheable`（缓存 key 由 CacheKeyUtils 生成）
- 请求体：`AppQueryRequest`
- 返回：BaseResponse<Page<AppVO>>

10) 管理员相关接口：
- POST /app/admin/delete — 管理员删除应用（需要 admin）
- POST /app/admin/update — 管理员更新应用（需要 admin）
- POST /app/admin/list/page/vo — 管理员分页查询应用（需要 admin）
- GET  /app/admin/get/vo?id={id} — 管理员查询应用详情（需要 admin）

---

## /chatHistory 模块

1) GET /chatHistory/app/{appId}?pageSize={n}&lastCreateTime={time}
- 描述：分页（游标）读取某应用的对话历史，返回 Page<ChatHistory>
- 参数：
  - path: appId (Long)
  - query: pageSize (default 10), lastCreateTime (LocalDateTime 可选，用于游标分页)
- 权限：需登录（校验用户所属或权限）

2) POST /chatHistory/admin/list/page/vo
- 描述：管理员分页查询所有对话历史
- 请求体：`ChatHistoryQueryRequest`（继承 PageRequest）
- 权限：admin

---

## /workflow 模块（演示）

接口用于演示 LangGraph4j 工作流的执行：
- POST /workflow/execute?prompt={text} — 同步执行，返回 WorkflowContext
- GET  /workflow/execute-flux?prompt={text} — Flux<String> 流式执行
- GET  /workflow/execute-sse?prompt={text} — SSE 返回 SseEmitter

这些接口主要用于演示与调试工作流，不一定用于生产流量。

---

## /static（静态资源预览）

GET /static/{deployKey}/**
- 描述：访问部署后生成的静态文件，支持目录重定向（如果只访问目录则返回 Location 重定向到带 / 的路径）
- 示例：

```
GET http://localhost:8123/static/yourDeployKey/
```

该接口会根据 `AppConstant.CODE_OUTPUT_ROOT_DIR` 构建文件路径并返回文件内容。

---

## /health

GET /health/
- 描述：健康检查，返回 BaseResponse<String> data="ok"

---

## 常见响应封装与错误码

所有接口使用 `BaseResponse<T>` 封装：

```json
{
  "code": 0,
  "data": null,
  "message": ""
}
```

错误时返回对应的 ErrorCode 与 message（参见 `exception/ErrorCode` 枚举）。

---

## 调试建议与快速示例

- 使用浏览器或 curl 结合 cookie 文件测试需要登录的接口。
- SSE 调试：在命令行使用 `curl.exe -N`（Windows）或 `curl -N`（Linux/Mac）来查看流式输出。

---

如果你希望，我可以：

- 从这些接口自动生成 OpenAPI / Swagger JSON 或 Postman collection 并将文件加入 `docs/`；
- 生成每个接口的完整示例请求/响应文件（JSON）并在 `docs/api-samples/` 下归档；
- 或者把这些文档合并到 `README.md` 中（现在是独立的 docs 文件）。

请选择要我接下来的动作（例如回复 "生成 OpenAPI" 或 "生成 Postman" 或 "生成 ERD PNG"），我会继续自动完成并提交到仓库。


