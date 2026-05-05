package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiCollection;
import com.testhub.modules.api_testing.mapper.ApiCollectionMapper;
import com.testhub.modules.api_testing.service.ApiCollectionService;
import com.testhub.modules.api_testing.service.ApiRequestService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.ObjectProvider;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * API集合服务实现
 */
@Slf4j
@Service
public class ApiCollectionServiceImpl extends ServiceImpl<ApiCollectionMapper, ApiCollection> implements ApiCollectionService {

    private final ObjectProvider<ApiRequestService> apiRequestServiceProvider;

    public ApiCollectionServiceImpl(ObjectProvider<ApiRequestService> apiRequestServiceProvider) {
        this.apiRequestServiceProvider = apiRequestServiceProvider;
    }

    @Override
    public IPage<ApiCollection> getCollectionPage(Long projectId, Long parentId, String keyword, long current, long size) {
        Page<ApiCollection> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiCollection> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(ApiCollection::getProjectId, projectId);
        }

        // 如果指定了parentId，只返回该父级的子集合
        if (parentId != null) {
            wrapper.eq(ApiCollection::getParentId, parentId);
        }
        // parentId为null时不加parent_id条件，返回所有集合让前端构建树

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(ApiCollection::getName, keyword)
                    .or()
                    .like(ApiCollection::getDescription, keyword));
        }

        wrapper.orderByAsc(ApiCollection::getSortOrder);
        return this.page(page, wrapper);
    }

    @Override
    public ApiCollection createCollection(ApiCollection collection) {
        // 确保projectId有值
        if (collection.getProjectId() == null) {
            throw new RuntimeException("projectId不能为空");
        }
        this.save(collection);
        log.info("创建API集合: id={}, name={}, projectId={}", collection.getId(), collection.getName(), collection.getProjectId());
        return collection;
    }

    @Override
    public ApiCollection updateCollection(Long id, ApiCollection collection) {
        collection.setId(id);
        this.updateById(collection);
        log.info("更新API集合: id={}", id);
        return collection;
    }

    @Override
    public void deleteCollection(Long id) {
        // 递归获取所有子集合ID（包括自己）
        List<Long> idsToDelete = getAllDescendantIds(id);
        // 先删除集合下的所有请求（延迟获取避免循环依赖）
        ApiRequestService apiRequestService = apiRequestServiceProvider.getObject();
        if (apiRequestService != null) {
            apiRequestService.deleteRequestsByCollectionIds(idsToDelete);
        }
        // 删除所有子集合
        this.removeBatchByIds(idsToDelete);
        log.info("删除API集合(含子集合): id={}, 共删除{}个集合", id, idsToDelete.size());
    }

    /**
     * 递归获取所有后代集合ID（包括自己）
     */
    private List<Long> getAllDescendantIds(Long parentId) {
        List<Long> result = new java.util.ArrayList<>();
        result.add(parentId);
        List<ApiCollection> children = this.list(new LambdaQueryWrapper<ApiCollection>()
                .eq(ApiCollection::getParentId, parentId));
        for (ApiCollection child : children) {
            result.addAll(getAllDescendantIds(child.getId()));
        }
        return result;
    }

    @Override
    public List<ApiCollection> getCollectionsByProject(Long projectId) {
        return this.list(new LambdaQueryWrapper<ApiCollection>()
                .eq(ApiCollection::getProjectId, projectId)
                .orderByAsc(ApiCollection::getSortOrder));
    }

    @Override
    public List<ApiCollection> getChildCollections(Long parentId) {
        return this.list(new LambdaQueryWrapper<ApiCollection>()
                .eq(ApiCollection::getParentId, parentId)
                .orderByAsc(ApiCollection::getSortOrder));
    }

    @Override
    public List<ApiCollection> getCollectionsBySuite(Long suiteId) {
        return this.list(new LambdaQueryWrapper<ApiCollection>()
                .eq(ApiCollection::getSuiteId, suiteId)
                .orderByAsc(ApiCollection::getSortOrder));
    }
}
