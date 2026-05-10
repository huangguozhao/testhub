package com.testhub.modules.ai_generation.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.domain.TestCaseGenerationTask;
import com.testhub.modules.ai_generation.service.TestCaseGenerationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

@Slf4j
@Tag(name = "AI用例生成", description = "AI驱动的测试用例生成")
@RestController
@RequestMapping("/api/requirement-analysis/testcase-generation")
@RequiredArgsConstructor
public class TestCaseGenerationController {

    private final TestCaseGenerationService testCaseGenerationService;
    private final ExecutorService sseExecutor = Executors.newCachedThreadPool();

    @PostMapping("/generate")
    @Operation(summary = "创建生成任务")
    public Result<Map<String, Object>> generate(@RequestBody Map<String, Object> request) {
        Long userId = 1L; // TODO: 从认证上下文获取
        TestCaseGenerationTask task = testCaseGenerationService.createTask(request, userId);

        Map<String, Object> result = new java.util.HashMap<>();
        result.put("task_id", task.getTaskId());
        result.put("status", task.getStatus());
        result.put("message", "生成任务已创建");
        return Result.success(result);
    }

    @GetMapping("/{taskId}/progress")
    @Operation(summary = "获取任务进度")
    public Result<Map<String, Object>> getProgress(@PathVariable String taskId) {
        Map<String, Object> progress = testCaseGenerationService.getProgress(taskId);
        return Result.success(progress);
    }

    @GetMapping(value = "/{taskId}/stream_progress")
    @Operation(summary = "SSE流式推送任务进度")
    public SseEmitter streamProgress(@PathVariable String taskId) {
        // 超时设置为10分钟
        SseEmitter emitter = new SseEmitter(600_000L);
        final com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();

        sseExecutor.execute(() -> {
            try {
                int lastStreamPos = 0;
                int lastReviewPos = 0;
                int lastFinalPos = 0;
                String lastProgressHash = "";
                long lastDataTime = System.currentTimeMillis();
                String lastStatus = "";

                // 立即发送一个初始事件，确认SSE连接建立
                emitter.send(SseEmitter.event()
                        .name("connected")
                        .data("{\"type\":\"connected\"}"));
                log.info("SSE连接已建立, taskId={}", taskId);

                for (int i = 0; i < 1200; i++) { // 最多轮询10分钟
                    TestCaseGenerationTask task = testCaseGenerationService.getTaskByTaskId(taskId);
                    if (task == null) {
                        log.warn("SSE[{}] 任务不存在, 结束轮询", i);
                        emitter.send(SseEmitter.event().data("{\"type\":\"error\",\"message\":\"任务不存在\"}"));
                        emitter.complete();
                        return;
                    }

                    String currentStatus = task.getStatus() != null ? task.getStatus() : "pending";
                    Integer progress = task.getProgress() != null ? task.getProgress() : 0;
                    Integer streamPos = task.getStreamPosition() != null ? task.getStreamPosition() : 0;
                    Integer reviewPos = task.getReviewPosition() != null ? task.getReviewPosition() : 0;
                    Integer finalPos = task.getFinalPosition() != null ? task.getFinalPosition() : 0;
                    boolean hasSentData = false;

                    // 每30轮打一次详细日志
                    if (i % 30 == 0) {
                        log.debug("SSE[{}] 状态={}, progress={}, streamPos={}, reviewPos={}, finalPos={}",
                                i, currentStatus, progress, streamPos, reviewPos, finalPos);
                    }

                    // 检测状态变化
                    if (!currentStatus.equals(lastStatus)) {
                        log.info("SSE状态变化: {} -> {}, taskId={}", lastStatus, currentStatus, taskId);
                        if ("revising".equals(currentStatus)) {
                            lastFinalPos = 0;
                        }
                        lastStatus = currentStatus;
                    }

                    // 推送生成内容增量
                    if (task.getStreamBuffer() != null && streamPos > lastStreamPos) {
                        String buffer = task.getStreamBuffer();
                        if (buffer.length() >= streamPos) {
                            String newContent = buffer.substring(lastStreamPos, streamPos);
                            lastStreamPos = streamPos;
                            log.debug("SSE[{}] 发送content增量, 长度={}", i, newContent.length());
                            sendSseData(emitter, mapper, "content", Map.of("content", newContent));
                            hasSentData = true;
                        }
                    }

                    // 推送评审内容增量
                    if (task.getReviewFeedback() != null && reviewPos > lastReviewPos) {
                        String reviewBuf = task.getReviewFeedback();
                        if (reviewBuf.length() >= reviewPos) {
                            String newReview = reviewBuf.substring(lastReviewPos, reviewPos);
                            lastReviewPos = reviewPos;
                            log.debug("SSE[{}] 发送review_content增量, 长度={}", i, newReview.length());
                            sendSseData(emitter, mapper, "review_content", Map.of("content", newReview));
                            hasSentData = true;
                        }
                    }

                    // 推送最终用例增量
                    if (task.getFinalTestCases() != null && finalPos > lastFinalPos) {
                        String finalBuf = task.getFinalTestCases();
                        if (finalBuf.length() >= finalPos) {
                            String newFinal = finalBuf.substring(lastFinalPos, finalPos);
                            lastFinalPos = finalPos;
                            log.debug("SSE[{}] 发送final_content增量, 长度={}", i, newFinal.length());
                            sendSseData(emitter, mapper, "final_content", Map.of("content", newFinal));
                            hasSentData = true;
                        }
                    }

                    // 推送进度变更（仅当变化时）
                    String currentProgressHash = currentStatus + "_" + progress;
                    if (!currentProgressHash.equals(lastProgressHash)) {
                        lastProgressHash = currentProgressHash;
                        log.debug("SSE[{}] 发送progress: status={}, progress={}", i, currentStatus, progress);
                        Map<String, Object> progressData = new java.util.HashMap<>();
                        progressData.put("type", "progress");
                        progressData.put("status", currentStatus);
                        progressData.put("progress", progress);
                        sendSseData(emitter, mapper, null, progressData);
                        hasSentData = true;
                    }

                    // 检查任务是否结束
                    if ("completed".equals(currentStatus) || "failed".equals(currentStatus)) {
                        log.info("SSE任务结束, status={}", currentStatus);
                        Map<String, Object> statusData = new java.util.HashMap<>();
                        statusData.put("type", "status");
                        statusData.put("status", currentStatus);
                        statusData.put("progress", progress);
                        sendSseData(emitter, mapper, null, statusData);
                        sendSseData(emitter, mapper, "done", null);
                        emitter.complete();
                        return;
                    }

                    // 心跳保活：每15秒无数据时发送
                    if (hasSentData) {
                        lastDataTime = System.currentTimeMillis();
                    } else if (System.currentTimeMillis() - lastDataTime >= 15000) {
                        try {
                            emitter.send(SseEmitter.event().comment("keep-alive"));
                            log.debug("SSE心跳已发送");
                        } catch (IOException e) {
                            log.warn("SSE心跳发送失败, 连接已断开: {}", e.getMessage());
                            return;
                        }
                        lastDataTime = System.currentTimeMillis();
                    }

                    Thread.sleep(500);
                }

                log.warn("SSE轮询超时, taskId={}", taskId);
                emitter.send(SseEmitter.event().data("{\"type\":\"timeout\"}"));
                emitter.complete();

            } catch (IOException e) {
                log.info("SSE连接已关闭: {}", e.getMessage());
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            } catch (Exception e) {
                log.error("SSE推送异常: {}", e.getMessage(), e);
                try {
                    emitter.completeWithError(e);
                } catch (Exception ignored) {
                }
            }
        });

        emitter.onTimeout(() -> {
            log.debug("SSE超时回调: taskId={}", taskId);
            emitter.complete();
        });
        emitter.onCompletion(() -> log.debug("SSE完成回调: taskId={}", taskId));
        emitter.onError(th -> log.debug("SSE错误回调: taskId={}, error={}", taskId, th.getMessage()));

        return emitter;
    }

    /**
     * 发送SSE数据事件
     */
    private void sendSseData(SseEmitter emitter,
                             com.fasterxml.jackson.databind.ObjectMapper mapper,
                             String eventType,
                             Map<String, Object> data) throws IOException {
        Map<String, Object> payload = data != null ? new java.util.HashMap<>(data) : new java.util.HashMap<>();
        if (eventType != null) {
            payload.putIfAbsent("type", eventType);
        }
        String json = mapper.writeValueAsString(payload);
        try {
            emitter.send(SseEmitter.event().data(json));
        } catch (IOException e) {
            log.warn("SSE发送失败: {}", e.getMessage());
            throw e;
        }
    }

    @PostMapping("/{taskId}/save_to_records")
    @Operation(summary = "保存到正式用例记录")
    public Result<Map<String, Object>> saveToRecords(@PathVariable String taskId) {
        Map<String, Object> result = testCaseGenerationService.saveToRecords(taskId);
        return Result.success(result);
    }
}
