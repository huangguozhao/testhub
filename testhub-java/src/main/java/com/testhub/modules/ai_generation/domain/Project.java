package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

import java.util.List;

@Data
@EqualsAndHashCode(callSuper = true)
@TableName("prj_project")
public class Project extends BaseEntity {

    /**
     * 项目名称
     */
    private String name;

    /**
     * 项目描述
     */
    private String description;

    /**
     * 项目状态：active/paused/completed/archived
     */
    private String status;

    /**
     * 项目负责人ID
     */
    private Long ownerId;

    /**
     * 项目图标
     */
    private String icon;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 是否包含测试用例：true/false
     */
    private Boolean includeTestCases;

    /**
     * 是否包含自动化测试：true/false
     */
    private Boolean includeAutomatedTests;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String ownerName;

    @TableField(exist = false)
    private String creatorUsername;

    @TableField(exist = false)
    private String creatorRealName;

    @TableField(exist = false)
    private Long memberCount;

    @TableField(exist = false)
    private Long testCaseCount;

    @TableField(exist = false)
    private List<ProjectMember> members;

    @TableField(exist = false)
    private List<ProjectEnvironment> environments;
}