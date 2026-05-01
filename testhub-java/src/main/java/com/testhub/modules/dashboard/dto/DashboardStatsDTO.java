package com.testhub.modules.dashboard.dto;

import lombok.Data;

/**
 * 仪表盘统计数据
 */
@Data
public class DashboardStatsDTO {

    /**
     * API项目数量
     */
    private Long projectCount;

    /**
     * 接口数量
     */
    private Long interfaceCount;

    /**
     * 测试套件数量
     */
    private Long suiteCount;

    /**
     * 执行记录数量
     */
    private Long historyCount;
}
