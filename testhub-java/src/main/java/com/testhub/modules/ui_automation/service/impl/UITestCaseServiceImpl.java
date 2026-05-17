package com.testhub.modules.ui_automation.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ui_automation.domain.UITestCase;
import com.testhub.modules.ui_automation.mapper.UITestCaseMapper;
import com.testhub.modules.ui_automation.service.UITestCaseService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * UI测试用例服务实现
 */
@Service
@RequiredArgsConstructor
public class UITestCaseServiceImpl extends ServiceImpl<UITestCaseMapper, UITestCase> implements UITestCaseService {

    @Override
    public IPage<UITestCase> getTestCasePage(Long projectId, String keyword, long current, long size) {
        Page<UITestCase> page = new Page<>(current, size);
        return this.page(page);
    }

    @Override
    public UITestCase createTestCase(UITestCase testCase) {
        this.save(testCase);
        return testCase;
    }

    @Override
    public UITestCase updateTestCase(Long id, UITestCase testCase) {
        testCase.setId(id);
        this.updateById(testCase);
        return testCase;
    }

    @Override
    public void deleteTestCase(Long id) {
        this.removeById(id);
    }

    @Override
    public long countByProjectId(Long projectId) {
        if (projectId == null) {
            return this.count();
        }
        return this.lambdaQuery()
                .eq(UITestCase::getProjectId, projectId)
                .count();
    }
}