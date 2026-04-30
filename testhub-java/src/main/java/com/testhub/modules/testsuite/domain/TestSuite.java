package com.testhub.modules.testsuite.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * 测试套件实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ts_test_suite")
public class TestSuite extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 套件名称
     */
    private String name;

    /**
     * 套件描述
     */
    private String description;

    /**
     * 排序
     */
    private Integer sortOrder;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private Long caseCount;
}
