package com.testhub.modules.ui_automation.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ui_automation.domain.UIExecution;
import com.testhub.modules.ui_automation.mapper.UIExecutionMapper;
import com.testhub.modules.ui_automation.service.UIExecutionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * UI执行记录服务实现
 */
@Service
@RequiredArgsConstructor
public class UIExecutionServiceImpl extends ServiceImpl<UIExecutionMapper, UIExecution> implements UIExecutionService {

    @Override
    public IPage<UIExecution> getExecutionPage(Long projectId, String keyword, long current, long size) {
        Page<UIExecution> page = new Page<>(current, size);
        return this.page(page);
    }

    @Override
    public UIExecution createExecution(UIExecution execution) {
        this.save(execution);
        return execution;
    }

    @Override
    public UIExecution updateExecution(Long id, UIExecution execution) {
        execution.setId(id);
        this.updateById(execution);
        return execution;
    }

    @Override
    public void deleteExecution(Long id) {
        this.removeById(id);
    }

    @Override
    public long countByProjectId(Long projectId) {
        if (projectId == null) {
            return this.count();
        }
        return this.lambdaQuery()
                .eq(UIExecution::getSuiteId, projectId)
                .count();
    }
}