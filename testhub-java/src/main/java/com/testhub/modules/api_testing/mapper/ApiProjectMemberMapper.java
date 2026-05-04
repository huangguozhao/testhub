package com.testhub.modules.api_testing.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.api_testing.domain.ApiProjectMember;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

/**
 * API项目成员 Mapper
 */
@Mapper
public interface ApiProjectMemberMapper extends BaseMapper<ApiProjectMember> {

    /**
     * 查询项目成员ID列表
     */
    @Select("SELECT user_id FROM api_project_member WHERE project_id = #{projectId} AND is_deleted = 0")
    List<Long> selectUserIdsByProjectId(@Param("projectId") Long projectId);

    /**
     * 查询项目成员列表
     */
    @Select("SELECT pm.*, u.username, u.real_name, u.email, u.avatar, u.status " +
            "FROM api_project_member pm " +
            "INNER JOIN sys_user u ON pm.user_id = u.id " +
            "WHERE pm.project_id = #{projectId} AND pm.is_deleted = 0")
    List<ApiProjectMember> selectMembersByProjectId(@Param("projectId") Long projectId);
}
