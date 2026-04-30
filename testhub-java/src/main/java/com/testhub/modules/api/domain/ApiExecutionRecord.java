package com.testhub.modules.api.domain;

import com.baomidou.mybatisplus.annotation.*;
import lombok.Data;
import com.testhub.modules.system.domain.BaseEntity;

import java.time.LocalDateTime;

/**
 * API执行记录实体
 */
@Data
@TableName("api_execution_record")
public class ApiExecutionRecord extends BaseEntity {

    /**
     * 套件ID
     */
    private Long suiteId;

    /**
     * 执行时间
     */
    private LocalDateTime executedAt;

    /**
     * 总请求数
     */
    private Integer totalCount;

    /**
     * 通过数
     */
    private Integer passCount;

    /**
     * 失败数
     */
    private Integer failCount;

    /**
     * 执行结果(JSON)
     */
    private String resultData;

    /**
     * 执行状态: 0=失败, 1=成功
     */
    private Boolean status;

    /**
     * 执行时长(毫秒)
     */
    private Long duration;

    /**
     * 执行环境ID
     */
    private Long environmentId;

    /**
     * 触发类型: manual=手动, scheduled=定时任务
     */
    private String triggerType;

    /**
     * 触发来源ID(定时任务ID等)
     */
    private Long triggerId;
}