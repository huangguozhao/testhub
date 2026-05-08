package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.TaskNotificationSetting;
import com.testhub.modules.api_testing.dto.TaskNotificationSettingDTO;

/**
 * 定时任务通知设置服务接口
 */
public interface TaskNotificationSettingService extends IService<TaskNotificationSetting> {

    /**
     * 根据任务ID获取通知设置
     */
    TaskNotificationSetting getByTaskId(Long taskId);

    /**
     * 创建或更新通知设置
     */
    TaskNotificationSetting createOrUpdate(TaskNotificationSettingDTO dto);

    /**
     * 根据任务ID删除通知设置
     */
    void deleteByTaskId(Long taskId);

    /**
     * 判断是否应该发送通知
     *
     * @param setting        通知设置
     * @param executionStatus 执行状态: success / failed / timeout / error
     * @return true=应该发送通知
     */
    boolean shouldNotify(TaskNotificationSetting setting, String executionStatus);
}
