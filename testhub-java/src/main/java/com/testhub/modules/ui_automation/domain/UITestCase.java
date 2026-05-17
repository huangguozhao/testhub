package com.testhub.modules.ui_automation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * UI自动化测试用例实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ui_test_case")
public class UITestCase extends BaseEntity {

    /**
     * 关联UI项目ID
     */
    private Long projectId;

    /**
     * 测试用例名称
     */
    private String name;

    /**
     * 测试用例描述
     */
    private String description;

    /**
     * 前置条件
     */
    private String preconditions;

    /**
     * 测试步骤（JSON格式）
     */
    private String steps;

    /**
     * 预期结果（JSON格式）
     */
    private String expectedResults;

    /**
     * 优先级: P0, P1, P2, P3
     */
    private String priority;

    /**
     * 状态: DRAFT, READY, APPROVED
     */
    private String status;

    /**
     * 创建者ID
     */
    private Long createdBy;
}