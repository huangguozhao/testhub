package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;
import com.testhub.modules.api_testing.mapper.ApiTestSuiteMapper;
import com.testhub.modules.api_testing.mapper.ApiTestSuiteRequestMapper;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * API测试套件服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiTestSuiteServiceImpl extends ServiceImpl<ApiTestSuiteMapper, ApiTestSuite> implements ApiTestSuiteService {

    private final ApiTestSuiteRequestMapper apiTestSuiteRequestMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiTestSuite createTestSuite(ApiTestSuite suite) {
        this.save(suite);
        log.info("创建API测试套件: id={}, name={}", suite.getId(), suite.getName());
        return suite;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiTestSuite updateTestSuite(Long id, ApiTestSuite suite) {
        suite.setId(id);
        this.updateById(suite);
        log.info("更新API测试套件: id={}", id);
        return suite;
    }

    @Override
    public void deleteTestSuite(Long id) {
        this.removeById(id);
        log.info("删除API测试套件: id={}", id);
    }

    @Override
    public List<ApiTestSuite> getTestSuitesByProject(Long projectId) {
        List<ApiTestSuite> suites = this.list(new LambdaQueryWrapper<ApiTestSuite>()
                .eq(ApiTestSuite::getProjectId, projectId)
                .orderByDesc(ApiTestSuite::getCreatedAt));

        // 统计每个套件的请求数量
        for (ApiTestSuite suite : suites) {
            Long count = apiTestSuiteRequestMapper.selectCount(
                    new LambdaQueryWrapper<ApiTestSuiteRequest>()
                            .eq(ApiTestSuiteRequest::getTestSuiteId, suite.getId())
            );
            suite.setRequestCount(count != null ? count.intValue() : 0);
        }

        return suites;
    }

    @Override
    public ApiTestSuite getTestSuite(Long id) {
        return this.getById(id);
    }
}