package com.testhub.modules.review.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.Result;
import com.testhub.modules.review.domain.ReviewTemplate;
import com.testhub.modules.review.domain.TestCaseReview;
import com.testhub.modules.review.service.ReviewService;
import com.testhub.modules.review.service.ReviewTemplateService;
import com.testhub.modules.system.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@Tag(name = "评审管理", description = "测试用例评审管理")
@RestController
@RequestMapping("/api/reviews")
@RequiredArgsConstructor
public class ReviewController {

    private final ReviewService reviewService;
    private final ReviewTemplateService reviewTemplateService;

    @GetMapping
    @Operation(summary = "获取评审列表")
    public Result<Map<String, Object>> listReviews(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int page_size,
            @RequestParam(required = false) Long project_id,
            @RequestParam(required = false) String status) {
        Map<String, Object> result = reviewService.listReviews(page, page_size, project_id, status);
        return Result.success(result);
    }

    @GetMapping("/{id:\\d+}")
    @Operation(summary = "获取评审详情")
    public Result<TestCaseReview> getReview(@PathVariable Long id) {
        TestCaseReview review = reviewService.getReview(id);
        return Result.success(review);
    }

    @PostMapping
    @Operation(summary = "创建评审")
    public Result<TestCaseReview> createReview(@RequestBody TestCaseReview review) {
        Long userId = 1L; // TODO: 从认证上下文获取
        TestCaseReview created = reviewService.createReview(review, userId);
        return Result.success(created);
    }

    @PutMapping("/{id:\\d+}")
    @Operation(summary = "更新评审")
    public Result<TestCaseReview> updateReview(@PathVariable Long id, @RequestBody TestCaseReview review) {
        Long userId = 1L; // TODO: 从认证上下文获取
        TestCaseReview updated = reviewService.updateReview(id, review, userId);
        return Result.success(updated);
    }

    @DeleteMapping("/{id:\\d+}")
    @Operation(summary = "删除评审")
    public Result<Void> deleteReview(@PathVariable Long id) {
        Long userId = 1L; // TODO: 从认证上下文获取
        reviewService.deleteReview(id, userId);
        return Result.success();
    }

    @PostMapping("/{id:\\d+}/submit_review")
    @Operation(summary = "提交评审")
    public Result<TestCaseReview> submitReview(
            @PathVariable Long id,
            @RequestBody Map<String, Object> request) {
        Long userId = 1L; // TODO: 从认证上下文获取
        String status = (String) request.get("status");
        String comment = (String) request.get("comment");
        TestCaseReview review = reviewService.submitReview(id, status, comment, userId);
        return Result.success(review);
    }

    // ==================== 评审模板 ====================

    @GetMapping("/review-templates")
    @Operation(summary = "获取评审模板列表")
    public Result<IPage<ReviewTemplate>> listTemplates(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "20") int page_size,
            @RequestParam(required = false) Long project) {
        IPage<ReviewTemplate> result = reviewTemplateService.listTemplates(page, page_size, project);
        return Result.success(result);
    }

    @GetMapping("/review-templates/{id:\\d+}")
    @Operation(summary = "获取评审模板详情")
    public Result<ReviewTemplate> getTemplate(@PathVariable Long id) {
        ReviewTemplate template = reviewTemplateService.getTemplate(id);
        return Result.success(template);
    }

    @PostMapping("/review-templates")
    @Operation(summary = "创建评审模板")
    public Result<ReviewTemplate> createTemplate(
            @RequestBody ReviewTemplate template,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        ReviewTemplate created = reviewTemplateService.createTemplate(template, userDetails.getId());
        return Result.success(created);
    }

    @PutMapping("/review-templates/{id:\\d+}")
    @Operation(summary = "更新评审模板")
    public Result<ReviewTemplate> updateTemplate(
            @PathVariable Long id,
            @RequestBody ReviewTemplate template,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        ReviewTemplate updated = reviewTemplateService.updateTemplate(id, template, userDetails.getId());
        return Result.success(updated);
    }

    @DeleteMapping("/review-templates/{id:\\d+}")
    @Operation(summary = "删除评审模板")
    public Result<Void> deleteTemplate(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        reviewTemplateService.deleteTemplate(id, userDetails.getId());
        return Result.success();
    }
}
