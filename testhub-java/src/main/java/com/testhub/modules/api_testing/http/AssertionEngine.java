package com.testhub.modules.api_testing.http;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * 响应断言引擎
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class AssertionEngine {

    private final ObjectMapper objectMapper;

    /**
     * 执行断言
     */
    public List<AssertionResult> executeAssertions(String assertionsJson, ApiResponse response) {
        List<AssertionResult> results = new ArrayList<>();

        if (assertionsJson == null || assertionsJson.isBlank()) {
            return results;
        }

        try {
            List<Map<String, Object>> assertions = objectMapper.readValue(
                    assertionsJson, new TypeReference<List<Map<String, Object>>>() {});

            for (Map<String, Object> assertion : assertions) {
                AssertionResult result = executeSingleAssertion(assertion, response);
                results.add(result);
            }
        } catch (Exception e) {
            log.error("解析断言规则失败: {}", e.getMessage(), e);
            results.add(AssertionResult.fail("断言解析", null, e.getMessage()));
        }

        return results;
    }

    /**
     * 执行单个断言
     */
    private AssertionResult executeSingleAssertion(Map<String, Object> assertion, ApiResponse response) {
        String type = (String) assertion.getOrDefault("type", "");
        String name = (String) assertion.getOrDefault("name", type);

        try {
            return switch (type) {
                case "status_code" -> assertStatusCode(assertion, response, name);
                case "response_time" -> assertResponseTime(assertion, response, name);
                case "contains" -> assertContains(assertion, response, name);
                case "json_path" -> assertJsonPath(assertion, response, name);
                case "equals" -> assertEquals(assertion, response, name);
                case "regex" -> assertRegex(assertion, response, name);
                case "header" -> assertHeader(assertion, response, name);
                default -> AssertionResult.fail(name, null, "未知断言类型: " + type);
            };
        } catch (Exception e) {
            log.error("执行断言失败: {}", e.getMessage(), e);
            return AssertionResult.fail(name, null, e.getMessage());
        }
    }

    private AssertionResult assertStatusCode(Map<String, Object> assertion, ApiResponse response, String name) {
        int expected = ((Number) assertion.get("expected")).intValue();
        int actual = response.getStatusCode() != null ? response.getStatusCode() : 0;
        boolean passed = actual == expected;
        return AssertionResult.of(name, passed, String.valueOf(expected), String.valueOf(actual));
    }

    private AssertionResult assertResponseTime(Map<String, Object> assertion, ApiResponse response, String name) {
        long expected = ((Number) assertion.get("expected")).longValue();
        String operator = (String) assertion.getOrDefault("operator", "<=");
        long actual = response.getResponseTime() != null ? response.getResponseTime() : 0;

        boolean passed = switch (operator) {
            case "<" -> actual < expected;
            case "<=" -> actual <= expected;
            case ">" -> actual > expected;
            case ">=" -> actual >= expected;
            case "==" -> actual == expected;
            case "!=" -> actual != expected;
            default -> actual <= expected;
        };

        return AssertionResult.of(name, passed, expected + "ms (" + operator + ")", actual + "ms");
    }

    private AssertionResult assertContains(Map<String, Object> assertion, ApiResponse response, String name) {
        String expected = (String) assertion.get("expected");
        String actual = response.getBody();
        boolean passed = actual != null && actual.contains(expected);
        return AssertionResult.of(name, passed, "包含: " + expected, passed ? "包含" : "不包含");
    }

    private AssertionResult assertJsonPath(Map<String, Object> assertion, ApiResponse response, String name) {
        String path = (String) assertion.get("path");
        Object expected = assertion.get("expected");
        String operator = (String) assertion.getOrDefault("operator", "==");

        try {
            Object actual = jsonPathParse(response.getBody(), path);
            boolean passed = compareValues(actual, expected, operator);
            return AssertionResult.of(name, passed, formatValue(expected), formatValue(actual));
        } catch (Exception e) {
            return AssertionResult.fail(name, null, "JSONPath解析失败: " + path);
        }
    }

    private AssertionResult assertEquals(Map<String, Object> assertion, ApiResponse response, String name) {
        String path = (String) assertion.getOrDefault("path", "$.code");
        Object expected = assertion.get("expected");

        try {
            Object actual = jsonPathParse(response.getBody(), path);
            boolean passed = String.valueOf(actual).equals(String.valueOf(expected));
            return AssertionResult.of(name, passed, formatValue(expected), formatValue(actual));
        } catch (Exception e) {
            return AssertionResult.fail(name, null, "JSON解析失败: " + path);
        }
    }

    private AssertionResult assertRegex(Map<String, Object> assertion, ApiResponse response, String name) {
        String pattern = (String) assertion.get("pattern");
        String body = response.getBody() != null ? response.getBody() : "";

        try {
            Pattern regex = Pattern.compile(pattern);
            boolean passed = regex.matcher(body).find();
            return AssertionResult.of(name, passed, "匹配: " + pattern, passed ? "匹配成功" : "不匹配");
        } catch (PatternSyntaxException e) {
            return AssertionResult.fail(name, null, "正则表达式语法错误: " + pattern);
        }
    }

    private AssertionResult assertHeader(Map<String, Object> assertion, ApiResponse response, String name) {
        String headerName = (String) assertion.get("name");
        String expected = (String) assertion.get("expected");
        Map<String, String> headers = response.getHeaders();
        String actual = headers != null ? headers.get(headerName) : null;
        boolean passed = actual != null && actual.equals(expected);
        return AssertionResult.of(name, passed, expected, actual != null ? actual : "null");
    }

    private Object jsonPathParse(String json, String path) throws Exception {
        if (json == null || json.isBlank()) return null;

        JsonNode root = objectMapper.readTree(json);
        String jsonPath = path.startsWith("$.") ? path.substring(2) : path;
        String[] parts = jsonPath.split("\\.");
        JsonNode current = root;

        for (String part : parts) {
            if (current == null) return null;

            if (part.contains("[")) {
                int bracketIdx = part.indexOf('[');
                String fieldName = part.substring(0, bracketIdx);
                String arrayIndexStr = part.substring(bracketIdx + 1, part.length() - 1);

                if (!fieldName.isEmpty()) current = current.get(fieldName);
                if (current != null && current.isArray()) {
                    current = current.get(Integer.parseInt(arrayIndexStr));
                } else {
                    return null;
                }
            } else {
                current = current.get(part);
            }
        }

        if (current == null) return null;
        if (current.isTextual()) return current.asText();
        if (current.isNumber()) return current.numberValue();
        if (current.isBoolean()) return current.booleanValue();
        return current.asText();
    }

    private boolean compareValues(Object actual, Object expected, String operator) {
        String actualStr = String.valueOf(actual);
        String expectedStr = String.valueOf(expected);

        return switch (operator) {
            case "==" -> actualStr.equals(expectedStr);
            case "!=" -> !actualStr.equals(expectedStr);
            case "contains" -> actualStr.contains(expectedStr);
            case "startsWith" -> actualStr.startsWith(expectedStr);
            case "endsWith" -> actualStr.endsWith(expectedStr);
            default -> actualStr.equals(expectedStr);
        };
    }

    private String formatValue(Object value) {
        if (value == null) return "null";
        if (value instanceof Number) return value.toString();
        return "\"" + value + "\"";
    }

    @Data
    @lombok.Builder
    public static class AssertionResult {
        private String name;
        private boolean passed;
        private String expected;
        private String actual;
        private String error;

        public static AssertionResult of(String name, boolean passed, String expected, String actual) {
            return AssertionResult.builder()
                    .name(name).passed(passed).expected(expected).actual(actual).build();
        }

        public static AssertionResult fail(String name, String expected, String error) {
            return AssertionResult.builder()
                    .name(name).passed(false).expected(expected).actual(null).error(error).build();
        }
    }
}
