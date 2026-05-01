package com.testhub.modules.notification.dto;

import lombok.Data;

/**
 * 发送通知 DTO
 */
@Data
public class SendNotificationDTO {

    /**
     * 通知渠道: feishu, wechat, dingtalk, email
     */
    private String channel;

    /**
     * 通知配置ID (可选，不传则使用默认配置)
     */
    private Long configId;

    /**
     * 通知标题
     */
    private String title;

    /**
     * 通知内容
     */
    private String content;

    /**
     * 任务ID (可选)
     */
    private Long taskId;

    /**
     * 任务类型 (可选)
     */
    private String taskType;
}
