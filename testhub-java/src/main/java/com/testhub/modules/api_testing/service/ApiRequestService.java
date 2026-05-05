package com.testhub.modules.api_testing.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.api_testing.domain.ApiRequest;
import com.testhub.modules.api_testing.dto.ApiExecuteDTO;
import com.testhub.modules.api_testing.dto.ApiRequestDTO;
import com.testhub.modules.api_testing.http.ApiResponse;

import java.util.List;

/**
 * API请求服务接口
 */
public interface ApiRequestService extends IService<ApiRequest> {

    IPage<ApiRequest> getApiRequestPage(Long collectionId, String keyword, long current, long size);

    ApiRequest createApiRequest(ApiRequestDTO dto);

    ApiRequest updateApiRequest(Long id, ApiRequestDTO dto);

    void deleteApiRequest(Long id);

    void deleteRequestsByCollectionIds(List<Long> collectionIds);

    ApiResponse executeApiRequest(ApiExecuteDTO dto);

    List<ApiRequest> getRequestsByCollection(Long collectionId);
}
