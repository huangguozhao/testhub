package com.testhub.modules.api_testing.http;

import lombok.Builder;
import lombok.Data;

import java.util.List;
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
    private boolean abort;      // Tests脚本是否中止请求
    private String abortReason; // 中止原因
    private List<AssertionEngine.AssertionResult> assertionResults; // 断言结果
}
