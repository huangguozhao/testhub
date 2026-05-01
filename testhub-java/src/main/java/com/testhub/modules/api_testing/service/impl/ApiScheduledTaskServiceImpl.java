package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiScheduledTask;
import com.testhub.modules.api_testing.http.ApiExecutor;
import com.testhub.modules.api_testing.mapper.ApiScheduledTaskMapper;
import com.testhub.modules.api_testing.service.ApiScheduledTaskService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * API定时任务服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiScheduledTaskServiceImpl extends ServiceImpl<ApiScheduledTaskMapper, ApiScheduledTask> implements ApiScheduledTaskService {

    private final ApiTestSuiteService apiTestSuiteService;
    private final ApiExecutor apiExecutor;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiScheduledTask createTask(ApiScheduledTask task) {
        this.save(task);
        log.info("创建API定时任务: id={}, name={}", task.getId(), task.getName());
        return task;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiScheduledTask updateTask(Long id, ApiScheduledTask task) {
        task.setId(id);
        this.updateById(task);
        log.info("更新API定时任务: id={}", id);
        return task;
    }

    @Override
    public void deleteTask(Long id) {
        this.removeById(id);
        log.info("删除API定时任务: id={}", id);
    }

    @Override
    public List<ApiScheduledTask> getTasksByProject(Long projectId) {
        return this.list(new LambdaQueryWrapper<ApiScheduledTask>()
                .inSql(ApiScheduledTask::getSuiteId,
                        "SELECT id FROM api_test_suite WHERE project_id = " + projectId)
                .orderByDesc(ApiScheduledTask::getCreatedAt));
    }

    @Override
    public List<ApiScheduledTask> getTasksBySuite(Long suiteId) {
        return this.list(new LambdaQueryWrapper<ApiScheduledTask>()
                .eq(ApiScheduledTask::getSuiteId, suiteId)
                .orderByDesc(ApiScheduledTask::getCreatedAt));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void enableTask(Long id) {
        ApiScheduledTask task = this.getById(id);
        if (task != null) {
            task.setIsEnabled(true);
            this.updateById(task);
            log.info("启用定时任务: id={}", id);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void disableTask(Long id) {
        ApiScheduledTask task = this.getById(id);
        if (task != null) {
            task.setIsEnabled(false);
            this.updateById(task);
            log.info("禁用定时任务: id={}", id);
        }
    }

    @Override
    public void executeTaskNow(Long id) {
        ApiScheduledTask task = this.getById(id);
        if (task == null) {
            throw new RuntimeException("定时任务不存在: " + id);
        }

        var suite = apiTestSuiteService.getTestSuite(task.getSuiteId());
        if (suite == null) {
            throw new RuntimeException("测试套件不存在: " + task.getSuiteId());
        }

        log.info("立即执行定时任务: id={}, name={}", id, task.getName());
        apiExecutor.executeSuite(suite.getId());
    }

    @Override
    public ApiScheduledTask getTask(Long id) {
        return this.getById(id);
    }
}