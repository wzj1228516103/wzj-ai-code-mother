# 实体字段到数据库列映射

下面列出项目中实体类与对应数据库列、类型（基于 `model/entity/*.java` 与 `sql/create_table.sql`）。

## user

- id : BIGINT (主键，雪花/生成器)
- userAccount : VARCHAR(256) NOT NULL (唯一)
- userPassword : VARCHAR(512) NOT NULL
- userName : VARCHAR(256)
- userAvatar : VARCHAR(1024)
- userProfile : VARCHAR(512)
- userRole : VARCHAR(256) NOT NULL DEFAULT 'user'
- editTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- createTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- updateTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- isDelete : TINYINT NOT NULL DEFAULT 0 (逻辑删除)

## app

- id : BIGINT (主键)
- appName : VARCHAR(256)
- cover : VARCHAR(512)
- initPrompt : TEXT
- codeGenType : VARCHAR(64)
- deployKey : VARCHAR(64) UNIQUE
- deployedTime : DATETIME
- priority : INT NOT NULL DEFAULT 0
- userId : BIGINT NOT NULL (外键，关联 user.id)
- editTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- createTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- updateTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- isDelete : TINYINT NOT NULL DEFAULT 0

## chat_history

- id : BIGINT (主键)
- message : TEXT NOT NULL
- messageType : VARCHAR(32) NOT NULL
- appId : BIGINT NOT NULL (外键，关联 app.id)
- userId : BIGINT NOT NULL (外键，关联 user.id)
- createTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
- updateTime : DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
- isDelete : TINYINT NOT NULL DEFAULT 0

