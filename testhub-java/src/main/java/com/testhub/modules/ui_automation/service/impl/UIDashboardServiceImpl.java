package com.testhub.modules.ui_automation.service.impl;

import com.testhub.modules.ui_automation.dto.UIDashboardStatsDTO;
import com.testhub.modules.ui_automation.service.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

/**
 * UI仪表盘服务实现
 */
@Service
@RequiredArgsConstructor
public class UIDashboardServiceImpl implements UIDashboardService {

    private final UIProjectService uiProjectService;
    private final UITestCaseService uiTestCaseService;
    private final UITestSuiteService uiTestSuiteService;
    private final UIExecutionService uiExecutionService;

    @Override
    public UIDashboardStatsDTO getDashboardStats() {
        UIDashboardStatsDTO stats = new UIDashboardStatsDTO();
        stats.setProjectCount(uiProjectService.count());
        stats.setTestCaseCount(uiTestCaseService.count());
        stats.setSuiteCount(uiTestSuiteService.count());
        stats.setExecutionCount(uiExecutionService.count());
        return stats;
    }

    @Override
    public UIDashboardStatsDTO getDashboardStatsByProjectId(Long projectId) {
        UIDashboardStatsDTO stats = new UIDashboardStatsDTO();
        stats.setProjectCount(uiProjectService.countByProjectId(projectId));
        stats.setTestCaseCount(uiTestCaseService.countByProjectId(projectId));
        stats.setSuiteCount(uiTestSuiteService.countByProjectId(projectId));
        stats.setExecutionCount(uiExecutionService.countByProjectId(projectId));
        return stats;
    }
}