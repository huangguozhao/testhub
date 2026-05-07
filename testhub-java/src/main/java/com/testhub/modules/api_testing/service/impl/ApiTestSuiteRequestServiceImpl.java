package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiRequest;
import com.testhub.modules.api_testing.domain.ApiTestSuiteRequest;
import com.testhub.modules.api_testing.mapper.ApiTestSuiteRequestMapper;
import com.testhub.modules.api_testing.service.ApiRequestService;
import com.testhub.modules.api_testing.service.ApiTestSuiteRequestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ApiTestSuiteRequestServiceImpl extends ServiceImpl<ApiTestSuiteRequestMapper, ApiTestSuiteRequest> implements ApiTestSuiteRequestService {

    private final ApiRequestService apiRequestService;

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void addRequestsToSuite(Long suiteId, List<Long> requestIds) {
        // 获取当前最大排序号
        ApiTestSuiteRequest lastRequest = this.lambdaQuery()
                .eq(ApiTestSuiteRequest::getTestSuiteId, suiteId)
                .orderByDesc(ApiTestSuiteRequest::getSortOrder)
                .last("LIMIT 1")
                .one();

        int order = (lastRequest != null && lastRequest.getSortOrder() != null) ? lastRequest.getSortOrder() + 1 : 1;

        for (Long requestId : requestIds) {
            // 检查是否已存在
            boolean exists = this.lambdaQuery()
                    .eq(ApiTestSuiteRequest::getTestSuiteId, suiteId)
                    .eq(ApiTestSuiteRequest::getRequestId, requestId)
                    .count() > 0;

            if (!exists) {
                ApiTestSuiteRequest suiteRequest = new ApiTestSuiteRequest();
                suiteRequest.setTestSuiteId(suiteId);
                suiteRequest.setRequestId(requestId);
                suiteRequest.setSortOrder(order++);
                suiteRequest.setEnabled(true);
                this.save(suiteRequest);
            }
        }

        log.info("添加请求到套件: suiteId={}, count={}", suiteId, requestIds.size());
    }

    @Override
    public List<ApiTestSuiteRequest> getRequestsBySuite(Long suiteId) {
        List<ApiTestSuiteRequest> suiteRequests = this.list(new LambdaQueryWrapper<ApiTestSuiteRequest>()
                .eq(ApiTestSuiteRequest::getTestSuiteId, suiteId)
                .orderByAsc(ApiTestSuiteRequest::getSortOrder));

        if (suiteRequests.isEmpty()) {
            return suiteRequests;
        }

        // 批量查询关联的API请求
        Set<Long> requestIds = suiteRequests.stream()
                .map(ApiTestSuiteRequest::getRequestId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        Map<Long, ApiRequest> requestMap = new HashMap<>();
        for (Long requestId : requestIds) {
            try {
                ApiRequest apiRequest = apiRequestService.getById(requestId);
                if (apiRequest != null) {
                    requestMap.put(requestId, apiRequest);
                }
            } catch (Exception e) {
                log.warn("查询API请求失败: requestId={}", requestId);
            }
        }

        // 填充request字段
        for (ApiTestSuiteRequest suiteRequest : suiteRequests) {
            ApiRequest apiRequest = requestMap.get(suiteRequest.getRequestId());
            if (apiRequest != null) {
                Map<String, Object> requestInfo = new HashMap<>();
                requestInfo.put("id", apiRequest.getId());
                requestInfo.put("name", apiRequest.getName());
                requestInfo.put("method", apiRequest.getMethod());
                requestInfo.put("url", apiRequest.getUrl());
                suiteRequest.setRequest(requestInfo);
            }
        }

        return suiteRequests;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void updateSuiteRequest(Long id, ApiTestSuiteRequest suiteRequest) {
        suiteRequest.setId(id);
        this.updateById(suiteRequest);
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public void deleteSuiteRequest(Long id) {
        this.removeById(id);
    }
}
