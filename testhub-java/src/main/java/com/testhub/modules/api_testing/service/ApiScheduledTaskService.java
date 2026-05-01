package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiScheduledTask;

import java.util.List;

/**
 * API定时任务服务接口
 */
public interface ApiScheduledTaskService extends IService<ApiScheduledTask> {

    /**
     * 创建定时任务
     */
    ApiScheduledTask createTask(ApiScheduledTask task);

    /**
     * 更新定时任务
     */
    ApiScheduledTask updateTask(Long id, ApiScheduledTask task);

    /**
     * 删除定时任务
     */
    void deleteTask(Long id);

    /**
     * 获取项目的所有定时任务
     */
    List<ApiScheduledTask> getTasksByProject(Long projectId);

    /**
     * 获取套件的所有定时任务
     */
    List<ApiScheduledTask> getTasksBySuite(Long suiteId);

    /**
     * 启用任务
     */
    void enableTask(Long id);

    /**
     * 禁用任务
     */
    void disableTask(Long id);

    /**
     * 立即执行任务
     */
    void executeTaskNow(Long id);

    /**
     * 获取任务详情
     */
    ApiScheduledTask getTask(Long id);
}