package com.testhub.modules.operation_log.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.modules.operation_log.domain.OperationLog;

import java.util.List;

/**
 * 操作日志服务接口
 */
public interface OperationLogService {

    /**
     * 记录操作日志
     */
    void logOperation(String operationType, String resourceType, Long resourceId,
                      String resourceName, String description, Long userId, String username);

    /**
     * 分页查询日志
     */
    IPage<OperationLog> getLogPage(String operationType, String resourceType,
                                    Long userId, Long resourceId, long current, long size);

    /**
     * 获取日志详情
     */
    OperationLog getLogDetail(Long id);

    /**
     * 获取资源的操作记录
     */
    List<OperationLog> getLogsByResource(String resourceType, Long resourceId);

    /**
     * 获取用户的操作记录
     */
    List<OperationLog> getLogsByUser(Long userId, int limit);

    /**
     * 删除日志
     */
    void deleteLog(Long id);

    /**
     * 清理指定天数之前的日志
     */
    int cleanOldLogs(int days);
}
