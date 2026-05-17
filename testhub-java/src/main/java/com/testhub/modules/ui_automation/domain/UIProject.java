package com.testhub.modules.ui_automation.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;
import com.testhub.modules.system.domain.User;

/**
 * UI自动化项目实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ui_project")
public class UIProject extends BaseEntity {

    /**
     * 关联项目ID
     */
    @JsonProperty("project_id")
    private Long projectId;

    /**
     * UI项目名称
     */
    private String name;

    /**
     * 项目描述
     */
    private String description;

    /**
     * 引擎类型: selenium, playwright
     */
    private String engine;

    /**
     * 项目状态（从Django版本获取）
     */
    @TableField(exist = false)
    private String status;

    /**
     * 负责人ID
     */
    @TableField(exist = false)
    @JsonProperty("owner_id")
    private Long ownerId;

    /**
     * 浏览器类型
     */
    @TableField(exist = false)
    @JsonProperty("browser_type")
    private String browserType;

    /**
     * 默认超时时间（秒）
     */
    @TableField(exist = false)
    @JsonProperty("default_timeout")
    private Integer defaultTimeout;

    /**
     * 基础URL
     */
    @TableField(exist = false)
    @JsonProperty("base_url")
    private String baseUrl;

    /**
     * 开始日期
     */
    @TableField(exist = false)
    @JsonProperty("start_date")
    private String startDate;

    /**
     * 结束日期
     */
    @TableField(exist = false)
    @JsonProperty("end_date")
    private String endDate;

    /**
     * 负责人信息（瞬态）
     */
    @TableField(exist = false)
    private User owner;

    /**
     * 兼容前端发送 owner 为数字ID的情况
     */
    @JsonProperty("owner")
    public void setOwnerFromJson(Object value) {
        if (value instanceof Number) {
            this.ownerId = ((Number) value).longValue();
        } else if (value instanceof User) {
            this.owner = (User) value;
            this.ownerId = ((User) value).getId();
        }
    }
}