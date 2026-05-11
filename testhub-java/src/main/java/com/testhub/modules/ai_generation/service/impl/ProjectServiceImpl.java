package com.testhub.modules.ai_generation.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.plugins.pagination.Page;
import com.baomidou.mybatisplus.extension.service.impl.ServiceImpl;
import com.testhub.common.exception.BusinessException;
import com.testhub.modules.ai_generation.domain.Project;
import com.testhub.modules.ai_generation.domain.ProjectEnvironment;
import com.testhub.modules.ai_generation.domain.ProjectMember;
import com.testhub.modules.ai_generation.mapper.ProjectEnvironmentMapper;
import com.testhub.modules.ai_generation.mapper.ProjectMapper;
import com.testhub.modules.ai_generation.mapper.ProjectMemberMapper;
import com.testhub.modules.ai_generation.service.ProjectService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ProjectServiceImpl extends ServiceImpl<ProjectMapper, Project> implements ProjectService {

    private final ProjectMapper projectMapper;
    private final ProjectMemberMapper projectMemberMapper;
    private final ProjectEnvironmentMapper projectEnvironmentMapper;
    private final UserMapper userMapper;

    // ========== Project 基本操作 ==========

    @Override
    @Transactional
    public Project createProject(Project project, Long creatorId) {
        // 设置创建者
        project.setOwnerId(creatorId);
        project.setStatus("active");
        projectMapper.insert(project);

        // 创建者自动成为项目负责人
        ProjectMember ownerMember = new ProjectMember();
        ownerMember.setProjectId(project.getId());
        ownerMember.setUserId(creatorId);
        ownerMember.setRole("owner");
        ownerMember.setJoinedAt(LocalDateTime.now());
        projectMemberMapper.insert(ownerMember);

        // 创建默认环境
        ProjectEnvironment defaultEnv = new ProjectEnvironment();
        defaultEnv.setProjectId(project.getId());
        defaultEnv.setName("默认环境");
        defaultEnv.setBaseUrl("");
        defaultEnv.setIsDefault(true);
        projectEnvironmentMapper.insert(defaultEnv);

        return project;
    }

    @Override
    @Transactional
    public Project updateProject(Long projectId, Project project, Long userId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限更新该项目");
        }

        Project existProject = projectMapper.selectById(projectId);
        if (existProject == null) {
            throw new BusinessException("项目不存在");
        }

        if (project.getName() != null) {
            existProject.setName(project.getName());
        }
        if (project.getDescription() != null) {
            existProject.setDescription(project.getDescription());
        }
        if (project.getStatus() != null) {
            existProject.setStatus(project.getStatus());
        }

        projectMapper.updateById(existProject);
        return projectMapper.selectById(projectId);
    }

    @Override
    @Transactional
    public void deleteProject(Long projectId, Long userId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限删除该项目");
        }

        Project project = projectMapper.selectById(projectId);
        if (project == null) {
            throw new BusinessException("项目不存在");
        }

        // 软删除：设置 is_deleted = 1
        project.setIsDeleted(1);
        projectMapper.updateById(project);
    }

    /**
     * 检查用户是否为管理员
     */
    private boolean isAdmin(Long userId) {
        User user = userMapper.selectById(userId);
        if (user == null) {
            return false;
        }
        return user.getIsSuperuser() != null && user.getIsSuperuser() == 1
                || "ADMIN".equals(user.getRoleName());
    }

    @Override
    public Project getProjectDetail(Long projectId) {
        Project project = projectMapper.selectProjectWithCreator(projectId);
        if (project != null) {
            // 填充成员信息
            List<ProjectMember> members = projectMemberMapper.selectByProjectId(projectId);
            project.setMembers(members);

            // 填充环境信息
            List<ProjectEnvironment> environments = projectEnvironmentMapper.selectByProjectId(projectId);
            project.setEnvironments(environments);
        }
        return project;
    }

    @Override
    public List<Project> getUserProjects(Long userId) {
        return projectMapper.selectProjectsByUserId(userId);
    }

    @Override
    public IPage<Project> getProjectPage(String keyword, Long userId, long current, long size) {
        Page<Project> page = new Page<>(current, size);
        LambdaQueryWrapper<Project> wrapper = new LambdaQueryWrapper<>();

        if (keyword != null && !keyword.isBlank()) {
            wrapper.like(Project::getName, keyword)
                    .or()
                    .like(Project::getDescription, keyword);
        }

        wrapper.eq(Project::getStatus, "active");
        wrapper.orderByDesc(Project::getCreatedAt);

        return projectMapper.selectPage(page, wrapper);
    }

    @Override
    public List<Project> searchProjects(String keyword, Long userId) {
        return projectMapper.searchProjects(keyword, userId);
    }

    // ========== ProjectMember 成员管理 ==========

    @Override
    @Transactional
    public ProjectMember addMember(Long projectId, Long userId, String role, Long requesterId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, requesterId) && !isAdmin(requesterId)) {
            throw new BusinessException("没有权限添加项目成员");
        }

        // 检查项目是否存在
        if (projectMapper.selectById(projectId) == null) {
            throw new BusinessException("项目不存在");
        }

        // 检查是否已是成员
        if (projectMemberMapper.existsByProjectAndUser(projectId, userId)) {
            throw new BusinessException("用户已是项目成员");
        }

        ProjectMember member = new ProjectMember();
        member.setProjectId(projectId);
        member.setUserId(userId);
        member.setRole(role != null ? role : "tester");
        member.setJoinedAt(LocalDateTime.now());
        projectMemberMapper.insert(member);

        return member;
    }

    @Override
    @Transactional
    public ProjectMember updateMemberRole(Long projectId, Long memberId, String role, Long requesterId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, requesterId) && !isAdmin(requesterId)) {
            throw new BusinessException("没有权限更新成员角色");
        }

        ProjectMember member = projectMemberMapper.selectById(memberId);
        if (member == null) {
            throw new BusinessException("成员不存在");
        }
        member.setRole(role);
        projectMemberMapper.updateById(member);
        return member;
    }

    @Override
    @Transactional
    public void removeMember(Long projectId, Long userId, Long requesterId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, requesterId) && !isAdmin(requesterId)) {
            throw new BusinessException("没有权限移除项目成员");
        }

        LambdaQueryWrapper<ProjectMember> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProjectMember::getProjectId, projectId)
                .eq(ProjectMember::getUserId, userId);
        projectMemberMapper.delete(wrapper);
    }

    @Override
    public List<ProjectMember> getProjectMembers(Long projectId) {
        return projectMemberMapper.selectByProjectId(projectId);
    }

    @Override
    public String getUserRole(Long projectId, Long userId) {
        ProjectMember member = projectMemberMapper.selectByProjectAndUser(projectId, userId);
        return member != null ? member.getRole() : null;
    }

    @Override
    public boolean isProjectMember(Long projectId, Long userId) {
        return projectMemberMapper.existsByProjectAndUser(projectId, userId);
    }

    @Override
    public boolean isProjectOwner(Long projectId, Long userId) {
        String role = getUserRole(projectId, userId);
        return "owner".equals(role);
    }

    // ========== ProjectEnvironment 环境管理 ==========

    @Override
    @Transactional
    public ProjectEnvironment createEnvironment(ProjectEnvironment environment, Long userId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(environment.getProjectId(), userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限创建项目环境");
        }

        if (projectMapper.selectById(environment.getProjectId()) == null) {
            throw new BusinessException("项目不存在");
        }
        projectEnvironmentMapper.insert(environment);
        return environment;
    }

    @Override
    @Transactional
    public ProjectEnvironment updateEnvironment(Long envId, ProjectEnvironment environment, Long userId) {
        ProjectEnvironment existEnv = projectEnvironmentMapper.selectById(envId);
        if (existEnv == null) {
            throw new BusinessException("环境不存在");
        }

        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(existEnv.getProjectId(), userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限更新项目环境");
        }

        if (environment.getName() != null) {
            existEnv.setName(environment.getName());
        }
        if (environment.getBaseUrl() != null) {
            existEnv.setBaseUrl(environment.getBaseUrl());
        }
        if (environment.getDescription() != null) {
            existEnv.setDescription(environment.getDescription());
        }
        if (environment.getVariables() != null) {
            existEnv.setVariables(environment.getVariables());
        }

        projectEnvironmentMapper.updateById(existEnv);
        return existEnv;
    }

    @Override
    @Transactional
    public void deleteEnvironment(Long envId, Long userId) {
        ProjectEnvironment existEnv = projectEnvironmentMapper.selectById(envId);
        if (existEnv == null) {
            throw new BusinessException("环境不存在");
        }

        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(existEnv.getProjectId(), userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限删除项目环境");
        }

        projectEnvironmentMapper.deleteById(envId);
    }

    @Override
    public List<ProjectEnvironment> getProjectEnvironments(Long projectId) {
        return projectEnvironmentMapper.selectByProjectId(projectId);
    }

    @Override
    public ProjectEnvironment getDefaultEnvironment(Long projectId) {
        return projectEnvironmentMapper.selectDefaultByProjectId(projectId);
    }

    @Override
    @Transactional
    public void setDefaultEnvironment(Long projectId, Long envId, Long userId) {
        // 检查权限：必须是项目负责人或管理员
        if (!isProjectOwner(projectId, userId) && !isAdmin(userId)) {
            throw new BusinessException("没有权限设置默认环境");
        }

        // 取消当前默认环境
        LambdaQueryWrapper<ProjectEnvironment> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(ProjectEnvironment::getProjectId, projectId)
                .eq(ProjectEnvironment::getIsDefault, true);
        List<ProjectEnvironment> defaultEnvs = projectEnvironmentMapper.selectList(wrapper);
        for (ProjectEnvironment env : defaultEnvs) {
            env.setIsDefault(false);
            projectEnvironmentMapper.updateById(env);
        }

        // 设置新的默认环境
        ProjectEnvironment newDefault = projectEnvironmentMapper.selectById(envId);
        if (newDefault != null && newDefault.getProjectId().equals(projectId)) {
            newDefault.setIsDefault(true);
            projectEnvironmentMapper.updateById(newDefault);
        }
    }
}
