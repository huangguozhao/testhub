package com.testhub.modules.ui_automation.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * 操作记录DTO
 */
@Data
public class UIOperationRecordDTO {

    private Long id;

    /**
     * 操作类型: create, edit, delete, run, rerun, save, rename
     */
    @JsonProperty("operation_type")
    private String operationType;

    /**
     * 操作类型显示名称
     */
    @JsonProperty("operation_type_display")
    private String operationTypeDisplay;

    /**
     * 资源类型: project, test_case, test_suite, element, script, execution
     */
    @JsonProperty("resource_type")
    private String resourceType;

    /**
     * 资源类型显示名称
     */
    @JsonProperty("resource_type_display")
    private String resourceTypeDisplay;

    /**
     * 资源ID
     */
    @JsonProperty("resource_id")
    private Long resourceId;

    /**
     * 资源名称
     */
    @JsonProperty("resource_name")
    private String resourceName;

    /**
     * 用户ID
     */
    @JsonProperty("user_id")
    private Long userId;

    /**
     * 用户名
     */
    @JsonProperty("user_name")
    private String userName;

    /**
     * 创建时间
     */
    @JsonProperty("created_at")
    private String createdAt;
}