package com.testhub.modules.api.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api.domain.ApiExecutionRecord;
import com.testhub.modules.api.mapper.ApiExecutionRecordMapper;
import com.testhub.modules.api.service.ApiExecutionRecordService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * API执行记录服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiExecutionRecordServiceImpl extends ServiceImpl<ApiExecutionRecordMapper, ApiExecutionRecord> implements ApiExecutionRecordService {

    @Override
    public ApiExecutionRecord createRecord(ApiExecutionRecord record) {
        this.save(record);
        log.info("创建API执行记录: id={}, suiteId={}", record.getId(), record.getSuiteId());
        return record;
    }

    @Override
    public List<ApiExecutionRecord> getRecordsBySuite(Long suiteId, Integer limit) {
        LambdaQueryWrapper<ApiExecutionRecord> wrapper = new LambdaQueryWrapper<ApiExecutionRecord>()
                .eq(ApiExecutionRecord::getSuiteId, suiteId)
                .orderByDesc(ApiExecutionRecord::getExecutedAt);

        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }

        return this.list(wrapper);
    }

    @Override
    public List<ApiExecutionRecord> getRecordsByProject(Long projectId, Integer limit) {
        LambdaQueryWrapper<ApiExecutionRecord> wrapper = new LambdaQueryWrapper<ApiExecutionRecord>()
                .inSql(ApiExecutionRecord::getSuiteId,
                        "SELECT id FROM api_test_suite WHERE project_id = " + projectId)
                .orderByDesc(ApiExecutionRecord::getExecutedAt);

        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }

        return this.list(wrapper);
    }

    @Override
    public ApiExecutionRecord getRecord(Long id) {
        return this.getById(id);
    }
}