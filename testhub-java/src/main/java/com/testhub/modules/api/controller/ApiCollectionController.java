package com.testhub.modules.api.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.api.domain.ApiCollection;
import com.testhub.modules.api.service.ApiCollectionService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * API集合控制器
 */
@Tag(name = "API集合", description = "API集合管理")
@RestController
@RequestMapping("/api/api-collections")
@RequiredArgsConstructor
public class ApiCollectionController {

    private final ApiCollectionService apiCollectionService;

    @GetMapping
    @Operation(summary = "分页查询API集合")
    public Result<PageResult<ApiCollection>> getCollectionPage(
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) Long parentId,
            @RequestParam(required = false) String keyword,
            @RequestParam(defaultValue = "1") long current,
            @RequestParam(defaultValue = "10") long size) {
        IPage<ApiCollection> page = apiCollectionService.getCollectionPage(projectId, parentId, keyword, current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/tree")
    @Operation(summary = "获取集合树形结构")
    public Result<List<ApiCollection>> getCollectionTree(@RequestParam Long projectId) {
        List<ApiCollection> collections = apiCollectionService.getCollectionsByProject(projectId);
        return Result.success(collections);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取集合详情")
    public Result<ApiCollection> getCollection(@PathVariable Long id) {
        ApiCollection collection = apiCollectionService.getById(id);
        return Result.success(collection);
    }

    @PostMapping
    @Operation(summary = "创建集合")
    public Result<ApiCollection> createCollection(@Valid @RequestBody ApiCollection collection) {
        ApiCollection created = apiCollectionService.createCollection(collection);
        return Result.success(created);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新集合")
    public Result<ApiCollection> updateCollection(
            @PathVariable Long id,
            @Valid @RequestBody ApiCollection collection) {
        ApiCollection updated = apiCollectionService.updateCollection(id, collection);
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除集合")
    public Result<Void> deleteCollection(@PathVariable Long id) {
        apiCollectionService.deleteCollection(id);
        return Result.success();
    }
}
