package com.testhub.modules.ui_automation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * UI自动化测试套件实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ui_test_suite")
public class UITestSuite extends BaseEntity {

    /**
     * 关联UI项目ID
     */
    private Long projectId;

    /**
     * 测试套件名称
     */
    private String name;

    /**
     * 测试套件描述
     */
    private String description;

    /**
     * 测试环境ID
     */
    private Long environmentId;

    /**
     * 创建者ID
     */
    private Long createdBy;
}