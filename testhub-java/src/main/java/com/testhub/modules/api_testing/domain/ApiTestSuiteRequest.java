package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.util.Map;

/**
 * 测试套件请求关联实体
 */
@Data
@TableName("api_test_suite_requests")
public class ApiTestSuiteRequest {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 测试套件ID
     */
    private Long testSuiteId;

    /**
     * API请求ID
     */
    private Long requestId;

    /**
     * 执行顺序
     */
    @TableField("`order`")
    private Integer sortOrder;

    /**
     * 断言规则 (JSON)
     */
    private String assertions;

    /**
     * 是否启用
     */
    private Boolean enabled;

    /**
     * 关联的API请求信息（瞬态字段）
     */
    @TableField(exist = false)
    private Map<String, Object> request;
}
