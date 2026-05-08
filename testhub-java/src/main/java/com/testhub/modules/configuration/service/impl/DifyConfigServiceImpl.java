package com.testhub.modules.configuration.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.configuration.domain.DifyConfig;
import com.testhub.modules.configuration.dto.DifyConfigDTO;
import com.testhub.modules.configuration.mapper.DifyConfigMapper;
import com.testhub.modules.configuration.service.DifyConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class DifyConfigServiceImpl extends ServiceImpl<DifyConfigMapper, DifyConfig>
        implements DifyConfigService {

    @Override
    public DifyConfig getActiveConfig() {
        DifyConfig config = this.getOne(new LambdaQueryWrapper<DifyConfig>()
                .eq(DifyConfig::getIsActive, true));
        if (config != null) {
            config.setApiKeyMasked(maskApiKey(config.getApiKey()));
        }
        return config;
    }

    @Override
    @Transactional
    public DifyConfig createConfig(DifyConfigDTO dto) {
        // 如果启用，先禁用其他
        if (Boolean.TRUE.equals(dto.getIsActive())) {
            disableAllConfigs();
        }

        DifyConfig config = new DifyConfig();
        config.setApiUrl(dto.getApiUrl());
        config.setApiKey(dto.getApiKey());
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);

        this.save(config);
        log.info("创建Dify配置: id={}", config.getId());
        config.setApiKeyMasked(maskApiKey(config.getApiKey()));
        return config;
    }

    @Override
    @Transactional
    public DifyConfig updateConfig(Long id, DifyConfigDTO dto) {
        DifyConfig config = this.getById(id);
        if (config == null) {
            throw new RuntimeException("Dify配置不存在: " + id);
        }

        if (dto.getApiUrl() != null) config.setApiUrl(dto.getApiUrl());
        if (dto.getApiKey() != null && !dto.getApiKey().isEmpty()) config.setApiKey(dto.getApiKey());
        if (dto.getIsActive() != null) {
            if (dto.getIsActive()) disableAllConfigs();
            config.setIsActive(dto.getIsActive());
        }

        this.updateById(config);
        log.info("更新Dify配置: id={}", id);
        config.setApiKeyMasked(maskApiKey(config.getApiKey()));
        return config;
    }

    @Override
    public Map<String, Object> testConnection(String apiUrl, String apiKey) {
        Map<String, Object> result = new HashMap<>();

        if (apiUrl == null || apiUrl.isBlank() || apiKey == null || apiKey.isBlank()) {
            result.put("success", false);
            result.put("error", "API URL和API Key都是必填项");
            return result;
        }

        apiUrl = apiUrl.replaceAll("/+$", "");

        try {
            String jsonBody = "{\"inputs\":{},\"query\":\"test\",\"user\":\"test_user\"}";

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(30))
                    .build();

            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(apiUrl + "/chat-messages"))
                    .header("Authorization", "Bearer " + apiKey)
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody))
                    .timeout(Duration.ofSeconds(30))
                    .build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                result.put("success", true);
                result.put("message", "连接成功！");
            } else {
                result.put("success", false);
                result.put("error", "连接失败: " + response.statusCode());
            }
        } catch (Exception e) {
            log.error("Dify连接测试异常", e);
            result.put("success", false);
            result.put("error", "连接错误: " + e.getMessage());
        }

        return result;
    }

    private void disableAllConfigs() {
        DifyConfig update = new DifyConfig();
        update.setIsActive(false);
        this.update(update, new LambdaQueryWrapper<DifyConfig>()
                .eq(DifyConfig::getIsActive, true));
    }

    private String maskApiKey(String apiKey) {
        if (apiKey == null || apiKey.length() < 8) return "****";
        return apiKey.substring(0, 8) + "****";
    }
}
