package com.testhub.modules.ui_automation.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

/**
 * UI自动化仪表盘统计数据DTO
 */
@Data
public class UIDashboardStatsDTO {

    /**
     * 项目数量
     */
    @JsonProperty("project_count")
    private Long projectCount;

    /**
     * 测试用例数量
     */
    @JsonProperty("test_case_count")
    private Long testCaseCount;

    /**
     * 测试套件数量
     */
    @JsonProperty("suite_count")
    private Long suiteCount;

    /**
     * 执行记录数量
     */
    @JsonProperty("execution_count")
    private Long executionCount;
}