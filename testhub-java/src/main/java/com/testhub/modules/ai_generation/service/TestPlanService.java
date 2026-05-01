package com.testhub.modules.ai_generation.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.ai_generation.domain.TestPlan;
import com.testhub.modules.ai_generation.dto.TestPlanDTO;

import java.util.List;

/**
 * 测试计划服务接口
 */
public interface TestPlanService extends IService<TestPlan> {

    /**
     * 分页查询计划
     */
    IPage<TestPlan> getTestPlanPage(Long projectId, String keyword, String status, long current, long size);

    /**
     * 创建计划
     */
    TestPlan createTestPlan(TestPlanDTO dto);

    /**
     * 更新计划
     */
    TestPlan updateTestPlan(Long id, TestPlanDTO dto);

    /**
     * 删除计划
     */
    void deleteTestPlan(Long id);

    /**
     * 获取计划详情
     */
    TestPlan getTestPlanDetail(Long id);
}
