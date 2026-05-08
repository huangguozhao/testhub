package com.testhub.modules.configuration.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cfg_generation_config")
public class GenerationConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String name;

    private String defaultOutputMode;

    private Boolean enableAutoReview;

    private Integer reviewTimeout;

    @TableField("is_enabled")
    @JsonProperty("is_active")
    private Boolean isActive;

    @TableLogic
    private Integer isDeleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;
}
