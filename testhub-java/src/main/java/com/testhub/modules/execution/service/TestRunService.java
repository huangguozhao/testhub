package com.testhub.modules.execution.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.execution.domain.TestRun;
import com.testhub.modules.execution.domain.TestRunCase;
import com.testhub.modules.execution.dto.TestRunDTO;

import java.util.List;

/**
 * 测试执行服务接口
 */
public interface TestRunService extends IService<TestRun> {

    /**
     * 分页查询执行记录
     */
    IPage<TestRun> getTestRunPage(Long planId, Long suiteId, String status, long current, long size);

    /**
     * 创建执行记录
     */
    TestRun createTestRun(Long planId, Long suiteId, Long executorId);

    /**
     * 开始执行
     */
    TestRun startRun(Long runId);

    /**
     * 完成执行
     */
    TestRun completeRun(Long runId, int passedCount, int failedCount);

    /**
     * 更新用例执行结果
     */
    void updateCaseResult(Long runId, Long caseId, String status, String result, String bugIds, Long executorId);

    /**
     * 获取执行的用例列表
     */
    List<TestRunCase> getRunCases(Long runId);

    /**
     * 删除执行记录
     */
    void deleteTestRun(Long id);
}
