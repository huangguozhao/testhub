package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

@Data
@TableName("prj_project_member")
public class ProjectMember extends BaseEntity {

    /**
     * 项目ID
     */
    private Long projectId;

    /**
     * 用户ID
     */
    private Long userId;

    /**
     * 角色：owner/admin/developer/tester/viewer
     */
    private String role;

    /**
     * 加入时间
     */
    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime joinedAt;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String username;

    @TableField(exist = false)
    private String realName;

    @TableField(exist = false)
    private String email;

    @TableField(exist = false)
    private String avatar;
}