package com.testhub.modules.api_testing.http;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.modules.api_testing.domain.ApiRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.mozilla.javascript.*;
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
        Map<String, Object> currentVars = new HashMap<>();
        if (variables != null) {
            currentVars.putAll(variables);
        }

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("variables", currentVars);

            Boolean abort = executeScript(script, env);

            // 从variables中获取更新后的值
            @SuppressWarnings("unchecked")
            Map<String, String> updatedVars = (Map<String, String>) env.get("variables");
            return ScriptExecutionResult.success()
                    .setVariables(updatedVars != null ? updatedVars : variables)
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
        Map<String, Object> currentVars = new HashMap<>();
        if (variables != null) {
            currentVars.putAll(variables);
        }
        Map<String, Object> testsObj = new HashMap<>(); // 用于存储测试结果

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("response", responseObj);
            env.put("variables", currentVars);
            env.put("tests", testsObj);

            Boolean abort = executeScript(script, env);

            // 从variables中获取更新后的值
            @SuppressWarnings("unchecked")
            Map<String, String> updatedVars = (Map<String, String>) env.get("variables");
            return ScriptExecutionResult.success()
                    .setVariables(updatedVars != null ? updatedVars : variables)
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

            // 创建console对象
            Scriptable consoleObj = cx.newObject(scope);
            consoleObj.setPrototype(getGlobalPrototype(cx, scope, "console"));
            consoleObj.put("log", consoleObj, new ConsolFunction("log"));
            consoleObj.put("info", consoleObj, new ConsolFunction("info"));
            consoleObj.put("warn", consoleObj, new ConsolFunction("warn"));
            consoleObj.put("error", consoleObj, new ConsolFunction("error"));
            scope.put("console", scope, consoleObj);

            // 注入request
            if (env.containsKey("request")) {
                Object requestObj = env.get("request");
                if (requestObj instanceof Map) {
                    scope.put("request", scope, toRhinoObject(cx, scope, (Map<?, ?>) requestObj));
                }
            }

            // 注入response
            if (env.containsKey("response")) {
                Object responseObj = env.get("response");
                if (responseObj instanceof Map) {
                    scope.put("response", scope, toRhinoObject(cx, scope, (Map<?, ?>) responseObj));
                }
            }

            // 注入variables (使用NativeObject使其属性可修改)
            NativeObject variablesObj = new NativeObject();
            if (env.containsKey("variables")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> vars = (Map<String, Object>) env.get("variables");
                for (Map.Entry<String, Object> entry : vars.entrySet()) {
                    variablesObj.put(entry.getKey(), variablesObj, entry.getValue());
                }
            }
            scope.put("variables", scope, variablesObj);

            // 注入tests (仅Tests脚本需要)
            if (env.containsKey("tests")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> tests = (Map<String, Object>) env.get("tests");
                NativeObject testsObj = new NativeObject();
                for (Map.Entry<String, Object> entry : tests.entrySet()) {
                    testsObj.put(entry.getKey(), testsObj, entry.getValue());
                }
                scope.put("tests", scope, testsObj);
            }

            // 执行脚本
            Object result = cx.evaluateString(scope, script, "<cmd>", 1, null);

            // 从variables中提取更新后的值
            if (scope.has("variables", scope)) {
                Object varsObj = scope.get("variables", scope);
                if (varsObj instanceof NativeObject) {
                    Object[] ids = ((NativeObject) varsObj).getIds();
                    Map<String, String> updatedVars = new HashMap<>();
                    for (Object id : ids) {
                        String key = String.valueOf(id);
                        Object value = ((NativeObject) varsObj).get(key, (Scriptable) varsObj);
                        updatedVars.put(key, value != null ? String.valueOf(value) : "");
                    }
                    env.put("variables", updatedVars);
                }
            }

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

    private Scriptable getGlobalPrototype(Context cx, Scriptable scope, String name) {
        return cx.newObject(scope);
    }

    private Object toRhinoObject(Context cx, Scriptable scope, Map<?, ?> map) {
        NativeObject obj = new NativeObject();
        for (Map.Entry<?, ?> entry : map.entrySet()) {
            String key = String.valueOf(entry.getKey());
            Object value = entry.getValue();
            if (value instanceof Map) {
                obj.put(key, obj, toRhinoObject(cx, scope, (Map<?, ?>) value));
            } else if (value instanceof Iterable) {
                obj.put(key, obj, Context.javaToJS(value, scope));
            } else {
                obj.put(key, obj, value);
            }
        }
        return obj;
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

    /**
     * Console函数
     */
    private static class ConsolFunction extends BaseFunction {
        private final String level;

        public ConsolFunction(String level) {
            this.level = level;
        }

        @Override
        public Object call(Context cx, Scriptable scope, Scriptable thisObj, Object[] args) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < args.length; i++) {
                if (i > 0) sb.append(" ");
                sb.append(Context.toString(args[i]));
            }
            if ("error".equals(level)) {
                log.error("[JS Console] {}", sb);
            } else if ("warn".equals(level)) {
                log.warn("[JS Console] {}", sb);
            } else {
                log.info("[JS Console] {}", sb);
            }
            return null;
        }
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