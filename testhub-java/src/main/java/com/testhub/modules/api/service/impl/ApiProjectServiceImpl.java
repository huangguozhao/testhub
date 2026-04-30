package com.testhub.modules.api.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api.domain.ApiProject;
import com.testhub.modules.api.mapper.ApiProjectMapper;
import com.testhub.modules.api.service.ApiProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * API项目管理服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiProjectServiceImpl extends ServiceImpl<ApiProjectMapper, ApiProject> implements ApiProjectService {

    @Override
    public IPage<ApiProject> getApiProjectPage(Long projectId, String keyword, long current, long size) {
        Page<ApiProject> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiProject> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(ApiProject::getProjectId, projectId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(ApiProject::getName, keyword)
                    .or()
                    .like(ApiProject::getDescription, keyword));
        }

        wrapper.orderByDesc(ApiProject::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public ApiProject createApiProject(ApiProject apiProject) {
        this.save(apiProject);
        log.info("创建API项目: id={}, name={}", apiProject.getId(), apiProject.getName());
        return apiProject;
    }

    @Override
    public ApiProject updateApiProject(Long id, ApiProject apiProject) {
        apiProject.setId(id);
        this.updateById(apiProject);
        log.info("更新API项目: id={}", id);
        return apiProject;
    }

    @Override
    public void deleteApiProject(Long id) {
        this.removeById(id);
        log.info("删除API项目: id={}", id);
    }
}
