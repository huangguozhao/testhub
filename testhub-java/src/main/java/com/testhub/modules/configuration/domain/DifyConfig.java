package com.testhub.modules.configuration.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.time.LocalDateTime;

@Data
@TableName("cfg_dify_config")
public class DifyConfig {

    @TableId(type = IdType.AUTO)
    private Long id;

    private String apiUrl;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String apiKey;

    @TableField("is_enabled")
    @JsonProperty("is_active")
    private Boolean isActive;

    @TableLogic
    private Integer isDeleted;

    @TableField(fill = FieldFill.INSERT)
    private LocalDateTime createdAt;

    @TableField(fill = FieldFill.INSERT_UPDATE)
    private LocalDateTime updatedAt;

    @TableField(exist = false)
    private String apiKeyMasked;
}
