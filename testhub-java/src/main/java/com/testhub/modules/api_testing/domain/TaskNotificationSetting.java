package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.TableName;
import com.testhub.modules.system.domain.BaseEntity;
import lombok.Data;

/**
 * 定时任务通知设置实体
 * 对应 Python 版的 TaskNotificationSetting 模型
 */
@Data
@TableName("api_task_notification_settings")
public class TaskNotificationSetting extends BaseEntity {

    /**
     * 关联的定时任务ID
     */
    private Long taskId;

    /**
     * 通知类型: email=邮箱通知, webhook=Webhook机器人, both=两种都发送
     */
    private String notificationType;

    /**
     * 通知配置ID (关联 notification_config 表，可选)
     * 不指定则使用系统默认配置
     */
    private Long notificationConfigId;

    /**
     * 是否启用通知
     */
    private Boolean isEnabled;

    /**
     * 成功时通知
     */
    private Boolean notifyOnSuccess;

    /**
     * 失败时通知
     */
    private Boolean notifyOnFailure;

    /**
     * 超时时通知
     */
    private Boolean notifyOnTimeout;

    /**
     * 错误时通知
     */
    private Boolean notifyOnError;

    /**
     * 自定义Webhook机器人配置 (JSON格式，可选覆盖通知配置中的设置)
     */
    private String customWebhookBots;

    /**
     * 自定义收件人邮箱列表 (JSON格式，可选覆盖通知配置中的收件人)
     * 格式: ["email1@example.com", "email2@example.com"]
     */
    private String customRecipients;
}
