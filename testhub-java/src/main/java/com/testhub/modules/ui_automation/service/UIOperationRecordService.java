package com.testhub.modules.ui_automation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ui_automation.domain.UIOperationRecord;
import com.testhub.modules.ui_automation.dto.UIOperationRecordDTO;

import java.util.List;

/**
 * UI操作记录服务接口
 */
public interface UIOperationRecordService extends IService<UIOperationRecord> {

    IPage<UIOperationRecordDTO> getRecordPage(Long projectId, Long userId, String operationType,
                                                String resourceType, long current, long size);

    UIOperationRecord createRecord(UIOperationRecord record);

    List<UIOperationRecordDTO> getRecentRecords(Long userId, int limit);

    /**
     * 获取操作类型的显示文本
     */
    String getOperationTypeDisplay(String operationType);

    /**
     * 获取资源类型的显示文本
     */
    String getResourceTypeDisplay(String resourceType);
}