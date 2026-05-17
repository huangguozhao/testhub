package com.testhub.modules.ai_generation.review.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Data
@TableName("rv_test_case_review")
public class TestCaseReview {

    @TableId(type = IdType.AUTO)
    private Long id;

    private Long projectId;
    private String name;
    private String description;
    private String status;
    private Long templateId;
    private Long assigneeId;
    private LocalDate dueDate;
    private Integer isDeleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    private Long createdBy;
    private Long updatedBy;

    // 扩展字段
    @TableField(exist = false)
    private String projectName;

    @TableField(exist = false)
    private String assigneeName;

    @TableField(exist = false)
    private String creatorName;
}