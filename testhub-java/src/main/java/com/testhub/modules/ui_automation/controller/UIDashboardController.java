package com.testhub.modules.ui_automation.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.dto.UIDashboardStatsDTO;
import com.testhub.modules.ui_automation.service.UIDashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * UI自动化仪表盘控制器
 */
@Tag(name = "UI自动化仪表盘", description = "UI自动化模块统计数据")
@RestController
@RequestMapping("/api/ui-automation/dashboard")
@RequiredArgsConstructor
public class UIDashboardController {

    private final UIDashboardService uiDashboardService;

    @GetMapping("/stats")
    @Operation(summary = "获取仪表盘统计数据")
    public Result<UIDashboardStatsDTO> getDashboardStats(
            @RequestParam(required = false) Long projectId) {
        UIDashboardStatsDTO stats;
        if (projectId != null) {
            stats = uiDashboardService.getDashboardStatsByProjectId(projectId);
        } else {
            stats = uiDashboardService.getDashboardStats();
        }
        return Result.success(stats);
    }
}