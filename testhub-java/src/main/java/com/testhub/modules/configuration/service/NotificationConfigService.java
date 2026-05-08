package com.testhub.modules.configuration.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.configuration.domain.NotificationConfig;
import com.testhub.modules.configuration.dto.NotificationConfigDTO;

import java.util.List;

/**
 * 通知配置服务接口
 */
public interface NotificationConfigService extends IService<NotificationConfig> {

    /**
     * 创建通知配置
     */
    NotificationConfig createConfig(NotificationConfigDTO dto);

    /**
     * 更新通知配置
     */
    NotificationConfig updateConfig(Long id, NotificationConfigDTO dto);

    /**
     * 删除通知配置
     */
    void deleteConfig(Long id);

    /**
     * 获取通知配置详情
     */
    NotificationConfig getConfig(Long id);

    /**
     * 分页查询通知配置
     */
    IPage<NotificationConfig> getConfigPage(String keyword, String configType, long current, long size);

    /**
     * 获取所有启用的配置
     */
    List<NotificationConfig> getActiveConfigs();

    /**
     * 获取默认配置
     */
    NotificationConfig getDefaultConfig();

    /**
     * 设为默认配置
     */
    void setDefault(Long id);

    /**
     * 启用/禁用配置
     */
    void toggleActive(Long id, Boolean isActive);

    /**
     * 测试Webhook连接
     * @param id 配置ID
     * @param botType 机器人类型 (feishu/wechat/dingtalk)
     * @return 测试结果
     */
    java.util.Map<String, Object> testWebhook(Long id, String botType);
}
