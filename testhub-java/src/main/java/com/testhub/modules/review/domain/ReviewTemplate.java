package com.testhub.modules.review.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("review_templates")
public class ReviewTemplate {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;
    private String description;
    private Long projectId;
    private Long createdBy;

    /**
     * 检查清单，JSON格式存储
     */
    private String checklist;

    private Integer isActive;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    // 扩展字段
    @TableField(exist = false)
    private String projectName;

    @TableField(exist = false)
    private String creatorName;
}
