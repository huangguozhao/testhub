package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.ApiExecutionRecord;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import com.testhub.modules.api_testing.mapper.ApiExecutionRecordMapper;
import com.testhub.modules.api_testing.service.ApiExecutionRecordService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.service.UserService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * API执行记录服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiExecutionRecordServiceImpl extends ServiceImpl<ApiExecutionRecordMapper, ApiExecutionRecord> implements ApiExecutionRecordService {

    private final ApiTestSuiteService apiTestSuiteService;
    private final UserService userService;
    private final ObjectMapper objectMapper;

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

        List<ApiExecutionRecord> records = this.list(wrapper);
        enrichRecords(records);
        return records;
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

        List<ApiExecutionRecord> records = this.list(wrapper);
        enrichRecords(records);
        return records;
    }

    @Override
    public List<ApiExecutionRecord> getRecordsByTriggerId(Long triggerId, Integer limit) {
        LambdaQueryWrapper<ApiExecutionRecord> wrapper = new LambdaQueryWrapper<ApiExecutionRecord>()
                .eq(ApiExecutionRecord::getTriggerId, triggerId)
                .orderByDesc(ApiExecutionRecord::getExecutedAt);

        if (limit != null && limit > 0) {
            wrapper.last("LIMIT " + limit);
        }

        List<ApiExecutionRecord> records = this.list(wrapper);
        enrichRecords(records);
        return records;
    }

    @Override
    public ApiExecutionRecord getRecord(Long id) {
        ApiExecutionRecord record = this.getById(id);
        if (record != null) {
            enrichRecords(List.of(record));
        }
        return record;
    }

    /**
     * 填充关联信息：套件名称、执行者
     */
    private void enrichRecords(List<ApiExecutionRecord> records) {
        if (records == null || records.isEmpty()) return;

        // 批量查询套件名称
        Set<Long> suiteIds = records.stream()
                .map(ApiExecutionRecord::getSuiteId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, String> suiteNameMap = new HashMap<>();
        for (Long suiteId : suiteIds) {
            try {
                ApiTestSuite suite = apiTestSuiteService.getById(suiteId);
                if (suite != null) {
                    suiteNameMap.put(suiteId, suite.getName());
                }
            } catch (Exception e) {
                log.warn("查询套件失败: suiteId={}", suiteId);
            }
        }

        // 批量查询执行者
        Set<Long> userIds = records.stream()
                .map(r -> r.getCreatedBy())
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());
        Map<Long, User> userMap = new HashMap<>();
        for (Long userId : userIds) {
            try {
                User user = userService.getById(userId);
                if (user != null) {
                    userMap.put(userId, user);
                }
            } catch (Exception e) {
                log.warn("查询用户失败: userId={}", userId);
            }
        }

        // 填充到记录
        for (ApiExecutionRecord record : records) {
            record.setSuiteName(suiteNameMap.get(record.getSuiteId()));
            if (record.getCreatedBy() != null && userMap.containsKey(record.getCreatedBy())) {
                User user = userMap.get(record.getCreatedBy());
                record.setExecutedBy(Map.of("id", user.getId(), "username", user.getUsername()));
            }

            // 解析 resultData 为 requestResults
            if (record.getResultData() != null && !record.getResultData().isBlank()) {
                try {
                    List<Map<String, Object>> requestResults = objectMapper.readValue(
                            record.getResultData(),
                            new TypeReference<List<Map<String, Object>>>() {}
                    );
                    record.setRequestResults(requestResults);
                } catch (Exception e) {
                    log.warn("解析执行结果失败: {}", e.getMessage());
                    record.setRequestResults(Collections.emptyList());
                }
            } else {
                record.setRequestResults(Collections.emptyList());
            }
        }
    }
}