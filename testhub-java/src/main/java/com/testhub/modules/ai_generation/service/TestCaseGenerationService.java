package com.testhub.modules.ai_generation.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.modules.ai_generation.domain.TestCaseGenerationTask;
import com.testhub.modules.ai_generation.mapper.TestCaseGenerationTaskMapper;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.mapper.AIModelConfigMapper;
import com.testhub.modules.configuration.mapper.PromptConfigMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
@RequiredArgsConstructor
public class TestCaseGenerationService {

    private final TestCaseGenerationTaskMapper taskMapper;
    private final AIModelConfigMapper aiModelConfigMapper;
    private final PromptConfigMapper promptConfigMapper;
    private final AIModelCallService aiModelCallService;

    /**
     * 创建生成任务
     */
    public TestCaseGenerationTask createTask(Map<String, Object> request, Long userId) {
        TestCaseGenerationTask task = new TestCaseGenerationTask();
        task.setTaskId("gen_" + UUID.randomUUID().toString().replace("-", "").substring(0, 12));
        task.setTitle((String) request.getOrDefault("title", "未命名任务"));
        task.setRequirementText((String) request.get("requirement_text"));
        task.setStatus("pending");
        task.setProgress(0);
        task.setOutputMode((String) request.getOrDefault("output_mode", "stream"));
        task.setStreamBuffer("");
        task.setStreamPosition(0);
        task.setCreatedBy(userId);

        // 关联项目
        Object projectObj = request.get("project");
        if (projectObj != null) {
            task.setProjectId(Long.valueOf(projectObj.toString()));
        }

        // 查找 writer 模型配置
        AIModelConfig writerConfig = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "testcase_writer")
                        .eq(AIModelConfig::getIsActive, true)
                        .last("LIMIT 1"));
        if (writerConfig != null) {
            task.setWriterModelConfigId(writerConfig.getId());
        }

        // 查找 reviewer 模型配置
        AIModelConfig reviewerConfig = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "testcase_reviewer")
                        .eq(AIModelConfig::getIsActive, true)
                        .last("LIMIT 1"));
        if (reviewerConfig != null) {
            task.setReviewerModelConfigId(reviewerConfig.getId());
        }

        // 查找 writer 提示词
        PromptConfig writerPrompt = promptConfigMapper.selectOne(
                new LambdaQueryWrapper<PromptConfig>()
                        .eq(PromptConfig::getPromptType, "writer")
                        .eq(PromptConfig::getIsActive, true)
                        .last("LIMIT 1"));
        if (writerPrompt != null) {
            task.setWriterPromptConfigId(writerPrompt.getId());
        }

        // 查找 reviewer 提示词
        PromptConfig reviewerPrompt = promptConfigMapper.selectOne(
                new LambdaQueryWrapper<PromptConfig>()
                        .eq(PromptConfig::getPromptType, "reviewer")
                        .eq(PromptConfig::getIsActive, true)
                        .last("LIMIT 1"));
        if (reviewerPrompt != null) {
            task.setReviewerPromptConfigId(reviewerPrompt.getId());
        }

        taskMapper.insert(task);
        log.info("创建用例生成任务: taskId={}", task.getTaskId());

        // 启动后台生成
        executeGeneration(task.getId());

        return task;
    }

    /**
     * 获取任务进度
     */
    public Map<String, Object> getProgress(String taskId) {
        TestCaseGenerationTask task = taskMapper.selectOne(
                new LambdaQueryWrapper<TestCaseGenerationTask>()
                        .eq(TestCaseGenerationTask::getTaskId, taskId));
        if (task == null) {
            throw new RuntimeException("任务不存在: " + taskId);
        }

        Map<String, Object> result = new HashMap<>();
        result.put("task_id", task.getTaskId());
        result.put("status", task.getStatus());
        result.put("progress", task.getProgress());
        result.put("generated_test_cases", task.getGeneratedTestCases());
        result.put("review_feedback", task.getReviewFeedback());
        result.put("final_test_cases", task.getFinalTestCases());
        result.put("error_message", task.getErrorMessage());
        result.put("completed_at", task.getCompletedAt());
        return result;
    }

    /**
     * 获取 SSE 流式数据（供 Controller 使用）
     */
    public TestCaseGenerationTask getTaskByTaskId(String taskId) {
        return taskMapper.selectOne(
                new LambdaQueryWrapper<TestCaseGenerationTask>()
                        .eq(TestCaseGenerationTask::getTaskId, taskId));
    }

    /**
     * 保存到正式用例记录
     */
    public Map<String, Object> saveToRecords(String taskId) {
        TestCaseGenerationTask task = taskMapper.selectOne(
                new LambdaQueryWrapper<TestCaseGenerationTask>()
                        .eq(TestCaseGenerationTask::getTaskId, taskId));
        if (task == null) {
            throw new RuntimeException("任务不存在: " + taskId);
        }
        if (!"completed".equals(task.getStatus())) {
            throw new RuntimeException("任务尚未完成，无法保存");
        }

        String content = task.getFinalTestCases();
        if (content == null || content.isBlank()) {
            content = task.getGeneratedTestCases();
        }

        task.setIsSavedToRecords(1);
        task.setSavedAt(LocalDateTime.now());
        taskMapper.updateById(task);

        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("message", "已保存到记录");
        result.put("task_id", taskId);
        return result;
    }

    /**
     * 后台执行生成任务
     */
    @Async
    public void executeGeneration(Long taskId) {
        TestCaseGenerationTask task = taskMapper.selectById(taskId);
        if (task == null) return;

        try {
            // 阶段1: 生成测试用例
            task.setStatus("generating");
            task.setProgress(10);
            taskMapper.updateById(task);

            AIModelConfig writerConfig = task.getWriterModelConfigId() != null
                    ? aiModelConfigMapper.selectById(task.getWriterModelConfigId()) : null;
            PromptConfig writerPrompt = task.getWriterPromptConfigId() != null
                    ? promptConfigMapper.selectById(task.getWriterPromptConfigId()) : null;

            if (writerConfig == null) {
                throw new RuntimeException("未配置测试用例编写模型");
            }

            // 构建消息
            List<Map<String, String>> messages = new ArrayList<>();
            String systemPrompt = writerPrompt != null ? writerPrompt.getContent()
                    : "你是一位资深的测试用例编写专家，能够根据需求精确生成高质量的测试用例。";
            messages.add(Map.of("role", "system", "content", systemPrompt));
            messages.add(Map.of("role", "user", "content",
                    "请根据以下需求生成详细的测试用例：\n\n" + task.getRequirementText()
                            + "\\n\n请以JSON数组格式输出，每个用例包含：case_id, title, priority, precondition, test_steps, expected_result"));

            task.setProgress(30);
            taskMapper.updateById(task);

            // 流式生成
            StringBuilder generatedContent = new StringBuilder();
            String generated = aiModelCallService.chatCompletionStream(writerConfig, messages, chunk -> {
                generatedContent.append(chunk);
                // 更新流式缓冲区
                task.setStreamBuffer(generatedContent.toString());
                task.setStreamPosition(generatedContent.length());
                task.setLastStreamUpdate(LocalDateTime.now());
                if (generatedContent.length() % 500 < 50) {
                    taskMapper.updateById(task);
                }
            });

            task.setGeneratedTestCases(generated);
            task.setProgress(60);
            taskMapper.updateById(task);
            log.info("任务 {} 生成完成，内容长度: {}", task.getTaskId(), generated.length());

            // 阶段2: 评审
            AIModelConfig reviewerConfig = task.getReviewerModelConfigId() != null
                    ? aiModelConfigMapper.selectById(task.getReviewerModelConfigId()) : null;
            PromptConfig reviewerPrompt = task.getReviewerPromptConfigId() != null
                    ? promptConfigMapper.selectById(task.getReviewerPromptConfigId()) : null;

            if (reviewerConfig != null && reviewerPrompt != null) {
                task.setStatus("reviewing");
                task.setProgress(70);
                taskMapper.updateById(task);

                List<Map<String, String>> reviewMessages = new ArrayList<>();
                reviewMessages.add(Map.of("role", "system", "content", reviewerPrompt.getContent()));
                reviewMessages.add(Map.of("role", "user", "content",
                        "请评审以下测试用例，给出改进建议：\n\n" + generated));

                StringBuilder reviewContent = new StringBuilder();
                String reviewFeedback = aiModelCallService.chatCompletionStream(reviewerConfig, reviewMessages, chunk -> {
                    reviewContent.append(chunk);
                    task.setReviewFeedback(reviewContent.toString());
                    if (reviewContent.length() % 200 < 30) {
                        taskMapper.updateById(task);
                    }
                });

                task.setReviewFeedback(reviewFeedback);
                task.setProgress(80);
                taskMapper.updateById(task);
                log.info("任务 {} 评审完成", task.getTaskId());

                // 阶段3: 改进
                task.setStatus("revising");
                task.setProgress(85);
                taskMapper.updateById(task);

                List<Map<String, String>> reviseMessages = new ArrayList<>();
                reviseMessages.add(Map.of("role", "system", "content", systemPrompt));
                reviseMessages.add(Map.of("role", "user", "content",
                        "原始需求：\n" + task.getRequirementText()
                                + "\n\n评审意见：\n" + reviewFeedback
                                + "\n\n请根据评审意见改进以下测试用例，以JSON数组格式输出：\n" + generated));

                StringBuilder finalContent = new StringBuilder();
                String finalCases = aiModelCallService.chatCompletionStream(writerConfig, reviseMessages, chunk -> {
                    finalContent.append(chunk);
                    task.setFinalTestCases(finalContent.toString());
                    if (finalContent.length() % 200 < 30) {
                        taskMapper.updateById(task);
                    }
                });

                task.setFinalTestCases(finalCases);
                log.info("任务 {} 改进完成", task.getTaskId());
            } else {
                // 没有评审模型，直接使用生成结果
                task.setFinalTestCases(generated);
                log.info("任务 {} 跳过评审", task.getTaskId());
            }

            // 完成
            task.setStatus("completed");
            task.setProgress(100);
            task.setCompletedAt(LocalDateTime.now());
            taskMapper.updateById(task);
            log.info("任务 {} 完成", task.getTaskId());

        } catch (Exception e) {
            log.error("任务 {} 失败: {}", task.getTaskId(), e.getMessage(), e);
            task.setStatus("failed");
            task.setErrorMessage(e.getMessage());
            task.setCompletedAt(LocalDateTime.now());
            taskMapper.updateById(task);
        }
    }
}
