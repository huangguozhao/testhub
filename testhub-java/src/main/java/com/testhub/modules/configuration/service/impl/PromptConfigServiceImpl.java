package com.testhub.modules.configuration.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.configuration.domain.PromptConfig;
import com.testhub.modules.configuration.dto.PromptConfigDTO;
import com.testhub.modules.configuration.mapper.PromptConfigMapper;
import com.testhub.modules.configuration.service.PromptConfigService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class PromptConfigServiceImpl extends ServiceImpl<PromptConfigMapper, PromptConfig>
        implements PromptConfigService {

    @Value("${app.docs-path:docs}")
    private String docsPath;

    @Override
    public IPage<PromptConfig> getConfigPage(String promptType, Boolean isActive, long current, long size) {
        Page<PromptConfig> page = new Page<>(current, size);
        LambdaQueryWrapper<PromptConfig> wrapper = new LambdaQueryWrapper<>();

        if (promptType != null && !promptType.isBlank()) {
            wrapper.eq(PromptConfig::getPromptType, promptType);
        }
        if (isActive != null) {
            wrapper.eq(PromptConfig::getIsActive, isActive);
        }

        wrapper.orderByDesc(PromptConfig::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public PromptConfig getConfigDetail(Long id) {
        return this.getById(id);
    }

    @Override
    public PromptConfig createConfig(PromptConfigDTO dto) {
        PromptConfig config = new PromptConfig();
        config.setName(dto.getName());
        config.setPromptType(dto.getPromptType());
        config.setContent(dto.getContent());
        config.setIsActive(dto.getIsActive() != null ? dto.getIsActive() : true);

        this.save(config);
        log.info("创建提示词配置: id={}, name={}", config.getId(), config.getName());
        return config;
    }

    @Override
    public PromptConfig updateConfig(Long id, PromptConfigDTO dto) {
        PromptConfig config = this.getById(id);
        if (config == null) {
            throw new RuntimeException("提示词配置不存在: " + id);
        }

        config.setName(dto.getName());
        config.setPromptType(dto.getPromptType());
        config.setContent(dto.getContent());
        if (dto.getIsActive() != null) {
            config.setIsActive(dto.getIsActive());
        }

        this.updateById(config);
        log.info("更新提示词配置: id={}", id);
        return config;
    }

    @Override
    public void deleteConfig(Long id) {
        this.removeById(id);
        log.info("删除提示词配置: id={}", id);
    }

    @Override
    public Map<String, String> loadDefaults() {
        Map<String, String> defaults = new HashMap<>();

        defaults.put("writer", readFileOrDefault("tester.md", getDefaultWriterPrompt()));
        defaults.put("reviewer", readFileOrDefault("tester_pro.md", getDefaultReviewerPrompt()));

        return defaults;
    }

    private String readFileOrDefault(String fileName, String defaultContent) {
        try {
            Path filePath = Paths.get(docsPath, fileName);
            if (Files.exists(filePath)) {
                return Files.readString(filePath);
            }
        } catch (IOException e) {
            log.warn("读取默认提示词文件失败: {}", fileName, e);
        }
        return defaultContent;
    }

    private String getDefaultWriterPrompt() {
        return "你是一位拥有10年经验的资深测试用例编写专家，能够根据需求精确生成高质量的测试用例。\n\n"
             + "# 核心目标\n"
             + "生成高覆盖率、颗粒度细致的测试用例，确保不遗漏任何功能逻辑、异常场景和边界条件。\n\n"
             + "# 角色设定\n"
             + "1. 身份：精通全栈测试（Web/App/API）的高级QA专家\n"
             + "2. 测试风格：破坏性测试思维，善于发现潜在Bug\n"
             + "3. 输出原则：详细、独立、可执行";
    }

    private String getDefaultReviewerPrompt() {
        return "你是一位资深的测试用例评审专家，负责对测试用例进行质量评审。\n\n"
             + "# 评审标准\n"
             + "1. 覆盖率：是否覆盖了所有功能点和边界条件\n"
             + "2. 准确性：步骤是否清晰、可执行\n"
             + "3. 独立性：每条用例是否独立验证一个测试点\n"
             + "4. 规范性：是否符合用例编写规范";
    }
}
