package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiTestSuite;

import java.util.List;

/**
 * API测试套件服务接口
 */
public interface ApiTestSuiteService extends IService<ApiTestSuite> {

    /**
     * 创建测试套件
     */
    ApiTestSuite createTestSuite(ApiTestSuite suite);

    /**
     * 更新测试套件
     */
    ApiTestSuite updateTestSuite(Long id, ApiTestSuite suite);

    /**
     * 删除测试套件
     */
    void deleteTestSuite(Long id);

    /**
     * 获取项目的所有测试套件
     */
    List<ApiTestSuite> getTestSuitesByProject(Long projectId);

    /**
     * 获取套件详情
     */
    ApiTestSuite getTestSuite(Long id);
}