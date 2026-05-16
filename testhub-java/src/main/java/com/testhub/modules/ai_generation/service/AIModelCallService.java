package com.testhub.modules.ai_generation.service;

import com.testhub.modules.configuration.domain.AIModelConfig;
import dev.langchain4j.data.message.AiMessage;
import dev.langchain4j.data.message.ChatMessage;
import dev.langchain4j.data.message.SystemMessage;
import dev.langchain4j.data.message.UserMessage;
import dev.langchain4j.model.StreamingResponseHandler;
import dev.langchain4j.model.chat.ChatLanguageModel;
import dev.langchain4j.model.chat.StreamingChatLanguageModel;
import dev.langchain4j.model.output.Response;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CompletableFuture;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledThreadPoolExecutor;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicLong;
import java.util.function.Consumer;

@Slf4j
@Service
@RequiredArgsConstructor
public class AIModelCallService {

    private final LangChainModelFactory modelFactory;

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
            ChatLanguageModel model = modelFactory.createChatModel(config, maxTokens);
            List<ChatMessage> chatMessages = convertMessages(messages);

            log.debug("LangChain4j 非流式调用: model={}, messages={}", config.getModelName(), chatMessages.size());
            Response<AiMessage> response = model.generate(chatMessages);
            String content = response.content().text();

            log.debug("LangChain4j 调用完成, 返回长度={}", content != null ? content.length() : 0);
            return content;
        } catch (Exception e) {
            log.error("LangChain4j 调用失败: {}", e.getMessage(), e);
            throw new RuntimeException("AI API 调用失败: " + e.getMessage(), e);
        }
    }

    /**
     * 流式调用 AI API
     * 当 onComplete/onError 未被调用时（如连接中断），通过心跳检测自动完成
     */
    public String chatCompletionStream(AIModelConfig config, List<Map<String, String>> messages, Consumer<String> callback) {
        try {
            StreamingChatLanguageModel model = modelFactory.createStreamingModel(config);
            List<ChatMessage> chatMessages = convertMessages(messages);

            CompletableFuture<String> future = new CompletableFuture<>();
            StringBuilder fullContent = new StringBuilder();
            AtomicLong lastDataTime = new AtomicLong(System.currentTimeMillis());

            log.debug("LangChain4j 流式调用: model={}, baseUrl={}, messages={}", config.getModelName(), config.getBaseUrl(), chatMessages.size());

            // 心跳检测：30秒无新数据且已有内容时，认为流式调用已结束
            ScheduledExecutorService watchdog = new ScheduledThreadPoolExecutor(1);
            watchdog.scheduleAtFixedRate(() -> {
                try {
                    long elapsed = System.currentTimeMillis() - lastDataTime.get();
                    if (elapsed > 30000 && fullContent.length() > 0 && !future.isDone()) {
                        log.warn("LangChain4j 流式调用超时({}ms无新数据), 已收到内容长度={}, 视为完成", elapsed, fullContent.length());
                        future.complete(fullContent.toString());
                    }
                } catch (Exception e) {
                    log.debug("心跳检测异常: {}", e.getMessage());
                }
            }, 10, 10, TimeUnit.SECONDS);

            model.generate(chatMessages, new StreamingResponseHandler<>() {
                @Override
                public void onNext(String partialResponse) {
                    fullContent.append(partialResponse);
                    lastDataTime.set(System.currentTimeMillis());
                    if (callback != null) {
                        callback.accept(partialResponse);
                    }
                }

                @Override
                public void onComplete(Response<AiMessage> response) {
                    log.debug("LangChain4j 流式调用完成, 总长度={}", fullContent.length());
                    if (!future.isDone()) {
                        future.complete(fullContent.toString());
                    }
                }

                @Override
                public void onError(Throwable error) {
                    log.error("LangChain4j 流式调用失败: {}", error.getMessage(), error);
                    if (!future.isDone()) {
                        future.completeExceptionally(error);
                    }
                }
            });

            try {
                return future.get(15, TimeUnit.MINUTES);
            } finally {
                watchdog.shutdownNow();
            }
        } catch (Exception e) {
            log.error("LangChain4j 流式调用失败: {}", e.getMessage(), e);
            throw new RuntimeException("AI 流式 API 调用失败: " + e.getMessage(), e);
        }
    }

    /**
     * 将前端格式的消息列表转换为 LangChain4j ChatMessage
     */
    private List<ChatMessage> convertMessages(List<Map<String, String>> messages) {
        List<ChatMessage> chatMessages = new ArrayList<>();
        for (Map<String, String> msg : messages) {
            String role = msg.get("role");
            String content = msg.get("content");
            switch (role) {
                case "system" -> chatMessages.add(SystemMessage.from(content));
                case "user" -> chatMessages.add(UserMessage.from(content));
                case "assistant" -> chatMessages.add(AiMessage.from(content));
                default -> chatMessages.add(UserMessage.from(content));
            }
        }
        return chatMessages;
    }
}
