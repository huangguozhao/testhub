package com.testhub.modules.notification.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * 通知日志实体
 */
@Data
@TableName("notification_log")
public class NotificationLog extends BaseEntity {

    /**
     * 关联的任务ID (可选)
     */
    private Long taskId;

    /**
     * 任务名称快照
     */
    private String taskName;

    /**
     * 任务类型: api_test, ui_automation, app_automation
     */
    private String taskType;

    /**
     * 通知类型: task_execution, system_alert, manual
     */
    private String notificationType;

    /**
     * 通知渠道: feishu, wechat, dingtalk, email
     */
    private String channel;

    /**
     * 发送状态: pending, sending, success, failed
     */
    private String status;

    /**
     * 通知配置ID
     */
    private Long configId;

    /**
     * 收件人信息 (JSON格式)
     */
    private String recipientInfo;

    /**
     * 通知内容 (JSON格式)
     */
    private String content;

    /**
     * 错误信息
     */
    private String errorMessage;

    /**
     * 重试次数
     */
    private Integer retryCount;

    /**
     * 发送时间
     */
    private LocalDateTime sentAt;
}
