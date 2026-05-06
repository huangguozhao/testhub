package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonSetter;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;
import com.testhub.modules.system.domain.User;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
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
     * 负责人信息（瞬态，由Service层填充，用于响应返回）
     */
    @TableField(exist = false)
    private User owner;

    /**
     * 成员列表（瞬态，由Service层填充，用于响应返回）
     */
    @TableField(exist = false)
    private List<User> members;

    /**
     * 成员ID列表（前端发送 member_ids 字段）
     */
    @TableField(exist = false)
    @JsonProperty("member_ids")
    private List<Long> memberIds;

    /**
     * 兼容前端发送 owner 为数字ID的情况
     * 前端发送: {"owner": 3} → 设置 ownerId = 3
     * 前端发送: {"owner": {"id": 3, "username": "admin"}} → 设置 owner 对象
     */
    @JsonSetter("owner")
    public void setOwnerFromJson(Object value) {
        if (value instanceof Number) {
            this.ownerId = ((Number) value).longValue();
        } else if (value instanceof User) {
            this.owner = (User) value;
            this.ownerId = ((User) value).getId();
        }
    }

    /**
     * 兼容前端发送 members 为ID数组的情况
     */
    @JsonSetter("members")
    public void setMembersFromJson(Object value) {
        if (value instanceof List) {
            List<?> list = (List<?>) value;
            if (!list.isEmpty() && list.get(0) instanceof Number) {
                this.memberIds = new ArrayList<>();
                for (Object item : list) {
                    this.memberIds.add(((Number) item).longValue());
                }
            }
        }
    }
}
