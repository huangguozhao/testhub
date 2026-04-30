package com.testhub.modules.api.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * API定时任务实体
 */
@Data
@TableName("api_scheduled_task")
public class ApiScheduledTask extends BaseEntity {

    /**
     * 套件ID
     */
    private Long suiteId;

    /**
     * 任务名称
     */
    private String name;

    /**
     * 触发类型: cron=Cron表达式, interval=固定间隔, once=单次执行
     */
    private String triggerType;

    /**
     * Cron表达式
     */
    private String cronExpression;

    /**
     * 间隔值
     */
    private Long intervalValue;

    /**
     * 间隔单位: seconds, minutes, hours
     */
    private String intervalUnit;

    /**
     * 单次执行时间
     */
    private LocalDateTime onceTime;

    /**
     * 是否启用: 0=禁用, 1=启用
     */
    private Boolean isEnabled;

    /**
     * 通知配置 (JSON)
     */
    private String notificationConfig;

    /**
     * 上次执行时间
     */
    private LocalDateTime lastRunAt;

    /**
     * 下次执行时间
     */
    private LocalDateTime nextRunAt;
}
