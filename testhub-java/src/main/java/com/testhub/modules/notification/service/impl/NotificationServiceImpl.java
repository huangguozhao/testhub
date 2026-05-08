package com.testhub.modules.notification.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.TaskNotificationSetting;
import com.testhub.modules.api_testing.service.TaskNotificationSettingService;
import com.testhub.modules.notification.domain.NotificationConfig;
import com.testhub.modules.notification.domain.NotificationLog;
import com.testhub.modules.notification.dto.SendNotificationDTO;
import com.testhub.modules.notification.mapper.NotificationLogMapper;
import com.testhub.modules.notification.service.NotificationConfigService;
import com.testhub.modules.notification.service.NotificationService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.*;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.scheduling.annotation.Async;
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
    private final TaskNotificationSettingService taskNotificationSettingService;
    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final JavaMailSender mailSender;

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

            // 异步发送
            new Thread(() -> sendNotification(dto)).start();
        }
    }

    @Override
    @Async
    public void sendExecutionNotificationForTask(Long taskId, String taskName, String taskType, boolean success, String message) {
        log.info("=== 开始检查任务通知设置: taskId={} ===", taskId);

        // 1. 查询任务的通知设置
        TaskNotificationSetting setting = taskNotificationSettingService.getByTaskId(taskId);
        if (setting == null) {
            log.info("任务 {} 没有通知设置，跳过", taskId);
            return;
        }

        // 2. 判断是否应该发送通知
        String executionStatus = success ? "success" : "failed";
        if (!taskNotificationSettingService.shouldNotify(setting, executionStatus)) {
            log.info("根据通知设置，状态 {} 不需要通知 (taskId={})", executionStatus, taskId);
            return;
        }

        log.info("通知设置已启用，准备发送通知: type={}", setting.getNotificationType());

        // 3. 获取通知配置
        NotificationConfig config = null;
        if (setting.getNotificationConfigId() != null) {
            config = notificationConfigService.getConfig(setting.getNotificationConfigId());
        }
        if (config == null) {
            config = notificationConfigService.getDefaultConfig();
        }

        // 4. 根据通知类型发送
        String notificationType = setting.getNotificationType();
        if (notificationType == null) {
            notificationType = "both";
        }

        if ("email".equals(notificationType) || "both".equals(notificationType)) {
            sendTaskEmailNotification(taskId, taskName, taskType, success, message, setting);
        }

        if ("webhook".equals(notificationType) || "both".equals(notificationType)) {
            sendTaskWebhookNotification(taskId, taskName, taskType, success, message, setting, config);
        }

        log.info("=== 任务通知发送完成: taskId={} ===", taskId);
    }

    /**
     * 发送任务邮件通知
     */
    private void sendTaskEmailNotification(Long taskId, String taskName, String taskType,
                                            boolean success, String message,
                                            TaskNotificationSetting setting) {
        try {
            // 获取收件人列表
            List<String> recipients = new java.util.ArrayList<>();

            // 从自定义收件人 JSON 中解析
            if (setting.getCustomRecipients() != null && !setting.getCustomRecipients().isBlank()) {
                try {
                    List<String> customList = objectMapper.readValue(
                            setting.getCustomRecipients(), new TypeReference<>() {});
                    recipients.addAll(customList);
                } catch (Exception e) {
                    log.warn("解析自定义收件人失败: {}", e.getMessage());
                }
            }

            if (recipients.isEmpty()) {
                log.warn("没有找到任何邮件收件人 (taskId={})", taskId);
                saveFailedLog(taskId, taskName, taskType, "email", "没有找到收件人");
                return;
            }

            // 构建邮件内容
            String statusText = success ? "成功" : "失败";
            String subject = "定时任务执行" + statusText + ": " + taskName;
            String emailContent = buildEmailContent(taskName, taskType, success, message);

            // 发送邮件
            SimpleMailMessage mailMessage = new SimpleMailMessage();
            mailMessage.setTo(recipients.toArray(new String[0]));
            mailMessage.setSubject(subject);
            mailMessage.setText(emailContent);

            // 使用通知配置中的发件人，或使用默认
            mailMessage.setFrom(mailSender instanceof org.springframework.mail.javamail.JavaMailSenderImpl impl
                    ? impl.getUsername() : "noreply@testhub.com");

            mailSender.send(mailMessage);
            log.info("邮件通知发送成功: taskId={}, recipients={}", taskId, recipients);

            // 记录成功日志
            NotificationLog logEntry = new NotificationLog();
            logEntry.setTaskId(taskId);
            logEntry.setTaskName(taskName);
            logEntry.setTaskType(taskType);
            logEntry.setNotificationType("task_execution");
            logEntry.setChannel("email");
            logEntry.setStatus("success");
            logEntry.setContent(emailContent);
            logEntry.setRecipientInfo(objectMapper.writeValueAsString(recipients));
            logEntry.setRetryCount(0);
            logEntry.setSentAt(java.time.LocalDateTime.now());
            this.save(logEntry);

        } catch (Exception e) {
            log.error("邮件通知发送失败: taskId={}, error={}", taskId, e.getMessage(), e);
            saveFailedLog(taskId, taskName, taskType, "email", e.getMessage());
        }
    }

    /**
     * 发送任务 Webhook 通知
     */
    private void sendTaskWebhookNotification(Long taskId, String taskName, String taskType,
                                              boolean success, String message,
                                              TaskNotificationSetting setting,
                                              NotificationConfig config) {
        // 收集所有待发送的 webhook 机器人
        List<Map<String, Object>> allBots = new java.util.ArrayList<>();

        // 从通知配置的 webhookBots 中获取机器人
        if (config != null && config.getWebhookBots() != null) {
            try {
                Map<String, Map<String, Object>> botsMap = objectMapper.readValue(
                        config.getWebhookBots(), new TypeReference<>() {});
                for (Map.Entry<String, Map<String, Object>> entry : botsMap.entrySet()) {
                    Map<String, Object> botConfig = entry.getValue();
                    String webhookUrl = (String) botConfig.get("webhook_url");
                    if (webhookUrl != null && !webhookUrl.isBlank()
                            && !Boolean.FALSE.equals(botConfig.get("enabled"))) {
                        Map<String, Object> bot = new java.util.HashMap<>(botConfig);
                        bot.put("type", entry.getKey());
                        allBots.add(bot);
                    }
                }
            } catch (Exception e) {
                log.warn("解析通知配置失败: {}", e.getMessage());
            }
        }

        // 从自定义 Webhook 机器人配置中获取
        if (setting.getCustomWebhookBots() != null && !setting.getCustomWebhookBots().isBlank()) {
            try {
                Map<String, Map<String, Object>> customBots = objectMapper.readValue(
                        setting.getCustomWebhookBots(), new TypeReference<>() {});
                for (Map.Entry<String, Map<String, Object>> entry : customBots.entrySet()) {
                    Map<String, Object> botConfig = entry.getValue();
                    Map<String, Object> bot = new java.util.HashMap<>(botConfig);
                    bot.put("type", entry.getKey());
                    if (Boolean.TRUE.equals(bot.get("enabled")) && bot.get("webhook_url") != null) {
                        allBots.add(bot);
                    }
                }
            } catch (Exception e) {
                log.warn("解析自定义Webhook配置失败: {}", e.getMessage());
            }
        }

        if (allBots.isEmpty()) {
            log.warn("没有找到任何启用的 Webhook 机器人 (taskId={})", taskId);
            saveFailedLog(taskId, taskName, taskType, "webhook", "没有可用的Webhook机器人");
            return;
        }

        // 构建消息内容
        String statusText = success ? "成功" : "失败";
        String time = java.time.LocalDateTime.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        for (Map<String, Object> bot : allBots) {
            String botType = (String) bot.get("type");
            String webhookUrl = (String) bot.get("webhook_url");
            String botName = (String) bot.getOrDefault("name", "Unknown");

            if (webhookUrl == null || webhookUrl.isBlank()) {
                continue;
            }

            try {
                boolean sent;
                // 根据配置类型分发
                if (botType != null && botType.contains("feishu")) {
                    sent = sendFeishuNotification(webhookUrl, "定时任务执行" + statusText,
                            buildWebhookMarkdown(taskName, statusText, time, taskType, message));
                } else if (botType != null && botType.contains("wechat")) {
                    sent = sendWechatNotification(webhookUrl, "定时任务执行" + statusText,
                            buildWebhookMarkdown(taskName, statusText, time, taskType, message));
                } else if (botType != null && botType.contains("dingtalk")) {
                    String secret = (String) bot.get("secret");
                    sent = sendDingtalkNotification(webhookUrl, secret, "定时任务执行" + statusText,
                            buildWebhookMarkdown(taskName, statusText, time, taskType, message));
                } else {
                    log.warn("不支持的 Webhook 类型: {}", botType);
                    continue;
                }

                // 记录日志
                NotificationLog logEntry = new NotificationLog();
                logEntry.setTaskId(taskId);
                logEntry.setTaskName(taskName);
                logEntry.setTaskType(taskType);
                logEntry.setNotificationType("task_execution");
                logEntry.setChannel(botType);
                logEntry.setStatus(sent ? "success" : "failed");
                logEntry.setContent(buildWebhookMarkdown(taskName, statusText, time, taskType, message));
                logEntry.setRetryCount(0);
                if (sent) {
                    logEntry.setSentAt(java.time.LocalDateTime.now());
                }
                this.save(logEntry);

                log.info("Webhook通知{}: taskId={}, bot={}", sent ? "成功" : "失败", taskId, botName);

            } catch (Exception e) {
                log.error("Webhook通知发送异常: taskId={}, bot={}, error={}", taskId, botName, e.getMessage());
                saveFailedLog(taskId, taskName, taskType, botType, e.getMessage());
            }
        }
    }

    private void saveFailedLog(Long taskId, String taskName, String taskType, String channel, String errorMessage) {
        try {
            NotificationLog logEntry = new NotificationLog();
            logEntry.setTaskId(taskId);
            logEntry.setTaskName(taskName);
            logEntry.setTaskType(taskType);
            logEntry.setNotificationType("task_execution");
            logEntry.setChannel(channel);
            logEntry.setStatus("failed");
            logEntry.setErrorMessage(errorMessage);
            logEntry.setRetryCount(0);
            this.save(logEntry);
        } catch (Exception e) {
            log.error("保存通知失败日志时出错: {}", e.getMessage());
        }
    }

    private String buildEmailContent(String taskName, String taskType, boolean success, String message) {
        String statusText = success ? "成功" : "失败";
        String time = java.time.LocalDateTime.now()
                .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        String typeDisplay = "TEST_SUITE".equals(taskType) ? "测试套件执行" : "API请求执行";

        return String.format("""
                任务名称: %s
                执行状态: %s
                执行时间: %s
                任务类型: %s

                执行详情:
                %s
                """, taskName, statusText, time, typeDisplay,
                message != null && !message.isBlank() ? message : "无详细信息");
    }

    private String buildWebhookMarkdown(String taskName, String statusText, String time, String taskType, String message) {
        String typeDisplay = "TEST_SUITE".equals(taskType) ? "测试套件执行" : "API请求执行";
        String detail = message != null && !message.isBlank() ? "\n\n执行详情:\n" + message : "";
        return String.format("**定时任务执行%s**\n\n任务名称: %s\n执行状态: %s\n执行时间: %s\n任务类型: %s%s",
                statusText, taskName, statusText, time, typeDisplay, detail);
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
            // 从 webhookBots JSON 中提取对应机器人的 webhook
            Map<String, Map<String, Object>> botsMap = objectMapper.readValue(
                    config.getWebhookBots(), new TypeReference<>() {});
            String botKey = configType;
            if (botKey != null && botKey.startsWith("webhook_")) {
                botKey = botKey.substring("webhook_".length());
            }
            Map<String, Object> botConfig = botsMap.get(botKey);
            if (botConfig == null) {
                log.warn("webhookBots 中未找到机器人: {}", botKey);
                return false;
            }
            String webhook = (String) botConfig.get("webhook_url");

            switch (configType) {
                case "webhook_feishu":
                    return sendFeishuNotification(webhook, title, content);
                case "webhook_wechat":
                    return sendWechatNotification(webhook, title, content);
                case "webhook_dingtalk":
                    String secret = (String) botConfig.get("secret");
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
