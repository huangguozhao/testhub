package com.testhub.modules.api.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api.domain.ApiCollection;

import java.util.List;

/**
 * API集合服务接口
 */
public interface ApiCollectionService extends IService<ApiCollection> {

    IPage<ApiCollection> getCollectionPage(Long projectId, Long parentId, String keyword, long current, long size);

    ApiCollection createCollection(ApiCollection collection);

    ApiCollection updateCollection(Long id, ApiCollection collection);

    void deleteCollection(Long id);

    List<ApiCollection> getCollectionsByProject(Long projectId);

    List<ApiCollection> getChildCollections(Long parentId);

    List<ApiCollection> getCollectionsBySuite(Long suiteId);
}
