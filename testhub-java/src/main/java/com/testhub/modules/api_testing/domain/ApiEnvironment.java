package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;
import com.testhub.modules.system.domain.User;

/**
 * API环境实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("api_environment")
public class ApiEnvironment extends BaseEntity {

    /**
     * 项目ID (scope=LOCAL时必填，scope=GLOBAL时为null)
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
     * 作用域: GLOBAL=全局环境, LOCAL=项目级环境
     */
    private String scope;

    /**
     * 环境变量 (JSON格式)
     */
    private String variables;

    /**
     * 是否默认: 0=否, 1=是
     */
    private Boolean isDefault;

    /**
     * 是否激活: 0=否, 1=是
     */
    @TableField("is_active")
    private Boolean isActive;

    // ========== 瞬态字段，不对应数据库列 ==========

    /**
     * 项目名称（瞬态，由Service层填充）
     */
    @TableField(exist = false)
    @JsonProperty("project_name")
    private String projectName;

    /**
     * 创建者信息（瞬态，由Service层填充）
     */
    @TableField(exist = false)
    @JsonProperty("created_by")
    private User creator;
}
