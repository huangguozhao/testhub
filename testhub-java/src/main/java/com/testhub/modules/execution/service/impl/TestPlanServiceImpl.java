package com.testhub.modules.execution.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.execution.domain.TestPlan;
import com.testhub.modules.execution.dto.TestPlanDTO;
import com.testhub.modules.execution.mapper.TestPlanMapper;
import com.testhub.modules.execution.service.TestPlanService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

/**
 * 测试计划服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class TestPlanServiceImpl extends ServiceImpl<TestPlanMapper, TestPlan> implements TestPlanService {

    @Override
    public IPage<TestPlan> getTestPlanPage(Long projectId, String keyword, String status, long current, long size) {
        Page<TestPlan> page = new Page<>(current, size);
        LambdaQueryWrapper<TestPlan> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(TestPlan::getProjectId, projectId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(TestPlan::getName, keyword);
        }

        if (status != null && !status.isBlank()) {
            wrapper.eq(TestPlan::getStatus, status);
        }

        wrapper.orderByDesc(TestPlan::getCreatedAt);
        return this.page(page, wrapper);
    }

    @Override
    public TestPlan createTestPlan(TestPlanDTO dto) {
        TestPlan plan = new TestPlan();
        plan.setProjectId(dto.getProjectId());
        plan.setName(dto.getName());
        plan.setDescription(dto.getDescription());
        plan.setStartDate(dto.getStartDate());
        plan.setEndDate(dto.getEndDate());
        plan.setStatus(dto.getStatus() != null ? dto.getStatus() : "pending");
        plan.setAssigneeId(dto.getAssigneeId());

        this.save(plan);
        log.info("创建测试计划: id={}, name={}", plan.getId(), plan.getName());
        return plan;
    }

    @Override
    public TestPlan updateTestPlan(Long id, TestPlanDTO dto) {
        TestPlan plan = this.getById(id);
        if (plan == null) {
            throw new RuntimeException("计划不存在: " + id);
        }

        plan.setName(dto.getName());
        plan.setDescription(dto.getDescription());
        plan.setStartDate(dto.getStartDate());
        plan.setEndDate(dto.getEndDate());
        plan.setStatus(dto.getStatus());
        plan.setAssigneeId(dto.getAssigneeId());

        this.updateById(plan);
        log.info("更新测试计划: id={}", id);
        return plan;
    }

    @Override
    public void deleteTestPlan(Long id) {
        this.removeById(id);
        log.info("删除测试计划: id={}", id);
    }

    @Override
    public TestPlan getTestPlanDetail(Long id) {
        return this.getById(id);
    }
}
