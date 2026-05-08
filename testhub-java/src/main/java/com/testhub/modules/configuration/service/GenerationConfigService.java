package com.testhub.modules.configuration.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.configuration.domain.GenerationConfig;
import com.testhub.modules.configuration.dto.GenerationConfigDTO;

import java.util.List;

public interface GenerationConfigService extends IService<GenerationConfig> {

    List<GenerationConfig> getConfigList();

    GenerationConfig createConfig(GenerationConfigDTO dto);

    GenerationConfig updateConfig(Long id, GenerationConfigDTO dto);

    void deleteConfig(Long id);

    void enableConfig(Long id);
}
