package com.testhub.modules.ui_automation.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ui_automation.domain.UITestSuite;
import com.testhub.modules.ui_automation.mapper.UITestSuiteMapper;
import com.testhub.modules.ui_automation.service.UITestSuiteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * UI测试套件服务实现
 */
@Service
@RequiredArgsConstructor
public class UITestSuiteServiceImpl extends ServiceImpl<UITestSuiteMapper, UITestSuite> implements UITestSuiteService {

    @Override
    public IPage<UITestSuite> getSuitePage(Long projectId, String keyword, long current, long size) {
        Page<UITestSuite> page = new Page<>(current, size);
        return this.page(page);
    }

    @Override
    public UITestSuite createSuite(UITestSuite suite) {
        this.save(suite);
        return suite;
    }

    @Override
    public UITestSuite updateSuite(Long id, UITestSuite suite) {
        suite.setId(id);
        this.updateById(suite);
        return suite;
    }

    @Override
    public void deleteSuite(Long id) {
        this.removeById(id);
    }

    @Override
    public long countByProjectId(Long projectId) {
        if (projectId == null) {
            return this.count();
        }
        return this.lambdaQuery()
                .eq(UITestSuite::getProjectId, projectId)
                .count();
    }
}