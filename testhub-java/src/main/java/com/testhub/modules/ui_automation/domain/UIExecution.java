package com.testhub.modules.ui_automation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import lombok.EqualsAndHashCode;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * UI自动化执行记录实体
 */
@Data
@EqualsAndHashCode(callSuper = true)
@TableName("ui_execution")
public class UIExecution extends BaseEntity {

    /**
     * 测试套件ID
     */
    private Long suiteId;

    /**
     * 测试用例ID
     */
    private Long testCaseId;

    /**
     * 执行状态: PENDING, RUNNING, PASSED, FAILED, ERROR, STOPPED
     */
    private String status;

    /**
     * 执行人ID
     */
    private Long executorId;

    /**
     * 开始时间
     */
    private LocalDateTime startTime;

    /**
     * 结束时间
     */
    private LocalDateTime endTime;

    /**
     * 执行时长（秒）
     */
    private Integer duration;

    /**
     * 通过数
     */
    private Integer passedCount;

    /**
     * 失败数
     */
    private Integer failedCount;

    /**
     * 执行结果详情（JSON）
     */
    private String resultDetail;
}