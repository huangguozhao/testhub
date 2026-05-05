package com.testhub.modules.api_testing.dto;

import lombok.Data;

/**
 * API临时执行请求 DTO（不保存到数据库，直接执行）
 */
@Data
public class ApiTempExecuteDTO {

    /**
     * 请求ID（如果只有id，从数据库查询完整数据）
     */
    private Long id;

    private String url;

    private String method;

    /**
     * URL参数 (JSON格式)
     */
    private String params;

    /**
     * 请求头 (JSON格式)
     */
    private String headers;

    /**
     * 环境ID
     */
    private Long environmentId;

    /**
     * 请求体类型: none, json, form, xml, raw, binary
     */
    private String bodyType;

    /**
     * 请求体内容 (JSON格式)
     */
    private String bodyContent;

    /**
     * 前置脚本 (JavaScript)
     */
    private String preScript;

    /**
     * 后置脚本 (JavaScript)
     */
    private String postScript;

    /**
     * 断言规则 (JSON)
     */
    private String assertions;
}