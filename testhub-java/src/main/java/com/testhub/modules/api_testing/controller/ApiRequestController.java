package com.testhub.modules.api_testing.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.api_testing.domain.ApiRequest;
import com.testhub.modules.api_testing.dto.ApiExecuteDTO;
import com.testhub.modules.api_testing.dto.ApiRequestDTO;
import com.testhub.modules.api_testing.http.ApiExecutor;
import com.testhub.modules.api_testing.http.ApiResponse;
import com.testhub.modules.api_testing.service.ApiRequestService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API请求控制器
 */
@Tag(name = "API请求", description = "API请求管理")
@RestController
@RequestMapping("/api/api-requests")
@RequiredArgsConstructor
public class ApiRequestController {

    private final ApiRequestService apiRequestService;

    @GetMapping
    @Operation(summary = "分页查询API请求")
    public Result<PageResult<ApiRequest>> getApiRequestPage(
            @RequestParam(required = false) Long collectionId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<ApiRequest> page = apiRequestService.getApiRequestPage(collectionId, keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取请求详情")
    public Result<ApiRequest> getApiRequest(@PathVariable Long id) {
        ApiRequest request = apiRequestService.getById(id);
        return Result.success(request);
    }

    @PostMapping
    @Operation(summary = "创建API请求")
    public Result<ApiRequest> createApiRequest(@Valid @RequestBody ApiRequestDTO dto) {
        ApiRequest created = apiRequestService.createApiRequest(dto);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新API请求")
    public Result<ApiRequest> updateApiRequest(
            @PathVariable Long id,
            @Valid @RequestBody ApiRequestDTO dto) {
        ApiRequest updated = apiRequestService.updateApiRequest(id, dto);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除API请求")
    public Result<Void> deleteApiRequest(@PathVariable Long id) {
        apiRequestService.deleteApiRequest(id);
        return Result.success();
    }

    @PostMapping("/execute")
    @Operation(summary = "执行API请求")
    public Result<ApiResponse> executeApiRequest(@RequestBody ApiExecuteDTO dto) {
        ApiResponse response = apiRequestService.executeApiRequest(dto);
        return Result.success(response);
    }

    @PostMapping("/{id}/execute")
    @Operation(summary = "执行指定API请求")
    public Result<ApiResponse> executeApiRequestById(
            @PathVariable Long id,
            @RequestParam(required = false) Long environmentId,
            @RequestBody(required = false) String overrideVariables) {
        ApiExecuteDTO dto = new ApiExecuteDTO();
        dto.setRequestId(id);
        dto.setEnvironmentId(environmentId);
        dto.setOverrideVariables(overrideVariables);
        ApiResponse response = apiRequestService.executeApiRequest(dto);
        return Result.success(response);
    }

    @GetMapping("/collection/{collectionId}")
    @Operation(summary = "获取集合下的所有请求")
    public Result<List<ApiRequest>> getRequestsByCollection(@PathVariable Long collectionId) {
        List<ApiRequest> requests = apiRequestService.getRequestsByCollection(collectionId);
        return Result.success(requests);
    }
}
