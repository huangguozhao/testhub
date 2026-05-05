package com.testhub.modules.api_testing.http;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.ApiCollection;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.domain.ApiExecutionRecord;
import com.testhub.modules.api_testing.domain.ApiRequest;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import com.testhub.modules.api_testing.service.*;
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
    private final ScriptEngine scriptEngine;

    /**
     * 执行API请求（内部核心方法）
     */
    private ApiResponse executeRequest(ApiRequest request, Map<String, String> variables, Long suiteExecutionId, Long executedBy, boolean saveHistory) {
        long startTime = System.currentTimeMillis();
        ApiResponse response;
        Map<String, String> currentVars = new HashMap<>(variables != null ? variables : new HashMap<>());

        log.info("========== API请求开始 ==========");
        log.info("请求信息: name=%s, url=%s, method=%s", request.getName(), request.getUrl(), request.getMethod());

        ScriptResult preScriptResult = null;
        ScriptResult postScriptResult = null;

        try {
            // 执行Pre-request Script
            if (request.getPreScript() != null && !request.getPreScript().isBlank()) {
                log.info("【Pre-request Script】开始执行, 内容长度=%d", request.getPreScript().length());
                preScriptResult = scriptEngine.executePreScript(request.getPreScript(), request, currentVars);
                log.info("【Pre-request Script】执行结果: success=%s, abort=%s, error=%s, logs=%s",
                        preScriptResult.isSuccess(), preScriptResult.isAbort(), preScriptResult.getError(), preScriptResult.getLogs());
                if (preScriptResult.getVariables() != null && !preScriptResult.getVariables().isEmpty()) {
                    log.info("【Pre-request Script】更新变量: %s", preScriptResult.getVariables());
                    currentVars.putAll(preScriptResult.getVariables());
                }
                if (!preScriptResult.isSuccess()) {
                    log.warn("【Pre-request Script】执行失败: %s", preScriptResult.getError());
                }
                if (preScriptResult.isAbort()) {
                    log.warn("【Pre-request Script】中止请求");
                    return ApiResponse.builder()
                            .success(false)
                            .error("Pre-request Script中止了请求")
                            .preScriptResult(preScriptResult)
                            .responseTime(System.currentTimeMillis() - startTime)
                            .build();
                }
            } else {
                log.info("【Pre-request Script】无");
            }

            // 替换变量
            String url = replaceVariables(request.getUrl(), currentVars);
            String body = replaceVariables(request.getBodyContent(), currentVars);

            // 构建完整的URL（包含query参数）
            url = buildUrlWithParams(url, request.getParams(), currentVars);

            log.info("【构建请求】url=%s, body=%s", url, body != null && body.length() > 200 ? body.substring(0, 200) + "..." : body);

            // 构建HTTP请求
            HttpHeaders headers = buildHeaders(request.getHeaders(), currentVars);
            HttpEntity<String> entity = new HttpEntity<>(body, headers);

            log.info("【发送HTTP请求】...");

            // 发送请求
            ResponseEntity<String> httpResponse = restTemplate.exchange(
                    url,
                    HttpMethod.valueOf(request.getMethod().toUpperCase()),
                    entity,
                    String.class
            );

            long duration = System.currentTimeMillis() - startTime;

            log.info("【HTTP响应】status=%d, duration=%dms, body长度=%d",
                    httpResponse.getStatusCode().value(), duration,
                    httpResponse.getBody() != null ? httpResponse.getBody().length() : 0);

            response = ApiResponse.builder()
                    .success(true)
                    .statusCode(httpResponse.getStatusCode().value())
                    .headers(httpResponse.getHeaders().toSingleValueMap())
                    .body(httpResponse.getBody())
                    .responseTime(duration)
                    .preScriptResult(preScriptResult)
                    .build();

            // 执行Tests脚本
            if (request.getPostScript() != null && !request.getPostScript().isBlank()) {
                log.info("【Tests脚本】开始执行, 内容长度=%d", request.getPostScript().length());
                postScriptResult = scriptEngine.executeTests(request.getPostScript(), request, response, currentVars);
                log.info("【Tests脚本】执行结果: success=%s, abort=%s, error=%s, logs=%s, testResults=%s",
                        postScriptResult.isSuccess(), postScriptResult.isAbort(), postScriptResult.getError(),
                        postScriptResult.getLogs(), postScriptResult.getTestResults());
                if (postScriptResult.getVariables() != null && !postScriptResult.getVariables().isEmpty()) {
                    log.info("【Tests脚本】更新变量: %s", postScriptResult.getVariables());
                    currentVars.putAll(postScriptResult.getVariables());
                }
                if (!postScriptResult.isSuccess()) {
                    log.warn("【Tests脚本】执行失败: %s", postScriptResult.getError());
                }
                if (postScriptResult.isAbort()) {
                    response.setAbort(true);
                    response.setAbortReason("Tests脚本中止了请求");
                }
                response.setPostScriptResult(postScriptResult);
            } else {
                log.info("【Tests脚本】无");
            }

            // 执行断言
            if (request.getAssertions() != null && !request.getAssertions().isBlank()) {
                log.info("【断言】开始执行, 内容长度=%d", request.getAssertions().length());
                List<AssertionEngine.AssertionResult> assertionResults = assertionEngine.executeAssertions(
                        request.getAssertions(), response);
                log.info("【断言】执行完成, 结果数=%d", assertionResults.size());
                for (AssertionEngine.AssertionResult ar : assertionResults) {
                    log.info("  断言结果: name=%s, passed=%s, expected=%s, actual=%s",
                            ar.getName(), ar.isPassed(), ar.getExpected(), ar.getActual());
                }
                response.setAssertionResults(assertionResults);
            } else {
                log.info("【断言】无");
            }

            log.info("========== API请求结束 ==========");

        } catch (Exception e) {
            long duration = System.currentTimeMillis() - startTime;
            log.error("API执行失败: %s", e.getMessage(), e);

            response = ApiResponse.builder()
                    .success(false)
                    .error(e.getMessage())
                    .responseTime(duration)
                    .build();
        }

        // 保存历史记录（仅当需要时）
        if (saveHistory) {
            saveRequestHistory(request, response, currentVars, suiteExecutionId, executedBy);
        }

        return response;
    }

    /**
     * 执行API请求（快捷方法，不保存历史）
     */
    public ApiResponse execute(ApiRequest request, Map<String, String> variables) {
        return executeRequest(request, variables, null, null, false);
    }

    /**
     * 执行API请求并保存历史记录
     */
    public ApiResponse execute(ApiRequest request, Map<String, String> variables,
                               Long suiteExecutionId, Long executedBy) {
        return executeRequest(request, variables, suiteExecutionId, executedBy, true);
    }

    /**
     * 执行API请求不保存历史记录（用于临时请求）
     * @deprecated 使用 {@link #execute(ApiRequest, Map)} 代替
     */
    @Deprecated
    public ApiResponse executeWithoutHistory(ApiRequest request, Map<String, String> variables) {
        return executeRequest(request, variables, null, null, false);
    }

    /**
     * 构建带参数的完整URL
     */
    private String buildUrlWithParams(String baseUrl, String paramsJson, Map<String, String> variables) {
        if (paramsJson == null || paramsJson.isBlank()) {
            return baseUrl;
        }

        try {
            Map<String, String> params = objectMapper.readValue(paramsJson, Map.class);
            if (params == null || params.isEmpty()) {
                return baseUrl;
            }

            StringBuilder urlBuilder = new StringBuilder(baseUrl);
            boolean hasQueryParams = baseUrl.contains("?");

            for (Map.Entry<String, String> entry : params.entrySet()) {
                String key = replaceVariables(entry.getKey(), variables);
                String value = replaceVariables(entry.getValue(), variables);

                if (key != null && !key.isBlank()) {
                    urlBuilder.append(hasQueryParams ? "&" : "?");
                    urlBuilder.append(key);
                    if (value != null && !value.isBlank()) {
                        urlBuilder.append("=").append(value);
                    }
                    hasQueryParams = true;
                }
            }

            return urlBuilder.toString();
        } catch (Exception e) {
            log.warn("解析params失败: {}", e.getMessage());
            return baseUrl;
        }
    }

    /**
     * 构建请求头
     */
    private HttpHeaders buildHeaders(String headersJson, Map<String, String> variables) {
        HttpHeaders headers = new HttpHeaders();

        // 如果有自定义Content-Type，先不设置默认，后面根据bodyType设置
        boolean hasCustomContentType = false;

        if (headersJson != null && !headersJson.isBlank()) {
            try {
                // 尝试解析为JSON数组格式 [{key, value}, ...]
                if (headersJson.trim().startsWith("[")) {
                    List<Map<String, String>> headerList = objectMapper.readValue(headersJson, List.class);
                    for (Map<String, String> item : headerList) {
                        String key = item.get("key");
                        String value = item.get("value");
                        if (key != null && value != null) {
                            String resolvedValue = replaceVariables(value, variables);
                            headers.add(key, resolvedValue);
                            if (key.equalsIgnoreCase("Content-Type")) {
                                hasCustomContentType = true;
                            }
                        }
                    }
                } else {
                    // 解析为JSON对象格式 {key: value}
                    Map<String, String> headersMap = objectMapper.readValue(headersJson, Map.class);
                    for (Map.Entry<String, String> entry : headersMap.entrySet()) {
                        String value = replaceVariables(entry.getValue(), variables);
                        headers.add(entry.getKey(), value);
                        if (entry.getKey().equalsIgnoreCase("Content-Type")) {
                            hasCustomContentType = true;
                        }
                    }
                }
            } catch (Exception e) {
                log.warn("解析请求头失败: {}", e.getMessage());
            }
        }

        // 设置Content-Type（如果没有自定义的话，根据bodyType设置）
        if (!hasCustomContentType) {
            if (headers.getContentType() == null) {
                headers.setContentType(MediaType.APPLICATION_JSON);
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
