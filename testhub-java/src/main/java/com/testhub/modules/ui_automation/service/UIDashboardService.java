package com.testhub.modules.ui_automation.service;

import com.testhub.modules.ui_automation.dto.UIDashboardStatsDTO;

/**
 * UI仪表盘服务接口
 */
public interface UIDashboardService {

    /**
     * 获取仪表盘统计数据
     */
    UIDashboardStatsDTO getDashboardStats();

    /**
     * 获取指定项目的统计数据
     */
    UIDashboardStatsDTO getDashboardStatsByProjectId(Long projectId);
}