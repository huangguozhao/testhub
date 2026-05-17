package com.testhub.modules.ui_automation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ui_automation.domain.UITestCase;

/**
 * UI测试用例服务接口
 */
public interface UITestCaseService extends IService<UITestCase> {

    IPage<UITestCase> getTestCasePage(Long projectId, String keyword, long current, long size);

    UITestCase createTestCase(UITestCase testCase);

    UITestCase updateTestCase(Long id, UITestCase testCase);

    void deleteTestCase(Long id);

    long countByProjectId(Long projectId);
}