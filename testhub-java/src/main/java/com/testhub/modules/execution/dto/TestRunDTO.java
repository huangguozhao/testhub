package com.testhub.modules.execution.dto;

import lombok.Data;

/**
 * 测试执行 DTO
 */
@Data
public class TestRunDTO {

    private Long planId;

    private Long suiteId;

    /**
     * 执行状态更新
     */
    private Long runId;

    private String status;

    /**
     * 用例执行结果
     */
    private Long caseId;

    private String caseStatus;

    private String result;

    private String bugIds;

    /**
     * 通过数量
     */
    private Integer passedCount;

    /**
     * 失败数量
     */
    private Integer failedCount;
}
