package com.testhub.modules.review.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ai_generation.domain.Project;
import com.testhub.modules.ai_generation.mapper.ProjectMapper;
import com.testhub.modules.review.domain.ReviewTemplate;
import com.testhub.modules.review.mapper.ReviewTemplateMapper;
import com.testhub.modules.review.service.ReviewTemplateService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewTemplateServiceImpl extends ServiceImpl<ReviewTemplateMapper, ReviewTemplate> implements ReviewTemplateService {

    private final ProjectMapper projectMapper;
    private final UserMapper userMapper;

    @Override
    public IPage<ReviewTemplate> listTemplates(int page, int pageSize, Long projectId) {
        Page<ReviewTemplate> pageParam = new Page<>(page, pageSize);
        LambdaQueryWrapper<ReviewTemplate> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(ReviewTemplate::getProjectId, projectId);
        }

        wrapper.eq(ReviewTemplate::getIsActive, 1);
        wrapper.orderByDesc(ReviewTemplate::getCreatedAt);

        IPage<ReviewTemplate> result = this.page(pageParam, wrapper);

        // 填充项目名称和创建者信息
        for (ReviewTemplate template : result.getRecords()) {
            enrichTemplate(template);
        }

        return result;
    }

    @Override
    public ReviewTemplate getTemplate(Long id) {
        ReviewTemplate template = this.getById(id);
        if (template == null) {
            throw new RuntimeException("模板不存在: " + id);
        }
        enrichTemplate(template);
        return template;
    }

    @Override
    public ReviewTemplate createTemplate(ReviewTemplate template, Long userId) {
        template.setCreatedBy(userId);
        template.setIsActive(1);
        this.save(template);
        log.info("创建评审模板: id={}, name={}", template.getId(), template.getName());
        return template;
    }

    @Override
    public ReviewTemplate updateTemplate(Long id, ReviewTemplate template, Long userId) {
        ReviewTemplate existing = this.getById(id);
        if (existing == null) {
            throw new RuntimeException("模板不存在: " + id);
        }

        template.setId(id);
        template.setCreatedBy(existing.getCreatedBy());
        this.updateById(template);
        log.info("更新评审模板: id={}", id);
        return this.getById(id);
    }

    @Override
    public void deleteTemplate(Long id, Long userId) {
        ReviewTemplate template = new ReviewTemplate();
        template.setId(id);
        template.setIsActive(0);
        this.updateById(template);
        log.info("删除评审模板: id={}", id);
    }

    private void enrichTemplate(ReviewTemplate template) {
        if (template.getProjectId() != null) {
            Project project = projectMapper.selectById(template.getProjectId());
            if (project != null) {
                template.setProjectName(project.getName());
            }
        }
        if (template.getCreatedBy() != null) {
            User creator = userMapper.selectById(template.getCreatedBy());
            if (creator != null) {
                template.setCreatorName(creator.getUsername());
            }
        }
    }
}
