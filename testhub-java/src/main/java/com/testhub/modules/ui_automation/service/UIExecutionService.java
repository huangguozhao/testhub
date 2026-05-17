package com.testhub.modules.ui_automation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ui_automation.domain.UIExecution;

/**
 * UI执行记录服务接口
 */
public interface UIExecutionService extends IService<UIExecution> {

    IPage<UIExecution> getExecutionPage(Long projectId, String keyword, long current, long size);

    UIExecution createExecution(UIExecution execution);

    UIExecution updateExecution(Long id, UIExecution execution);

    void deleteExecution(Long id);

    long countByProjectId(Long projectId);
}