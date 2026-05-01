package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiEnvironment;

import java.util.List;

/**
 * API环境服务接口
 */
public interface ApiEnvironmentService extends IService<ApiEnvironment> {

    ApiEnvironment createEnvironment(ApiEnvironment environment);

    ApiEnvironment updateEnvironment(Long id, ApiEnvironment environment);

    void deleteEnvironment(Long id);

    List<ApiEnvironment> getEnvironmentsByProject(Long projectId);

    ApiEnvironment getDefaultEnvironment(Long projectId);

    void setDefaultEnvironment(Long id, Long projectId);
}
