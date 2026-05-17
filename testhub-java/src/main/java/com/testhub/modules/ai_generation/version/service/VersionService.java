package com.testhub.modules.ai_generation.version.service;

import com.testhub.modules.ai_generation.version.domain.Version;
import com.testhub.modules.ai_generation.version.mapper.VersionMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Slf4j
@Service
@RequiredArgsConstructor
public class VersionService {

    private final VersionMapper versionMapper;

    /**
     * 分页查询版本列表
     */
    public Map<String, Object> listVersions(int page, int pageSize, Long projectId, String status) {
        var wrapper = new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Version>();
        wrapper.eq(Version::getIsDeleted, 0);

        if (projectId != null) {
            wrapper.eq(Version::getProjectId, projectId);
        }
        if (status != null && !status.isEmpty()) {
            wrapper.eq(Version::getStatus, status);
        }
        wrapper.orderByDesc(Version::getCreatedAt);

        long total = versionMapper.selectCount(wrapper);
        List<Version> versions = versionMapper.selectList(
                wrapper.last("LIMIT " + pageSize + " OFFSET " + (page - 1) * pageSize));

        Map<String, Object> result = new HashMap<>();
        result.put("count", total);
        result.put("results", versions);
        return result;
    }

    /**
     * 获取项目版本列表
     */
    public List<Version> getProjectVersions(Long projectId) {
        return versionMapper.selectList(
                new com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper<Version>()
                        .eq(Version::getProjectId, projectId)
                        .eq(Version::getIsDeleted, 0)
                        .orderByDesc(Version::getCreatedAt));
    }

    /**
     * 获取版本详情
     */
    public Version getVersion(Long id) {
        Version version = versionMapper.selectById(id);
        if (version == null || version.getIsDeleted() == 1) {
            throw new RuntimeException("版本不存在: " + id);
        }
        return version;
    }

    /**
     * 创建版本
     */
    public Version createVersion(Version version) {
        version.setIsDeleted(0);
        versionMapper.insert(version);
        log.info("创建版本: id={}, name={}", version.getId(), version.getName());
        return version;
    }

    /**
     * 更新版本
     */
    public Version updateVersion(Long id, Version versionData) {
        Version version = getVersion(id);
        if (versionData.getName() != null) {
            version.setName(versionData.getName());
        }
        if (versionData.getDescription() != null) {
            version.setDescription(versionData.getDescription());
        }
        if (versionData.getStatus() != null) {
            version.setStatus(versionData.getStatus());
        }
        if (versionData.getReleaseDate() != null) {
            version.setReleaseDate(versionData.getReleaseDate());
        }
        if (versionData.getIsBaseline() != null) {
            version.setIsBaseline(versionData.getIsBaseline());
        }
        versionMapper.updateById(version);
        log.info("更新版本: id={}", id);
        return version;
    }

    /**
     * 删除版本（软删除）
     */
    public void deleteVersion(Long id) {
        Version version = getVersion(id);
        version.setIsDeleted(1);
        versionMapper.updateById(version);
        log.info("删除版本: id={}", id);
    }
}