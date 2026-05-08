package com.testhub.modules.configuration.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.dto.AIModelConfigDTO;
import com.testhub.modules.configuration.mapper.AIModelConfigMapper;
import com.testhub.modules.configuration.service.AIModelConfigService;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * AI模型配置 Service 实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AIModelConfigServiceImpl extends ServiceImpl<AIModelConfigMapper, AIModelConfig>
        implements AIModelConfigService {

    private final ObjectMapper objectMapper;

    @Override
    public IPage<AIModelConfig> getConfigPage(String modelType, String role, Boolean isActive, long current, long size) {
        Page<AIModelConfig> page = new Page<>(current, size);
        LambdaQueryWrapper<AIModelConfig> wrapper = new LambdaQueryWrapper<>();

        if (modelType != null && !modelType.isBlank()) {
            wrapper.eq(AIModelConfig::getModelType, modelType);
        }
        if (role != null && !role.isBlank()) {
            wrapper.eq(AIModelConfig::getRole, role);
        }
        if (isActive != null) {
            wrapper.eq(AIModelConfig::getIsActive, isActive);
        }

        wrapper.orderByDesc(AIModelConfig::getCreatedAt);
        IPage<AIModelConfig> result = this.page(page, wrapper);

        // API Key 掩码处理
        for (AIModelConfig config : result.getRecords()) {
            config.setApiKeyMasked(maskApiKey(config.getApiKey()));
            config.setApiKey(null);
        }
        return result;
    }

    @Override
    @Transactional
    public AIModelConfig createConfig(AIModelConfigDTO dto) {
        AIModelConfig config = new AIModelConfig();
        config.setName(dto.getName());
        config.setModelType(dto.getModelType());
        config.setRole(dto.getRole());
        config.setApiKey(dto.getApiKey());
        config.setBaseUrl(dto.getBaseUrl());
        config.setModelName(dto.getModelName());
        config.setMaxTokens(dto.getMaxTokens() != null ? dto.getMaxTokens() : 4096);
        config.setTemperature(dto.getTemperature() != null ? dto.getTemperature() : new BigDecimal("0.7"));
        config.setTopP(dto.getTopP() != null ? dto.getTopP() : new BigDecimal("0.9"));
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);

        this.save(config);
        log.info("创建AI模型配置: id={}, name={}", config.getId(), config.getName());
        return config;
    }

    @Override
    @Transactional
    public AIModelConfig updateConfig(Long id, AIModelConfigDTO dto) {
        AIModelConfig config = this.getById(id);
        if (config == null) {
            throw new RuntimeException("AI模型配置不存在: " + id);
        }

        if (dto.getName() != null) config.setName(dto.getName());
        if (dto.getModelType() != null) config.setModelType(dto.getModelType());
        if (dto.getRole() != null) config.setRole(dto.getRole());
        if (dto.getApiKey() != null && !dto.getApiKey().contains("*")) {
            config.setApiKey(dto.getApiKey());
        }
        if (dto.getBaseUrl() != null) config.setBaseUrl(dto.getBaseUrl());
        if (dto.getModelName() != null) config.setModelName(dto.getModelName());
        if (dto.getMaxTokens() != null) config.setMaxTokens(dto.getMaxTokens());
        if (dto.getTemperature() != null) config.setTemperature(dto.getTemperature());
        if (dto.getTopP() != null) config.setTopP(dto.getTopP());
        if (dto.getIsActive() != null) config.setIsActive(dto.getIsActive());

        this.updateById(config);
        log.info("更新AI模型配置: id={}", id);
        return config;
    }

    @Override
    public void deleteConfig(Long id) {
        this.removeById(id);
        log.info("删除AI模型配置: id={}", id);
    }

    @Override
    public AIModelConfig getConfigDetail(Long id) {
        AIModelConfig config = this.getById(id);
        if (config != null) {
            config.setApiKeyMasked(maskApiKey(config.getApiKey()));
            config.setApiKey(null); // 不返回真实 key
        }
        return config;
    }


    @Override
    public Map<String, Object> testConnection(Long id) {
        AIModelConfig config = this.getById(id);
        if (config == null) {
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "配置不存在");
            return result;
        }

        try {
            String baseUrl = config.getBaseUrl().replaceAll("/+$", "");
            boolean isAnthropicApi = baseUrl.contains("anthropic");

            String url;
            String jsonBody;

            if (isAnthropicApi) {
                // Anthropic 兼容接口: /v1/messages
                if (baseUrl.matches(".*/v\\d+/?$")) {
                    url = baseUrl + "/messages";
                } else if (baseUrl.endsWith("/messages")) {
                    url = baseUrl;
                } else {
                    url = baseUrl + "/v1/messages";
                }

                Map<String, Object> requestBody = new HashMap<>();
                requestBody.put("model", config.getModelName());
                requestBody.put("max_tokens", 50);
                requestBody.put("messages", List.of(
                        Map.of("role", "user", "content", "请回复'连接成功'")
                ));
                jsonBody = objectMapper.writeValueAsString(requestBody);
            } else {
                // OpenAI 兼容接口: /v1/chat/completions
                if (baseUrl.matches(".*/v\\d+/?$")) {
                    url = baseUrl + "/chat/completions";
                } else if (baseUrl.endsWith("/chat/completions")) {
                    url = baseUrl;
                } else {
                    url = baseUrl + "/v1/chat/completions";
                }

                Map<String, Object> requestBody = new HashMap<>();
                requestBody.put("model", config.getModelName());
                requestBody.put("messages", List.of(
                        Map.of("role", "system", "content", "你是一个AI助手"),
                        Map.of("role", "user", "content", "请回复'连接成功'")
                ));
                requestBody.put("max_tokens", 50);
                requestBody.put("temperature", 0.7);
                requestBody.put("stream", false);
                jsonBody = objectMapper.writeValueAsString(requestBody);
            }

            HttpClient httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .header("x-api-key", config.getApiKey())
                    .header("anthropic-version", "2023-06-01")
                    .header("Authorization", "Bearer " + config.getApiKey())
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .timeout(Duration.ofSeconds(60))
                    .build();

            log.info("测试AI模型连接: url={}, model={}, type={}", url, config.getModelName(), isAnthropicApi ? "anthropic" : "openai");
            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());

            Map<String, Object> result = new HashMap<>();
            if (response.statusCode() == 200) {
                Map<String, Object> responseBody = objectMapper.readValue(response.body(), Map.class);
                String aiResponse = "";

                if (isAnthropicApi) {
                    // Anthropic 响应格式: { "content": [{ "text": "..." }] }
                    List<Map<String, Object>> content = (List<Map<String, Object>>) responseBody.get("content");
                    if (content != null && !content.isEmpty()) {
                        aiResponse = (String) content.get(0).get("text");
                    }
                } else {
                    // OpenAI 响应格式: { "choices": [{ "message": { "content": "..." } }] }
                    List<Map<String, Object>> choices = (List<Map<String, Object>>) responseBody.get("choices");
                    if (choices != null && !choices.isEmpty()) {
                        Map<String, Object> message = (Map<String, Object>) choices.get(0).get("message");
                        if (message != null) {
                            aiResponse = (String) message.get("content");
                        }
                    }
                }

                result.put("success", true);
                result.put("message", "连接成功");
                result.put("response", aiResponse);
            } else {
                result.put("success", false);
                result.put("message", "API返回错误: HTTP " + response.statusCode() + " - " + response.body());
            }
            return result;

        } catch (Exception e) {
            log.error("测试AI模型连接失败: {}", e.getMessage());
            Map<String, Object> result = new HashMap<>();
            result.put("success", false);
            result.put("message", "连接失败: " + e.getMessage());
            return result;
        }
    }

    private String maskApiKey(String apiKey) {
        if (apiKey == null || apiKey.isBlank()) return "";
        if (apiKey.length() > 7) {
            return apiKey.substring(0, 3) + "*".repeat(apiKey.length() - 7) + apiKey.substring(apiKey.length() - 4);
        }
        return "*".repeat(apiKey.length());
    }
}
