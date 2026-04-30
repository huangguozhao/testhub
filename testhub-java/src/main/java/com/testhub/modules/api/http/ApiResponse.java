package com.testhub.modules.api.http;

import lombok.Builder;
import lombok.Data;

import java.util.Map;

/**
 * API响应结果
 */
@Data
@Builder
public class ApiResponse {
    private boolean success;
    private Integer statusCode;
    private Map<String, String> headers;
    private String body;
    private Long responseTime;
    private String error;
}
