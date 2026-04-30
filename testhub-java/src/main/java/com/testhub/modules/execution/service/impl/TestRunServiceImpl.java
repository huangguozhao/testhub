package com.testhub.modules.execution.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.execution.domain.TestRun;
import com.testhub.modules.execution.domain.TestRunCase;
import com.testhub.modules.execution.mapper.TestRunCaseMapper;
import com.testhub.modules.execution.mapper.TestRunMapper;
import com.testhub.modules.execution.service.TestRunService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 测试执行服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TestRunServiceImpl extends ServiceImpl<TestRunMapper, TestRun> implements TestRunService {

    private final TestRunCaseMapper testRunCaseMapper;

    @Override
    public IPage<TestRun> getTestRunPage(Long planId, Long suiteId, String status, long current, long size) {
        Page<TestRun> page = new Page<>(current, size);
        LambdaQueryWrapper<TestRun> wrapper = new LambdaQueryWrapper<>();

        if (planId != null) {
            wrapper.eq(TestRun::getPlanId, planId);
        }

        if (suiteId != null) {
            wrapper.eq(TestRun::getSuiteId, suiteId);
        }

        if (status != null && !status.isBlank()) {
            wrapper.eq(TestRun::getStatus, status);
        }

        wrapper.orderByDesc(TestRun::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestRun createTestRun(Long planId, Long suiteId, Long executorId) {
        TestRun run = new TestRun();
        run.setPlanId(planId);
        run.setSuiteId(suiteId);
        run.setExecutorId(executorId);
        run.setStatus("pending");

        this.save(run);
        log.info("创建测试执行记录: id={}", run.getId());
        return run;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestRun startRun(Long runId) {
        TestRun run = this.getById(runId);
        if (run == null) {
            throw new RuntimeException("执行记录不存在: " + runId);
        }

        run.setStatus("running");
        run.setStartedAt(LocalDateTime.now());
        this.updateById(run);

        log.info("开始执行: runId={}", runId);
        return run;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestRun completeRun(Long runId, int passedCount, int failedCount) {
        TestRun run = this.getById(runId);
        if (run == null) {
            throw new RuntimeException("执行记录不存在: " + runId);
        }

        run.setStatus(failedCount > 0 ? "failed" : "completed");
        run.setCompletedAt(LocalDateTime.now());
        run.setPassedCount(passedCount);
        run.setFailedCount(failedCount);
        this.updateById(run);

        log.info("完成执行: runId={}, passed={}, failed={}", runId, passedCount, failedCount);
        return run;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateCaseResult(Long runId, Long caseId, String status, String result, String bugIds, Long executorId) {
        TestRunCase runCase = new TestRunCase();
        runCase.setRunId(runId);
        runCase.setTestCaseId(caseId);
        runCase.setStatus(status);
        runCase.setResult(result);
        runCase.setBugIds(bugIds);
        runCase.setExecutorId(executorId);
        runCase.setExecutedAt(LocalDateTime.now());

        testRunCaseMapper.insert(runCase);
        log.info("更新用例执行结果: runId={}, caseId={}, status={}", runId, caseId, status);
    }

    @Override
    public List<TestRunCase> getRunCases(Long runId) {
        return testRunCaseMapper.selectList(
                new LambdaQueryWrapper<TestRunCase>()
                        .eq(TestRunCase::getRunId, runId)
                        .orderByAsc(TestRunCase::getCreatedAt)
        );
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTestRun(Long id) {
        // 删除用例执行记录
        testRunCaseMapper.delete(
                new LambdaQueryWrapper<TestRunCase>()
                        .eq(TestRunCase::getRunId, id)
        );
        // 删除执行记录
        this.removeById(id);
        log.info("删除测试执行记录: id={}", id);
    }
}
