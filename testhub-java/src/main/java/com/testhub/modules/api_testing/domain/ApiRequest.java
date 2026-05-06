package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * API请求实体
 */
@Data
@TableName("api_request")
public class ApiRequest extends BaseEntity {

    /**
     * 集合ID
     */
    private Long collectionId;

    /**
     * 请求名称
     */
    private String name;

    /**
     * HTTP方法: GET, POST, PUT, PATCH, DELETE, HEAD, OPTIONS
     */
    private String method;

    /**
     * 请求URL
     */
    private String url;

    /**
     * 请求头 (JSON)
     */
    private String headers;

    /**
     * URL参数 (JSON)
     */
    private String params;

    /**
     * 请求体类型: none, json, form, xml, raw, binary
     */
    private String bodyType;

    /**
     * 请求体内容
     */
    private String bodyContent;

    /**
     * 认证类型: none, basic, bearer, api_key, oauth2
     */
    private String authType;

    /**
     * 认证配置 (JSON)
     */
    private String authConfig;

    /**
     * 前置脚本
     */
    private String preScript;

    /**
     * 后置脚本
     */
    private String postScript;

    /**
     * 断言规则 (JSON)
     */
    private String assertions;

    /**
     * 变量提取规则 (JSON)
     */
    private String extractors;

    /**
     * 排序
     */
    private Integer sortOrder;

    /**
     * 请求类型: HTTP, WEBSOCKET
     */
    private String requestType;
}
