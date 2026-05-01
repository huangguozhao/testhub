package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.Project;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectMapper extends BaseMapper<Project> {

    /**
     * 查询用户参与的项目列表
     */
    List<Project> selectProjectsByUserId(@Param("userId") Long userId);

    /**
     * 查询项目详情（含创建者信息）
     */
    Project selectProjectWithCreator(@Param("id") Long id);

    /**
     * 关键词搜索项目
     */
    List<Project> searchProjects(@Param("keyword") String keyword, @Param("userId") Long userId);
}
