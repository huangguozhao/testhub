package com.testhub.modules.ai_generation.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.domain.TestCaseGenerationTask;
import com.testhub.modules.ai_generation.service.TestCaseGenerationService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
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

    @GetMapping(value = "/{taskId}/stream_progress", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
    @Operation(summary = "SSE流式推送任务进度")
    public SseEmitter streamProgress(@PathVariable String taskId) {
        SseEmitter emitter = new SseEmitter(300_000L); // 5分钟超时

        sseExecutor.execute(() -> {
            try {
                int lastPosition = 0;
                String lastStatus = "";

                for (int i = 0; i < 600; i++) { // 最多轮询5分钟
                    TestCaseGenerationTask task = testCaseGenerationService.getTaskByTaskId(taskId);
                    if (task == null) {
                        emitter.send("{\"type\":\"error\",\"message\":\"任务不存在\"}");
                        emitter.complete();
                        return;
                    }

                    String currentStatus = task.getStatus();

                    // 推送流式内容增量
                    if (task.getStreamBuffer() != null && task.getStreamPosition() != null
                            && task.getStreamPosition() > lastPosition) {
                        String newContent = task.getStreamBuffer().substring(lastPosition);
                        lastPosition = task.getStreamPosition();

                        String eventType = "generating".equals(currentStatus) ? "content"
                                : "reviewing".equals(currentStatus) ? "review_content"
                                : "revising".equals(currentStatus) ? "final_content"
                                : "content";

                        Map<String, Object> eventData = new java.util.HashMap<>();
                        eventData.put("type", eventType);
                        eventData.put("content", newContent);
                        emitter.send(new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(eventData));
                    }

                    // 推送状态变更
                    if (!currentStatus.equals(lastStatus)) {
                        lastStatus = currentStatus;

                        Map<String, Object> statusData = new java.util.HashMap<>();
                        statusData.put("type", "status");
                        statusData.put("status", currentStatus);
                        statusData.put("progress", task.getProgress());

                        if ("completed".equals(currentStatus)) {
                            statusData.put("final_test_cases", task.getFinalTestCases());
                            statusData.put("review_feedback", task.getReviewFeedback());
                        } else if ("failed".equals(currentStatus)) {
                            statusData.put("error_message", task.getErrorMessage());
                        }

                        emitter.send(new com.fasterxml.jackson.databind.ObjectMapper().writeValueAsString(statusData));

                        if ("completed".equals(currentStatus) || "failed".equals(currentStatus)) {
                            // 推送 done 事件
                            emitter.send("{\"type\":\"done\"}");
                            emitter.complete();
                            return;
                        }
                    }

                    Thread.sleep(500);
                }

                // 超时
                emitter.send("{\"type\":\"timeout\",\"message\":\"轮询超时\"}");
                emitter.complete();

            } catch (IOException e) {
                log.debug("SSE连接已关闭: {}", e.getMessage());
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

        emitter.onTimeout(() -> log.debug("SSE超时: taskId={}", taskId));
        emitter.onCompletion(() -> log.debug("SSE完成: taskId={}", taskId));

        return emitter;
    }

    @PostMapping("/{taskId}/save_to_records")
    @Operation(summary = "保存到正式用例记录")
    public Result<Map<String, Object>> saveToRecords(@PathVariable String taskId) {
        Map<String, Object> result = testCaseGenerationService.saveToRecords(taskId);
        return Result.success(result);
    }
}
