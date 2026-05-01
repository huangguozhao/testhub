package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.mapper.ApiEnvironmentMapper;
import com.testhub.modules.api_testing.service.ApiEnvironmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/**
 * API环境服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiEnvironmentServiceImpl extends ServiceImpl<ApiEnvironmentMapper, ApiEnvironment> implements ApiEnvironmentService {

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiEnvironment createEnvironment(ApiEnvironment environment) {
        // 如果设置为默认环境，先取消其他默认
        if (Boolean.TRUE.equals(environment.getIsDefault())) {
            cancelDefaultEnvironment(environment.getProjectId());
        }
        this.save(environment);
        log.info("创建API环境: id={}, name={}", environment.getId(), environment.getName());
        return environment;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiEnvironment updateEnvironment(Long id, ApiEnvironment environment) {
        environment.setId(id);

        // 如果设置为默认环境，先取消其他默认
        if (Boolean.TRUE.equals(environment.getIsDefault())) {
            cancelDefaultEnvironment(environment.getProjectId());
        }

        this.updateById(environment);
        log.info("更新API环境: id={}", id);
        return environment;
    }

    @Override
    public void deleteEnvironment(Long id) {
        this.removeById(id);
        log.info("删除API环境: id={}", id);
    }

    @Override
    public List<ApiEnvironment> getEnvironmentsByProject(Long projectId) {
        return this.list(new LambdaQueryWrapper<ApiEnvironment>()
                .eq(ApiEnvironment::getProjectId, projectId)
                .orderByAsc(ApiEnvironment::getIsDefault));
    }

    @Override
    public ApiEnvironment getDefaultEnvironment(Long projectId) {
        return this.getOne(new LambdaQueryWrapper<ApiEnvironment>()
                .eq(ApiEnvironment::getProjectId, projectId)
                .eq(ApiEnvironment::getIsDefault, true));
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void setDefaultEnvironment(Long id, Long projectId) {
        // 取消项目下所有默认环境
        cancelDefaultEnvironment(projectId);

        // 设置指定环境为默认
        ApiEnvironment environment = this.getById(id);
        if (environment != null) {
            environment.setIsDefault(true);
            this.updateById(environment);
        }
    }

    private void cancelDefaultEnvironment(Long projectId) {
        // 先查询所有默认环境
        List<ApiEnvironment> defaultEnvs = this.list(
                new LambdaQueryWrapper<ApiEnvironment>()
                        .eq(ApiEnvironment::getProjectId, projectId)
                        .eq(ApiEnvironment::getIsDefault, true)
        );
        // 取消默认状态
        for (ApiEnvironment env : defaultEnvs) {
            env.setIsDefault(false);
            this.updateById(env);
        }
    }
}
