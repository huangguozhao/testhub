package com.testhub.modules.ui_automation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ui_automation.domain.UIProject;

/**
 * UI项目服务接口
 */
public interface UIProjectService extends IService<UIProject> {

    IPage<UIProject> getProjectPage(Long projectId, String keyword, long current, long size);

    UIProject createProject(UIProject project);

    UIProject updateProject(Long id, UIProject project);

    void deleteProject(Long id);

    long countByProjectId(Long projectId);
}