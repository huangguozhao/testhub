package com.testhub.modules.configuration.controller;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.common.result.Result;
import com.testhub.modules.configuration.domain.AIModelConfig;
import com.testhub.modules.configuration.domain.GenerationConfig;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.mapper.AIModelConfigMapper;
import com.testhub.modules.configuration.mapper.GenerationConfigMapper;
import com.testhub.modules.configuration.mapper.PromptConfigMapper;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.Map;

@Tag(name = "需求分析配置检查", description = "检查AI用例生成所需的配置是否就绪")
@RestController
@RequestMapping("/api/requirement-analysis/config")
@RequiredArgsConstructor
public class RequirementAnalysisConfigController {

    private final AIModelConfigMapper aiModelConfigMapper;
    private final PromptConfigMapper promptConfigMapper;
    private final GenerationConfigMapper generationConfigMapper;

    @GetMapping("/check")
    @Operation(summary = "检查配置状态")
    public Result<Map<String, Object>> checkConfig() {
        Map<String, Object> result = new HashMap<>();

        // 检查用例编写模型
        AIModelConfig writerModel = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "testcase_writer")
                        .eq(AIModelConfig::getIsActive, true)
                        .last("LIMIT 1"));
        result.put("writer_model", buildModelStatus(writerModel));

        // 检查用例评审模型
        AIModelConfig reviewerModel = aiModelConfigMapper.selectOne(
                new LambdaQueryWrapper<AIModelConfig>()
                        .eq(AIModelConfig::getRole, "testcase_reviewer")
                        .eq(AIModelConfig::getIsActive, true)
                        .last("LIMIT 1"));
        result.put("reviewer_model", buildModelStatus(reviewerModel));

        // 检查用例编写提示词
        PromptConfig writerPrompt = promptConfigMapper.selectOne(
                new LambdaQueryWrapper<PromptConfig>()
                        .eq(PromptConfig::getPromptType, "writer")
                        .eq(PromptConfig::getIsActive, true)
                        .last("LIMIT 1"));
        result.put("writer_prompt", buildPromptStatus(writerPrompt));

        // 检查用例评审提示词
        PromptConfig reviewerPrompt = promptConfigMapper.selectOne(
                new LambdaQueryWrapper<PromptConfig>()
                        .eq(PromptConfig::getPromptType, "reviewer")
                        .eq(PromptConfig::getIsActive, true)
                        .last("LIMIT 1"));
        result.put("reviewer_prompt", buildPromptStatus(reviewerPrompt));

        // 检查生成行为配置
        GenerationConfig genConfig = generationConfigMapper.selectOne(
                new LambdaQueryWrapper<GenerationConfig>()
                        .eq(GenerationConfig::getIsActive, true)
                        .last("LIMIT 1"));
        result.put("generation_config", buildGenerationStatus(genConfig));

        return Result.success(result);
    }

    private Map<String, Object> buildModelStatus(AIModelConfig model) {
        Map<String, Object> status = new HashMap<>();
        if (model != null) {
            status.put("configured", true);
            status.put("enabled", model.getIsActive());
            status.put("name", model.getName());
            status.put("model_name", model.getModelName());
        } else {
            status.put("configured", false);
            status.put("enabled", false);
        }
        return status;
    }

    private Map<String, Object> buildPromptStatus(PromptConfig prompt) {
        Map<String, Object> status = new HashMap<>();
        if (prompt != null) {
            status.put("configured", true);
            status.put("enabled", prompt.getIsActive());
            status.put("name", prompt.getName());
        } else {
            status.put("configured", false);
            status.put("enabled", false);
        }
        return status;
    }

    private Map<String, Object> buildGenerationStatus(GenerationConfig config) {
        Map<String, Object> status = new HashMap<>();
        if (config != null) {
            status.put("configured", true);
            status.put("enabled", config.getIsActive());
            status.put("default_output_mode", config.getDefaultOutputMode());
            status.put("enable_auto_review", config.getEnableAutoReview());
            status.put("review_timeout", config.getReviewTimeout());
        } else {
            status.put("configured", false);
            status.put("enabled", false);
        }
        return status;
    }
}
