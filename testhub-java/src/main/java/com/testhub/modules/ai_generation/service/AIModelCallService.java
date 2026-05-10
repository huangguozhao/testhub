package com.testhub.modules.ai_generation.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.configuration.domain.AIModelConfig;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.time.Duration;
import java.util.*;
import java.util.function.Consumer;

@Slf4j
@Service
@RequiredArgsConstructor
public class AIModelCallService {

    private final ObjectMapper objectMapper;

    /**
     * 非流式调用 AI API
     */
    public String chatCompletion(AIModelConfig config, List<Map<String, String>> messages) {
        return chatCompletion(config, messages, null);
    }

    /**
     * 非流式调用 AI API，支持自定义 max_tokens
     */
    public String chatCompletion(AIModelConfig config, List<Map<String, String>> messages, Integer maxTokens) {
        try {
            String url = buildUrl(config);
            boolean isAnthropic = config.getBaseUrl().contains("anthropic");

            Map<String, Object> body = new HashMap<>();
            body.put("model", config.getModelName());
            body.put("messages", messages);
            body.put("max_tokens", maxTokens != null ? maxTokens : config.getMaxTokens());
            body.put("temperature", config.getTemperature());
            body.put("top_p", config.getTopP());
            body.put("stream", false);

            String jsonBody = objectMapper.writeValueAsString(body);

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(60))
                    .build();

            HttpRequest.Builder reqBuilder = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(900));

            if (isAnthropic) {
                reqBuilder.header("x-api-key", config.getApiKey());
                reqBuilder.header("anthropic-version", "2023-06-01");
            } else {
                reqBuilder.header("Authorization", "Bearer " + config.getApiKey());
            }

            HttpResponse<String> response = client.send(reqBuilder.build(), HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() != 200) {
                throw new RuntimeException("AI API 返回错误: HTTP " + response.statusCode() + " - " + response.body());
            }

            return extractContent(response.body(), isAnthropic);
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("AI API 调用失败: " + e.getMessage(), e);
        }
    }

    /**
     * 流式调用 AI API
     */
    public String chatCompletionStream(AIModelConfig config, List<Map<String, String>> messages, Consumer<String> callback) {
        try {
            String url = buildUrl(config);
            boolean isAnthropic = config.getBaseUrl().contains("anthropic");

            Map<String, Object> body = new HashMap<>();
            body.put("model", config.getModelName());
            body.put("messages", messages);
            body.put("max_tokens", config.getMaxTokens());
            body.put("temperature", config.getTemperature());
            body.put("top_p", config.getTopP());
            body.put("stream", true);

            String jsonBody = objectMapper.writeValueAsString(body);

            HttpClient client = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(60))
                    .build();

            HttpRequest.Builder reqBuilder = HttpRequest.newBuilder()
                    .uri(URI.create(url))
                    .header("Content-Type", "application/json")
                    .POST(HttpRequest.BodyPublishers.ofString(jsonBody, StandardCharsets.UTF_8))
                    .timeout(Duration.ofSeconds(900));

            if (isAnthropic) {
                reqBuilder.header("x-api-key", config.getApiKey());
                reqBuilder.header("anthropic-version", "2023-06-01");
            } else {
                reqBuilder.header("Authorization", "Bearer " + config.getApiKey());
            }

            HttpRequest request = reqBuilder.build();
            HttpResponse<java.io.InputStream> response = client.send(request, HttpResponse.BodyHandlers.ofInputStream());

            if (response.statusCode() != 200) {
                String errorBody = new String(response.body().readAllBytes(), StandardCharsets.UTF_8);
                throw new RuntimeException("AI API 返回错误: HTTP " + response.statusCode() + " - " + errorBody);
            }

            StringBuilder fullContent = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(response.body(), StandardCharsets.UTF_8))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    if (!line.startsWith("data: ")) continue;
                    String data = line.substring(6).trim();
                    if ("[DONE]".equals(data)) break;

                    try {
                        String content = extractStreamChunk(data, isAnthropic);
                        if (content != null && !content.isEmpty()) {
                            fullContent.append(content);
                            if (callback != null) {
                                callback.accept(content);
                            }
                        }
                    } catch (Exception e) {
                        log.warn("解析流式数据块失败: {}", e.getMessage());
                    }
                }
            }

            return fullContent.toString();
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException("AI 流式 API 调用失败: " + e.getMessage(), e);
        }
    }

    private String buildUrl(AIModelConfig config) {
        String baseUrl = config.getBaseUrl().replaceAll("/+$", "");
        boolean isAnthropic = baseUrl.contains("anthropic");

        if (isAnthropic) {
            if (baseUrl.matches(".*/v\\d+/?$")) return baseUrl + "/messages";
            if (baseUrl.endsWith("/messages")) return baseUrl;
            return baseUrl + "/v1/messages";
        } else {
            if (baseUrl.matches(".*/v\\d+/?$")) return baseUrl + "/chat/completions";
            if (baseUrl.endsWith("/chat/completions")) return baseUrl;
            return baseUrl + "/v1/chat/completions";
        }
    }

    private String extractContent(String responseBody, boolean isAnthropic) throws Exception {
        JsonNode root = objectMapper.readTree(responseBody);
        if (isAnthropic) {
            JsonNode content = root.get("content");
            if (content != null && content.isArray() && !content.isEmpty()) {
                return content.get(0).get("text").asText();
            }
        } else {
            JsonNode choices = root.get("choices");
            if (choices != null && choices.isArray() && !choices.isEmpty()) {
                JsonNode message = choices.get(0).get("message");
                if (message != null) return message.get("content").asText();
            }
        }
        return "";
    }

    private String extractStreamChunk(String data, boolean isAnthropic) throws Exception {
        JsonNode root = objectMapper.readTree(data);
        if (isAnthropic) {
            JsonNode type = root.get("type");
            if (type != null && "content_block_delta".equals(type.asText())) {
                JsonNode delta = root.get("delta");
                if (delta != null && delta.has("text") && delta.get("text").isTextual()) return delta.get("text").asText();
            }
        } else {
            JsonNode choices = root.get("choices");
            if (choices != null && choices.isArray() && !choices.isEmpty()) {
                JsonNode delta = choices.get(0).get("delta");
                if (delta != null && delta.has("content") && delta.get("content").isTextual()) return delta.get("content").asText();
            }
        }
        return null;
    }
}
