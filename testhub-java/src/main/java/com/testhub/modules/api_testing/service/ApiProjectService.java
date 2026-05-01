package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiProject;

/**
 * API项目管理服务接口
 */
public interface ApiProjectService extends IService<ApiProject> {

    IPage<ApiProject> getApiProjectPage(Long projectId, String keyword, long current, long size);

    ApiProject createApiProject(ApiProject apiProject);

    ApiProject updateApiProject(Long id, ApiProject apiProject);

    void deleteApiProject(Long id);
}
