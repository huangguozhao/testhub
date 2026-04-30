package com.testhub.modules.api.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * API集合实体
 */
@Data
@TableName("api_collection")
public class ApiCollection extends BaseEntity {

    /**
     * API项目ID
     */
    private Long projectId;

    /**
     * 测试套件ID
     */
    private Long suiteId;

    /**
     * 父集合ID(树形结构)
     */
    private Long parentId;

    /**
     * 集合名称
     */
    private String name;

    /**
     * 集合描述
     */
    private String description;

    /**
     * 排序
     */
    private Integer sortOrder;
}
