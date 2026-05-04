package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * API项目成员
 */
@Data
@TableName("api_project_member")
public class ApiProjectMember {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * API项目ID
     */
    private Long projectId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 角色: owner, admin, member
     */
    private String role;

    /**
     * 加入时间
     */
    private LocalDateTime joinedAt;

    /**
     * 是否删除
     */
    @TableLogic
    private Integer isDeleted;
}
