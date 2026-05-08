package com.testhub.modules.configuration.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.GenerationConfig;
import com.testhub.modules.configuration.dto.GenerationConfigDTO;
import com.testhub.modules.configuration.service.GenerationConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "生成行为配置", description = "生成行为配置管理")
@RestController
@RequestMapping("/api/requirement-analysis/generation-config")
@RequiredArgsConstructor
public class GenerationConfigController {

    private final GenerationConfigService generationConfigService;

    @GetMapping
    @Operation(summary = "获取所有生成行为配置")
    public Result<List<GenerationConfig>> getConfigList() {
        List<GenerationConfig> list = generationConfigService.getConfigList();
        return Result.success(list);
    }

    @PostMapping
    @Operation(summary = "创建生成行为配置")
    public Result<GenerationConfig> createConfig(@RequestBody GenerationConfigDTO dto) {
        GenerationConfig config = generationConfigService.createConfig(dto);
        return Result.success(config);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新生成行为配置")
    public Result<GenerationConfig> updateConfig(@PathVariable Long id, @RequestBody GenerationConfigDTO dto) {
        GenerationConfig config = generationConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除生成行为配置")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        generationConfigService.deleteConfig(id);
        return Result.success();
    }

    @PostMapping("/{id}/enable")
    @Operation(summary = "启用生成行为配置")
    public Result<Void> enableConfig(@PathVariable Long id) {
        generationConfigService.enableConfig(id);
        return Result.success();
    }
}
