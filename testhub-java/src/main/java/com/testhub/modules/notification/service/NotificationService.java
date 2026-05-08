package com.testhub.modules.notification.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.modules.notification.domain.NotificationLog;
import com.testhub.modules.notification.dto.SendNotificationDTO;

/**
 * 通知服务接口
 */
public interface NotificationService {

    /**
     * 发送通知
     */
    NotificationLog sendNotification(SendNotificationDTO dto);

    /**
     * 发送执行结果通知 (通知所有启用的配置)
     */
    void sendExecutionNotification(Long taskId, String taskType, boolean success, String message);

    /**
     * 根据任务的通知设置发送执行结果通知
     * 会检查 TaskNotificationSetting，按配置发送邮件和/或 Webhook
     *
     * @param taskId      定时任务ID
     * @param taskName    任务名称
     * @param taskType    任务类型
     * @param success     是否成功
     * @param message     执行详情
     */
    void sendExecutionNotificationForTask(Long taskId, String taskName, String taskType, boolean success, String message);

    /**
     * 分页查询通知日志
     */
    IPage<NotificationLog> getLogPage(Long taskId, String taskType, String channel, String status, long current, long size);

    /**
     * 获取通知日志详情
     */
    NotificationLog getLog(Long id);

    /**
     * 重试失败的通知
     */
    NotificationLog retryNotification(Long id);

    /**
     * 删除通知日志
     */
    void deleteLog(Long id);
}
