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
    public ScriptResult executePreScript(String script, ApiRequest request, Map<String, String> variables) {
        if (script == null || script.isBlank()) {
            return ScriptResult.success();
        }

        Map<String, Object> requestObj = buildRequestObject(request);
        Map<String, Object> currentVars = new HashMap<>();
        if (variables != null) {
            currentVars.putAll(variables);
        }
        ScriptResult result = ScriptResult.success();

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("variables", currentVars);
            env.put("scriptResult", result);

            Boolean abort = executeScript(script, env, result);

            // 从variables中获取更新后的值
            @SuppressWarnings("unchecked")
            Map<String, String> updatedVars = (Map<String, String>) env.get("variables");
            result.setVariables(updatedVars != null ? updatedVars : variables);
            result.setAbort(abort != null && abort);

        } catch (Exception e) {
            log.error("Pre-request Script执行失败: {}", e.getMessage());
            result.setSuccess(false);
            result.setError(e.getMessage());
        }

        return result;
    }

    /**
     * 执行Tests (请求后脚本)
     */
    public ScriptResult executeTests(String script, ApiRequest request, ApiResponse response,
                                    Map<String, String> variables) {
        if (script == null || script.isBlank()) {
            return ScriptResult.success();
        }

        Map<String, Object> requestObj = buildRequestObject(request);
        Map<String, Object> responseObj = buildResponseObject(response);
        Map<String, Object> currentVars = new HashMap<>();
        if (variables != null) {
            currentVars.putAll(variables);
        }
        ScriptResult result = ScriptResult.success();

        try {
            Map<String, Object> env = new HashMap<>();
            env.put("request", requestObj);
            env.put("response", responseObj);
            env.put("variables", currentVars);
            env.put("scriptResult", result);

            Boolean abort = executeScript(script, env, result);

            // 从variables中获取更新后的值
            @SuppressWarnings("unchecked")
            Map<String, String> updatedVars = (Map<String, String>) env.get("variables");
            result.setVariables(updatedVars != null ? updatedVars : variables);
            result.setAbort(abort != null && abort);

        } catch (Exception e) {
            log.error("Tests执行失败: {}", e.getMessage());
            result.setSuccess(false);
            result.setError(e.getMessage());
        }

        return result;
    }

    private Boolean executeScript(String script, Map<String, Object> env, ScriptResult result) throws Exception {
        Context cx = Context.enter();
        try {
            Scriptable scope = cx.initStandardObjects();

            // 创建console对象
            Scriptable consoleObj = cx.newObject(scope);
            consoleObj.setPrototype(getGlobalPrototype(cx, scope, "console"));
            consoleObj.put("log", consoleObj, new ConsoleFunction("log", result));
            consoleObj.put("info", consoleObj, new ConsoleFunction("info", result));
            consoleObj.put("warn", consoleObj, new ConsoleFunction("warn", result));
            consoleObj.put("error", consoleObj, new ConsoleFunction("error", result));
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

            // 注入variables (使用Scriptable使其可修改)
            NativeObject variablesObj = new NativeObject();
            if (env.containsKey("variables")) {
                @SuppressWarnings("unchecked")
                Map<String, Object> vars = (Map<String, Object>) env.get("variables");
                for (Map.Entry<String, Object> entry : vars.entrySet()) {
                    variablesObj.put(entry.getKey(), variablesObj, entry.getValue());
                }
            }
            scope.put("variables", scope, variablesObj);

            // 注入tests对象
            NativeObject testsObj = new NativeObject();
            scope.put("tests", scope, testsObj);

            // 执行脚本
            Object evalResult = cx.evaluateString(scope, script, "<cmd>", 1, null);

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

            // 从tests中提取测试结果
            if (scope.has("tests", scope)) {
                Object testsResultObj = scope.get("tests", scope);
                if (testsResultObj instanceof NativeObject) {
                    Object[] ids = ((NativeObject) testsResultObj).getIds();
                    for (Object id : ids) {
                        String key = String.valueOf(id);
                        Object value = ((NativeObject) testsResultObj).get(key, (Scriptable) testsResultObj);
                        result.setTestResult(key, Boolean.TRUE.equals(value));
                    }
                }
            }

            // 检查是否有abort属性
            if (evalResult instanceof Scriptable) {
                Object abort = ((Scriptable) evalResult).get("abort", (Scriptable) evalResult);
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
     * Console函数 - 将日志输出到ScriptResult中
     */
    private static class ConsoleFunction extends BaseFunction {
        private final String level;
        private final ScriptResult result;

        public ConsoleFunction(String level, ScriptResult result) {
            this.level = level;
            this.result = result;
        }

        @Override
        public Object call(Context cx, Scriptable scope, Scriptable thisObj, Object[] args) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < args.length; i++) {
                if (i > 0) sb.append(" ");
                sb.append(Context.toString(args[i]));
            }
            String logMessage = sb.toString();

            // 同时输出到后端日志
            if ("error".equals(level)) {
                log.error("[JS Console] {}", logMessage);
            } else if ("warn".equals(level)) {
                log.warn("[JS Console] {}", logMessage);
            } else {
                log.info("[JS Console] {}", logMessage);
            }

            // 添加到ScriptResult的日志列表
            result.addLog("[" + level.toUpperCase() + "] " + logMessage);

            return null;
        }
    }
}
