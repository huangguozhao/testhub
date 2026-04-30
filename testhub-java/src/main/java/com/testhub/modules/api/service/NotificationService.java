package com.testhub.modules.api.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.modules.api.domain.NotificationLog;
import com.testhub.modules.api.dto.SendNotificationDTO;

/**
 * 通知服务接口
 */
public interface NotificationService {

    /**
     * 发送通知
     */
    NotificationLog sendNotification(SendNotificationDTO dto);

    /**
     * 发送执行结果通知
     */
    void sendExecutionNotification(Long taskId, String taskType, boolean success, String message);

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
