package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiCollection;
import com.testhub.modules.api_testing.mapper.ApiCollectionMapper;
import com.testhub.modules.api_testing.service.ApiCollectionService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * API集合服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiCollectionServiceImpl extends ServiceImpl<ApiCollectionMapper, ApiCollection> implements ApiCollectionService {

    @Override
    public IPage<ApiCollection> getCollectionPage(Long projectId, Long parentId, String keyword, long current, long size) {
        Page<ApiCollection> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiCollection> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(ApiCollection::getProjectId, projectId);
        }

        if (parentId != null) {
            wrapper.eq(ApiCollection::getParentId, parentId);
        } else {
            wrapper.isNull(ApiCollection::getParentId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(ApiCollection::getName, keyword);
        }

        wrapper.orderByAsc(ApiCollection::getSortOrder);
        return this.page(page, wrapper);
    }

    @Override
    public ApiCollection createCollection(ApiCollection collection) {
        this.save(collection);
        log.info("创建API集合: id={}, name={}", collection.getId(), collection.getName());
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
        this.removeById(id);
        log.info("删除API集合: id={}", id);
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
