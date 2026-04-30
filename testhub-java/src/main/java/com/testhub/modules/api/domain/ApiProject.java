package com.testhub.modules.api.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * API项目实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("api_project")
public class ApiProject extends BaseEntity {

    /**
     * 关联项目ID
     */
    private Long projectId;

    /**
     * API项目名称
     */
    private String name;

    /**
     * 项目描述
     */
    private String description;

    /**
     * 基础URL
     */
    private String baseUrl;
}
