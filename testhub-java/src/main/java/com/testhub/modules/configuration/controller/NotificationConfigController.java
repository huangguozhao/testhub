package com.testhub.modules.configuration.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.NotificationConfig;
import com.testhub.modules.configuration.dto.NotificationConfigDTO;
import com.testhub.modules.configuration.service.NotificationConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 通知配置控制器
 */
@Tag(name = "通知配置", description = "通知配置管理")
@RestController
@RequestMapping("/api/notification-configs")
@RequiredArgsConstructor
public class NotificationConfigController {

    private final NotificationConfigService notificationConfigService;

    @GetMapping
    @Operation(summary = "分页查询通知配置")
    public Result<PageResult<NotificationConfig>> getConfigPage(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String configType,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<NotificationConfig> page = notificationConfigService.getConfigPage(keyword, configType, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取配置详情")
    public Result<NotificationConfig> getConfig(@PathVariable Long id) {
        NotificationConfig config = notificationConfigService.getConfig(id);
        return Result.success(config);
    }

    @PostMapping
    @Operation(summary = "创建通知配置")
    public Result<NotificationConfig> createConfig(@RequestBody NotificationConfigDTO dto) {
        NotificationConfig config = notificationConfigService.createConfig(dto);
        return Result.success(config);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新通知配置")
    public Result<NotificationConfig> updateConfig(@PathVariable Long id, @RequestBody NotificationConfigDTO dto) {
        NotificationConfig config = notificationConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除通知配置")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        notificationConfigService.deleteConfig(id);
        return Result.success();
    }

    @GetMapping("/active")
    @Operation(summary = "获取所有启用的配置")
    public Result<List<NotificationConfig>> getActiveConfigs() {
        List<NotificationConfig> configs = notificationConfigService.getActiveConfigs();
        return Result.success(configs);
    }

    @PostMapping("/{id}/set-default")
    @Operation(summary = "设为默认配置")
    public Result<Void> setDefault(@PathVariable Long id) {
        notificationConfigService.setDefault(id);
        return Result.success();
    }

    @PostMapping("/{id}/toggle")
    @Operation(summary = "启用/禁用配置")
    public Result<Void> toggleActive(@PathVariable Long id, @RequestParam Boolean isActive) {
        notificationConfigService.toggleActive(id, isActive);
        return Result.success();
    }
}
