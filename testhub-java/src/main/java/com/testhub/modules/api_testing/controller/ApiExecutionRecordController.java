package com.testhub.modules.api_testing.controller;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.testhub.common.result.Result;
import com.testhub.config.MinioConfig;
import com.testhub.modules.api_testing.domain.ApiExecutionRecord;
import com.testhub.modules.api_testing.domain.ApiTestSuite;
import com.testhub.modules.api_testing.service.AllureReportGenerator;
import com.testhub.modules.api_testing.service.ApiExecutionRecordService;
import com.testhub.modules.api_testing.service.ApiTestSuiteService;
import com.testhub.modules.storage.service.FileStorageService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.io.ByteArrayInputStream;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * API执行记录控制器
 */
@Slf4j
@Tag(name = "API执行记录", description = "API执行记录管理")
@RestController
@RequestMapping("/api/api-execution-records")
@RequiredArgsConstructor
public class ApiExecutionRecordController {

    private final ApiExecutionRecordService apiExecutionRecordService;
    private final ApiTestSuiteService apiTestSuiteService;
    private final AllureReportGenerator allureReportGenerator;
    private final FileStorageService fileStorageService;
    private final MinioConfig minioConfig;
    private final ObjectMapper objectMapper;

    // 报告生成锁：同一份报告同时只允许一个请求生成，其他请求等待结果
    private final ConcurrentHashMap<Long, Object> reportLocks = new ConcurrentHashMap<>();

    @GetMapping("/project/{projectId}")
    @Operation(summary = "获取项目的执行记录")
    public Result<List<ApiExecutionRecord>> getRecordsByProject(
            @PathVariable Long projectId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        List<ApiExecutionRecord> records = apiExecutionRecordService.getRecordsByProject(projectId, limit);
        return Result.success(records);
    }

    @GetMapping("/suite/{suiteId}")
    @Operation(summary = "获取套件的执行记录")
    public Result<List<ApiExecutionRecord>> getRecordsBySuite(
            @PathVariable Long suiteId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        List<ApiExecutionRecord> records = apiExecutionRecordService.getRecordsBySuite(suiteId, limit);
        return Result.success(records);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取记录详情")
    public Result<ApiExecutionRecord> getRecord(@PathVariable Long id) {
        ApiExecutionRecord record = apiExecutionRecordService.getRecord(id);
        return Result.success(record);
    }

    @GetMapping("/trigger/{triggerId}")
    @Operation(summary = "按触发来源获取执行记录")
    public Result<List<ApiExecutionRecord>> getRecordsByTriggerId(
            @PathVariable Long triggerId,
            @RequestParam(required = false, defaultValue = "50") Integer limit) {
        List<ApiExecutionRecord> records = apiExecutionRecordService.getRecordsByTriggerId(triggerId, limit);
        return Result.success(records);
    }

    @PostMapping("/{id}/generate-allure-report")
    @Operation(summary = "生成Allure报告")
    public Result<Map<String, String>> generateAllureReport(@PathVariable Long id) {
        ApiExecutionRecord record = apiExecutionRecordService.getRecord(id);
        if (record == null) {
            return Result.notFound("执行记录不存在");
        }

        String minioObject = "api-testing/reports/execution_" + id + "/report.html";

        // 1. 检查 MinIO 中是否已有报告
        String bucket = minioConfig.getBucketName();
        if (fileStorageService.fileExists(bucket, minioObject)) {
            String url = getReportUrl(minioObject);
            return Result.success(Map.of("report_url", url));
        }

        // 2. 加锁生成报告（同一份报告同时只允许一个请求生成）
        Object lock = reportLocks.computeIfAbsent(id, k -> new Object());
        synchronized (lock) {
            try {
                // 双重检查
                if (fileStorageService.fileExists(bucket, minioObject)) {
                    String url = getReportUrl(minioObject);
                    return Result.success(Map.of("report_url", url));
                }

                // 3. 生成 HTML 报告
                String html = buildHtmlReport(record);

                // 4. 上传到 MinIO
                byte[] htmlBytes = html.getBytes(StandardCharsets.UTF_8);
                ByteArrayInputStream inputStream = new ByteArrayInputStream(htmlBytes);
                fileStorageService.uploadFile(bucket, minioObject, inputStream, "text/html", htmlBytes.length);

                log.info("报告已上传到 MinIO: executionId={}, object={}", id, minioObject);

                // 5. 返回 URL
                String url = getReportUrl(minioObject);
                return Result.success(Map.of("report_url", url));

            } catch (Exception e) {
                log.error("生成报告失败: {}", e.getMessage(), e);
                return Result.error("生成报告失败: " + e.getMessage());
            } finally {
                reportLocks.remove(id);
            }
        }
    }

    /**
     * 获取报告访问 URL
     */
    private String getReportUrl(String objectName) {
        // 返回 MinIO 直接访问 URL（需要 bucket 设置为公开访问）
        return minioConfig.getEndpoint() + "/" + minioConfig.getBucketName() + "/" + objectName;
    }

    /**
     * 构建 HTML 报告内容
     */
    private String buildHtmlReport(ApiExecutionRecord record) throws Exception {
        List<Map<String, Object>> results = parseResultData(record.getResultData());

        String suiteName = record.getSuiteName();
        if (suiteName == null && record.getSuiteId() != null) {
            ApiTestSuite suite = apiTestSuiteService.getById(record.getSuiteId());
            suiteName = suite != null ? suite.getName() : "未知套件";
        }

        StringBuilder rows = new StringBuilder();
        for (int i = 0; i < results.size(); i++) {
            Map<String, Object> r = results.get(i);
            String name = getStringValue(r, "request_name", "请求 " + (i + 1));
            String method = getStringValue(r, "method", "GET");
            String url = getStringValue(r, "url", "");
            boolean passed = Boolean.TRUE.equals(r.get("success")) || Boolean.TRUE.equals(r.get("passed"));
            Object statusCode = r.get("status_code");
            Object responseTime = r.get("response_time");
            String error = getStringValue(r, "error", "");

            rows.append("<tr class=\"").append(passed ? "passed" : "failed").append("\">");
            rows.append("<td>").append(i + 1).append("</td>");
            rows.append("<td>").append(escapeHtml(name)).append("</td>");
            rows.append("<td><span class=\"method\">").append(method).append("</span></td>");
            rows.append("<td class=\"url\">").append(escapeHtml(url)).append("</td>");
            rows.append("<td>").append(statusCode != null ? statusCode : "-").append("</td>");
            rows.append("<td>").append(responseTime != null ? responseTime + "ms" : "-").append("</td>");
            rows.append("<td><span class=\"badge ").append(passed ? "pass" : "fail").append("\">").append(passed ? "通过" : "失败").append("</span></td>");
            rows.append("<td>").append(escapeHtml(error)).append("</td>");
            rows.append("</tr>\n");
        }

        return """
                <!DOCTYPE html>
                <html lang="zh">
                <head>
                    <meta charset="UTF-8">
                    <title>测试报告 - %s</title>
                    <style>
                        body { font-family: -apple-system, sans-serif; margin: 0; padding: 20px; background: #f5f5f5; }
                        .header { background: #409eff; color: white; padding: 20px; border-radius: 8px; margin-bottom: 20px; }
                        .header h1 { margin: 0; font-size: 20px; }
                        .summary { display: flex; gap: 20px; margin-bottom: 20px; }
                        .card { background: white; padding: 16px 24px; border-radius: 8px; flex: 1; text-align: center; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
                        .card .num { font-size: 28px; font-weight: bold; }
                        .card .label { color: #666; font-size: 13px; }
                        .total .num { color: #303133; }
                        .pass .num { color: #67c23a; }
                        .fail .num { color: #f56c6c; }
                        table { width: 100%%; border-collapse: collapse; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.1); }
                        th { background: #f5f7fa; padding: 12px; text-align: left; font-size: 13px; color: #606266; }
                        td { padding: 10px 12px; border-bottom: 1px solid #ebeef5; font-size: 13px; }
                        tr.passed td { background: #f0f9eb; }
                        tr.failed td { background: #fef0f0; }
                        .method { background: #409eff; color: white; padding: 2px 8px; border-radius: 4px; font-size: 12px; }
                        .url { word-break: break-all; max-width: 300px; }
                        .badge { padding: 2px 10px; border-radius: 10px; font-size: 12px; }
                        .badge.pass { background: #67c23a; color: white; }
                        .badge.fail { background: #f56c6c; color: white; }
                    </style>
                </head>
                <body>
                    <div class="header">
                        <h1>测试报告 - %s</h1>
                        <p>执行时间: %s | 耗时: %dms</p>
                    </div>
                    <div class="summary">
                        <div class="card total"><div class="num">%d</div><div class="label">总请求数</div></div>
                        <div class="card pass"><div class="num">%d</div><div class="label">通过</div></div>
                        <div class="card fail"><div class="num">%d</div><div class="label">失败</div></div>
                    </div>
                    <table>
                        <thead><tr><th>#</th><th>请求名称</th><th>方法</th><th>URL</th><th>状态码</th><th>耗时</th><th>结果</th><th>错误信息</th></tr></thead>
                        <tbody>%s</tbody>
                    </table>
                </body>
                </html>
                """.formatted(
                escapeHtml(suiteName),
                escapeHtml(suiteName),
                record.getExecutedAt() != null ? record.getExecutedAt().toString() : "-",
                record.getDuration() != null ? record.getDuration() : 0,
                record.getTotalCount() != null ? record.getTotalCount() : 0,
                record.getPassCount() != null ? record.getPassCount() : 0,
                record.getFailCount() != null ? record.getFailCount() : 0,
                rows
        );
    }

    @SuppressWarnings("unchecked")
    private List<Map<String, Object>> parseResultData(String resultData) {
        if (resultData == null || resultData.isBlank()) return List.of();
        try {
            return objectMapper.readValue(resultData, new TypeReference<List<Map<String, Object>>>() {});
        } catch (Exception e) {
            log.warn("解析 resultData 失败: {}", e.getMessage());
            return List.of();
        }
    }

    private String getStringValue(Map<String, Object> map, String key, String defaultValue) {
        Object value = map.get(key);
        return value != null ? String.valueOf(value) : defaultValue;
    }

    private String escapeHtml(String str) {
        if (str == null) return "";
        return str.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;");
    }
}
