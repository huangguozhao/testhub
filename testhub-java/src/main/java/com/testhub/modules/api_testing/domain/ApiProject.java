package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;
import com.testhub.modules.system.domain.User;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

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
     * 项目类型: HTTP, WEBSOCKET
     */
    private String projectType;

    /**
     * 项目状态: NOT_STARTED, IN_PROGRESS, COMPLETED
     */
    private String status;

    /**
     * 开始日期
     */
    private LocalDate startDate;

    /**
     * 结束日期
     */
    private LocalDate endDate;

    /**
     * 负责人ID
     */
    private Long ownerId;

    /**
     * 基础URL
     */
    private String baseUrl;

    // ========== 瞬态字段，不对应数据库列 ==========

    /**
     * 负责人信息（瞬态，由Service层填充）
     */
    @TableField(exist = false)
    private User owner;

    /**
     * 成员列表（瞬态，由Service层填充）
     */
    @TableField(exist = false)
    private List<User> members;
}
