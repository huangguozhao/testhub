package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiScheduledTask;
import com.testhub.modules.api_testing.http.ApiExecutor;
import com.testhub.modules.api_testing.job.XxlJobApiClient;
import com.testhub.modules.api_testing.mapper.ApiScheduledTaskMapper;
import com.testhub.modules.api_testing.service.ApiScheduledTaskService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * API定时任务服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiScheduledTaskServiceImpl extends ServiceImpl<ApiScheduledTaskMapper, ApiScheduledTask> implements ApiScheduledTaskService {

    private static final int XXL_JOB_GROUP_ID = 1; // testhub-executor 组ID
    private static final String XXL_JOB_HANDLER = "apiScheduledTaskJob";

    private final ApiTestSuiteService apiTestSuiteService;
    private final ApiExecutor apiExecutor;
    private final XxlJobApiClient xxlJobApiClient;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiScheduledTask createTask(ApiScheduledTask task) {
        // 1. 保存任务到数据库
        this.save(task);

        // 2. 注册到 XXL-JOB
        try {
            String scheduleType;
            String scheduleConf;

            switch (task.getTriggerType()) {
                case "CRON" -> {
                    scheduleType = "CRON";
                    scheduleConf = task.getCronExpression();
                    // 计算下次执行时间
                    try {
                        var cron = org.springframework.scheduling.support.CronExpression.parse(scheduleConf);
                        task.setNextRunAt(cron.next(LocalDateTime.now()));
                    } catch (Exception e) {
                        log.warn("解析CRON表达式失败: {}", scheduleConf);
                    }
                }
                case "INTERVAL" -> {
                    scheduleType = "FIX_RATE";
                    long seconds = task.getIntervalValue() != null ? task.getIntervalValue() : 3600;
                    scheduleConf = String.valueOf(seconds); // XXL-JOB FIX_RATE 单位是秒
                    task.setNextRunAt(LocalDateTime.now().plusSeconds(seconds));
                }
                case "ONCE" -> {
                    scheduleType = "FIX_RATE";
                    scheduleConf = "31536000"; // 365天（不会自动触发，靠手动触发）
                }
                default -> {
                    scheduleType = "CRON";
                    scheduleConf = "0 0 * * * ?";
                }
            }

            String jobDesc = "API定时任务-" + task.getName() + "(ID:" + task.getId() + ")";
            Long xxlJobId = xxlJobApiClient.addJob(
                    XXL_JOB_GROUP_ID, jobDesc, XXL_JOB_HANDLER,
                    String.valueOf(task.getId()), scheduleType, scheduleConf);

            if (xxlJobId != null) {
                task.setXxlJobId(xxlJobId);
                this.updateById(task);
                log.info("XXL-JOB 注册成功: taskId={}, xxlJobId={}", task.getId(), xxlJobId);

                // ONCE 类型立即触发一次
                if ("ONCE".equals(task.getTriggerType())) {
                    xxlJobApiClient.triggerJob(xxlJobId, String.valueOf(task.getId()));
                }
            } else {
                log.warn("XXL-JOB 注册失败，任务已保存但不会自动触发: taskId={}", task.getId());
            }
        } catch (Exception e) {
            log.error("注册XXL-JOB失败: taskId={}, error={}", task.getId(), e.getMessage(), e);
        }

        log.info("创建API定时任务: id={}, name={}, triggerType={}", task.getId(), task.getName(), task.getTriggerType());
        return task;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiScheduledTask updateTask(Long id, ApiScheduledTask task) {
        task.setId(id);
        this.updateById(task);

        // 更新 XXL-JOB 任务配置
        ApiScheduledTask existing = this.getById(id);
        if (existing != null && existing.getXxlJobId() != null) {
            try {
                String scheduleType;
                String scheduleConf;

                switch (task.getTriggerType() != null ? task.getTriggerType() : existing.getTriggerType()) {
                    case "CRON" -> {
                        scheduleType = "CRON";
                        scheduleConf = task.getCronExpression() != null ? task.getCronExpression() : existing.getCronExpression();
                    }
                    case "INTERVAL" -> {
                        scheduleType = "FIX_RATE";
                        long seconds = task.getIntervalValue() != null ? task.getIntervalValue()
                                : (existing.getIntervalValue() != null ? existing.getIntervalValue() : 3600);
                        scheduleConf = String.valueOf(seconds * 1000);
                    }
                    default -> {
                        scheduleType = "FIX_RATE";
                        scheduleConf = "31536000";
                    }
                }

                String jobDesc = "API定时任务-" + (task.getName() != null ? task.getName() : existing.getName()) + "(ID:" + id + ")";
                xxlJobApiClient.updateJob(existing.getXxlJobId(), XXL_JOB_GROUP_ID, jobDesc,
                        XXL_JOB_HANDLER, String.valueOf(id), scheduleType, scheduleConf);
            } catch (Exception e) {
                log.error("更新XXL-JOB失败: taskId={}, error={}", id, e.getMessage(), e);
            }
        }

        log.info("更新API定时任务: id={}", id);
        return task;
    }

    @Override
    public void deleteTask(Long id) {
        ApiScheduledTask task = this.getById(id);
        if (task != null && task.getXxlJobId() != null) {
            try {
                xxlJobApiClient.removeJob(task.getXxlJobId());
                log.info("XXL-JOB 任务已移除: xxlJobId={}", task.getXxlJobId());
            } catch (Exception e) {
                log.error("移除XXL-JOB任务失败: xxlJobId={}, error={}", task.getXxlJobId(), e.getMessage(), e);
            }
        }
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
            // 启动 XXL-JOB 任务
            if (task.getXxlJobId() != null) {
                xxlJobApiClient.startJob(task.getXxlJobId());
            }
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
            // 停止 XXL-JOB 任务
            if (task.getXxlJobId() != null) {
                xxlJobApiClient.stopJob(task.getXxlJobId());
            }
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

        log.info("执行定时任务: id={}, name={}", id, task.getName());
        apiExecutor.executeSuite(suite.getId());

        // 更新执行时间
        task.setLastRunAt(LocalDateTime.now());
        if ("ONCE".equals(task.getTriggerType())) {
            task.setIsEnabled(false);
            // 停止 XXL-JOB 任务
            if (task.getXxlJobId() != null) {
                xxlJobApiClient.stopJob(task.getXxlJobId());
            }
        }
        this.updateById(task);
    }

    @Override
    public ApiScheduledTask getTask(Long id) {
        return this.getById(id);
    }
}
