package com.testhub.modules.ai_generation.review.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.modules.ai_generation.review.domain.ReviewTemplate;

public interface ReviewTemplateService {

    IPage<ReviewTemplate> listTemplates(int page, int pageSize, Long projectId);

    ReviewTemplate getTemplate(Long id);

    ReviewTemplate createTemplate(ReviewTemplate template, Long userId);

    ReviewTemplate updateTemplate(Long id, ReviewTemplate template, Long userId);

    void deleteTemplate(Long id, Long userId);
}