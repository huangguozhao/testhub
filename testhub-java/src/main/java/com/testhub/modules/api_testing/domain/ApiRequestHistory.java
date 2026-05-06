package com.testhub.modules.api_testing.domain;

import com.baomidou.mybatisplus.annotation.IdType;
import com.baomidou.mybatisplus.annotation.TableId;
import com.baomidou.mybatisplus.annotation.TableName;
import lombok.Data;

import java.time.LocalDateTime;

/**
 * API请求历史记录实体
 */
@Data
@TableName("api_request_history")
public class ApiRequestHistory {

    @TableId(type = IdType.AUTO)
    private Long id;

    /**
     * 关联的API请求ID
     */
    private Long requestId;

    /**
     * 关联的套件执行记录ID (可选)
     */
    private Long suiteExecutionId;

    /**
     * HTTP方法
     */
    private String method;

    /**
     * 请求URL
     */
    private String url;

    /**
     * 请求头 (JSON)
     */
    private String requestHeaders;

    /**
     * 请求体
     */
    private String requestBody;

    /**
     * 响应状态码
     */
    private Integer responseStatusCode;

    /**
     * 响应头 (JSON)
     */
    private String responseHeaders;

    /**
     * 响应体
     */
    private String responseBody;

    /**
     * 响应时间 (毫秒)
     */
    private Long responseTime;

    /**
     * 断言结果 (JSON)
     */
    private String assertions;

    /**
     * 提取变量 (JSON)
     */
    private String extractedVariables;

    /**
     * 是否成功
     */
    private Boolean success;

    /**
     * 错误信息
     */
    private String errorMessage;

    /**
     * 执行时间
     */
    private LocalDateTime executedAt;

    /**
     * 执行人ID
     */
    private Long executedBy;

    /**
     * 创建时间
     */
    private LocalDateTime createdAt;

    /**
     * 请求类型: HTTP, WEBSOCKET
     */
    private String requestType;
}
