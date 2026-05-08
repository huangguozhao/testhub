package com.testhub.modules.api_testing.dto;

import lombok.Data;

/**
 * 任务通知设置 DTO
 */
@Data
public class TaskNotificationSettingDTO {

    /**
     * 通知设置ID (更新时必填)
     */
    private Long id;

    /**
     * 关联的定时任务ID
     */
    private Long taskId;

    /**
     * 通知类型: email / webhook / both
     */
    private String notificationType;

    /**
     * 通知配置ID (可选)
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
     * 自定义Webhook机器人配置 (JSON)
     */
    private String customWebhookBots;

    /**
     * 自定义收件人邮箱列表 (JSON)
     */
    private String customRecipients;
}
