package com.testhub.modules.operation_log.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

/**
 * 操作日志实体
 */
@Data
@TableName("operation_log")
public class OperationLog extends BaseEntity {

    /**
     * 操作类型: create, edit, delete, execute, run, save
     */
    private String operationType;

    /**
     * 资源类型: project, collection, request, suite, environment, task, execution
     */
    private String resourceType;

    /**
     * 资源ID
     */
    private Long resourceId;

    /**
     * 资源名称
     */
    private String resourceName;

    /**
     * 操作描述
     */
    private String description;

    /**
     * 操作用户ID
     */
    private Long userId;

    /**
     * 操作用户名
     */
    private String username;

    /**
     * IP地址
     */
    private String ipAddress;

    /**
     * 用户代理
     */
    private String userAgent;
}
