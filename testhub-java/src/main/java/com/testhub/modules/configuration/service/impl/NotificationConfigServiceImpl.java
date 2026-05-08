package com.testhub.modules.configuration.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.configuration.domain.NotificationConfig;
import com.testhub.modules.configuration.dto.NotificationConfigDTO;
import com.testhub.modules.configuration.mapper.NotificationConfigMapper;
import com.testhub.modules.configuration.service.NotificationConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;

/**
 * 通知配置服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationConfigServiceImpl extends ServiceImpl<NotificationConfigMapper, NotificationConfig>
        implements NotificationConfigService {

    private final ObjectMapper objectMapper;
    private final RestTemplate restTemplate;

    @Override
    @Transactional
    public NotificationConfig createConfig(NotificationConfigDTO dto) {
        NotificationConfig config = new NotificationConfig();
        config.setName(dto.getName());
        config.setConfigType(dto.getConfigType());
        config.setWebhookBots(serializeWebhookBots(dto.getWebhookBots()));
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
        config.setWebhookBots(serializeWebhookBots(dto.getWebhookBots()));
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

    @Override
    public Map<String, Object> testWebhook(Long id, String botType) {
        Map<String, Object> result = new HashMap<>();
        NotificationConfig config = this.getById(id);
        if (config == null) {
            result.put("success", false);
            result.put("message", "配置不存在");
            return result;
        }

        if (config.getWebhookBots() == null || config.getWebhookBots().isBlank()) {
            result.put("success", false);
            result.put("message", "未配置Webhook机器人");
            return result;
        }

        try {
            Map<String, Map<String, Object>> botsMap = objectMapper.readValue(
                    config.getWebhookBots(), new com.fasterxml.jackson.core.type.TypeReference<>() {});
            Map<String, Object> botConfig = botsMap.get(botType);
            if (botConfig == null) {
                result.put("success", false);
                result.put("message", "未找到 " + botType + " 类型的机器人配置");
                return result;
            }

            String webhookUrl = (String) botConfig.get("webhook_url");
            if (webhookUrl == null || webhookUrl.isBlank()) {
                result.put("success", false);
                result.put("message", "Webhook URL 为空");
                return result;
            }

            String testMessage = "[TestHub] 这是一条测试消息，用于验证 Webhook 配置是否正确。";
            boolean sent = false;

            switch (botType) {
                case "feishu":
                    sent = sendFeishuTest(webhookUrl, testMessage);
                    break;
                case "wechat":
                    sent = sendWechatTest(webhookUrl, testMessage);
                    break;
                case "dingtalk":
                    String secret = (String) botConfig.get("secret");
                    sent = sendDingtalkTest(webhookUrl, secret, testMessage);
                    break;
                default:
                    result.put("success", false);
                    result.put("message", "不支持的机器人类型: " + botType);
                    return result;
            }

            if (sent) {
                result.put("success", true);
                result.put("message", "测试消息发送成功，请检查机器人是否收到");
            } else {
                result.put("success", false);
                result.put("message", "测试消息发送失败，请检查 Webhook URL 是否正确");
            }
        } catch (Exception e) {
            log.error("测试Webhook连接失败: {}", e.getMessage());
            result.put("success", false);
            result.put("message", "测试失败: " + e.getMessage());
        }
        return result;
    }

    private boolean sendFeishuTest(String webhook, String message) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("msg_type", "text");
            body.put("content", Map.of("text", message));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送飞书测试消息失败: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendWechatTest(String webhook, String message) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("msgtype", "text");
            body.put("text", Map.of("content", message));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送企微测试消息失败: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendDingtalkTest(String webhook, String secret, String message) {
        try {
            if (secret != null && !secret.isBlank()) {
                long timestamp = System.currentTimeMillis();
                String stringToSign = timestamp + "\n" + secret;
                Mac mac = Mac.getInstance("HmacSHA256");
                mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
                byte[] signData = mac.doFinal(stringToSign.getBytes(StandardCharsets.UTF_8));
                String sign = Base64.getEncoder().encodeToString(signData);
                webhook = webhook + "&sign=" + URLEncoder.encode(sign, StandardCharsets.UTF_8);
            }

            Map<String, Object> body = new HashMap<>();
            body.put("msgtype", "text");
            body.put("text", Map.of("content", message));

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            HttpEntity<Map<String, Object>> request = new HttpEntity<>(body, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);
            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送钉钉测试消息失败: {}", e.getMessage());
            return false;
        }
    }

    private void clearDefaultConfigs() {
        NotificationConfig config = new NotificationConfig();
        config.setIsDefault(false);
        this.update(config, new LambdaQueryWrapper<NotificationConfig>()
                .eq(NotificationConfig::getIsDefault, true));
    }

    private String serializeWebhookBots(Object webhookBots) {
        if (webhookBots == null) return null;
        if (webhookBots instanceof String) return (String) webhookBots;
        try {
            return objectMapper.writeValueAsString(webhookBots);
        } catch (Exception e) {
            log.error("序列化webhookBots失败: {}", e.getMessage());
            return webhookBots.toString();
        }
    }
}
