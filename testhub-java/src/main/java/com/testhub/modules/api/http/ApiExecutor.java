package com.testhub.modules.api.http;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api.domain.ApiCollection;
import com.testhub.modules.api.domain.ApiEnvironment;
import com.testhub.modules.api.domain.ApiExecutionRecord;
import com.testhub.modules.api.domain.ApiRequest;
import com.testhub.modules.api.domain.ApiTestSuite;
import com.testhub.modules.api.service.*;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.time.LocalDateTime;
import java.util.*;

/**
 * API HTTP执行器
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ApiExecutor {

    private final RestTemplate restTemplate;
    private final ObjectMapper objectMapper;
    private final ObjectProvider<ApiRequestService> apiRequestServiceProvider;
    private final ApiCollectionService apiCollectionService;
    private final ApiEnvironmentService apiEnvironmentService;
    private final ApiExecutionRecordService apiExecutionRecordService;
    private final ApiTestSuiteService apiTestSuiteService;
    private final AssertionEngine assertionEngine;
    private final VariableExtractor variableExtractor;
    private final ApiRequestHistoryService apiRequestHistoryService;

    /**
     * 执行API请求
     */
    public ApiResponse execute(ApiRequest request, Map<String, String> variables) {
        return execute(request, variables, null, null);
    }

    /**
     * 执行API请求并保存历史记录
     */
    public ApiResponse execute(ApiRequest request, Map<String, String> variables,
                               Long suiteExecutionId, Long executedBy) {
        long startTime = System.currentTimeMillis();
        ApiResponse response;

        try {
            // 替换变量
            String url = replaceVariables(request.getUrl(), variables);
            String body = replaceVariables(request.getBodyContent(), variables);

            // 构建HTTP请求
            HttpHeaders headers = buildHeaders(request.getHeaders(), variables);
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            // 发送请求
            ResponseEntity<String> httpResponse = restTemplate.exchange(
                    url,
                    HttpMethod.valueOf(request.getMethod().toUpperCase()),
                    entity,
                    String.class
            );

            long duration = System.currentTimeMillis() - startTime;

            response = ApiResponse.builder()
                    .success(true)
                    .statusCode(httpResponse.getStatusCode().value())
                    .headers(httpResponse.getHeaders().toSingleValueMap())
                    .body(httpResponse.getBody())
                    .responseTime(duration)
                    .build();

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("API执行失败: {}", e.getMessage(), e);

            response = ApiResponse.builder()
                    .success(false)
                    .error(e.getMessage())
                    .responseTime(duration)
                    .build();
        }

        // 保存历史记录
        saveRequestHistory(request, response, variables, suiteExecutionId, executedBy);

        return response;
    }

    /**
     * 构建请求头
     */
    private HttpHeaders buildHeaders(String headersJson, Map<String, String> variables) {
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);

        if (headersJson != null && !headersJson.isBlank()) {
            try {
                Map<String, String> headersMap = objectMapper.readValue(headersJson, Map.class);
                for (Map.Entry<String, String> entry : headersMap.entrySet()) {
                    String value = replaceVariables(entry.getValue(), variables);
                    headers.add(entry.getKey(), value);
                }
            } catch (Exception e) {
                log.warn("解析请求头失败: {}", e.getMessage());
            }
        }

        return headers;
    }

    /**
     * 替换变量 {{varName}} -> value
     */
    private String replaceVariables(String content, Map<String, String> variables) {
        if (content == null || variables == null) {
            return content;
        }

        String result = content;
        for (Map.Entry<String, String> entry : variables.entrySet()) {
            result = result.replace("{{" + entry.getKey() + "}}", entry.getValue() != null ? entry.getValue() : "");
        }
        return result;
    }

    /**
     * 执行测试套件
     */
    public SuiteExecutionResult executeSuite(Long suiteId) {
        log.info("开始执行测试套件: suiteId={}", suiteId);

        SuiteExecutionResult result = new SuiteExecutionResult();
        result.setSuiteId(suiteId);
        result.setStartTime(new Date());

        ApiTestSuite suite = null;
        Map<String, String> variables = new HashMap<>();

        try {
            suite = apiTestSuiteService.getTestSuite(suiteId);
            if (suite == null) {
                throw new RuntimeException("测试套件不存在: " + suiteId);
            }

            // 获取环境变量
            if (suite.getEnvironmentId() != null) {
                ApiEnvironment env = apiEnvironmentService.getById(suite.getEnvironmentId());
                if (env != null && env.getVariables() != null) {
                    variables.putAll(parseVariables(env.getVariables()));
                }
            }

            // 获取套件下的所有集合
            List<ApiCollection> collections = apiCollectionService.getCollectionsBySuite(suiteId);

            List<RequestResult> requestResults = new ArrayList<>();
            int totalCount = 0;
            int passCount = 0;

            for (ApiCollection collection : collections) {
                ApiRequestService apiRequestService = apiRequestServiceProvider.getObject();
                List<ApiRequest> requests = apiRequestService.getRequestsByCollection(collection.getId());
                for (ApiRequest request : requests) {
                    totalCount++;
                    RequestResult requestResult = new RequestResult();
                    requestResult.setRequestId(request.getId());
                    requestResult.setRequestName(request.getName());

                    // 执行请求
                    ApiResponse response = execute(request, variables);

                    // 执行断言
                    List<AssertionEngine.AssertionResult> assertionResults = null;
                    if (request.getAssertions() != null && !request.getAssertions().isBlank()) {
                        assertionResults = assertionEngine.executeAssertions(request.getAssertions(), response);
                        requestResult.setAssertions(assertionResults);

                        // 检查是否有断言失败
                        boolean allPassed = response.isSuccess() && assertionResults.stream().allMatch(AssertionEngine.AssertionResult::isPassed);
                        requestResult.setSuccess(allPassed);

                        // 统计失败的断言
                        long failedAssertions = assertionResults.stream().filter(r -> !r.isPassed()).count();
                        if (failedAssertions > 0) {
                            requestResult.setError(failedAssertions + " assertion(s) failed");
                        }
                    } else {
                        requestResult.setSuccess(response.isSuccess());
                    }

                    requestResult.setStatusCode(response.getStatusCode());
                    requestResult.setResponseTime(response.getResponseTime());
                    requestResult.setError(response.getError());

                    requestResults.add(requestResult);
                    if (requestResult.isSuccess()) {
                        passCount++;
                    }

                    // 提取变量
                    if (request.getExtractors() != null && !request.getExtractors().isBlank()) {
                        Map<String, String> extracted = variableExtractor.extractVariables(request.getExtractors(), response);
                        variables.putAll(extracted);
                    }

                    // 保存历史记录
                    saveRequestHistory(request, response, variables, null, null);
                }
            }

            result.setRequestResults(requestResults);
            result.setTotalCount(totalCount);
            result.setPassCount(passCount);
            result.setFailCount(totalCount - passCount);
            result.setSuccess(true);
            result.setEndTime(new Date());

            // 保存执行记录
            saveExecutionRecord(suite, result, variables, "manual", null);

        } catch (Exception e) {
            log.error("执行测试套件失败: {}", e.getMessage(), e);
            result.setSuccess(false);
            result.setError(e.getMessage());
            result.setEndTime(new Date());
            if (suite != null) {
                saveExecutionRecord(suite, result, variables, "manual", null);
            }
        }

        return result;
    }

    /**
     * 保存执行记录
     */
    private void saveExecutionRecord(ApiTestSuite suite, SuiteExecutionResult result,
                                     Map<String, String> variables, String triggerType, Long triggerId) {
        try {
            ApiExecutionRecord record = new ApiExecutionRecord();
            record.setSuiteId(suite.getId());
            record.setExecutedAt(LocalDateTime.now());
            record.setTotalCount(result.getTotalCount());
            record.setPassCount(result.getPassCount());
            record.setFailCount(result.getFailCount());
            record.setStatus(result.isSuccess());
            record.setDuration(result.getEndTime().getTime() - result.getStartTime().getTime());
            record.setEnvironmentId(suite.getEnvironmentId());
            record.setTriggerType(triggerType);
            record.setTriggerId(triggerId);

            // 序列化请求结果
            record.setResultData(objectMapper.writeValueAsString(result.getRequestResults()));

            apiExecutionRecordService.createRecord(record);
            log.info("保存执行记录: suiteId={}, result={}/{}", suite.getId(), result.getPassCount(), result.getTotalCount());
        } catch (Exception e) {
            log.error("保存执行记录失败: {}", e.getMessage(), e);
        }
    }

    /**
     * 解析环境变量 (key1=value1,key2=value2)
     */
    private Map<String, String> parseVariables(String variablesStr) {
        Map<String, String> variables = new HashMap<>();
        if (variablesStr != null && !variablesStr.isBlank()) {
            String[] pairs = variablesStr.split(",");
            for (String pair : pairs) {
                String[] kv = pair.split("=", 2);
                if (kv.length == 2) {
                    variables.put(kv[0].trim(), kv[1].trim());
                }
            }
        }
        return variables;
    }

    /**
     * 保存请求历史记录
     */
    private void saveRequestHistory(ApiRequest request, ApiResponse response,
                                    Map<String, String> variables, Long suiteExecutionId, Long executedBy) {
        try {
            apiRequestHistoryService.saveFromExecution(
                    request.getId(),
                    request.getMethod(),
                    request.getUrl(),
                    request.getHeaders(),
                    request.getBodyContent(),
                    response,
                    request.getAssertions(),
                    variables,
                    suiteExecutionId,
                    executedBy
            );
        } catch (Exception e) {
            log.warn("保存请求历史失败: {}", e.getMessage());
        }
    }

    /**
     * 测试套件执行结果
     */
    @Data
    public static class SuiteExecutionResult {
        private Long suiteId;
        private Date startTime;
        private Date endTime;
        private boolean success;
        private int totalCount;
        private int passCount;
        private int failCount;
        private String error;
        private List<RequestResult> requestResults;
    }

    /**
     * 请求结果
     */
    @Data
    public static class RequestResult {
        private Long requestId;
        private String requestName;
        private boolean success;
        private Integer statusCode;
        private Long responseTime;
        private String error;
        private List<AssertionEngine.AssertionResult> assertions;
    }
}
