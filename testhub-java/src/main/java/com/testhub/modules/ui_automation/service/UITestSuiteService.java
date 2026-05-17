package com.testhub.modules.ui_automation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ui_automation.domain.UITestSuite;

/**
 * UI测试套件服务接口
 */
public interface UITestSuiteService extends IService<UITestSuite> {

    IPage<UITestSuite> getSuitePage(Long projectId, String keyword, long current, long size);

    UITestSuite createSuite(UITestSuite suite);

    UITestSuite updateSuite(Long id, UITestSuite suite);

    void deleteSuite(Long id);

    long countByProjectId(Long projectId);
}