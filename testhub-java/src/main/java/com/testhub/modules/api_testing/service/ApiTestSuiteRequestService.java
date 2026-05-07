package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;

import java.util.List;

public interface ApiTestSuiteRequestService extends IService<ApiTestSuiteRequest> {

    /**
     * 添加请求到测试套件
     */
    void addRequestsToSuite(Long suiteId, List<Long> requestIds);

    /**
     * 获取套件的所有请求
     */
    List<ApiTestSuiteRequest> getRequestsBySuite(Long suiteId);

    /**
     * 更新套件请求
     */
    void updateSuiteRequest(Long id, ApiTestSuiteRequest suiteRequest);

    /**
     * 删除套件请求
     */
    void deleteSuiteRequest(Long id);
}
