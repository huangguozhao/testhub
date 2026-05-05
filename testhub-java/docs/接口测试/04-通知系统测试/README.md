# 通知系统模块测试

## 一、接口列表

### 1.1 通知配置

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 分页查询 | GET | /api/notification-configs | 分页查询配置 | P1 |
| 获取详情 | GET | /api/notification-configs/{id} | 获取配置详情 | P1 |
| 创建配置 | POST | /api/notification-configs | 创建配置 | P0 |
| 更新配置 | PUT | /api/notification-configs/{id} | 更新配置 | P0 |
| 删除配置 | DELETE | /api/notification-configs/{id} | 删除配置 | P0 |
| 获取启用配置 | GET | /api/notification-configs/active | 获取启用配置 | P1 |
| 设为默认 | POST | /api/notification-configs/{id}/set-default | 设为默认 | P1 |
| 启用/禁用 | POST | /api/notification-configs/{id}/toggle | 切换状态 | P1 |

### 1.2 通知发送

| 接口 | 方法 | 路径 | 描述 | 优先级 |
|-----|------|-----|------|-------|
| 发送通知 | POST | /api/notifications/send | 发送通知 | P0 |
| 分页查询日志 | GET | /api/notifications/logs | 查询发送日志 | P1 |
| 获取日志详情 | GET | /api/notifications/logs/{id} | 获取日志详情 | P1 |
| 重试发送 | POST | /api/notifications/logs/{id}/retry | 重试失败通知 | P1 |
| 删除日志 | DELETE | /api/notifications/logs/{id} | 删除日志 | P2 |

## 二、测试用例

### 2.1 通知配置测试 (NOTI-CONFIG)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| NOTI-CONFIG-001 | 创建飞书配置 | 创建成功 | |
| NOTI-CONFIG-002 | 创建企业微信配置 | 创建成功 | |
| NOTI-CONFIG-003 | 创建钉钉配置 | 创建成功 | |
| NOTI-CONFIG-004 | 创建自定义Webhook配置 | 创建成功 | |
| NOTI-CONFIG-005 | Webhook URL无效 | 返回格式错误 | |
| NOTI-CONFIG-006 | 获取配置列表 | 返回分页列表 | |
| NOTI-CONFIG-007 | 获取启用配置 | 返回启用列表 | |
| NOTI-CONFIG-008 | 更新配置 | 更新成功 | |
| NOTI-CONFIG-009 | 设为默认配置 | 设置成功 | |
| NOTI-CONFIG-010 | 启用配置 | 启用成功 | |
| NOTI-CONFIG-011 | 禁用配置 | 禁用成功 | |
| NOTI-CONFIG-012 | 删除配置 | 删除成功 | |

### 2.2 通知发送测试 (NOTI-SEND)

| 用例ID | 用例名称 | 预期结果 | 状态 |
|-------|---------|---------|------|
| NOTI-SEND-001 | 发送飞书通知 | 发送成功 | |
| NOTI-SEND-002 | 发送企业微信通知 | 发送成功 | |
| NOTI-SEND-003 | 发送钉钉通知 | 发送成功 | |
| NOTI-SEND-004 | 发送自定义Webhook | 发送成功 | |
| NOTI-SEND-005 | 发送失败-Webhook不可达 | 记录失败日志 | |
| NOTI-SEND-006 | 获取通知日志 | 返回日志列表 | |
| NOTI-SEND-007 | 重试失败通知 | 重试成功 | |

## 三、curl 测试命令

### 3.1 通知配置

```bash
# 创建飞书通知配置
curl -X POST http://127.0.0.1:8080/api/notification-configs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "飞书通知",
    "configType": "feishu",
    "webhookUrl": "https://open.feishu.cn/open-apis/bot/v2/hook/xxx",
    "template": "测试消息",
    "isActive": true
  }'

# 创建企业微信配置
curl -X POST http://127.0.0.1:8080/api/notification-configs \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "name": "企业微信通知",
    "configType": "wecom",
    "webhookUrl": "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx",
    "isActive": true
  }'

# 获取启用配置
curl -X GET http://127.0.0.1:8080/api/notification-configs/active \
  -H "Authorization: Bearer TOKEN"

# 启用配置
curl -X POST http://127.0.0.1:8080/api/notification-configs/1/toggle?isActive=true \
  -H "Authorization: Bearer TOKEN"
```

### 3.2 发送通知

```bash
# 发送通知
curl -X POST http://127.0.0.1:8080/api/notifications/send \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{
    "configId": 1,
    "title": "测试通知",
    "content": "这是一条测试通知",
    "taskType": "api_test",
    "taskId": 1
  }'

# 获取通知日志
curl -X GET "http://127.0.0.1:8080/api/notifications/logs?current=1&size=10" \
  -H "Authorization: Bearer TOKEN"

# 重试失败通知
curl -X POST http://127.0.0.1:8080/api/notifications/logs/1/retry \
  -H "Authorization: Bearer TOKEN"
```

## 四、测试数据

### 4.1 测试配置数据

```json
{
  "feishu": {
    "name": "测试飞书配置",
    "configType": "feishu",
    "webhookUrl": "https://open.feishu.cn/open-apis/bot/v2/hook/test-webhook"
  },
  "wecom": {
    "name": "测试企业微信配置",
    "configType": "wecom",
    "webhookUrl": "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=test-key"
  },
  "dingtalk": {
    "name": "测试钉钉配置",
    "configType": "dingtalk",
    "webhookUrl": "https://oapi.dingtalk.com/robot/send?access_token=test-token"
  },
  "custom": {
    "name": "测试自定义Webhook",
    "configType": "custom",
    "webhookUrl": "https://httpbin.org/post"
  }
}
```

## 五、测试结果记录

| 测试日期 | 测试人员 | 通过数 | 失败数 | 通过率 | 备注 |
|---------|---------|-------|-------|-------|------|
| 2026-04-30 | | | | | |
