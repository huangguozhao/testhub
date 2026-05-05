package com.testhub.modules.api_testing.http;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.ApiRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.mozilla.javascript.Context;
import org.mozilla.javascript.RhinoException;
import org.mozilla.javascript.Scriptable;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.Map;

/**
 * JavaScript脚本引擎 (Pre-request Script / Tests)
 * 使用Mozilla Rhino执行用户编写的JavaScript代码
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class ScriptEngine {

    private final ObjectMapper objectMapper;

    /**
     * 执行Pre-request Script (请求前脚本)
     */
    public ScriptExecutionResult executePreScript(String script, ApiRequest request,
                                                   Map<String, String> variables) {
        if (script == null || script.isBlank()) {
            return ScriptExecutionResult.success();
        }

        Map<String, Object> requestObj = buildRequestObject(request);
        Map<String, String> currentVars = new HashMap<>(variables != null ? variables : new HashMap<>());

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("variables", currentVars);

            Boolean abort = executeScript(script, env);

            Map<String, String> updatedVars = extractVariables(env, currentVars);
            return ScriptExecutionResult.success()
                    .setVariables(updatedVars)
                    .setAbort(abort != null && abort);

        } catch (Exception e) {
            log.error("Pre-request Script执行失败: {}", e.getMessage());
            return ScriptExecutionResult.fail(e.getMessage());
        }
    }

    /**
     * 执行Tests (请求后脚本)
     */
    public ScriptExecutionResult executeTests(String script, ApiRequest request, ApiResponse response,
                                               Map<String, String> variables) {
        if (script == null || script.isBlank()) {
            return ScriptExecutionResult.success();
        }

        Map<String, Object> requestObj = buildRequestObject(request);
        Map<String, Object> responseObj = buildResponseObject(response);
        Map<String, String> currentVars = new HashMap<>(variables != null ? variables : new HashMap<>());

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("response", responseObj);
            env.put("variables", currentVars);

            Boolean abort = executeScript(script, env);

            Map<String, String> updatedVars = extractVariables(env, currentVars);
            return ScriptExecutionResult.success()
                    .setVariables(updatedVars)
                    .setAbort(abort != null && abort);

        } catch (Exception e) {
            log.error("Tests执行失败: {}", e.getMessage());
            return ScriptExecutionResult.fail(e.getMessage());
        }
    }

    private Boolean executeScript(String script, Map<String, Object> env) throws Exception {
        Context cx = Context.enter();
        try {
            Scriptable scope = cx.initStandardObjects();

            // 注入request
            if (env.containsKey("request")) {
                Object requestObj = toRhinoObject(cx, scope, env.get("request"));
                scope.put("request", scope, requestObj);
            }

            // 注入response
            if (env.containsKey("response")) {
                Object responseObj = toRhinoObject(cx, scope, env.get("response"));
                scope.put("response", scope, responseObj);
            }

            // 注入variables
            if (env.containsKey("variables")) {
                Object varsObj = toRhinoObject(cx, scope, env.get("variables"));
                scope.put("variables", scope, varsObj);
            }

            // 执行脚本
            Object result = cx.evaluateString(scope, script, "<cmd>", 1, null);

            // 检查是否有abort属性
            if (result instanceof Scriptable) {
                Object abort = ((Scriptable) result).get("abort", (Scriptable) result);
                if (abort instanceof Boolean) {
                    return (Boolean) abort;
                }
            }

            return null;

        } catch (RhinoException e) {
            log.error("JavaScript执行错误: {}", e.getMessage());
            throw new Exception(e.getMessage());
        } finally {
            Context.exit();
        }
    }

    private Object toRhinoObject(Context cx, Scriptable scope, Object value) {
        if (value instanceof Map) {
            Scriptable obj = cx.newObject(scope);
            for (Map.Entry<?, ?> entry : ((Map<?, ?>) value).entrySet()) {
                Object nestedValue = toRhinoObject(cx, scope, entry.getValue());
                obj.put(String.valueOf(entry.getKey()), obj, nestedValue);
            }
            return obj;
        } else if (value instanceof Iterable) {
            return Context.javaToJS(value, scope);
        } else {
            return Context.javaToJS(value, scope);
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, Object> buildRequestObject(ApiRequest request) {
        Map<String, Object> obj = new HashMap<>();
        obj.put("name", request.getName());
        obj.put("url", request.getUrl());
        obj.put("method", request.getMethod());
        obj.put("headers", parseJsonString(request.getHeaders()));
        obj.put("body", request.getBodyContent());
        obj.put("bodyType", request.getBodyType());
        obj.put("params", parseJsonString(request.getParams()));
        return obj;
    }

    private Map<String, Object> buildResponseObject(ApiResponse response) {
        Map<String, Object> obj = new HashMap<>();
        obj.put("statusCode", response.getStatusCode());
        obj.put("body", response.getBody());
        obj.put("headers", response.getHeaders());
        obj.put("responseTime", response.getResponseTime());
        obj.put("success", response.isSuccess());
        return obj;
    }

    private Map<String, String> parseJsonString(String json) {
        if (json == null || json.isBlank()) {
            return new HashMap<>();
        }
        try {
            Object parsed = objectMapper.readValue(json, Object.class);
            if (parsed instanceof Map) {
                Map<?, ?> map = (Map<?, ?>) parsed;
                Map<String, String> result = new HashMap<>();
                map.forEach((k, v) -> result.put(String.valueOf(k), v != null ? String.valueOf(v) : ""));
                return result;
            }
            return new HashMap<>();
        } catch (Exception e) {
            log.warn("解析JSON失败: {}", e.getMessage());
            return new HashMap<>();
        }
    }

    @SuppressWarnings("unchecked")
    private Map<String, String> extractVariables(Map<String, Object> env, Map<String, String> defaultVars) {
        Object variablesObj = env.get("variables");
        if (variablesObj instanceof Map) {
            Map<String, Object> map = (Map<String, Object>) variablesObj;
            Map<String, String> result = new HashMap<>(defaultVars);
            map.forEach((k, v) -> result.put(k, v != null ? String.valueOf(v) : ""));
            return result;
        }
        return defaultVars;
    }

    /**
     * 脚本执行结果
     */
    @lombok.Data
    @lombok.Builder
    @lombok.NoArgsConstructor
    @lombok.AllArgsConstructor
    public static class ScriptExecutionResult {
        private boolean success;
        private String error;
        private Map<String, String> variables;
        private boolean abort;

        public static ScriptExecutionResult success() {
            return ScriptExecutionResult.builder().success(true).build();
        }

        public static ScriptExecutionResult fail(String error) {
            return ScriptExecutionResult.builder().success(false).error(error).build();
        }

        public ScriptExecutionResult setVariables(Map<String, String> variables) {
            this.variables = variables;
            return this;
        }

        public ScriptExecutionResult setAbort(boolean abort) {
            this.abort = abort;
            return this;
        }
    }
}