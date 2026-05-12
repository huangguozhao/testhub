package com.testhub.modules.ai_generation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ai_generation.domain.Project;
import com.testhub.modules.ai_generation.domain.TestCase;
import com.testhub.modules.ai_generation.domain.TestCaseStep;
import com.testhub.modules.ai_generation.dto.TestCaseDTO;
import com.testhub.modules.ai_generation.mapper.ProjectMapper;
import com.testhub.modules.ai_generation.mapper.TestCaseMapper;
import com.testhub.modules.ai_generation.mapper.TestCaseStepMapper;
import com.testhub.modules.ai_generation.service.TestCaseService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 测试用例服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TestCaseServiceImpl extends ServiceImpl<TestCaseMapper, TestCase> implements TestCaseService {

    private final TestCaseStepMapper testCaseStepMapper;
    private final ProjectMapper projectMapper;
    private final UserMapper userMapper;

    @Override
    public IPage<TestCase> getTestCasePage(Long projectId, String keyword, String priority, String status, long current, long size) {
        Page<TestCase> page = new Page<>(current, size);
        LambdaQueryWrapper<TestCase> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(TestCase::getProjectId, projectId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(TestCase::getTitle, keyword)
                    .or()
                    .like(TestCase::getDescription, keyword));
        }

        if (priority != null && !priority.isBlank()) {
            wrapper.eq(TestCase::getPriority, priority);
        }

        if (status != null && !status.isBlank()) {
            wrapper.eq(TestCase::getStatus, status);
        }

        wrapper.orderByDesc(TestCase::getCreatedAt);
        IPage<TestCase> result = this.page(page, wrapper);

        // 统计每个用例的步骤数，填充项目名称和创建者信息
        for (TestCase testCase : result.getRecords()) {
            Long stepCount = testCaseStepMapper.selectCount(
                    new LambdaQueryWrapper<TestCaseStep>()
                            .eq(TestCaseStep::getTestCaseId, testCase.getId())
            );
            testCase.setStepCount(stepCount);

            // 填充项目名称
            if (testCase.getProjectId() != null) {
                Project project = projectMapper.selectById(testCase.getProjectId());
                if (project != null) {
                    testCase.setProjectName(project.getName());
                }
            }

            // 填充创建者信息
            if (testCase.getCreatedBy() != null) {
                User creator = userMapper.selectById(testCase.getCreatedBy());
                if (creator != null) {
                    testCase.setCreatorUsername(creator.getUsername());
                    testCase.setCreatorRealName(creator.getRealName());
                }
            }
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestCase createTestCase(TestCaseDTO dto, Long creatorId) {
        TestCase testCase = new TestCase();
        testCase.setProjectId(dto.getProjectId());
        testCase.setTitle(dto.getTitle());
        testCase.setDescription(dto.getDescription());
        testCase.setPriority(dto.getPriority() != null ? dto.getPriority() : "medium");
        testCase.setType(dto.getType() != null ? dto.getType() : "functional");
        testCase.setStatus(dto.getStatus() != null ? dto.getStatus() : "draft");
        testCase.setPrecondition(dto.getPrecondition());
        testCase.setExpectedResult(dto.getExpectedResult());

        this.save(testCase);

        // 创建步骤
        if (dto.getSteps() != null && !dto.getSteps().isEmpty()) {
            createSteps(testCase.getId(), dto.getSteps(), creatorId);
        }

        log.info("创建测试用例: id={}, title={}", testCase.getId(), testCase.getTitle());
        return testCase;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestCase updateTestCase(Long id, TestCaseDTO dto, Long updaterId) {
        TestCase testCase = this.getById(id);
        if (testCase == null) {
            throw new RuntimeException("用例不存在: " + id);
        }

        testCase.setTitle(dto.getTitle());
        testCase.setDescription(dto.getDescription());
        testCase.setPriority(dto.getPriority());
        testCase.setType(dto.getType());
        testCase.setStatus(dto.getStatus());
        testCase.setPrecondition(dto.getPrecondition());
        testCase.setExpectedResult(dto.getExpectedResult());

        this.updateById(testCase);

        // 更新步骤
        if (dto.getSteps() != null) {
            deleteAllSteps(id);
            createSteps(id, dto.getSteps(), updaterId);
        }

        log.info("更新测试用例: id={}", id);
        return testCase;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTestCase(Long id, Long userId) {
        // 删除步骤
        deleteAllSteps(id);

        // 删除用例
        this.removeById(id);
        log.info("删除测试用例: id={}", id);
    }

    @Override
    public TestCaseDTO getTestCaseDetail(Long id) {
        TestCase testCase = this.getById(id);
        if (testCase == null) {
            throw new RuntimeException("用例不存在: " + id);
        }

        TestCaseDTO dto = new TestCaseDTO();
        dto.setId(testCase.getId());
        dto.setProjectId(testCase.getProjectId());
        dto.setTitle(testCase.getTitle());
        dto.setDescription(testCase.getDescription());
        dto.setPriority(testCase.getPriority());
        dto.setType(testCase.getType());
        dto.setStatus(testCase.getStatus());
        dto.setPrecondition(testCase.getPrecondition());
        dto.setExpectedResult(testCase.getExpectedResult());
        dto.setCreatedAt(testCase.getCreatedAt());

        // 填充项目名称
        if (testCase.getProjectId() != null) {
            Project project = projectMapper.selectById(testCase.getProjectId());
            if (project != null) {
                dto.setProjectName(project.getName());
            }
        }

        // 填充创建者信息
        if (testCase.getCreatedBy() != null) {
            User creator = userMapper.selectById(testCase.getCreatedBy());
            if (creator != null) {
                dto.setCreatorUsername(creator.getUsername());
                dto.setCreatorRealName(creator.getRealName());
            }
        }

        // 获取步骤
        List<TestCaseStep> steps = getTestCaseSteps(id);
        dto.setSteps(steps.stream().map(step -> {
            TestCaseDTO.StepDTO stepDTO = new TestCaseDTO.StepDTO();
            stepDTO.setId(step.getId());
            stepDTO.setStepNumber(step.getStepNumber());
            stepDTO.setDescription(step.getDescription());
            stepDTO.setExpectedResult(step.getExpectedResult());
            return stepDTO;
        }).toList());

        return dto;
    }

    @Override
    public List<TestCaseStep> getTestCaseSteps(Long testCaseId) {
        return testCaseStepMapper.selectList(
                new LambdaQueryWrapper<TestCaseStep>()
                        .eq(TestCaseStep::getTestCaseId, testCaseId)
                        .orderByAsc(TestCaseStep::getStepNumber)
        );
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void createSteps(Long testCaseId, List<TestCaseDTO.StepDTO> steps, Long creatorId) {
        for (int i = 0; i < steps.size(); i++) {
            TestCaseDTO.StepDTO stepDTO = steps.get(i);
            TestCaseStep step = new TestCaseStep();
            step.setTestCaseId(testCaseId);
            step.setStepNumber(stepDTO.getStepNumber() != null ? stepDTO.getStepNumber() : i + 1);
            step.setDescription(stepDTO.getDescription());
            step.setExpectedResult(stepDTO.getExpectedResult());
            testCaseStepMapper.insert(step);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSteps(Long testCaseId, List<TestCaseDTO.StepDTO> steps, Long updaterId) {
        deleteAllSteps(testCaseId);
        createSteps(testCaseId, steps, updaterId);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteAllSteps(Long testCaseId) {
        testCaseStepMapper.delete(
                new LambdaQueryWrapper<TestCaseStep>()
                        .eq(TestCaseStep::getTestCaseId, testCaseId)
        );
    }
}
