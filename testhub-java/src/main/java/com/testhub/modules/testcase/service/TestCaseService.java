package com.testhub.modules.testcase.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.testcase.domain.TestCase;
import com.testhub.modules.testcase.domain.TestCaseStep;
import com.testhub.modules.testcase.dto.TestCaseDTO;

import java.util.List;

/**
 * 测试用例服务接口
 */
public interface TestCaseService extends IService<TestCase> {

    /**
     * 分页查询用例
     */
    IPage<TestCase> getTestCasePage(Long projectId, String keyword, String priority, String status, long current, long size);

    /**
     * 创建用例（含步骤）
     */
    TestCase createTestCase(TestCaseDTO dto, Long creatorId);

    /**
     * 更新用例（含步骤）
     */
    TestCase updateTestCase(Long id, TestCaseDTO dto, Long updaterId);

    /**
     * 删除用例
     */
    void deleteTestCase(Long id, Long userId);

    /**
     * 获取用例详情（含步骤）
     */
    TestCaseDTO getTestCaseDetail(Long id);

    /**
     * 获取用例的所有步骤
     */
    List<TestCaseStep> getTestCaseSteps(Long testCaseId);

    /**
     * 批量创建步骤
     */
    void createSteps(Long testCaseId, List<TestCaseDTO.StepDTO> steps, Long creatorId);

    /**
     * 更新步骤
     */
    void updateSteps(Long testCaseId, List<TestCaseDTO.StepDTO> steps, Long updaterId);

    /**
     * 删除所有步骤
     */
    void deleteAllSteps(Long testCaseId);
}
