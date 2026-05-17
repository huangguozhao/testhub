package com.testhub.modules.ui_automation.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.ui_automation.domain.UIOperationRecord;
import com.testhub.modules.ui_automation.dto.UIOperationRecordDTO;
import com.testhub.modules.ui_automation.service.UIOperationRecordService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * UI自动化操作记录控制器
 */
@Tag(name = "UI操作记录", description = "UI自动化模块操作记录查询和管理")
@RestController
@RequestMapping("/api/ui-automation/operation-records")
@RequiredArgsConstructor
public class UIOperationRecordController {

    private final UIOperationRecordService uiOperationRecordService;

    @GetMapping
    @Operation(summary = "分页查询操作记录")
    public Result<PageResult<UIOperationRecordDTO>> getRecordPage(
            @RequestParam(required = false) Long projectId,
            @RequestParam(required = false) Long userId,
            @RequestParam(required = false) String operationType,
            @RequestParam(required = false) String resourceType,
            @RequestParam(required = false, defaultValue = "1") Long current,
            @RequestParam(required = false, defaultValue = "20") Long size,
            @RequestParam(required = false, defaultValue = "10") Integer limit) {

        // 如果传了 limit 参数，返回简单列表
        if (limit != null) {
            List<UIOperationRecordDTO> records = uiOperationRecordService.getRecentRecords(userId, limit);
            return Result.success(PageResult.of(records, records.size(), 1L, limit));
        }

        IPage<UIOperationRecordDTO> page = uiOperationRecordService.getRecordPage(
                projectId, userId, operationType, resourceType, current, size);
        return Result.success(PageResult.of(page));
    }

    @PostMapping
    @Operation(summary = "创建操作记录")
    public Result<UIOperationRecord> createRecord(
            @RequestBody UIOperationRecord record,
            Authentication authentication) {
        if (authentication != null) {
            record.setUserName(authentication.getName());
        }
        UIOperationRecord created = uiOperationRecordService.createRecord(record);
        return Result.success(created);
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取操作记录详情")
    public Result<UIOperationRecord> getRecordDetail(@PathVariable Long id) {
        UIOperationRecord record = uiOperationRecordService.getById(id);
        return Result.success(record);
    }
}