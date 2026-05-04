package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.domain.ApiRequest;
import com.testhub.modules.api_testing.dto.ApiExecuteDTO;
import com.testhub.modules.api_testing.dto.ApiRequestDTO;
import com.testhub.modules.api_testing.http.ApiExecutor;
import com.testhub.modules.api_testing.http.ApiResponse;
import com.testhub.modules.api_testing.mapper.ApiRequestMapper;
import com.testhub.modules.api_testing.service.ApiEnvironmentService;
import com.testhub.modules.api_testing.service.ApiRequestService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * API请求服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiRequestServiceImpl extends ServiceImpl<ApiRequestMapper, ApiRequest> implements ApiRequestService {

    private final ApiExecutor apiExecutor;
    private final ApiEnvironmentService apiEnvironmentService;
    private final ObjectMapper objectMapper;

    @Override
    public IPage<ApiRequest> getApiRequestPage(Long collectionId, String keyword, long current, long size) {
        Page<ApiRequest> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiRequest> wrapper = new LambdaQueryWrapper<>();

        if (collectionId != null) {
            wrapper.eq(ApiRequest::getCollectionId, collectionId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(ApiRequest::getName, keyword)
                    .or()
                    .like(ApiRequest::getUrl, keyword));
        }

        wrapper.orderByAsc(ApiRequest::getSortOrder);
        return this.page(page, wrapper);
    }

    @Override
    public ApiRequest createApiRequest(ApiRequestDTO dto) {
        ApiRequest request = new ApiRequest();
        request.setCollectionId(dto.getCollectionId());
        request.setName(dto.getName());
        request.setMethod(dto.getMethod());
        request.setUrl(dto.getUrl());
        request.setHeaders(dto.getHeaders());
        request.setParams(dto.getParams());
        request.setBodyType(dto.getBodyType());
        request.setBodyContent(dto.getBodyContent());
        request.setAuthType(dto.getAuthType());
        request.setAuthConfig(dto.getAuthConfig());
        request.setPreScript(dto.getPreScript());
        request.setPostScript(dto.getPostScript());
        request.setAssertions(dto.getAssertions());
        request.setExtractors(dto.getExtractors());
        request.setSortOrder(dto.getSortOrder() != null ? dto.getSortOrder() : 0);

        this.save(request);
        log.info("创建API请求: id={}, name={}", request.getId(), request.getName());
        return request;
    }

    @Override
    public ApiRequest updateApiRequest(Long id, ApiRequestDTO dto) {
        ApiRequest request = this.getById(id);
        if (request == null) {
            throw new RuntimeException("API请求不存在: " + id);
        }

        request.setName(dto.getName());
        request.setMethod(dto.getMethod());
        request.setUrl(dto.getUrl());
        request.setHeaders(dto.getHeaders());
        request.setParams(dto.getParams());
        request.setBodyType(dto.getBodyType());
        request.setBodyContent(dto.getBodyContent());
        request.setAuthType(dto.getAuthType());
        request.setAuthConfig(dto.getAuthConfig());
        request.setPreScript(dto.getPreScript());
        request.setPostScript(dto.getPostScript());
        request.setAssertions(dto.getAssertions());
        request.setExtractors(dto.getExtractors());
        request.setSortOrder(dto.getSortOrder());

        this.updateById(request);
        log.info("更新API请求: id={}", id);
        return request;
    }

    @Override
    public void deleteApiRequest(Long id) {
        this.removeById(id);
        log.info("删除API请求: id={}", id);
    }

    @Override
    public ApiResponse executeApiRequest(ApiExecuteDTO dto) {
        ApiRequest request = this.getById(dto.getRequestId());
        if (request == null) {
            throw new RuntimeException("API请求不存在: " + dto.getRequestId());
        }

        // 获取环境变量
        Map<String, String> variables = new HashMap<>();

        // 如果指定了环境，获取环境变量
        if (dto.getEnvironmentId() != null) {
            ApiEnvironment env = apiEnvironmentService.getById(dto.getEnvironmentId());
            if (env != null && env.getVariables() != null) {
                try {
                    Map<String, String> envVars = objectMapper.readValue(env.getVariables(),
                            new TypeReference<Map<String, String>>() {});
                    variables.putAll(envVars);
                } catch (Exception e) {
                    log.warn("解析环境变量失败: {}", e.getMessage());
                }
            }
        }

        // 合并覆盖变量
        if (dto.getOverrideVariables() != null && !dto.getOverrideVariables().isBlank()) {
            try {
                Map<String, String> overrideVars = objectMapper.readValue(dto.getOverrideVariables(),
                        new TypeReference<Map<String, String>>() {});
                variables.putAll(overrideVars);
            } catch (Exception e) {
                log.warn("解析覆盖变量失败: {}", e.getMessage());
            }
        }

        log.info("执行API请求: id={}, url={}", dto.getRequestId(), request.getUrl());
        return apiExecutor.execute(request, variables, null, null);
    }

    @Override
    public List<ApiRequest> getRequestsByCollection(Long collectionId) {
        return this.list(new LambdaQueryWrapper<ApiRequest>()
                .eq(ApiRequest::getCollectionId, collectionId)
                .orderByAsc(ApiRequest::getSortOrder));
    }
}
