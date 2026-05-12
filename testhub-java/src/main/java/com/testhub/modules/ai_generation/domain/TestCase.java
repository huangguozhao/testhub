package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * 测试用例实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("tc_test_case")
public class TestCase extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 用例标题
     */
    private String title;

    /**
     * 用例描述
     */
    private String description;

    /**
     * 优先级: low=低, medium=中, high=高, critical=紧急
     */
    private String priority;

    /**
     * 类型: functional=功能测试, integration=集成测试, api=API测试, ui=UI测试, performance=性能测试, security=安全测试
     */
    private String type;

    /**
     * 状态: draft=草稿, active=激活, deprecated=废弃
     */
    private String status;

    /**
     * 前置条件
     */
    private String precondition;

    /**
     * 预期结果
     */
    private String expectedResult;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String creatorUsername;

    @TableField(exist = false)
    private String creatorRealName;

    @TableField(exist = false)
    private Long stepCount;

    @TableField(exist = false)
    private String projectName;
}
