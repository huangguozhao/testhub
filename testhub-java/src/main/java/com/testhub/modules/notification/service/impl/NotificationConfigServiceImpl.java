package com.testhub.modules.notification.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.notification.domain.NotificationConfig;
import com.testhub.modules.notification.dto.NotificationConfigDTO;
import com.testhub.modules.notification.mapper.NotificationConfigMapper;
import com.testhub.modules.notification.service.NotificationConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 通知配置服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationConfigServiceImpl extends ServiceImpl<NotificationConfigMapper, NotificationConfig>
        implements NotificationConfigService {

    @Override
    @Transactional
    public NotificationConfig createConfig(NotificationConfigDTO dto) {
        NotificationConfig config = new NotificationConfig();
        config.setName(dto.getName());
        config.setConfigType(dto.getConfigType());
        config.setWebhookBots(dto.getWebhookBots());
        config.setIsDefault(dto.getIsDefault() != null && dto.getIsDefault());
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);
        config.setRemark(dto.getRemark());

        // 如果设为默认，先取消其他默认
        if (config.getIsDefault()) {
            clearDefaultConfigs();
        }

        this.save(config);
        log.info("创建通知配置: id={}, name={}", config.getId(), config.getName());
        return config;
    }

    @Override
    @Transactional
    public NotificationConfig updateConfig(Long id, NotificationConfigDTO dto) {
        NotificationConfig config = this.getById(id);
        if (config == null) {
            throw new RuntimeException("通知配置不存在: " + id);
        }

        config.setName(dto.getName());
        config.setConfigType(dto.getConfigType());
        config.setWebhookBots(dto.getWebhookBots());
        config.setIsActive(dto.getIsActive());
        config.setRemark(dto.getRemark());

        // 如果设为默认，先取消其他默认
        if (Boolean.TRUE.equals(dto.getIsDefault())) {
            clearDefaultConfigs();
            config.setIsDefault(true);
        }

        this.updateById(config);
        log.info("更新通知配置: id={}", id);
        return config;
    }

    @Override
    public void deleteConfig(Long id) {
        this.removeById(id);
        log.info("删除通知配置: id={}", id);
    }

    @Override
    public NotificationConfig getConfig(Long id) {
        return this.getById(id);
    }

    @Override
    public IPage<NotificationConfig> getConfigPage(String keyword, String configType, long current, long size) {
        Page<NotificationConfig> page = new Page<>(current, size);
        LambdaQueryWrapper<NotificationConfig> wrapper = new LambdaQueryWrapper<>();

        if (configType != null && !configType.isBlank()) {
            wrapper.eq(NotificationConfig::getConfigType, configType);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(NotificationConfig::getName, keyword)
                    .or()
                    .like(NotificationConfig::getRemark, keyword));
        }

        wrapper.orderByDesc(NotificationConfig::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public List<NotificationConfig> getActiveConfigs() {
        return this.list(new LambdaQueryWrapper<NotificationConfig>()
                .eq(NotificationConfig::getIsActive, true));
    }

    @Override
    public NotificationConfig getDefaultConfig() {
        return this.getOne(new LambdaQueryWrapper<NotificationConfig>()
                .eq(NotificationConfig::getIsDefault, true)
                .eq(NotificationConfig::getIsActive, true));
    }

    @Override
    @Transactional
    public void setDefault(Long id) {
        clearDefaultConfigs();
        NotificationConfig config = this.getById(id);
        if (config != null) {
            config.setIsDefault(true);
            this.updateById(config);
            log.info("设置默认通知配置: id={}", id);
        }
    }

    @Override
    @Transactional
    public void toggleActive(Long id, Boolean isActive) {
        NotificationConfig config = this.getById(id);
        if (config != null) {
            config.setIsActive(isActive);
            this.updateById(config);
            log.info("{}通知配置: id={}", isActive ? "启用" : "禁用", id);
        }
    }

    private void clearDefaultConfigs() {
        NotificationConfig config = new NotificationConfig();
        config.setIsDefault(false);
        this.update(config, new LambdaQueryWrapper<NotificationConfig>()
                .eq(NotificationConfig::getIsDefault, true));
    }
}
