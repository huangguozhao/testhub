package com.testhub.modules.ai_generation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.ai_generation.domain.TestPlan;
import com.testhub.modules.ai_generation.domain.Project;
import com.testhub.modules.ai_generation.dto.TestPlanDTO;
import com.testhub.modules.ai_generation.mapper.TestPlanMapper;
import com.testhub.modules.ai_generation.mapper.ProjectMapper;
import com.testhub.modules.ai_generation.service.TestPlanService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
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

    private final ProjectMapper projectMapper;
    private final UserMapper userMapper;

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
        IPage<TestPlan> result = this.page(page, wrapper);

        // 填充扩展字段：项目名称、创建者名称
        for (TestPlan plan : result.getRecords()) {
            fillExtraFields(plan);
        }

        return result;
    }

    private void fillExtraFields(TestPlan plan) {
        // 设置 isActive 状态
        plan.setIsActive("active".equals(plan.getStatus()));

        // 填充项目名称
        if (plan.getProjectId() != null) {
            Project project = projectMapper.selectById(plan.getProjectId());
            if (project != null) {
                plan.setProjectName(project.getName());
            }
        }

        // 填充创建者名称
        if (plan.getCreatedBy() != null) {
            User user = userMapper.selectById(plan.getCreatedBy());
            if (user != null) {
                plan.setCreatorName(user.getUsername());
            }
        }
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

        log.info("updateTestPlan - dto.getProjectId() = {}", dto.getProjectId());
        log.info("updateTestPlan - before update, plan.projectId = {}", plan.getProjectId());

        // 使用LambdaUpdateWrapper直接更新，避免实体属性比较问题
        com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<TestPlan> updateWrapper =
            new com.baomidou.mybatisplus.core.conditions.update.LambdaUpdateWrapper<>();
        updateWrapper.eq(TestPlan::getId, id);

        if (dto.getName() != null) {
            updateWrapper.set(TestPlan::getName, dto.getName());
        }
        if (dto.getDescription() != null) {
            updateWrapper.set(TestPlan::getDescription, dto.getDescription());
        }
        if (dto.getProjectId() != null) {
            updateWrapper.set(TestPlan::getProjectId, dto.getProjectId());
            log.info("updateTestPlan - set projectId to {}", dto.getProjectId());
        }
        if (dto.getStartDate() != null) {
            updateWrapper.set(TestPlan::getStartDate, dto.getStartDate());
        }
        if (dto.getEndDate() != null) {
            updateWrapper.set(TestPlan::getEndDate, dto.getEndDate());
        }
        if (dto.getStatus() != null) {
            updateWrapper.set(TestPlan::getStatus, dto.getStatus());
        }
        if (dto.getAssigneeId() != null) {
            updateWrapper.set(TestPlan::getAssigneeId, dto.getAssigneeId());
        }
        // 处理 is_active 字段（激活/停用）
        if (dto.getIsActive() != null) {
            updateWrapper.set(TestPlan::getStatus, dto.getIsActive() ? "active" : "inactive");
        }

        log.info("updateTestPlan - executing update with projectId={}", dto.getProjectId());
        boolean updated = this.update(updateWrapper);
        log.info("updateTestPlan - update result = {}, rows affected", updated);

        // 返回更新后的数据
        TestPlan updatedPlan = this.getById(id);
        log.info("updateTestPlan - after update, plan.projectId = {}", updatedPlan.getProjectId());
        return updatedPlan;
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
