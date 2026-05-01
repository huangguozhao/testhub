package com.testhub.modules.notification.dto;

import lombok.Data;

/**
 * 通知配置 DTO
 */
@Data
public class NotificationConfigDTO {

    private Long id;

    /**
     * 配置名称
     */
    private String name;

    /**
     * 配置类型
     */
    private String configType;

    /**
     * Webhook配置 (JSON)
     */
    private String webhookConfig;

    /**
     * 是否默认
     */
    private Boolean isDefault;

    /**
     * 是否启用
     */
    private Boolean isActive;

    /**
     * 备注
     */
    private String remark;
}
