package com.testhub.modules.ai_generation.report.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.ai_generation.report.service.ReportService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "测试报告", description = "测试报告统计分析")
@RestController
@RequestMapping("/api/ai-generation/reports")
@RequiredArgsConstructor
public class ReportController {

    private final ReportService reportService;

    @GetMapping("/dashboard")
    @Operation(summary = "获取概览数据")
    public Result<Map<String, Object>> dashboard(
            @RequestParam(required = false) Long project) {
        return Result.success(reportService.getDashboard(project));
    }

    @GetMapping("/status_distribution")
    @Operation(summary = "获取执行状态分布")
    public Result<Map<String, Integer>> statusDistribution(
            @RequestParam(required = false) Long project,
            @RequestParam(required = false) Long version) {
        return Result.success(reportService.getStatusDistribution(project, version));
    }

    @GetMapping("/execution_trend")
    @Operation(summary = "获取每日执行趋势")
    public Result<List<Map<String, Object>>> executionTrend(
            @RequestParam(required = false) Long project,
            @RequestParam(defaultValue = "7") int days) {
        return Result.success(reportService.getExecutionTrend(project, days));
    }

    @GetMapping("/defect_distribution")
    @Operation(summary = "获取缺陷分布")
    public Result<List<Map<String, Object>>> defectDistribution(
            @RequestParam(required = false) Long project) {
        return Result.success(reportService.getDefectDistribution(project));
    }

    @GetMapping("/failed_cases_top")
    @Operation(summary = "获取失败用例TOP榜")
    public Result<List<Map<String, Object>>> failedCasesTop(
            @RequestParam(required = false) Long project) {
        return Result.success(reportService.getFailedCasesTop(project));
    }

    @GetMapping("/ai_efficiency")
    @Operation(summary = "获取AI效能分析")
    public Result<Map<String, Object>> aiEfficiency(
            @RequestParam(required = false) Long project) {
        return Result.success(reportService.getAiEfficiency(project));
    }

    @GetMapping("/team_workload")
    @Operation(summary = "获取团队工作量")
    public Result<List<Map<String, Object>>> teamWorkload(
            @RequestParam(required = false) Long project) {
        return Result.success(reportService.getTeamWorkload(project));
    }
}