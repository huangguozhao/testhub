package com.testhub.modules.configuration.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.dto.PromptConfigDTO;
import com.testhub.modules.configuration.service.PromptConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "提示词配置", description = "提示词配置管理")
@RestController
@RequestMapping("/api/requirement-analysis/prompts")
@RequiredArgsConstructor
public class PromptConfigController {

    private final PromptConfigService promptConfigService;

    @GetMapping
    @Operation(summary = "分页查询提示词配置")
    public Result<PageResult<PromptConfig>> getConfigPage(
            @RequestParam(required = false) String promptType,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<PromptConfig> page = promptConfigService.getConfigPage(promptType, isActive, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取配置详情")
    public Result<PromptConfig> getConfig(@PathVariable Long id) {
        PromptConfig config = promptConfigService.getConfigDetail(id);
        return Result.success(config);
    }

    @PostMapping
    @Operation(summary = "创建提示词配置")
    public Result<PromptConfig> createConfig(@RequestBody PromptConfigDTO dto) {
        PromptConfig config = promptConfigService.createConfig(dto);
        return Result.success(config);
    }

    @PatchMapping("/{id}")
    @Operation(summary = "更新提示词配置")
    public Result<PromptConfig> updateConfig(@PathVariable Long id, @RequestBody PromptConfigDTO dto) {
        PromptConfig config = promptConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除提示词配置")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        promptConfigService.deleteConfig(id);
        return Result.success();
    }

    @GetMapping("/load-defaults")
    @Operation(summary = "加载默认提示词")
    public Result<?> loadDefaults() {
        Map<String, String> defaults = promptConfigService.loadDefaults();
        Map<String, Object> result = new HashMap<>();
        result.put("defaults", defaults);
        return Result.success(result);
    }
}
