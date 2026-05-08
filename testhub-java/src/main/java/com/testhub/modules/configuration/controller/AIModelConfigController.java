package com.testhub.modules.configuration.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.dto.AIModelConfigDTO;
import com.testhub.modules.configuration.service.AIModelConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

/**
 * AI模型配置控制器
 */
@Tag(name = "AI模型配置", description = "AI模型配置管理")
@RestController
@RequestMapping("/api/requirement-analysis/ai-models")
@RequiredArgsConstructor
public class AIModelConfigController {

    private final AIModelConfigService aiModelConfigService;

    @GetMapping
    @Operation(summary = "分页查询AI模型配置")
    public Result<PageResult<AIModelConfig>> getConfigPage(
            @RequestParam(required = false) String modelType,
            @RequestParam(required = false) String role,
            @RequestParam(required = false) Boolean isActive,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<AIModelConfig> page = aiModelConfigService.getConfigPage(modelType, role, isActive, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取配置详情")
    public Result<AIModelConfig> getConfig(@PathVariable Long id) {
        AIModelConfig config = aiModelConfigService.getConfigDetail(id);
        return Result.success(config);
    }

    @PostMapping
    @Operation(summary = "创建AI模型配置")
    public Result<AIModelConfig> createConfig(@RequestBody AIModelConfigDTO dto) {
        AIModelConfig config = aiModelConfigService.createConfig(dto);
        return Result.success(config);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新AI模型配置")
    public Result<AIModelConfig> updateConfig(@PathVariable Long id, @RequestBody AIModelConfigDTO dto) {
        AIModelConfig config = aiModelConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @PatchMapping("/{id}")
    @Operation(summary = "部分更新AI模型配置")
    public Result<AIModelConfig> patchConfig(@PathVariable Long id, @RequestBody AIModelConfigDTO dto) {
        AIModelConfig config = aiModelConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除AI模型配置")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        aiModelConfigService.deleteConfig(id);
        return Result.success();
    }

    @PostMapping("/{id}/test-connection")
    @Operation(summary = "测试模型连接")
    public Result<Map<String, Object>> testConnection(@PathVariable Long id) {
        Map<String, Object> result = aiModelConfigService.testConnection(id);
        return Result.success(result);
    }
}
