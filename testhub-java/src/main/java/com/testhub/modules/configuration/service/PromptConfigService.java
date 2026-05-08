package com.testhub.modules.configuration.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.dto.PromptConfigDTO;

import java.util.Map;

public interface PromptConfigService extends IService<PromptConfig> {

    IPage<PromptConfig> getConfigPage(String promptType, Boolean isActive, long current, long size);

    PromptConfig getConfigDetail(Long id);

    PromptConfig createConfig(PromptConfigDTO dto);

    PromptConfig updateConfig(Long id, PromptConfigDTO dto);

    void deleteConfig(Long id);

    Map<String, String> loadDefaults();
}
