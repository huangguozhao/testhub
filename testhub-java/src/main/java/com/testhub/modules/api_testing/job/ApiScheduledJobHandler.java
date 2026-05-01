package com.testhub.modules.api_testing.job;

import com.testhub.modules.api_testing.domain.ApiScheduledTask;
import com.testhub.modules.api_testing.service.ApiScheduledTaskService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import com.xxl.job.core.context.XxlJobHelper;
import com.xxl.job.core.handler.annotation.XxlJob;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

/**
 * API定时任务 XXL-JOB 处理器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ApiScheduledJobHandler {

    private final ApiScheduledTaskService apiScheduledTaskService;
    private final ApiTestSuiteService apiTestSuiteService;

    /**
     * API定时任务执行入口
     * XXL-JOB 调用此方法执行任务
     */
    @XxlJob("apiScheduledTaskJob")
    public void execute() {
        String param = XxlJobHelper.getJobParam();
        log.info("XXL-JOB 触发 API 定时任务: param={}", param);

        try {
            if (param == null || param.isBlank()) {
                log.warn("XXL-JOB 参数为空，无法执行任务");
                XxlJobHelper.handleFail("参数错误: taskId 为空");
                return;
            }

            // 解析参数 (格式: taskId)
            Long taskId;
            try {
                taskId = Long.parseLong(param.trim());
            } catch (NumberFormatException e) {
                log.error("解析 taskId 失败: {}", param);
                XxlJobHelper.handleFail("参数错误: taskId 格式错误");
                return;
            }

            // 获取任务信息
            ApiScheduledTask task = apiScheduledTaskService.getById(taskId);
            if (task == null) {
                log.error("定时任务不存在: id={}", taskId);
                XxlJobHelper.handleFail("定时任务不存在");
                return;
            }

            // 检查任务是否启用
            if (!Boolean.TRUE.equals(task.getIsEnabled())) {
                log.info("定时任务未启用，跳过执行: id={}", taskId);
                XxlJobHelper.handleSuccess();
                return;
            }

            // 执行任务
            log.info("开始执行定时任务: id={}, name={}", taskId, task.getName());
            apiScheduledTaskService.executeTaskNow(taskId);

            // 更新执行时间
            task.setLastRunAt(LocalDateTime.now());
            apiScheduledTaskService.updateById(task);

            log.info("定时任务执行完成: id={}", taskId);
            XxlJobHelper.handleSuccess();

        } catch (Exception e) {
            log.error("定时任务执行失败: {}", e.getMessage(), e);
            XxlJobHelper.handleFail("执行失败: " + e.getMessage());
        }
    }

    /**
     * 每分钟检查一次，更新下次执行时间
     * 可以通过 XXL-JOB ADMIN 界面配置 cron 表达式来触发
     */
    @XxlJob("apiScheduledTaskUpdateNextRunJob")
    public void updateNextRunTime() {
        log.info("更新定时任务下次执行时间");

        try {
            // 获取所有启用的定时任务
            var enabledTasks = apiScheduledTaskService.list(
                    new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<ApiScheduledTask>()
                            .eq(ApiScheduledTask::getIsEnabled, true)
                            .eq(ApiScheduledTask::getTriggerType, "cron")
            );

            for (ApiScheduledTask task : enabledTasks) {
                try {
                    String cronExpression = task.getCronExpression();
                    if (cronExpression != null && !cronExpression.isBlank()) {
                        LocalDateTime nextRunAt = calculateNextRunTime(cronExpression);
                        task.setNextRunAt(nextRunAt);
                        apiScheduledTaskService.updateById(task);
                    }
                } catch (Exception e) {
                    log.warn("更新任务 {} 的下次执行时间失败: {}", task.getId(), e.getMessage());
                }
            }

            XxlJobHelper.handleSuccess();
        } catch (Exception e) {
            log.error("更新下次执行时间失败: {}", e.getMessage(), e);
            XxlJobHelper.handleFail("更新失败");
        }
    }

    /**
     * 计算 Cron 表达式的下次执行时间 (简化实现)
     */
    private LocalDateTime calculateNextRunTime(String cronExpression) {
        // 简化实现：默认 +1 小时
        // 完整实现需要使用 CronExpression 解析库
        return LocalDateTime.now().plusHours(1);
    }
}
