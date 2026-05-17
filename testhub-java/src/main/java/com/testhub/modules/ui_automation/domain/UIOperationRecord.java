package com.testhub.modules.ui_automation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * UI自动化操作记录实体
 */
@Data
@TableName("ui_operation_record")
public class UIOperationRecord extends BaseEntity {

    /**
     * 操作类型: create, edit, delete, run, rerun, save, rename
     */
    private String operationType;

    /**
     * 资源类型: project, test_case, test_suite, element, script, execution
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
     * 操作用户ID
     */
    private Long userId;

    /**
     * 操作用户名
     */
    private String userName;

    /**
     * 详情描述
     */
    private String detail;
}