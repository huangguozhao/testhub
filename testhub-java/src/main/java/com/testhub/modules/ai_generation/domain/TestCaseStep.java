package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * 用例步骤实体
 */
@Data
@TableName("tc_test_case_step")
public class TestCaseStep extends BaseEntity {

    /**
     * 用例ID
     */
    private Long testCaseId;

    /**
     * 步骤序号
     */
    private Integer stepNumber;

    /**
     * 步骤描述
     */
    private String description;

    /**
     * 预期结果
     */
    private String expectedResult;
}
