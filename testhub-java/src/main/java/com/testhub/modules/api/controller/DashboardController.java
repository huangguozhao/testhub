package com.testhub.modules.api.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api.dto.DashboardStatsDTO;
import com.testhub.modules.api.service.ApiProjectService;
import com.testhub.modules.api.service.ApiRequestService;
import com.testhub.modules.api.service.ApiTestSuiteService;
import com.testhub.modules.api.service.ApiRequestHistoryService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * API测试仪表盘控制器
 */
@Tag(name = "API仪表盘", description = "API测试模块统计数据")
@RestController
@RequestMapping("/api/api-testing/dashboard")
@RequiredArgsConstructor
public class DashboardController {

    private final ApiProjectService apiProjectService;
    private final ApiRequestService apiRequestService;
    private final ApiTestSuiteService apiTestSuiteService;
    private final ApiRequestHistoryService apiRequestHistoryService;

    @GetMapping("/stats")
    @Operation(summary = "获取仪表盘统计数据")
    public Result<DashboardStatsDTO> getDashboardStats() {
        DashboardStatsDTO stats = new DashboardStatsDTO();
        stats.setProjectCount(apiProjectService.count());
        stats.setInterfaceCount(apiRequestService.count());
        stats.setSuiteCount(apiTestSuiteService.count());
        stats.setHistoryCount(apiRequestHistoryService.count());
        return Result.success(stats);
    }
}
