package com.testhub.modules.configuration.domain;

import com.baomidou.mybatisplus.annotation.*;
import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.util.Map;

/**
 * 通知配置实体
 */
@Data
@TableName("notification_config")
public class NotificationConfig extends BaseEntity {

    /**
     * 配置名称
     */
    private String name;

    /**
     * 配置类型: webhook_feishu, webhook_wechat, webhook_dingtalk, email
     */
    private String configType;

    /**
     * Webhook机器人配置 (JSON格式，数据库存储)
     */
    @JsonIgnore
    private String webhookBots;

    /**
     * 是否默认: 0=否, 1=是
     */
    private Boolean isDefault;

    /**
     * 是否启用: 0=否, 1=是
     */
    private Boolean isActive;

    /**
     * 备注
     */
    private String remark;

    private static final ObjectMapper JSON_MAPPER = new ObjectMapper();

    /**
     * 返回解析后的webhook_bots对象（前端需要JSON对象而非字符串）
     */
    public Map<String, Object> getWebhook_bots() {
        if (webhookBots == null || webhookBots.isBlank()) return null;
        try {
            return JSON_MAPPER.readValue(webhookBots, new TypeReference<>() {});
        } catch (Exception e) {
            return null;
        }
    }
}
