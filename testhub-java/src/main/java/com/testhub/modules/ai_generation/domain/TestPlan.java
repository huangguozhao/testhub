package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * 测试计划实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("exec_test_plan")
public class TestPlan extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 计划名称
     */
    private String name;

    /**
     * 计划描述
     */
    private String description;

    /**
     * 开始日期
     */
    private LocalDateTime startDate;

    /**
     * 结束日期
     */
    private LocalDateTime endDate;

    /**
     * 状态: pending=待执行, in_progress=执行中, completed=已完成
     */
    private String status;

    /**
     * 负责人ID
     */
    private Long assigneeId;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String assigneeName;

    @TableField(exist = false)
    private Long totalCases;

    @TableField(exist = false)
    private Long passedCases;

    @TableField(exist = false)
    private Long failedCases;
}
