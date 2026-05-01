package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiExecutionRecord;

import java.util.List;

/**
 * API执行记录服务接口
 */
public interface ApiExecutionRecordService extends IService<ApiExecutionRecord> {

    /**
     * 创建执行记录
     */
    ApiExecutionRecord createRecord(ApiExecutionRecord record);

    /**
     * 获取套件的执行历史
     */
    List<ApiExecutionRecord> getRecordsBySuite(Long suiteId, Integer limit);

    /**
     * 获取项目的所有执行记录
     */
    List<ApiExecutionRecord> getRecordsByProject(Long projectId, Integer limit);

    /**
     * 获取记录详情
     */
    ApiExecutionRecord getRecord(Long id);
}