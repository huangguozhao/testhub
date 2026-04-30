package com.testhub.modules.api.http;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.regex.PatternSyntaxException;

/**
 * 响应变量提取引擎
 */
@Slf4j
@Component
@RequiredArgsConstructor
public class VariableExtractor {

    private final ObjectMapper objectMapper;

    /**
     * 从响应中提取变量
     */
    public Map<String, String> extractVariables(String extractorsJson, ApiResponse response) {
        Map<String, String> variables = new HashMap<>();

        if (extractorsJson == null || extractorsJson.isBlank()) {
            return variables;
        }

        try {
            List<Map<String, Object>> extractors = objectMapper.readValue(
                    extractorsJson, new TypeReference<List<Map<String, Object>>>() {});

            for (Map<String, Object> extractor : extractors) {
                String variableName = (String) extractor.get("variable");
                if (variableName == null || variableName.isBlank()) {
                    continue;
                }

                String value = extract(extractor, response);
                if (value != null) {
                    variables.put(variableName, value);
                    log.debug("提取变量: {} = {}", variableName, value);
                }
            }
        } catch (Exception e) {
            log.error("解析变量提取规则失败: {}", e.getMessage(), e);
        }

        return variables;
    }

    /**
     * 执行单个提取
     */
    private String extract(Map<String, Object> extractor, ApiResponse response) {
        String type = (String) extractor.getOrDefault("type", "");
        String variableName = (String) extractor.get("variable");

        try {
            return switch (type) {
                case "json_path" -> extractJsonPath(extractor, response);
                case "regex" -> extractRegex(extractor, response);
                case "header" -> extractHeader(extractor, response);
                case "cookie" -> extractCookie(extractor, response);
                case "body_text" -> extractBodyText(extractor, response);
                default -> {
                    log.warn("未知提取类型: {}", type);
                    yield null;
                }
            };
        } catch (Exception e) {
            log.error("提取变量 {} 失败: {}", variableName, e.getMessage());
            return null;
        }
    }

    /**
     * JSONPath 提取
     */
    private String extractJsonPath(Map<String, Object> extractor, ApiResponse response) {
        String from = (String) extractor.getOrDefault("from", "body");
        String path = (String) extractor.get("path");

        if (path == null || path.isBlank()) {
            return null;
        }

        try {
            String content = "header".equals(from) ? getHeadersAsString(response) : response.getBody();
            if (content == null) {
                return null;
            }

            Object value = jsonPathParse(content, path);
            return value != null ? String.valueOf(value) : null;
        } catch (Exception e) {
            log.warn("JSONPath 提取失败: {} - {}", path, e.getMessage());
            return null;
        }
    }

    /**
     * 正则提取
     */
    private String extractRegex(Map<String, Object> extractor, ApiResponse response) {
        String pattern = (String) extractor.get("pattern");
        String source = (String) extractor.getOrDefault("source", "body");
        int groupIndex = ((Number) extractor.getOrDefault("group", 1)).intValue();

        if (pattern == null || pattern.isBlank()) {
            return null;
        }

        try {
            String content = "header".equals(source) ? getHeadersAsString(response) : response.getBody();
            if (content == null) {
                return null;
            }

            Pattern regex = Pattern.compile(pattern);
            Matcher matcher = regex.matcher(content);
            if (matcher.find() && matcher.groupCount() >= groupIndex) {
                return matcher.group(groupIndex);
            }
            return null;
        } catch (PatternSyntaxException e) {
            log.warn("正则表达式语法错误: {}", pattern);
            return null;
        }
    }

    /**
     * 从响应头提取
     */
    private String extractHeader(Map<String, Object> extractor, ApiResponse response) {
        String headerName = (String) extractor.get("name");
        if (headerName == null) {
            return null;
        }

        Map<String, String> headers = response.getHeaders();
        return headers != null ? headers.get(headerName) : null;
    }

    /**
     * 从Cookie提取
     */
    private String extractCookie(Map<String, Object> extractor, ApiResponse response) {
        String cookieName = (String) extractor.get("name");
        if (cookieName == null) {
            return null;
        }

        Map<String, String> headers = response.getHeaders();
        if (headers == null) {
            return null;
        }

        String setCookie = headers.get("Set-Cookie");
        if (setCookie == null) {
            return null;
        }

        Pattern pattern = Pattern.compile(cookieName + "=([^;]+)");
        Matcher matcher = pattern.matcher(setCookie);
        if (matcher.find()) {
            return matcher.group(1);
        }
        return null;
    }

    /**
     * 提取纯文本
     */
    private String extractBodyText(Map<String, Object> extractor, ApiResponse response) {
        String content = response.getBody();
        if (content == null) {
            return null;
        }
        return content.replaceAll("<[^>]+>", "").trim();
    }

    /**
     * 将响应头转换为字符串
     */
    private String getHeadersAsString(ApiResponse response) {
        Map<String, String> headers = response.getHeaders();
        if (headers == null) {
            return "";
        }

        StringBuilder sb = new StringBuilder();
        headers.forEach((key, value) -> sb.append(key).append(": ").append(value).append("\n"));
        return sb.toString();
    }

    /**
     * 简单的 JSONPath 解析 (支持 $.path.to.value 格式)
     */
    private Object jsonPathParse(String json, String path) throws Exception {
        if (json == null || json.isBlank()) {
            return null;
        }

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

                if (!fieldName.isEmpty()) {
                    current = current.get(fieldName);
                }
                if (current != null && current.isArray()) {
                    int index = Integer.parseInt(arrayIndexStr);
                    current = current.get(index);
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
}
