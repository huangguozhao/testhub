package com.testhub.modules.configuration.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.dto.AIModelConfigDTO;

import java.util.Map;

/**
 * AI模型配置 Service
 */
public interface AIModelConfigService extends IService<AIModelConfig> {

    /**
     * 分页查询
     */
    IPage<AIModelConfig> getConfigPage(String modelType, String role, Boolean isActive, long current, long size);

    /**
     * 创建配置
     */
    AIModelConfig createConfig(AIModelConfigDTO dto);

    /**
     * 更新配置
     */
    AIModelConfig updateConfig(Long id, AIModelConfigDTO dto);

    /**
     * 删除配置
     */
    void deleteConfig(Long id);

    /**
     * 获取配置详情（API Key 掩码处理）
     */
    AIModelConfig getConfigDetail(Long id);

    /**
     * 测试模型连接
     */
    Map<String, Object> testConnection(Long id);
}
