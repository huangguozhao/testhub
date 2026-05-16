package com.testhub.modules.ai_generation.service;

import com.testhub.modules.configuration.domain.AIModelConfig;
import dev.langchain4j.model.anthropic.AnthropicChatModel;
import dev.langchain4j.model.anthropic.AnthropicStreamingChatModel;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.chat.StreamingChatLanguageModel;
import dev.langchain4j.model.openai.OpenAiChatModel;
import dev.langchain4j.model.openai.OpenAiStreamingChatModel;
import org.springframework.stereotype.Service;

import java.time.Duration;

/**
 * LangChain4j 模型工厂
 * 根据 AIModelConfig 创建对应的 ChatLanguageModel 实例
 */
@Service
public class LangChainModelFactory {

    private static final Duration TIMEOUT = Duration.ofSeconds(900);

    /**
     * 创建同步聊天模型
     */
    public ChatLanguageModel createChatModel(AIModelConfig config) {
        return createChatModel(config, null);
    }

    /**
     * 创建同步聊天模型（支持覆盖 maxTokens）
     */
    public ChatLanguageModel createChatModel(AIModelConfig config, Integer maxTokens) {
        int tokens = maxTokens != null ? maxTokens : config.getMaxTokens();
        if (isAnthropic(config)) {
            var builder = AnthropicChatModel.builder()
                    .apiKey(config.getApiKey())
                    .modelName(config.getModelName())
                    .maxTokens(tokens)
                    .temperature(config.getTemperature() != null ? config.getTemperature().doubleValue() : 0.7)
                    .topP(config.getTopP() != null ? config.getTopP().doubleValue() : 1.0)
                    .timeout(TIMEOUT);
            // 支持自定义 baseUrl（用于 Anthropic 兼容的第三方 API）
            if (config.getBaseUrl() != null) {
                builder.baseUrl(config.getBaseUrl());
            }
            return builder.build();
        }
        return OpenAiChatModel.builder()
                .apiKey(config.getApiKey())
                .baseUrl(normalizeBaseUrl(config.getBaseUrl()))
                .modelName(config.getModelName())
                .maxTokens(tokens)
                .temperature(config.getTemperature() != null ? config.getTemperature().doubleValue() : 0.7)
                .topP(config.getTopP() != null ? config.getTopP().doubleValue() : 1.0)
                .timeout(TIMEOUT)
                .build();
    }

    /**
     * 创建流式聊天模型
     */
    public StreamingChatLanguageModel createStreamingModel(AIModelConfig config) {
        if (isAnthropic(config)) {
            var builder = AnthropicStreamingChatModel.builder()
                    .apiKey(config.getApiKey())
                    .modelName(config.getModelName())
                    .maxTokens(config.getMaxTokens())
                    .temperature(config.getTemperature() != null ? config.getTemperature().doubleValue() : 0.7)
                    .topP(config.getTopP() != null ? config.getTopP().doubleValue() : 1.0)
                    .timeout(TIMEOUT);
            // 支持自定义 baseUrl（用于 Anthropic 兼容的第三方 API）
            if (config.getBaseUrl() != null) {
                builder.baseUrl(config.getBaseUrl());
            }
            return builder.build();
        }
        return OpenAiStreamingChatModel.builder()
                .apiKey(config.getApiKey())
                .baseUrl(normalizeBaseUrl(config.getBaseUrl()))
                .modelName(config.getModelName())
                .maxTokens(config.getMaxTokens())
                .temperature(config.getTemperature() != null ? config.getTemperature().doubleValue() : 0.7)
                .topP(config.getTopP() != null ? config.getTopP().doubleValue() : 1.0)
                .timeout(TIMEOUT)
                .build();
    }

    private boolean isAnthropic(AIModelConfig config) {
        // provider 为 anthropic 时使用 Anthropic 客户端
        if ("anthropic".equalsIgnoreCase(config.getModelType())) {
            return true;
        }
        String baseUrl = config.getBaseUrl();
        if (baseUrl == null) {
            return false;
        }
        // MiniMax 使用 OpenAI 兼容 API（langchain4j-anthropic 不支持其 thinking 响应格式）
        if (baseUrl.contains("minimaxi.com") || baseUrl.contains("minimax.chat")) {
            return false;
        }
        // 匹配 Anthropic 官方 API
        return baseUrl.startsWith("https://api.anthropic.com")
                || baseUrl.contains("anthropic.com");
    }

    private String normalizeBaseUrl(String baseUrl) {
        if (baseUrl == null) return baseUrl;
        baseUrl = baseUrl.replaceAll("/+$", "");

        // MiniMax: 转换 Anthropic 端点为 OpenAI 兼容端点
        if (baseUrl.contains("minimaxi.com/anthropic")) {
            return "https://api.minimax.chat/v1";
        }
        if (baseUrl.contains("minimaxi.com")) {
            return "https://api.minimax.chat/v1";
        }

        // 如果 URL 已经以 /v1 结尾，不再追加
        if (baseUrl.matches(".*/v\\d+$")) return baseUrl;
        // 如果已包含 /chat/completions 或 /messages，直接返回
        if (baseUrl.endsWith("/chat/completions") || baseUrl.endsWith("/messages")) return baseUrl;
        return baseUrl;
    }
}
