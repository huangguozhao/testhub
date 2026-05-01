package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.ProjectMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectMemberMapper extends BaseMapper<ProjectMember> {

    /**
     * 查询项目成员列表
     */
    List<ProjectMember> selectByProjectId(@Param("projectId") Long projectId);

    /**
     * 查询用户在项目中的角色
     */
    ProjectMember selectByProjectAndUser(@Param("projectId") Long projectId, @Param("userId") Long userId);

    /**
     * 查询用户参与的项目数量
     */
    Long countByUserId(@Param("userId") Long userId);

    /**
     * 检查用户是否为项目成员
     */
    boolean existsByProjectAndUser(@Param("projectId") Long projectId, @Param("userId") Long userId);

    /**
     * 查询用户在所有项目中的角色列表
     */
    List<ProjectMember> selectByUserId(@Param("userId") Long userId);
}
