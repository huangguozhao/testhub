package com.testhub.modules.api_testing.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.modules.api_testing.domain.ApiProject;
import com.testhub.modules.api_testing.domain.ApiProjectMember;
import com.testhub.modules.api_testing.mapper.ApiProjectMapper;
import com.testhub.modules.api_testing.mapper.ApiProjectMemberMapper;
import com.testhub.modules.api_testing.service.ApiProjectService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

/**
 * API项目管理服务实现
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class ApiProjectServiceImpl extends ServiceImpl<ApiProjectMapper, ApiProject> implements ApiProjectService {

    private final ApiProjectMapper apiProjectMapper;
    private final ApiProjectMemberMapper apiProjectMemberMapper;
    private final UserMapper userMapper;

    @Override
    public IPage<ApiProject> getApiProjectPage(Long projectId, String keyword, long current, long size) {
        Page<ApiProject> page = new Page<>(current, size);
        LambdaQueryWrapper<ApiProject> wrapper = new LambdaQueryWrapper<>();

        if (projectId != null) {
            wrapper.eq(ApiProject::getProjectId, projectId);
        }

        if (keyword != null && !keyword.isBlank()) {
            wrapper.and(w -> w.like(ApiProject::getName, keyword)
                    .or()
                    .like(ApiProject::getDescription, keyword));
        }

        wrapper.orderByDesc(ApiProject::getCreatedAt);
        IPage<ApiProject> result = this.page(page, wrapper);

        if (result.getRecords().isEmpty()) {
            return result;
        }

        // 填充 owner 和 members
        enrichOwnerAndMembers(result.getRecords());

        return result;
    }

    /**
     * 填充 owner 和 members 信息
     */
    private void enrichOwnerAndMembers(List<ApiProject> projects) {
        if (projects.isEmpty()) {
            return;
        }

        // 收集所有 ownerIds
        Set<Long> ownerIds = projects.stream()
                .map(ApiProject::getOwnerId)
                .filter(Objects::nonNull)
                .collect(Collectors.toSet());

        // 收集所有 projectIds
        Set<Long> projectIds = projects.stream()
                .map(ApiProject::getId)
                .collect(Collectors.toSet());

        // 批量查询 owners
        Map<Long, User> ownerMap = new HashMap<>();
        if (!ownerIds.isEmpty()) {
            List<User> owners = userMapper.selectBatchIds(ownerIds);
            ownerMap = owners.stream()
                    .collect(Collectors.toMap(User::getId, u -> u));
        }

        // 批量查询 members（每个项目的成员）
        Map<Long, List<User>> membersMap = new HashMap<>();
        for (Long projectId : projectIds) {
            List<ApiProjectMember> members = apiProjectMemberMapper.selectMembersByProjectId(projectId);
            if (!members.isEmpty()) {
                Set<Long> memberUserIds = members.stream()
                        .map(ApiProjectMember::getUserId)
                        .collect(Collectors.toSet());
                List<User> memberUsers = userMapper.selectBatchIds(memberUserIds);
                membersMap.put(projectId, memberUsers);
            } else {
                membersMap.put(projectId, new ArrayList<>());
            }
        }

        // 设置 owner 和 members
        for (ApiProject project : projects) {
            if (project.getOwnerId() != null) {
                project.setOwner(ownerMap.get(project.getOwnerId()));
            }
            project.setMembers(membersMap.getOrDefault(project.getId(), new ArrayList<>()));
        }
    }

    @Override
    public ApiProject createApiProject(ApiProject apiProject) {
        this.save(apiProject);

        // 如果有成员ID列表，插入成员记录
        if (apiProject.getMemberIds() != null && !apiProject.getMemberIds().isEmpty()) {
            for (Long userId : apiProject.getMemberIds()) {
                ApiProjectMember pm = new ApiProjectMember();
                pm.setProjectId(apiProject.getId());
                pm.setUserId(userId);
                pm.setRole("member");
                apiProjectMemberMapper.insert(pm);
            }
        }

        log.info("创建API项目: id={}, name={}", apiProject.getId(), apiProject.getName());
        return apiProject;
    }

    @Override
    public ApiProject updateApiProject(Long id, ApiProject apiProject) {
        ApiProject existing = this.getById(id);
        if (existing == null) {
            throw new RuntimeException("API项目不存在");
        }

        apiProject.setId(id);
        this.updateById(apiProject);

        // 更新成员（先删后增）
        LambdaQueryWrapper<ApiProjectMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ApiProjectMember::getProjectId, id);
        apiProjectMemberMapper.delete(wrapper);

        if (apiProject.getMemberIds() != null && !apiProject.getMemberIds().isEmpty()) {
            for (Long userId : apiProject.getMemberIds()) {
                ApiProjectMember pm = new ApiProjectMember();
                pm.setProjectId(id);
                pm.setUserId(userId);
                pm.setRole("member");
                apiProjectMemberMapper.insert(pm);
            }
        }

        log.info("更新API项目: id={}", id);
        return apiProject;
    }

    @Override
    public void deleteApiProject(Long id) {
        this.removeById(id);
        // 删除成员记录
        LambdaQueryWrapper<ApiProjectMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ApiProjectMember::getProjectId, id);
        apiProjectMemberMapper.delete(wrapper);
        log.info("删除API项目: id={}", id);
    }
}
