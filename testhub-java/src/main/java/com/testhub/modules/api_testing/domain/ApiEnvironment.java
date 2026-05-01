package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * API环境实体
 */
@Data
@TableName("api_environment")
public class ApiEnvironment extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 环境名称
     */
    private String name;

    /**
     * 环境描述
     */
    private String description;

    /**
     * 环境变量 (JSON格式)
     */
    private String variables;

    /**
     * 是否默认: 0=否, 1=是
     */
    private Boolean isDefault;
}
