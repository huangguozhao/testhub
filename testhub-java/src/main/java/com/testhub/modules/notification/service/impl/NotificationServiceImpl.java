package com.testhub.modules.notification.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.notification.domain.NotificationConfig;
import com.testhub.modules.notification.domain.NotificationLog;
import com.testhub.modules.notification.dto.SendNotificationDTO;
import com.testhub.modules.notification.mapper.NotificationLogMapper;
import com.testhub.modules.notification.service.NotificationConfigService;
import com.testhub.modules.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;

/**
 * 通知服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class NotificationServiceImpl extends ServiceImpl<NotificationLogMapper, NotificationLog>
        implements NotificationService {

    private final NotificationConfigService notificationConfigService;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;

    @Override
    public NotificationLog sendNotification(SendNotificationDTO dto) {
        NotificationLog logEntry = new NotificationLog();
        logEntry.setTaskId(dto.getTaskId());
        logEntry.setTaskType(dto.getTaskType());
        logEntry.setNotificationType("manual");
        logEntry.setChannel(dto.getChannel());
        logEntry.setStatus("pending");
        logEntry.setRetryCount(0);

        NotificationConfig config;
        if (dto.getConfigId() != null) {
            config = notificationConfigService.getConfig(dto.getConfigId());
        } else {
            config = notificationConfigService.getDefaultConfig();
        }

        if (config == null) {
            logEntry.setStatus("failed");
            logEntry.setErrorMessage("未找到可用的通知配置");
            this.save(logEntry);
            return logEntry;
        }

        logEntry.setConfigId(config.getId());

        try {
            logEntry.setStatus("sending");

            boolean success = sendByChannel(dto.getChannel(), config, dto.getTitle(), dto.getContent());

            if (success) {
                logEntry.setStatus("success");
                logEntry.setSentAt(LocalDateTime.now());
                log.info("通知发送成功: channel={}, configId={}", dto.getChannel(), config.getId());
            } else {
                logEntry.setStatus("failed");
                logEntry.setErrorMessage("发送失败");
            }
        } catch (Exception e) {
            logEntry.setStatus("failed");
            logEntry.setErrorMessage(e.getMessage());
            log.error("通知发送异常: {}", e.getMessage(), e);
        }

        // 保存通知内容
        Map<String, String> contentMap = new HashMap<>();
        contentMap.put("title", dto.getTitle());
        contentMap.put("content", dto.getContent());
        try {
            logEntry.setContent(objectMapper.writeValueAsString(contentMap));
        } catch (Exception e) {
            logEntry.setContent(dto.getContent());
        }

        this.save(logEntry);
        return logEntry;
    }

    @Override
    public void sendExecutionNotification(Long taskId, String taskType, boolean success, String message) {
        List<NotificationConfig> configs = notificationConfigService.getActiveConfigs();

        for (NotificationConfig config : configs) {
            SendNotificationDTO dto = new SendNotificationDTO();
            dto.setChannel(getChannelFromConfigType(config.getConfigType()));
            dto.setConfigId(config.getId());
            dto.setTaskId(taskId);
            dto.setTaskType(taskType);
            dto.setTitle(success ? "任务执行成功" : "任务执行失败");
            dto.setContent(buildExecutionContent(taskId, taskType, success, message));

            // 异步发送 (实际项目中应该用线程池)
            new Thread(() -> sendNotification(dto)).start();
        }
    }

    @Override
    public IPage<NotificationLog> getLogPage(Long taskId, String taskType, String channel, String status, long current, long size) {
        Page<NotificationLog> page = new Page<>(current, size);
        LambdaQueryWrapper<NotificationLog> wrapper = new LambdaQueryWrapper<>();

        if (taskId != null) {
            wrapper.eq(NotificationLog::getTaskId, taskId);
        }

        if (taskType != null && !taskType.isBlank()) {
            wrapper.eq(NotificationLog::getTaskType, taskType);
        }

        if (channel != null && !channel.isBlank()) {
            wrapper.eq(NotificationLog::getChannel, channel);
        }

        if (status != null && !status.isBlank()) {
            wrapper.eq(NotificationLog::getStatus, status);
        }

        wrapper.orderByDesc(NotificationLog::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public NotificationLog getLog(Long id) {
        return this.getById(id);
    }

    @Override
    public NotificationLog retryNotification(Long id) {
        NotificationLog logEntry = this.getById(id);
        if (logEntry == null) {
            throw new RuntimeException("通知日志不存在: " + id);
        }

        if (!"failed".equals(logEntry.getStatus())) {
            throw new RuntimeException("只能重试失败的通知");
        }

        NotificationConfig config = notificationConfigService.getConfig(logEntry.getConfigId());
        if (config == null) {
            logEntry.setStatus("failed");
            logEntry.setErrorMessage("通知配置已删除");
            this.updateById(logEntry);
            return logEntry;
        }

        try {
            Map<String, String> contentMap = objectMapper.readValue(logEntry.getContent(), Map.class);
            String title = contentMap.get("title");
            String content = contentMap.get("content");

            logEntry.setRetryCount(logEntry.getRetryCount() + 1);
            logEntry.setStatus("sending");

            boolean success = sendByChannel(logEntry.getChannel(), config, title, content);

            if (success) {
                logEntry.setStatus("success");
                logEntry.setSentAt(LocalDateTime.now());
                logEntry.setErrorMessage(null);
            } else {
                logEntry.setStatus("failed");
            }
        } catch (Exception e) {
            logEntry.setStatus("failed");
            logEntry.setErrorMessage(e.getMessage());
        }

        this.updateById(logEntry);
        return logEntry;
    }

    @Override
    public void deleteLog(Long id) {
        this.removeById(id);
    }

    private boolean sendByChannel(String channel, NotificationConfig config, String title, String content) {
        String configType = config.getConfigType();

        try {
            Map<String, Object> webhookConfig = objectMapper.readValue(config.getWebhookConfig(), Map.class);
            String webhook = (String) webhookConfig.get("webhook");

            switch (configType) {
                case "webhook_feishu":
                    return sendFeishuNotification(webhook, title, content);
                case "webhook_wechat":
                    return sendWechatNotification(webhook, title, content);
                case "webhook_dingtalk":
                    String secret = (String) webhookConfig.get("secret");
                    return sendDingtalkNotification(webhook, secret, title, content);
                default:
                    log.warn("不支持的通知类型: {}", configType);
                    return false;
            }
        } catch (Exception e) {
            log.error("发送通知失败: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendFeishuNotification(String webhook, String title, String content) {
        try {
            Map<String, Object> message = new HashMap<>();
            message.put("msg_type", "interactive");

            Map<String, Object> card = new HashMap<>();
            card.put("tag", "div");
            card.put("text", content);

            Map<String, Object> element = new HashMap<>();
            element.put("tag", "markdown");
            element.put("content", "**" + title + "**\n\n" + content);

            Map<String, Object> body = new HashMap<>();
            body.put("elements", Collections.singletonList(element));

            card.put("body", body);
            message.put("card", card);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(message, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);

            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送飞书通知失败: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendWechatNotification(String webhook, String title, String content) {
        try {
            Map<String, Object> message = new HashMap<>();
            message.put("msgtype", "markdown");

            Map<String, Object> markdown = new HashMap<>();
            markdown.put("content", "**" + title + "**\n\n" + content);
            message.put("markdown", markdown);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(message, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);

            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送企微通知失败: {}", e.getMessage());
            return false;
        }
    }

    private boolean sendDingtalkNotification(String webhook, String secret, String title, String content) {
        try {
            String sign = "";
            if (secret != null && !secret.isBlank()) {
                sign = generateDingtalkSign(secret);
                webhook = webhook + "&sign=" + URLEncoder.encode(sign, StandardCharsets.UTF_8);
            }

            Map<String, Object> message = new HashMap<>();
            message.put("msgtype", "markdown");

            Map<String, Object> markdown = new HashMap<>();
            markdown.put("title", title);
            markdown.put("text", "**" + title + "**\n\n" + content);
            message.put("markdown", markdown);

            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);

            HttpEntity<Map<String, Object>> request = new HttpEntity<>(message, headers);
            ResponseEntity<String> response = restTemplate.postForEntity(webhook, request, String.class);

            return response.getStatusCode().is2xxSuccessful();
        } catch (Exception e) {
            log.error("发送钉钉通知失败: {}", e.getMessage());
            return false;
        }
    }

    private String generateDingtalkSign(String secret) throws Exception {
        long timestamp = System.currentTimeMillis();
        String stringToSign = timestamp + "\n" + secret;
        Mac mac = Mac.getInstance("HmacSHA256");
        mac.init(new SecretKeySpec(secret.getBytes(StandardCharsets.UTF_8), "HmacSHA256"));
        byte[] signData = mac.doFinal(stringToSign.getBytes(StandardCharsets.UTF_8));
        return Base64.getEncoder().encodeToString(signData);
    }

    private String getChannelFromConfigType(String configType) {
        if (configType == null) return "unknown";
        if (configType.contains("feishu")) return "feishu";
        if (configType.contains("wechat")) return "wechat";
        if (configType.contains("dingtalk")) return "dingtalk";
        if (configType.contains("email")) return "email";
        return "unknown";
    }

    private String buildExecutionContent(Long taskId, String taskType, boolean success, String message) {
        String status = success ? "成功" : "失败";
        String time = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        return String.format("**任务执行%s**\n\n- 任务ID: %d\n- 任务类型: %s\n- 执行时间: %s\n- 状态: %s",
                status, taskId, taskType, time, status) +
                (message != null && !message.isBlank() ? "\n- 详情: " + message : "");
    }
}
