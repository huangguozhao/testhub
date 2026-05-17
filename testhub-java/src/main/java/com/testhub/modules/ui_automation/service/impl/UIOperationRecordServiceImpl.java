package com.testhub.modules.ui_automation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ui_automation.domain.UIOperationRecord;
import com.testhub.modules.ui_automation.dto.UIOperationRecordDTO;
import com.testhub.modules.ui_automation.mapper.UIOperationRecordMapper;
import com.testhub.modules.ui_automation.service.UIOperationRecordService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * UI操作记录服务实现
 */
@Service
@RequiredArgsConstructor
public class UIOperationRecordServiceImpl extends ServiceImpl<UIOperationRecordMapper, UIOperationRecord>
        implements UIOperationRecordService {

    private static final Map<String, String> OPERATION_TYPE_DISPLAY = new HashMap<>();
    private static final Map<String, String> RESOURCE_TYPE_DISPLAY = new HashMap<>();
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ISO_LOCAL_DATE_TIME;

    static {
        OPERATION_TYPE_DISPLAY.put("create", "创建");
        OPERATION_TYPE_DISPLAY.put("edit", "编辑");
        OPERATION_TYPE_DISPLAY.put("delete", "删除");
        OPERATION_TYPE_DISPLAY.put("run", "运行");
        OPERATION_TYPE_DISPLAY.put("rerun", "重新运行");
        OPERATION_TYPE_DISPLAY.put("save", "保存");
        OPERATION_TYPE_DISPLAY.put("rename", "重命名");

        RESOURCE_TYPE_DISPLAY.put("project", "项目");
        RESOURCE_TYPE_DISPLAY.put("test_case", "测试用例");
        RESOURCE_TYPE_DISPLAY.put("test_suite", "测试套件");
        RESOURCE_TYPE_DISPLAY.put("element", "页面元素");
        RESOURCE_TYPE_DISPLAY.put("script", "测试脚本");
        RESOURCE_TYPE_DISPLAY.put("execution", "执行记录");
    }

    @Override
    public IPage<UIOperationRecordDTO> getRecordPage(Long projectId, Long userId, String operationType,
                                                     String resourceType, long current, long size) {
        Page<UIOperationRecord> page = new Page<>(current, size);
        LambdaQueryWrapper<UIOperationRecord> queryWrapper = new LambdaQueryWrapper<>();

        if (userId != null) {
            queryWrapper.eq(UIOperationRecord::getUserId, userId);
        }
        if (operationType != null && !operationType.isEmpty()) {
            queryWrapper.eq(UIOperationRecord::getOperationType, operationType);
        }
        if (resourceType != null && !resourceType.isEmpty()) {
            queryWrapper.eq(UIOperationRecord::getResourceType, resourceType);
        }

        queryWrapper.orderByDesc(UIOperationRecord::getCreatedAt);

        IPage<UIOperationRecord> recordPage = this.page(page, queryWrapper);

        // 转换为DTO
        Page<UIOperationRecordDTO> dtoPage = new Page<>(recordPage.getCurrent(), recordPage.getSize(), recordPage.getTotal());
        List<UIOperationRecordDTO> dtoList = recordPage.getRecords().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
        dtoPage.setRecords(dtoList);

        return dtoPage;
    }

    @Override
    public UIOperationRecord createRecord(UIOperationRecord record) {
        this.save(record);
        return record;
    }

    @Override
    public List<UIOperationRecordDTO> getRecentRecords(Long userId, int limit) {
        LambdaQueryWrapper<UIOperationRecord> queryWrapper = new LambdaQueryWrapper<>();
        if (userId != null) {
            queryWrapper.eq(UIOperationRecord::getUserId, userId);
        }
        queryWrapper.orderByDesc(UIOperationRecord::getCreatedAt);
        queryWrapper.last("LIMIT " + limit);

        return this.list(queryWrapper).stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public String getOperationTypeDisplay(String operationType) {
        return OPERATION_TYPE_DISPLAY.getOrDefault(operationType, operationType);
    }

    @Override
    public String getResourceTypeDisplay(String resourceType) {
        return RESOURCE_TYPE_DISPLAY.getOrDefault(resourceType, resourceType);
    }

    private UIOperationRecordDTO convertToDTO(UIOperationRecord record) {
        UIOperationRecordDTO dto = new UIOperationRecordDTO();
        dto.setId(record.getId());
        dto.setOperationType(record.getOperationType());
        dto.setOperationTypeDisplay(getOperationTypeDisplay(record.getOperationType()));
        dto.setResourceType(record.getResourceType());
        dto.setResourceTypeDisplay(getResourceTypeDisplay(record.getResourceType()));
        dto.setResourceId(record.getResourceId());
        dto.setResourceName(record.getResourceName());
        dto.setUserId(record.getUserId());
        dto.setUserName(record.getUserName());
        dto.setCreatedAt(record.getCreatedAt() != null ? record.getCreatedAt().format(DATE_FORMATTER) : null);
        return dto;
    }
}