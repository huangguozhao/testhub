package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("testcase_generation_task")
public class TestCaseGenerationTask {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String taskId;
    private String title;
    private String requirementText;
    private String status;
    private Integer progress;
    private String outputMode;

    private String streamBuffer;
    private Integer streamPosition;
    private LocalDateTime lastStreamUpdate;

    private Long projectId;
    private Long writerModelConfigId;
    private Long reviewerModelConfigId;
    private Long writerPromptConfigId;
    private Long reviewerPromptConfigId;

    private String generatedTestCases;
    private String reviewFeedback;
    private String finalTestCases;
    private String generationLog;
    private String errorMessage;

    private Long createdBy;
    private Integer isSavedToRecords;
    private LocalDateTime savedAt;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;
    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
    private LocalDateTime completedAt;
}
