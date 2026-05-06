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

    /**
     * 按作用域和项目过滤环境列表
     * @param scope 作用域 (GLOBAL/LOCAL)，为null时返回所有
     * @param projectId 项目ID，scope=LOCAL时用于过滤
     * @return 环境列表（已填充 projectName 和 creator）
     */
    List<ApiEnvironment> listByScopeAndProject(String scope, Long projectId);

    /**
     * 激活环境（取消同作用域下其他环境的激活状态）
     * @param id 环境ID
     */
    void activate(Long id);

    /**
     * 获取所有激活的全局环境（供请求执行时使用）
     */
    List<ApiEnvironment> getActiveGlobalEnvironments();

    /**
     * 获取环境详情（填充瞬态字段）
     */
    ApiEnvironment getEnvironmentDetail(Long id);

    ApiEnvironment getDefaultEnvironment(Long projectId);

    void setDefaultEnvironment(Long id, Long projectId);
}
