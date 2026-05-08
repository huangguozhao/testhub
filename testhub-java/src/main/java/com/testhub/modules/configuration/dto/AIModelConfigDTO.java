package com.testhub.modules.configuration.dto;

import lombok.Data;

import java.math.BigDecimal;

/**
 * AI模型配置 DTO
 */
@Data
public class AIModelConfigDTO {

    private Long id;

    /**
     * 配置名称
     */
    private String name;

    /**
     * 模型类型: deepseek, qwen, siliconflow, zhipu, other
     */
    private String modelType;

    /**
     * 角色: writer, reviewer
     */
    private String role;

    /**
     * API Key
     */
    private String apiKey;

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
     */
    private Boolean isActive;
}
