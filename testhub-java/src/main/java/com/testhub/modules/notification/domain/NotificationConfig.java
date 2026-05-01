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
     * Webhook配置 (JSON格式)
     * 飞书: {"webhook": "https://open.feishu.cn/open-apis/bot/v2/hook/xxx", "secret": "xxx"}
     * 企微: {"webhook": "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx"}
     * 钉钉: {"webhook": "https://oapi.dingtalk.com/robot/send?access_token=xxx", "secret": "xxx"}
     * 邮件: {"smtp_host": "smtp.xxx.com", "smtp_port": 465, "username": "xxx", "password": "xxx", "from": "xxx@xxx.com"}
     */
    private String webhookConfig;

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
