package com.testhub.modules.operation_log.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.operation_log.domain.OperationLog;
import com.testhub.modules.operation_log.mapper.OperationLogMapper;
import com.testhub.modules.operation_log.service.OperationLogService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.scheduling.annotation.Async;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

/**
 * 操作日志服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class OperationLogServiceImpl extends ServiceImpl<OperationLogMapper, OperationLog>
        implements OperationLogService {

    @Override
    @Async
    public void logOperation(String operationType, String resourceType, Long resourceId,
                              String resourceName, String description, Long userId, String username) {
        try {
            OperationLog log = new OperationLog();
            log.setOperationType(operationType);
            log.setResourceType(resourceType);
            log.setResourceId(resourceId);
            log.setResourceName(resourceName);
            log.setUserId(userId);
            log.setUsername(username);

            // 自动生成描述
            if (description == null || description.isBlank()) {
                description = generateDescription(operationType, resourceType, resourceName);
            }
            log.setDescription(description);

            this.save(log);
            OperationLogServiceImpl.log.info("记录操作日志: {} - {} - {}", operationType, resourceType, resourceName);
        } catch (Exception e) {
            // 记录日志失败不影响主业务流程
            OperationLogServiceImpl.log.warn("记录操作日志失败: {}", e.getMessage());
        }
    }

    @Override
    public IPage<OperationLog> getLogPage(String operationType, String resourceType,
                                          Long userId, Long resourceId, long current, long size) {
        Page<OperationLog> page = new Page<>(current, size);
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();

        if (operationType != null && !operationType.isBlank()) {
            wrapper.eq(OperationLog::getOperationType, operationType);
        }

        if (resourceType != null && !resourceType.isBlank()) {
            wrapper.eq(OperationLog::getResourceType, resourceType);
        }

        if (userId != null) {
            wrapper.eq(OperationLog::getUserId, userId);
        }

        if (resourceId != null) {
            wrapper.eq(OperationLog::getResourceId, resourceId);
        }

        wrapper.orderByDesc(OperationLog::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public OperationLog getLogDetail(Long id) {
        return this.getById(id);
    }

    @Override
    public List<OperationLog> getLogsByResource(String resourceType, Long resourceId) {
        return this.list(new LambdaQueryWrapper<OperationLog>()
                .eq(OperationLog::getResourceType, resourceType)
                .eq(OperationLog::getResourceId, resourceId)
                .orderByDesc(OperationLog::getCreatedAt)
                .last("LIMIT 100"));
    }

    @Override
    public List<OperationLog> getLogsByUser(Long userId, int limit) {
        return this.list(new LambdaQueryWrapper<OperationLog>()
                .eq(OperationLog::getUserId, userId)
                .orderByDesc(OperationLog::getCreatedAt)
                .last("LIMIT " + limit));
    }

    @Override
    public void deleteLog(Long id) {
        this.removeById(id);
    }

    @Override
    public int cleanOldLogs(int days) {
        LocalDateTime cutoffTime = LocalDateTime.now().minusDays(days);
        LambdaQueryWrapper<OperationLog> wrapper = new LambdaQueryWrapper<>();
        wrapper.lt(OperationLog::getCreatedAt, cutoffTime);
        return this.remove(wrapper) ? 1 : 0;
    }

    /**
     * 生成操作描述
     */
    private String generateDescription(String operationType, String resourceType, String resourceName) {
        String action = switch (operationType) {
            case "create" -> "创建";
            case "edit" -> "编辑";
            case "delete" -> "删除";
            case "execute" -> "执行";
            case "run" -> "运行";
            case "save" -> "保存";
            default -> operationType;
        };

        String type = switch (resourceType) {
            case "project" -> "项目";
            case "collection" -> "集合";
            case "request" -> "请求";
            case "suite" -> "套件";
            case "environment" -> "环境";
            case "task" -> "任务";
            case "execution" -> "执行记录";
            default -> resourceType;
        };

        String name = resourceName != null ? "「" + resourceName + "」" : "";
        return action + type + name;
    }
}
