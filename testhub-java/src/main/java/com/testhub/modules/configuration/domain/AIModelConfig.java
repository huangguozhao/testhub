package com.testhub.modules.configuration.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.math.BigDecimal;

/**
 * AI模型配置实体
 */
@Data
@TableName("cfg_ai_model_config")
public class AIModelConfig extends BaseEntity {

    /**
     * 配置名称
     */
    private String name;

    /**
     * 模型类型: deepseek, qwen, siliconflow, zhipu, other
     * 对应数据库列 provider
     */
    @TableField("provider")
    private String modelType;

    /**
     * 角色: writer, reviewer, browser_use_text, browser_use_vision
     */
    private String role;

    /**
     * API Key（写入时使用，响应中不返回）
     */
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String apiKey;

    /**
     * API Key 掩码版本（只读，响应中返回）
     */
    @TableField(exist = false)
    private String apiKeyMasked;

    /**
     * API Base URL
     */
    private String baseUrl;

    /**
     * 模型名称
     */
    private String modelName;

    /**
     * 最大Token数
     */
    private Integer maxTokens;

    /**
     * 温度参数
     */
    private BigDecimal temperature;

    /**
     * Top P参数
     */
    private BigDecimal topP;

    /**
     * 是否启用
     * 对应数据库列 is_enabled
     */
    @TableField("is_enabled")
    private Boolean isActive;
}
