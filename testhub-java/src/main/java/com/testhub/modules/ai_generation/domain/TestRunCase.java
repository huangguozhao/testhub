package com.testhub.modules.ai_generation.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * 执行用例记录实体
 */
@Data
@TableName("exec_test_run_case")
public class TestRunCase extends BaseEntity {

    /**
     * 执行ID
     */
    private Long runId;

    /**
     * 用例ID
     */
    private Long testCaseId;

    /**
     * 状态: untested=未测试, passed=通过, failed=失败, blocked=阻塞, retest=重测
     */
    private String status;

    /**
     * 执行结果
     */
    private String result;

    /**
     * 关联的缺陷ID(逗号分隔)
     */
    private String bugIds;

    /**
     * 执行人ID
     */
    private Long executorId;

    /**
     * 执行时间
     */
    private LocalDateTime executedAt;

    // 扩展字段（非数据库）
    @TableField(exist = false)
    private String testCaseTitle;

    @TableField(exist = false)
    private String executorName;
}
