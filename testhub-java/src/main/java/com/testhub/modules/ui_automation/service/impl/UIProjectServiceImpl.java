package com.testhub.modules.ui_automation.service.impl;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ui_automation.domain.UIProject;
import com.testhub.modules.ui_automation.mapper.UIProjectMapper;
import com.testhub.modules.ui_automation.service.UIProjectService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.util.List;

/**
 * UI项目服务实现
 */
@Service
@RequiredArgsConstructor
public class UIProjectServiceImpl extends ServiceImpl<UIProjectMapper, UIProject> implements UIProjectService {

    @Override
    public IPage<UIProject> getProjectPage(Long projectId, String keyword, long current, long size) {
        Page<UIProject> page = new Page<>(current, size);
        // 如果需要按关键词搜索，可以添加查询条件
        return this.page(page);
    }

    @Override
    public UIProject createProject(UIProject project) {
        this.save(project);
        return project;
    }

    @Override
    public UIProject updateProject(Long id, UIProject project) {
        project.setId(id);
        this.updateById(project);
        return project;
    }

    @Override
    public void deleteProject(Long id) {
        this.removeById(id);
    }

    @Override
    public long countByProjectId(Long projectId) {
        if (projectId == null) {
            return this.count();
        }
        return this.lambdaQuery()
                .eq(UIProject::getProjectId, projectId)
                .count();
    }
}