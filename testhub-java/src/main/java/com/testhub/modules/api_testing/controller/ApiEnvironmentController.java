package com.testhub.modules.api_testing.controller;

import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiEnvironment;
import com.testhub.modules.api_testing.service.ApiEnvironmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * API环境控制器
 */
@Slf4j
@Tag(name = "API环境", description = "API环境管理")
@RestController
@RequestMapping("/api/api-environments")
@RequiredArgsConstructor
public class ApiEnvironmentController {

    private final ApiEnvironmentService apiEnvironmentService;

    @GetMapping
    @Operation(summary = "获取环境列表（支持按作用域和项目过滤）")
    public Result<List<ApiEnvironment>> getEnvironments(
            @RequestParam(required = false) String scope,
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) Long project) {
        // 前端可能发 project 或 projectId
        Long pid = projectId != null ? projectId : project;
        List<ApiEnvironment> environments = apiEnvironmentService.listByScopeAndProject(scope, pid);
        return Result.success(environments);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取环境详情")
    public Result<ApiEnvironment> getEnvironment(@PathVariable Long id) {
        ApiEnvironment environment = apiEnvironmentService.getEnvironmentDetail(id);
        if (environment == null) {
            return Result.notFound("环境不存在");
        }
        return Result.success(environment);
    }

    @PostMapping
    @Operation(summary = "创建环境")
    public Result<ApiEnvironment> createEnvironment(@RequestBody Map<String, Object> body) {
        try {
            ApiEnvironment environment = parseEnvironmentFromBody(body);
            ApiEnvironment created = apiEnvironmentService.createEnvironment(environment);
            return Result.success(created);
        } catch (Exception e) {
            log.error("创建环境失败: {}", e.getMessage(), e);
            return Result.error(e.getMessage());
        }
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新环境")
    public Result<ApiEnvironment> updateEnvironment(
            @PathVariable Long id,
            @RequestBody Map<String, Object> body) {
        try {
            ApiEnvironment environment = parseEnvironmentFromBody(body);
            ApiEnvironment updated = apiEnvironmentService.updateEnvironment(id, environment);
            return Result.success(updated);
        } catch (Exception e) {
            log.error("更新环境失败: {}", e.getMessage(), e);
            return Result.error(e.getMessage());
        }
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除环境")
    public Result<Void> deleteEnvironment(@PathVariable Long id) {
        apiEnvironmentService.deleteEnvironment(id);
        return Result.success();
    }

    @PostMapping("/{id}/activate")
    @Operation(summary = "激活环境")
    public Result<Void> activateEnvironment(@PathVariable Long id) {
        try {
            apiEnvironmentService.activate(id);
            return Result.success("环境已激活", null);
        } catch (Exception e) {
            log.error("激活环境失败: {}", e.getMessage(), e);
            return Result.error(e.getMessage());
        }
    }

    @GetMapping("/default")
    @Operation(summary = "获取项目默认环境")
    public Result<ApiEnvironment> getDefaultEnvironment(@RequestParam Long projectId) {
        ApiEnvironment environment = apiEnvironmentService.getDefaultEnvironment(projectId);
        return Result.success(environment);
    }

    @PutMapping("/{id}/default")
    @Operation(summary = "设置默认环境")
    public Result<Void> setDefaultEnvironment(
            @PathVariable Long id,
            @RequestParam Long projectId) {
        apiEnvironmentService.setDefaultEnvironment(id, projectId);
        return Result.success();
    }

    /**
     * 从前端请求体中解析环境数据
     * 前端发送的字段名: name, scope, project, variables
     * Java实体字段: name, scope, projectId, variables
     */
    private ApiEnvironment parseEnvironmentFromBody(Map<String, Object> body) {
        ApiEnvironment environment = new ApiEnvironment();

        if (body.containsKey("name")) {
            environment.setName((String) body.get("name"));
        }
        if (body.containsKey("scope")) {
            environment.setScope((String) body.get("scope"));
        }
        if (body.containsKey("description")) {
            environment.setDescription((String) body.get("description"));
        }

        // 前端发 "project" 字段，映射到 projectId
        if (body.containsKey("project") && body.get("project") != null) {
            Object projectValue = body.get("project");
            if (projectValue instanceof Number) {
                environment.setProjectId(((Number) projectValue).longValue());
            }
        }

        // variables 字段：前端发送的是 JSON 对象，需要转为字符串存储
        if (body.containsKey("variables")) {
            Object variables = body.get("variables");
            if (variables instanceof String) {
                environment.setVariables((String) variables);
            } else {
                // 对象/Map 类型，序列化为 JSON 字符串
                try {
                    com.fasterxml.jackson.databind.ObjectMapper mapper = new com.fasterxml.jackson.databind.ObjectMapper();
                    environment.setVariables(mapper.writeValueAsString(variables));
                } catch (Exception e) {
                    log.warn("序列化variables失败: {}", e.getMessage());
                    environment.setVariables("{}");
                }
            }
        }

        return environment;
    }
}
