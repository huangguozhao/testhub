package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * 测试套件用例关联实体
 */
@Data
@TableName("ts_test_suite_case")
public class TestSuiteCase extends BaseEntity {

    /**
     * 套件ID
     */
    private Long suiteId;

    /**
     * 用例ID
     */
    private Long testCaseId;

    /**
     * 排序
     */
    private Integer sortOrder;
}
