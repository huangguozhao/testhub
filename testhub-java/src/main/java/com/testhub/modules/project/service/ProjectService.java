package com.testhub.modules.project.service;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.baomidou.mybatisplus.extension.service.IService;
import com.testhub.modules.project.domain.Project;
import com.testhub.modules.project.domain.ProjectMember;
import com.testhub.modules.project.domain.ProjectEnvironment;

import java.util.List;

/**
 * 项目服务接口
 */
public interface ProjectService extends IService<Project> {

    // ========== Project 基本操作 ==========

    /**
     * 创建项目
     */
    Project createProject(Project project, Long creatorId);

    /**
     * 更新项目
     */
    Project updateProject(Long projectId, Project project, Long userId);

    /**
     * 删除项目
     */
    void deleteProject(Long projectId, Long userId);

    /**
     * 获取项目详情
     */
    Project getProjectDetail(Long projectId);

    /**
     * 获取用户参与的项目列表
     */
    List<Project> getUserProjects(Long userId);

    /**
     * 分页查询项目
     */
    IPage<Project> getProjectPage(String keyword, Long userId, long current, long size);

    /**
     * 搜索项目
     */
    List<Project> searchProjects(String keyword, Long userId);

    // ========== ProjectMember 成员管理 ==========

    /**
     * 添加项目成员
     */
    ProjectMember addMember(Long projectId, Long userId, String role, Long requesterId);

    /**
     * 更新成员角色
     */
    ProjectMember updateMemberRole(Long projectId, Long memberId, String role, Long requesterId);

    /**
     * 移除项目成员
     */
    void removeMember(Long projectId, Long userId, Long requesterId);

    /**
     * 获取项目成员列表
     */
    List<ProjectMember> getProjectMembers(Long projectId);

    /**
     * 获取用户在项目中的角色
     */
    String getUserRole(Long projectId, Long userId);

    /**
     * 检查用户是否为项目成员
     */
    boolean isProjectMember(Long projectId, Long userId);

    /**
     * 检查用户是否为项目负责人
     */
    boolean isProjectOwner(Long projectId, Long userId);

    // ========== ProjectEnvironment 环境管理 ==========

    /**
     * 创建项目环境
     */
    ProjectEnvironment createEnvironment(ProjectEnvironment environment, Long userId);

    /**
     * 更新项目环境
     */
    ProjectEnvironment updateEnvironment(Long envId, ProjectEnvironment environment, Long userId);

    /**
     * 删除项目环境
     */
    void deleteEnvironment(Long envId, Long userId);

    /**
     * 获取项目环境列表
     */
    List<ProjectEnvironment> getProjectEnvironments(Long projectId);

    /**
     * 获取项目默认环境
     */
    ProjectEnvironment getDefaultEnvironment(Long projectId);

    /**
     * 设置默认环境
     */
    void setDefaultEnvironment(Long projectId, Long envId, Long userId);
}
