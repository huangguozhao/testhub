package com.testhub.modules.notification.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * 通知配置实体
 */
@Data
@TableName("notification_config")
public class NotificationConfig extends BaseEntity {

    /**
     * 配置名称
     */
    private String name;

    /**
     * 配置类型: webhook_feishu, webhook_wechat, webhook_dingtalk, email
     */
    private String configType;

    /**
     * Webhook机器人配置 (JSON格式)
     * 结构: {"botType": {"name": "机器人名称", "webhook_url": "https://...", "enabled": true, ...}}
     * 示例:
     * {
     *   "feishu": {"name": "飞书机器人", "webhook_url": "https://open.feishu.cn/...", "enabled": true, "enable_ui_automation": true, "enable_api_testing": true},
     *   "wechat": {"name": "企微机器人", "webhook_url": "https://qyapi.weixin.qq.com/...", "enabled": true},
     *   "dingtalk": {"name": "钉钉机器人", "webhook_url": "https://oapi.dingtalk.com/...", "secret": "xxx", "enabled": true}
     * }
     */
    private String webhookBots;

    /**
     * 是否默认: 0=否, 1=是
     */
    private Boolean isDefault;

    /**
     * 是否启用: 0=否, 1=是
     */
    private Boolean isActive;

    /**
     * 备注
     */
    private String remark;
}
