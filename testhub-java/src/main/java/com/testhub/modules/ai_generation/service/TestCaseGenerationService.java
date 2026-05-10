package com.testhub.modules.ai_generation.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.modules.ai_generation.domain.TestCaseGenerationTask;
import com.testhub.modules.ai_generation.mapper.TestCaseGenerationTaskMapper;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.mapper.AIModelConfigMapper;
import com.testhub.modules.configuration.mapper.PromptConfigMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Lazy;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.*;

@Slf4j
@Service
public class TestCaseGenerationService {

    private final TestCaseGenerationTaskMapper taskMapper;
    private final AIModelConfigMapper aiModelConfigMapper;
    private final PromptConfigMapper promptConfigMapper;
    private final AIModelCallService aiModelCallService;
    private final TestCaseGenerationService self;

    public TestCaseGenerationService(TestCaseGenerationTaskMapper taskMapper,
                                     AIModelConfigMapper aiModelConfigMapper,
                                     PromptConfigMapper promptConfigMapper,
                                     AIModelCallService aiModelCallService,
                                     @Lazy @Autowired TestCaseGenerationService self) {
        this.taskMapper = taskMapper;
        this.aiModelConfigMapper = aiModelConfigMapper;
        this.promptConfigMapper = promptConfigMapper;
        this.aiModelCallService = aiModelCallService;
        this.self = self;
    }

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
        task.setReviewPosition(0);
        task.setFinalPosition(0);
        task.setCreatedBy(userId);

        // 关联项目
        Object projectObj = request.get("project");
        if (projectObj != null) {
            task.setProjectId(Long.valueOf(projectObj.toString()));
        }

        // 查找 writer 模型配置
        AIModelConfig writerConfig = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "writer")
                        .eq(AIModelConfig::getIsActive, true)
                        .last("LIMIT 1"));
        if (writerConfig != null) {
            task.setWriterModelConfigId(writerConfig.getId());
        }

        // 查找 reviewer 模型配置
        AIModelConfig reviewerConfig = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "reviewer")
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

        // 启动后台生成（通过 self 调用以触发 @Async 代理）
        self.executeGeneration(task.getId());

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
        log.info("异步生成任务开始执行: taskId={}, thread={}", taskId, Thread.currentThread().getName());
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

            String systemPrompt = writerPrompt != null ? writerPrompt.getContent()
                    : "你是一位资深的测试用例编写专家，能够根据需求精确生成高质量的测试用例。";

            task.setProgress(30);
            taskMapper.updateById(task);

            // 阶段1: 流式生成（支持分批续写）
            StringBuilder generatedContent = new StringBuilder();
            generateWithBatching(writerConfig, systemPrompt,
                    "请根据以下需求生成详细的测试用例：\n\n" + task.getRequirementText()
                            + "\n\n请以JSON数组格式输出，每个用例包含：case_id, title, priority, precondition, test_steps, expected_result",
                    generatedContent, task, "stream");

            String generated = generatedContent.toString();
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

                StringBuilder reviewContent = new StringBuilder();
                generateWithBatching(reviewerConfig, reviewerPrompt.getContent(),
                        "请评审以下测试用例，给出改进建议：\n\n" + generated,
                        reviewContent, task, "review");

                String reviewFeedback = reviewContent.toString();
                task.setReviewFeedback(reviewFeedback);
                task.setProgress(80);
                taskMapper.updateById(task);
                log.info("任务 {} 评审完成", task.getTaskId());

                // 阶段3: 改进（支持分批续写）
                task.setStatus("revising");
                task.setProgress(85);
                taskMapper.updateById(task);

                StringBuilder finalContent = new StringBuilder();
                generateWithBatching(writerConfig, systemPrompt,
                        "原始需求：\n" + task.getRequirementText()
                                + "\n\n评审意见：\n" + reviewFeedback
                                + "\n\n请根据评审意见改进以下测试用例，以JSON数组格式输出：\n" + generated,
                        finalContent, task, "final");

                String finalCases = finalContent.toString();
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

    /**
     * 分批生成：检测JSON是否完整，不完整则自动续写
     *
     * @param config    AI模型配置
     * @param sysPrompt 系统提示词
     * @param userMsg   用户消息
     * @param buffer    内容累加器
     * @param task      任务实体（用于更新DB）
     * @param phase     阶段标识: stream/review/final
     */
    private void generateWithBatching(AIModelConfig config, String sysPrompt, String userMsg,
                                      StringBuilder buffer, TestCaseGenerationTask task, String phase) {
        int maxBatches = 5; // 最多续写5轮
        List<Map<String, String>> messages = new ArrayList<>();
        messages.add(Map.of("role", "system", "content", sysPrompt));
        messages.add(Map.of("role", "user", "content", userMsg));

        for (int batch = 0; batch < maxBatches; batch++) {
            int startPos = buffer.length();

            // 流式调用，实时更新DB
            aiModelCallService.chatCompletionStream(config, messages, chunk -> {
                buffer.append(chunk);
                switch (phase) {
                    case "stream" -> {
                        task.setStreamBuffer(buffer.toString());
                        task.setStreamPosition(buffer.length());
                    }
                    case "review" -> {
                        task.setReviewFeedback(buffer.toString());
                        task.setReviewPosition(buffer.length());
                    }
                    case "final" -> {
                        task.setFinalTestCases(buffer.toString());
                        task.setFinalPosition(buffer.length());
                    }
                }
                task.setLastStreamUpdate(LocalDateTime.now());
                if (buffer.length() % 500 < 50) {
                    taskMapper.updateById(task);
                }
            });

            String content = buffer.toString();
            log.info("任务 {} {}阶段第{}批完成, 总长度={}", task.getTaskId(), phase, batch + 1, content.length());

            // 检查JSON数组是否完整
            if (isJsonArrayComplete(content)) {
                log.info("任务 {} {}阶段JSON完整, 共{}批", task.getTaskId(), phase, batch + 1);
                break;
            }

            // JSON不完整，追加续写消息
            if (batch < maxBatches - 1) {
                log.info("任务 {} {}阶段JSON不完整, 准备续写第{}批", task.getTaskId(), phase, batch + 2);
                messages = new ArrayList<>();
                messages.add(Map.of("role", "system", "content", sysPrompt));
                messages.add(Map.of("role", "user", "content",
                        userMsg + "\n\n注意：你之前的输出被截断了，当前已生成的内容如下（可能末尾不完整）：\n"
                                + content
                                + "\n\n请从截断处继续输出，不要重复已有内容，直接继续JSON数组的后续部分，直到数组闭合。"));
            }
        }

        // 最终DB更新
        switch (phase) {
            case "stream" -> {
                task.setStreamBuffer(buffer.toString());
                task.setStreamPosition(buffer.length());
            }
            case "review" -> {
                task.setReviewFeedback(buffer.toString());
                task.setReviewPosition(buffer.length());
            }
            case "final" -> {
                task.setFinalTestCases(buffer.toString());
                task.setFinalPosition(buffer.length());
            }
        }
        taskMapper.updateById(task);
    }

    /**
     * 检查JSON数组是否完整（找到闭合的 ]）
     */
    private boolean isJsonArrayComplete(String content) {
        if (content == null || content.isBlank()) return false;
        String trimmed = content.trim();
        // 必须以 ] 结尾（允许后面有空白）
        if (!trimmed.endsWith("]")) return false;
        // 简单括号匹配：统计 [ 和 ] 的数量
        int open = 0, close = 0;
        boolean inString = false, escaped = false;
        for (char c : trimmed.toCharArray()) {
            if (escaped) { escaped = false; continue; }
            if (c == '\\') { escaped = true; continue; }
            if (c == '"') { inString = !inString; continue; }
            if (inString) continue;
            if (c == '[') open++;
            else if (c == ']') close++;
        }
        return open > 0 && open == close;
    }
}
