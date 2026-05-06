package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.domain.ApiProject;
import com.testhub.modules.api_testing.mapper.ApiEnvironmentMapper;
import com.testhub.modules.api_testing.service.ApiEnvironmentService;
import com.testhub.modules.api_testing.service.ApiProjectService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
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

    private final ApiProjectService apiProjectService;
    private final UserMapper userMapper;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiEnvironment createEnvironment(ApiEnvironment environment) {
        // 验证: scope=LOCAL 时 projectId 不能为空
        if ("LOCAL".equals(environment.getScope()) && environment.getProjectId() == null) {
            throw new RuntimeException("局部环境必须关联项目");
        }
        // scope=GLOBAL 时 projectId 设为 null
        if ("GLOBAL".equals(environment.getScope())) {
            environment.setProjectId(null);
        }
        // 如果设置为默认环境，先取消其他默认
        if (Boolean.TRUE.equals(environment.getIsDefault())) {
            cancelDefaultEnvironment(environment.getProjectId());
        }
        this.save(environment);
        log.info("创建API环境: id={}, name={}, scope={}", environment.getId(), environment.getName(), environment.getScope());
        return environment;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public ApiEnvironment updateEnvironment(Long id, ApiEnvironment environment) {
        environment.setId(id);

        // 验证: scope=LOCAL 时 projectId 不能为空
        if ("LOCAL".equals(environment.getScope()) && environment.getProjectId() == null) {
            throw new RuntimeException("局部环境必须关联项目");
        }
        // scope=GLOBAL 时 projectId 设为 null
        if ("GLOBAL".equals(environment.getScope())) {
            environment.setProjectId(null);
        }

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
        List<ApiEnvironment> list = this.list(new LambdaQueryWrapper<ApiEnvironment>()
                .eq(ApiEnvironment::getProjectId, projectId)
                .orderByAsc(ApiEnvironment::getIsDefault));
        enrichEnvironments(list);
        return list;
    }

    @Override
    public List<ApiEnvironment> listByScopeAndProject(String scope, Long projectId) {
        LambdaQueryWrapper<ApiEnvironment> wrapper = new LambdaQueryWrapper<>();

        if (scope != null && !scope.isEmpty()) {
            wrapper.eq(ApiEnvironment::getScope, scope);
        }
        if (projectId != null) {
            wrapper.eq(ApiEnvironment::getProjectId, projectId);
        }

        wrapper.orderByDesc(ApiEnvironment::getCreatedAt);
        List<ApiEnvironment> list = this.list(wrapper);
        enrichEnvironments(list);
        return list;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void activate(Long id) {
        ApiEnvironment environment = this.getById(id);
        if (environment == null) {
            throw new RuntimeException("环境不存在: " + id);
        }

        // 取消同作用域下其他环境的激活状态
        if ("GLOBAL".equals(environment.getScope())) {
            // 全局环境：取消所有 scope=GLOBAL 的激活状态
            List<ApiEnvironment> globalEnvs = this.list(new LambdaQueryWrapper<ApiEnvironment>()
                    .eq(ApiEnvironment::getScope, "GLOBAL")
                    .eq(ApiEnvironment::getIsActive, true));
            for (ApiEnvironment env : globalEnvs) {
                env.setIsActive(false);
                this.updateById(env);
            }
        } else if ("LOCAL".equals(environment.getScope()) && environment.getProjectId() != null) {
            // 项目级环境：取消同项目下所有 scope=LOCAL 的激活状态
            List<ApiEnvironment> localEnvs = this.list(new LambdaQueryWrapper<ApiEnvironment>()
                    .eq(ApiEnvironment::getScope, "LOCAL")
                    .eq(ApiEnvironment::getProjectId, environment.getProjectId())
                    .eq(ApiEnvironment::getIsActive, true));
            for (ApiEnvironment env : localEnvs) {
                env.setIsActive(false);
                this.updateById(env);
            }
        }

        // 设置目标环境为激活
        environment.setIsActive(true);
        this.updateById(environment);
        log.info("激活环境: id={}, name={}, scope={}", id, environment.getName(), environment.getScope());
    }

    @Override
    public List<ApiEnvironment> getActiveGlobalEnvironments() {
        List<ApiEnvironment> list = this.list(new LambdaQueryWrapper<ApiEnvironment>()
                .eq(ApiEnvironment::getScope, "GLOBAL")
                .eq(ApiEnvironment::getIsActive, true));
        return list;
    }

    @Override
    public ApiEnvironment getEnvironmentDetail(Long id) {
        ApiEnvironment environment = this.getById(id);
        if (environment != null) {
            enrichEnvironment(environment);
        }
        return environment;
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

    /**
     * 批量填充环境的瞬态字段
     */
    private void enrichEnvironments(List<ApiEnvironment> environments) {
        if (environments == null) return;
        for (ApiEnvironment env : environments) {
            enrichEnvironment(env);
        }
    }

    /**
     * 填充单个环境的瞬态字段（projectName、creator）
     */
    private void enrichEnvironment(ApiEnvironment env) {
        if (env == null) return;

        // 填充项目名称
        if (env.getProjectId() != null) {
            try {
                ApiProject project = apiProjectService.getById(env.getProjectId());
                if (project != null) {
                    env.setProjectName(project.getName());
                }
            } catch (Exception e) {
                log.warn("获取项目信息失败: projectId={}", env.getProjectId());
            }
        }

        // 填充创建者信息
        if (env.getCreatedBy() != null) {
            try {
                User user = userMapper.selectById(env.getCreatedBy());
                if (user != null) {
                    // 只保留必要字段，避免泄露密码等敏感信息
                    User safeUser = new User();
                    safeUser.setId(user.getId());
                    safeUser.setUsername(user.getUsername());
                    safeUser.setEmail(user.getEmail());
                    env.setCreator(safeUser);
                }
            } catch (Exception e) {
                log.warn("获取创建者信息失败: userId={}", env.getCreatedBy());
            }
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
