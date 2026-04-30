package com.testhub.modules.testsuite.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.testsuite.domain.TestSuite;
import com.testhub.modules.testsuite.domain.TestSuiteCase;
import com.testhub.modules.testsuite.dto.TestSuiteDTO;
import com.testhub.modules.testsuite.mapper.TestSuiteCaseMapper;
import com.testhub.modules.testsuite.mapper.TestSuiteMapper;
import com.testhub.modules.testsuite.service.TestSuiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * 测试套件服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TestSuiteServiceImpl extends ServiceImpl<TestSuiteMapper, TestSuite> implements TestSuiteService {

    private final TestSuiteCaseMapper testSuiteCaseMapper;

    @Override
    public IPage<TestSuite> getTestSuitePage(Long projectId, String keyword, long current, long size) {
        Page<TestSuite> page = new Page<>(current, size);
        LambdaQueryWrapper<TestSuite> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(TestSuite::getProjectId, projectId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(TestSuite::getName, keyword);
        }

        wrapper.orderByDesc(TestSuite::getCreatedAt);
        IPage<TestSuite> result = this.page(page, wrapper);

        // 统计每个套件的用例数
        for (TestSuite suite : result.getRecords()) {
            Long caseCount = testSuiteCaseMapper.selectCount(
                    new LambdaQueryWrapper<TestSuiteCase>()
                            .eq(TestSuiteCase::getSuiteId, suite.getId())
            );
            suite.setCaseCount(caseCount);
        }

        return result;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestSuite createTestSuite(TestSuiteDTO dto) {
        TestSuite suite = new TestSuite();
        suite.setProjectId(dto.getProjectId());
        suite.setName(dto.getName());
        suite.setDescription(dto.getDescription());
        suite.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);

        this.save(suite);

        // 添加用例关联
        if (dto.getCaseIds() != null && !dto.getCaseIds().isEmpty()) {
            addCases(suite.getId(), dto.getCaseIds());
        }

        log.info("创建测试套件: id={}, name={}", suite.getId(), suite.getName());
        return suite;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public TestSuite updateTestSuite(Long id, TestSuiteDTO dto) {
        TestSuite suite = this.getById(id);
        if (suite == null) {
            throw new RuntimeException("套件不存在: " + id);
        }

        suite.setName(dto.getName());
        suite.setDescription(dto.getDescription());
        suite.setSortOrder(dto.getSortOrder());

        this.updateById(suite);

        // 更新用例关联
        if (dto.getCaseIds() != null) {
            // 删除旧关联
            testSuiteCaseMapper.delete(
                    new LambdaQueryWrapper<TestSuiteCase>()
                            .eq(TestSuiteCase::getSuiteId, id)
            );
            // 添加新关联
            addCases(id, dto.getCaseIds());
        }

        log.info("更新测试套件: id={}", id);
        return suite;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteTestSuite(Long id) {
        // 删除用例关联
        testSuiteCaseMapper.delete(
                new LambdaQueryWrapper<TestSuiteCase>()
                        .eq(TestSuiteCase::getSuiteId, id)
        );
        // 删除套件
        this.removeById(id);
        log.info("删除测试套件: id={}", id);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addCases(Long suiteId, List<Long> caseIds) {
        int sortOrder = 0;
        for (Long caseId : caseIds) {
            TestSuiteCase relation = new TestSuiteCase();
            relation.setSuiteId(suiteId);
            relation.setTestCaseId(caseId);
            relation.setSortOrder(sortOrder++);
            testSuiteCaseMapper.insert(relation);
        }
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void removeCases(Long suiteId, List<Long> caseIds) {
        testSuiteCaseMapper.delete(
                new LambdaQueryWrapper<TestSuiteCase>()
                        .eq(TestSuiteCase::getSuiteId, suiteId)
                        .in(TestSuiteCase::getTestCaseId, caseIds)
        );
    }

    @Override
    public List<Long> getSuiteCaseIds(Long suiteId) {
        List<TestSuiteCase> cases = getSuiteCases(suiteId);
        return cases.stream()
                .map(TestSuiteCase::getTestCaseId)
                .toList();
    }

    @Override
    public List<TestSuiteCase> getSuiteCases(Long suiteId) {
        return testSuiteCaseMapper.selectList(
                new LambdaQueryWrapper<TestSuiteCase>()
                        .eq(TestSuiteCase::getSuiteId, suiteId)
                        .orderByAsc(TestSuiteCase::getSortOrder)
        );
    }
}
