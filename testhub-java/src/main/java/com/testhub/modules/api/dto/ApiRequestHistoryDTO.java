package com.testhub.modules.api.dto;

import lombok.Data;

import java.time.LocalDateTime;

/**
 * API请求历史记录 DTO
 */
@Data
public class ApiRequestHistoryDTO {

    private Long id;

    private Long requestId;

    private String requestName;

    private Long suiteExecutionId;

    private String method;

    private String url;

    private String requestHeaders;

    private String requestBody;

    private Integer responseStatusCode;

    private String responseHeaders;

    private String responseBody;

    private Long responseTime;

    private String assertions;

    private String extractedVariables;

    private Boolean success;

    private String errorMessage;

    private LocalDateTime executedAt;

    private Long executedBy;

    private String executedByName;

    private LocalDateTime createdAt;
}
