package com.testhub.common.constant;

/**
 * 通用常量定义
 */
public interface Constants {

    // ========== Token 相关 ==========
    String ACCESS_TOKEN = "access_token";
    String REFRESH_TOKEN = "refresh_token";
    String TOKEN_PREFIX = "token:";
    String BLACKLIST_PREFIX = "blacklist:";

    // ========== 用户角色 ==========
    String ROLE_OWNER = "owner";        // 负责人
    String ROLE_ADMIN = "admin";        // 管理员
    String ROLE_DEVELOPER = "developer"; // 开发者
    String ROLE_TESTER = "tester";      // 测试者
    String ROLE_VIEWER = "viewer";      // 观察者

    // ========== 项目状态 ==========
    String PROJECT_STATUS_ACTIVE = "active";
    String PROJECT_STATUS_PAUSED = "paused";
    String PROJECT_STATUS_COMPLETED = "completed";
    String PROJECT_STATUS_ARCHIVED = "archived";

    // ========== 测试用例状态 ==========
    String TC_STATUS_DRAFT = "draft";
    String TC_STATUS_ACTIVE = "active";
    String TC_STATUS_DEPRECATED = "deprecated";

    // ========== 测试用例优先级 ==========
    String TC_PRIORITY_LOW = "low";
    String TC_PRIORITY_MEDIUM = "medium";
    String TC_PRIORITY_HIGH = "high";
    String TC_PRIORITY_CRITICAL = "critical";

    // ========== 执行结果状态 ==========
    String EXEC_STATUS_UNTESTED = "untested";
    String EXEC_STATUS_PASSED = "passed";
    String EXEC_STATUS_FAILED = "failed";
    String EXEC_STATUS_BLOCKED = "blocked";
    String EXEC_STATUS_RETEST = "retest";

    // ========== 评审状态 ==========
    String REVIEW_STATUS_PENDING = "pending";
    String REVIEW_STATUS_IN_PROGRESS = "in_progress";
    String REVIEW_STATUS_PASSED = "passed";
    String REVIEW_STATUS_REJECTED = "rejected";
    String REVIEW_STATUS_NEEDS_REVISION = "needs_revision";

    // ========== 设备状态 ==========
    String DEVICE_STATUS_OFFLINE = "offline";
    String DEVICE_STATUS_ONLINE = "online";
    String DEVICE_STATUS_BUSY = "busy";
    String DEVICE_STATUS_ERROR = "error";

    // ========== AI 模型类型 ==========
    String AI_MODEL_DEEPSEEK = "deepseek";
    String AI_MODEL_QWEN = "qwen";
    String AI_MODEL_SILICONFLOW = "siliconflow";
    String AI_MODEL_ZHIPU = "zhipu";
    String AI_MODEL_OTHER = "other";
}