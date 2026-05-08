package com.testhub.modules.configuration.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.configuration.domain.GenerationConfig;
import com.testhub.modules.configuration.dto.GenerationConfigDTO;
import com.testhub.modules.configuration.mapper.GenerationConfigMapper;
import com.testhub.modules.configuration.service.GenerationConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class GenerationConfigServiceImpl extends ServiceImpl<GenerationConfigMapper, GenerationConfig>
        implements GenerationConfigService {

    @Override
    public List<GenerationConfig> getConfigList() {
        return this.list(new LambdaQueryWrapper<GenerationConfig>()
                .orderByDesc(GenerationConfig::getCreatedAt));
    }

    @Override
    public GenerationConfig createConfig(GenerationConfigDTO dto) {
        GenerationConfig config = new GenerationConfig();
        config.setName(dto.getName());
        config.setDefaultOutputMode(dto.getDefaultOutputMode() != null ? dto.getDefaultOutputMode() : "stream");
        config.setEnableAutoReview(dto.getEnableAutoReview() != null ? dto.getEnableAutoReview() : true);
        config.setReviewTimeout(dto.getReviewTimeout() != null ? dto.getReviewTimeout() : 120);
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);

        this.save(config);
        log.info("创建生成行为配置: id={}, name={}", config.getId(), config.getName());
        return config;
    }

    @Override
    public GenerationConfig updateConfig(Long id, GenerationConfigDTO dto) {
        GenerationConfig config = this.getById(id);
        if (config == null) {
            throw new RuntimeException("生成行为配置不存在: " + id);
        }

        config.setName(dto.getName());
        config.setDefaultOutputMode(dto.getDefaultOutputMode());
        config.setEnableAutoReview(dto.getEnableAutoReview());
        config.setReviewTimeout(dto.getReviewTimeout());
        if (dto.getIsActive() != null) {
            config.setIsActive(dto.getIsActive());
        }

        this.updateById(config);
        log.info("更新生成行为配置: id={}", id);
        return config;
    }

    @Override
    public void deleteConfig(Long id) {
        this.removeById(id);
        log.info("删除生成行为配置: id={}", id);
    }

    @Override
    @Transactional
    public void enableConfig(Long id) {
        // 禁用所有配置
        GenerationConfig all = new GenerationConfig();
        all.setIsActive(false);
        this.update(all, new LambdaQueryWrapper<GenerationConfig>()
                .eq(GenerationConfig::getIsActive, true));

        // 启用当前配置
        GenerationConfig config = this.getById(id);
        if (config != null) {
            config.setIsActive(true);
            this.updateById(config);
            log.info("启用生成行为配置: id={}", id);
        }
    }
}
