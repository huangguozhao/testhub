package com.testhub.common.exception;

/**
 * 业务错误码枚举
 * <p>
 * 错误码范围:
 * - 1000-1099: 认证相关
 * - 1100-1199: 权限相关
 * - 2000-2999: 通用业务错误
 * - 3000-3999: API Testing模块
 * - 4000-4999: 项目/集合/环境相关
 */
public enum ErrorCode {

    // ===== 通用错误 (2000-2099) =====
    INVALID_PARAMETER(2001, "参数无效"),
    RESOURCE_NOT_FOUND(2002, "资源不存在"),
    RESOURCE_ALREADY_EXISTS(2003, "资源已存在"),
    OPERATION_FAILED(2004, "操作失败"),
    DATA_INTEGRITY_ERROR(2005, "数据完整性错误"),

    // ===== 认证相关 (1000-1099) =====
    AUTH_FAILED(1001, "认证失败"),
    TOKEN_EXPIRED(1002, "Token已过期"),
    TOKEN_INVALID(1003, "Token无效"),
    UNAUTHORIZED(1004, "未授权"),

    // ===== 权限相关 (1100-1199) =====
    NO_PERMISSION(1101, "没有权限访问该资源"),
    ACCESS_DENIED(1102, "访问被拒绝"),

    // ===== API Testing模块 (3000-3099) =====
    API_PROJECT_NOT_FOUND(3001, "API项目不存在"),
    API_COLLECTION_NOT_FOUND(3002, "API集合不存在"),
    API_ENVIRONMENT_NOT_FOUND(3003, "API环境不存在"),
    API_REQUEST_NOT_FOUND(3004, "API请求不存在"),
    API_EXECUTION_FAILED(3005, "API执行失败"),
    API_IMPORT_FAILED(3006, "API导入失败"),
    API_EXPORT_FAILED(3007, "API导出失败"),
    API_SCRIPT_EXECUTION_FAILED(3008, "脚本执行失败"),
    API_ASSERTION_FAILED(3009, "断言失败"),
    SCRIPT_TIMEOUT(3010, "脚本执行超时"),

    // ===== 项目/集合/环境 (4000-4099) =====
    PROJECT_NOT_FOUND(4001, "项目不存在"),
    COLLECTION_NOT_FOUND(4002, "集合不存在"),
    ENVIRONMENT_NOT_FOUND(4003, "环境不存在"),
    ENVIRONMENT_BASE_URL_NOT_SET(4004, "环境未设置Base URL"),

    // ===== 测试执行 (5000-5099) =====
    TEST_PLAN_NOT_FOUND(5001, "测试计划不存在"),
    TEST_RUN_NOT_FOUND(5002, "测试运行不存在"),
    TEST_CASE_NOT_FOUND(5003, "测试用例不存在"),
    TEST_EXECUTION_FAILED(5004, "测试执行失败"),

    // ===== 用户/团队 (6000-6099) =====
    USER_NOT_FOUND(6001, "用户不存在"),
    TEAM_NOT_FOUND(6002, "团队不存在"),
    MEMBER_NOT_FOUND(6003, "成员不存在"),

    // ===== 通知 (7000-7099) =====
    NOTIFICATION_CONFIG_NOT_FOUND(7001, "通知配置不存在"),
    NOTIFICATION_SEND_FAILED(7002, "通知发送失败"),

    // ===== AI功能 (8000-8099) =====
    AI_SERVICE_UNAVAILABLE(8001, "AI服务不可用"),
    AI_GENERATION_FAILED(8002, "AI生成失败"),
    AI_ANALYSIS_FAILED(8003, "AI分析失败");

    private final int code;
    private final String message;

    ErrorCode(int code, String message) {
        this.code = code;
        this.message = message;
    }

    public int getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    /**
     * 创建带自定义消息的业务异常
     */
    public BusinessException withMessage(String customMessage) {
        return new BusinessException(this.code, customMessage);
    }

    /**
     * 创建带原错误消息的业务异常
     */
    public BusinessException withDefaultMessage() {
        return new BusinessException(this.code, this.message);
    }

    /**
     * 创建带格式化消息的业务异常
     */
    public BusinessException withMessage(String template, Object... args) {
        return new BusinessException(this.code, String.format(template, args));
    }
}
