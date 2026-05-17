package com.testhub.modules.ai_generation.review.service;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.common.exception.BusinessException;
import com.testhub.modules.ai_generation.review.domain.TestCaseReview;
import com.testhub.modules.ai_generation.review.mapper.TestCaseReviewMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReviewService {

    private final TestCaseReviewMapper reviewMapper;

    /**
     * 分页查询评审列表
     */
    public Map<String, Object> listReviews(int page, int pageSize, Long projectId, String status) {
        LambdaQueryWrapper<TestCaseReview> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TestCaseReview::getIsDeleted, 0);

        if (projectId != null) {
            wrapper.eq(TestCaseReview::getProjectId, projectId);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq(TestCaseReview::getStatus, status);
        }
        wrapper.orderByDesc(TestCaseReview::getCreatedAt);

        long total = reviewMapper.selectCount(wrapper);
        List<TestCaseReview> reviews = reviewMapper.selectList(
                wrapper.last("LIMIT " + pageSize + " OFFSET " + (page - 1) * pageSize));

        Map<String, Object> result = new HashMap<>();
        result.put("count", total);
        result.put("results", reviews);
        return result;
    }

    /**
     * 获取评审详情
     */
    public TestCaseReview getReview(Long id) {
        TestCaseReview review = reviewMapper.selectById(id);
        if (review == null || review.getIsDeleted() == 1) {
            throw new BusinessException("评审不存在");
        }
        return review;
    }

    /**
     * 创建评审
     */
    @Transactional
    public TestCaseReview createReview(TestCaseReview review, Long userId) {
        review.setIsDeleted(0);
        review.setStatus("pending");
        review.setCreatedBy(userId);
        reviewMapper.insert(review);
        log.info("创建评审: id={}, name={}", review.getId(), review.getName());
        return review;
    }

    /**
     * 更新评审
     */
    @Transactional
    public TestCaseReview updateReview(Long id, TestCaseReview reviewData, Long userId) {
        TestCaseReview review = getReview(id);

        if (reviewData.getName() != null) {
            review.setName(reviewData.getName());
        }
        if (reviewData.getDescription() != null) {
            review.setDescription(reviewData.getDescription());
        }
        if (reviewData.getStatus() != null) {
            review.setStatus(reviewData.getStatus());
        }
        if (reviewData.getAssigneeId() != null) {
            review.setAssigneeId(reviewData.getAssigneeId());
        }
        if (reviewData.getDueDate() != null) {
            review.setDueDate(reviewData.getDueDate());
        }
        if (reviewData.getTemplateId() != null) {
            review.setTemplateId(reviewData.getTemplateId());
        }
        review.setUpdatedBy(userId);
        reviewMapper.updateById(review);

        return review;
    }

    /**
     * 删除评审（软删除）
     */
    @Transactional
    public void deleteReview(Long id, Long userId) {
        TestCaseReview review = getReview(id);
        review.setIsDeleted(1);
        review.setUpdatedBy(userId);
        reviewMapper.updateById(review);
        log.info("删除评审: id={}", id);
    }

    /**
     * 提交评审
     */
    @Transactional
    public TestCaseReview submitReview(Long id, String status, String comment, Long userId) {
        TestCaseReview review = getReview(id);
        review.setStatus(status);
        review.setUpdatedBy(userId);
        reviewMapper.updateById(review);
        log.info("提交评审: id={}, status={}", id, status);
        return review;
    }
}