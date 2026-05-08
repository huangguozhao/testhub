package com.testhub.modules.configuration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.dto.AIModelConfigDTO;
import com.testhub.modules.configuration.mapper.AIModelConfigMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.web.bind.annotation.*;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.List;
import java.util.Map;

@Slf4j
@Tag(name = "UI AI智能模式配置", description = "UI自动化AI模型配置管理")
@RestController
@RequestMapping("/api/ui-automation/ai-models")
@RequiredArgsConstructor
public class UIAIModelConfigController {

    private final AIModelConfigMapper aiModelConfigMapper;

    private static final String ROLE = "browser_use_text";

    @GetMapping
    @Operation(summary = "获取所有AI智能模式配置")
    public Result<List<AIModelConfig>> getConfigList() {
        List<AIModelConfig> list = aiModelConfigMapper.selectList(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, ROLE)
                        .eq(AIModelConfig::getIsDeleted, 0)
                        .orderByDesc(AIModelConfig::getCreatedAt));
        // 隐藏 API Key
        list.forEach(c -> c.setApiKey(null));
        return Result.success(list);
    }

    @PostMapping
    @Operation(summary = "创建AI智能模式配置")
    public Result<AIModelConfig> createConfig(@RequestBody AIModelConfigDTO dto) {
        AIModelConfig config = new AIModelConfig();
        config.setName(dto.getName());
        config.setModelType(dto.getModelType());
        config.setRole(ROLE);
        config.setModelName(dto.getModelName());
        config.setApiKey(dto.getApiKey());
        config.setBaseUrl(dto.getBaseUrl());
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);

        // 如果启用，先禁用其他
        if (Boolean.TRUE.equals(config.getIsActive())) {
            disableAllConfigs();
        }

        aiModelConfigMapper.insert(config);
        log.info("创建UI AI智能模式配置: id={}, name={}", config.getId(), config.getName());
        config.setApiKey(null);
        return Result.success(config);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新AI智能模式配置")
    public Result<AIModelConfig> updateConfig(@PathVariable Long id, @RequestBody AIModelConfigDTO dto) {
        AIModelConfig config = aiModelConfigMapper.selectById(id);
        if (config == null || !ROLE.equals(config.getRole())) {
            throw new RuntimeException("配置不存在: " + id);
        }

        if (dto.getName() != null) config.setName(dto.getName());
        if (dto.getModelType() != null) config.setModelType(dto.getModelType());
        if (dto.getModelName() != null) config.setModelName(dto.getModelName());
        if (dto.getApiKey() != null && !dto.getApiKey().isEmpty()) config.setApiKey(dto.getApiKey());
        if (dto.getBaseUrl() != null) config.setBaseUrl(dto.getBaseUrl());
        if (dto.getIsActive() != null) {
            if (dto.getIsActive()) disableAllConfigs();
            config.setIsActive(dto.getIsActive());
        }

        aiModelConfigMapper.updateById(config);
        log.info("更新UI AI智能模式配置: id={}", id);
        config.setApiKey(null);
        return Result.success(config);
    }

    @PatchMapping("/{id}")
    @Operation(summary = "部分更新AI智能模式配置")
    public Result<AIModelConfig> patchConfig(@PathVariable Long id, @RequestBody AIModelConfigDTO dto) {
        return updateConfig(id, dto);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除AI智能模式配置")
    public Result<Void> deleteConfig(@PathVariable Long id) {
        aiModelConfigMapper.deleteById(id);
        log.info("删除UI AI智能模式配置: id={}", id);
        return Result.success();
    }

    @PostMapping("/{id}/test-connection")
    @Operation(summary = "测试已保存配置的连接")
    public Result<Map<String, Object>> testConnection(@PathVariable Long id) {
        AIModelConfig config = aiModelConfigMapper.selectById(id);
        if (config == null || !ROLE.equals(config.getRole())) {
            throw new RuntimeException("配置不存在: " + id);
        }

        return doTestConnection(config.getBaseUrl(), config.getApiKey(), config.getModelName());
    }

    @PostMapping("/test-connection-preview")
    @Operation(summary = "预览测试连接(未保存)")
    public Result<Map<String, Object>> testConnectionPreview(@RequestBody Map<String, String> body) {
        String baseUrl = body.get("base_url");
        String apiKey = body.get("api_key");
        String modelName = body.get("model_name");

        if (apiKey == null || apiKey.isBlank()) {
            return Result.error("API Key is required");
        }

        return doTestConnection(baseUrl, apiKey, modelName);
    }

    private Result<Map<String, Object>> doTestConnection(String baseUrl, String apiKey, String modelName) {
        if (baseUrl == null || baseUrl.isBlank()) {
            return Result.error("Base URL is required");
        }

        baseUrl = baseUrl.replaceAll("/+$", "");
        String url = baseUrl + "/chat/completions";

        try {
            String jsonBody = String.format(
                    "{\"model\":\"%s\",\"messages\":[{\"role\":\"user\",\"content\":\"Hi\"}],\"max_tokens\":1}",
                    modelName != null ? modelName : "gpt-3.5-turbo");

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(60))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .timeout(Duration.ofSeconds(90))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return Result.success(Map.of("message", "连接成功"));
            } else {
                return Result.error("连接失败: " + response.statusCode() + " - " + response.body());
            }
        } catch (Exception e) {
            log.error("AI连接测试异常", e);
            return Result.error("连接异常: " + e.getMessage());
        }
    }

    private void disableAllConfigs() {
        AIModelConfig update = new AIModelConfig();
        update.setIsActive(false);
        aiModelConfigMapper.update(update, new LambdaQueryWrapper<AIModelConfig>()
                .eq(AIModelConfig::getRole, ROLE)
                .eq(AIModelConfig::getIsActive, true)
                .eq(AIModelConfig::getIsDeleted, 0));
    }
}
