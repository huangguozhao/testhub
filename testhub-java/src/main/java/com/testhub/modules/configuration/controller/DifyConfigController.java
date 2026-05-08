package com.testhub.modules.configuration.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.DifyConfig;
import com.testhub.modules.configuration.dto.DifyConfigDTO;
import com.testhub.modules.configuration.service.DifyConfigService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "Dify配置", description = "Dify AI助手配置管理")
@RestController
@RequestMapping("/api/assistant/config/dify")
@RequiredArgsConstructor
public class DifyConfigController {

    private final DifyConfigService difyConfigService;

    @GetMapping
    @Operation(summary = "获取激活的Dify配置")
    public Result<DifyConfig> getActiveConfig() {
        DifyConfig config = difyConfigService.getActiveConfig();
        if (config == null) {
            return Result.error("未找到激活的配置");
        }
        return Result.success(config);
    }

    @PostMapping
    @Operation(summary = "创建Dify配置")
    public Result<DifyConfig> createConfig(@RequestBody DifyConfigDTO dto) {
        DifyConfig config = difyConfigService.createConfig(dto);
        return Result.success(config);
    }

    @PatchMapping("/{id}")
    @Operation(summary = "更新Dify配置")
    public Result<DifyConfig> updateConfig(@PathVariable Long id, @RequestBody DifyConfigDTO dto) {
        DifyConfig config = difyConfigService.updateConfig(id, dto);
        return Result.success(config);
    }

    @PostMapping("/test-connection")
    @Operation(summary = "测试Dify连接")
    public Result<Map<String, Object>> testConnection(@RequestBody Map<String, String> body) {
        Map<String, Object> result = difyConfigService.testConnection(
                body.get("api_url"), body.get("api_key"));
        if (Boolean.TRUE.equals(result.get("success"))) {
            return Result.success(result);
        }
        return Result.error((String) result.get("error"));
    }
}
