package com.testhub.modules.ai_generation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ai_generation.domain.TestSuite;
import com.testhub.modules.ai_generation.domain.TestSuiteCase;
import com.testhub.modules.ai_generation.dto.TestSuiteDTO;

import java.util.List;

/**
 * 测试套件服务接口
 */
public interface TestSuiteService extends IService<TestSuite> {

    /**
     * 分页查询套件
     */
    IPage<TestSuite> getTestSuitePage(Long projectId, String keyword, long current, long size);

    /**
     * 创建套件
     */
    TestSuite createTestSuite(TestSuiteDTO dto);

    /**
     * 更新套件
     */
    TestSuite updateTestSuite(Long id, TestSuiteDTO dto);

    /**
     * 删除套件
     */
    void deleteTestSuite(Long id);

    /**
     * 添加用例到套件
     */
    void addCases(Long suiteId, List<Long> caseIds);

    /**
     * 从套件移除用例
     */
    void removeCases(Long suiteId, List<Long> caseIds);

    /**
     * 获取套件的用例ID列表
     */
    List<Long> getSuiteCaseIds(Long suiteId);

    /**
     * 获取套件的所有用例关联
     */
    List<TestSuiteCase> getSuiteCases(Long suiteId);
}
