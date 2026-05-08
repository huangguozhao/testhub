package com.testhub.modules.configuration.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.configuration.domain.DifyConfig;
import com.testhub.modules.configuration.dto.DifyConfigDTO;

import java.util.Map;

public interface DifyConfigService extends IService<DifyConfig> {

    DifyConfig getActiveConfig();

    DifyConfig createConfig(DifyConfigDTO dto);

    DifyConfig updateConfig(Long id, DifyConfigDTO dto);

    Map<String, Object> testConnection(String apiUrl, String apiKey);
}
