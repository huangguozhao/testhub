package com.testhub.modules.project.controller;

import com.baomidou.mybatisplus.core.metadata.IPage;
import com.testhub.common.result.PageResult;
import com.testhub.common.result.Result;
import com.testhub.modules.project.domain.Project;
import com.testhub.modules.project.domain.ProjectEnvironment;
import com.testhub.modules.project.domain.ProjectMember;
import com.testhub.modules.project.service.ProjectService;
import com.testhub.modules.system.security.UserDetailsImpl;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/projects")
@RequiredArgsConstructor
@Tag(name = "项目管理", description = "项目、成员、环境管理")
public class ProjectController {

    private final ProjectService projectService;

    // ========== Project 基本操作 ==========

    @PostMapping
    @Operation(summary = "创建项目")
    public Result<Project> createProject(
            @RequestBody Project project,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        Project created = projectService.createProject(project, userDetails.getId());
        return Result.success(created);
    }

    @GetMapping
    @Operation(summary = "获取我的项目列表")
    public Result<List<Project>> getMyProjects(@AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<Project> projects = projectService.getUserProjects(userDetails.getId());
        return Result.success(projects);
    }

    @GetMapping("/page")
    @Operation(summary = "分页查询项目")
    public Result<PageResult<Project>> getProjectPage(
            @Parameter(description = "关键词搜索") @RequestParam(required = false) String keyword,
            @Parameter(description = "当前页") @RequestParam(defaultValue = "1") long current,
            @Parameter(description = "每页大小") @RequestParam(defaultValue = "20") long size,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        IPage<Project> page = projectService.getProjectPage(keyword, userDetails.getId(), current, size);
        return Result.success(PageResult.of(page));
    }

    @GetMapping("/{id}")
    @Operation(summary = "获取项目详情")
    public Result<Project> getProjectById(@PathVariable Long id) {
        Project project = projectService.getProjectDetail(id);
        return Result.success(project);
    }

    @PutMapping("/{id}")
    @Operation(summary = "更新项目")
    public Result<Project> updateProject(
            @PathVariable Long id,
            @RequestBody Project project,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        Project updated = projectService.updateProject(id, project, userDetails.getId());
        return Result.success(updated);
    }

    @DeleteMapping("/{id}")
    @Operation(summary = "删除项目")
    public Result<Void> deleteProject(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        projectService.deleteProject(id, userDetails.getId());
        return Result.success();
    }

    @GetMapping("/search")
    @Operation(summary = "搜索项目")
    public Result<List<Project>> searchProjects(
            @Parameter(description = "关键词") @RequestParam String keyword,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        List<Project> projects = projectService.searchProjects(keyword, userDetails.getId());
        return Result.success(projects);
    }

    // ========== ProjectMember 成员管理 ==========

    @GetMapping("/{id}/members")
    @Operation(summary = "获取项目成员列表")
    public Result<List<ProjectMember>> getProjectMembers(@PathVariable Long id) {
        List<ProjectMember> members = projectService.getProjectMembers(id);
        return Result.success(members);
    }

    @PostMapping("/{id}/members")
    @Operation(summary = "添加项目成员")
    public Result<ProjectMember> addMember(
            @PathVariable Long id,
            @RequestParam Long userId,
            @RequestParam(defaultValue = "tester") String role,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        ProjectMember member = projectService.addMember(id, userId, role, userDetails.getId());
        return Result.success(member);
    }

    @PutMapping("/{projectId}/members/{memberId}")
    @Operation(summary = "更新成员角色")
    public Result<ProjectMember> updateMemberRole(
            @PathVariable Long projectId,
            @PathVariable Long memberId,
            @RequestParam String role,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        ProjectMember member = projectService.updateMemberRole(projectId, memberId, role, userDetails.getId());
        return Result.success(member);
    }

    @DeleteMapping("/{id}/members/{userId}")
    @Operation(summary = "移除项目成员")
    public Result<Void> removeMember(
            @PathVariable Long id,
            @PathVariable Long userId,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        projectService.removeMember(id, userId, userDetails.getId());
        return Result.success();
    }

    @GetMapping("/{id}/members/role")
    @Operation(summary = "获取当前用户在项目中的角色")
    public Result<String> getMyRole(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        String role = projectService.getUserRole(id, userDetails.getId());
        return Result.success(role);
    }

    // ========== ProjectEnvironment 环境管理 ==========

    @GetMapping("/{id}/environments")
    @Operation(summary = "获取项目环境列表")
    public Result<List<ProjectEnvironment>> getProjectEnvironments(@PathVariable Long id) {
        List<ProjectEnvironment> environments = projectService.getProjectEnvironments(id);
        return Result.success(environments);
    }

    @GetMapping("/{id}/environments/default")
    @Operation(summary = "获取项目默认环境")
    public Result<ProjectEnvironment> getDefaultEnvironment(@PathVariable Long id) {
        ProjectEnvironment env = projectService.getDefaultEnvironment(id);
        return Result.success(env);
    }

    @PostMapping("/{id}/environments")
    @Operation(summary = "创建项目环境")
    public Result<ProjectEnvironment> createEnvironment(
            @PathVariable Long id,
            @RequestBody ProjectEnvironment environment,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        environment.setProjectId(id);
        ProjectEnvironment created = projectService.createEnvironment(environment, userDetails.getId());
        return Result.success(created);
    }

    @PutMapping("/{projectId}/environments/{envId}")
    @Operation(summary = "更新项目环境")
    public Result<ProjectEnvironment> updateEnvironment(
            @PathVariable Long projectId,
            @PathVariable Long envId,
            @RequestBody ProjectEnvironment environment,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        ProjectEnvironment updated = projectService.updateEnvironment(envId, environment, userDetails.getId());
        return Result.success(updated);
    }

    @DeleteMapping("/{projectId}/environments/{envId}")
    @Operation(summary = "删除项目环境")
    public Result<Void> deleteEnvironment(
            @PathVariable Long projectId,
            @PathVariable Long envId,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        projectService.deleteEnvironment(envId, userDetails.getId());
        return Result.success();
    }

    @PutMapping("/{projectId}/environments/{envId}/default")
    @Operation(summary = "设置默认环境")
    public Result<Void> setDefaultEnvironment(
            @PathVariable Long projectId,
            @PathVariable Long envId,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        // 权限检查在 Service 层处理
        projectService.setDefaultEnvironment(projectId, envId, userDetails.getId());
        return Result.success();
    }
}
