package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * API测试套件实体
 */
@Data
@TableName("api_test_suite")
public class ApiTestSuite extends BaseEntity {

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
     * 执行环境ID
     */
    private Long environmentId;

    /**
     * 超时时间(毫秒)
     */
    private Integer timeout;

    /**
     * 失败重试次数
     */
    private Integer retryCount;
}
