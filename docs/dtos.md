# DTO 列表与字段说明

下面列出项目中常用的 DTO（请求/响应）类及其字段，便于编写 API 示例与前后端对接。

目录：`src/main/java/com/wuzijie/wzjaicodemother/model/dto`

## user 包

- `UserRegisterRequest`
  - `userAccount` (String) — 账号
  - `userPassword` (String) — 密码
  - `checkPassword` (String) — 确认密码

- `UserLoginRequest`
  - `userAccount` (String)
  - `userPassword` (String)

- `UserAddRequest` (管理员创建)
  - `userName` (String)
  - `userAccount` (String)
  - `userAvatar` (String)
  - `userProfile` (String)
  - `userRole` (String) — user/admin

- `UserUpdateRequest` (管理员更新)
  - `id` (Long)
  - `userName` (String)
  - `userAvatar` (String)
  - `userProfile` (String)
  - `userRole` (String)

- `UserQueryRequest` (分页查询，继承 `PageRequest`)
  - `id` (Long)
  - `userName` (String)
  - `userAccount` (String)
  - `userProfile` (String)
  - `userRole` (String)

## app 包

- `AppAddRequest`
  - `initPrompt` (String)

- `AppUpdateRequest`
  - `id` (Long)
  - `appName` (String)

- `AppAdminUpdateRequest`
  - `id` (Long)
  - `appName` (String)
  - `cover` (String)
  - `priority` (Integer)

- `AppDeployRequest`
  - `appId` (Long)

- `AppQueryRequest` (继承 `PageRequest`)
  - `id` (Long)
  - `appName` (String)
  - `cover` (String)
  - `initPrompt` (String)
  - `codeGenType` (String)
  - `deployKey` (String)
  - `priority` (Integer)
  - `userId` (Long)

## chathistory 包

- `ChatHistoryQueryRequest` (继承 `PageRequest`)
  - `id` (Long)
  - `message` (String)
  - `messageType` (String) — user/ai
  - `appId` (Long)
  - `userId` (Long)
  - `lastCreateTime` (LocalDateTime) — 游标分页

备注：更多 DTO 可在 `src/main/java/com/wuzijie/wzjaicodemother/model/dto` 下逐一查看并补充。

