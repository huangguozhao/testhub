package com.testhub.modules.execution.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * 测试执行记录实体
 */
@Data
@TableName("exec_test_run")
public class TestRun extends BaseEntity {

    /**
     * 计划ID
     */
    private Long planId;

    /**
     * 套件ID
     */
    private Long suiteId;

    /**
     * 状态: pending=待执行, running=执行中, completed=已完成, failed=失败
     */
    private String status;

    /**
     * 执行人ID
     */
    private Long executorId;

    /**
     * 开始时间
     */
    private LocalDateTime startedAt;

    /**
     * 完成时间
     */
    private LocalDateTime completedAt;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String executorName;

    @TableField(exist = false)
    private String suiteName;

    @TableField(exist = false)
    private Integer totalCount;

    @TableField(exist = false)
    private Integer passedCount;

    @TableField(exist = false)
    private Integer failedCount;
}
