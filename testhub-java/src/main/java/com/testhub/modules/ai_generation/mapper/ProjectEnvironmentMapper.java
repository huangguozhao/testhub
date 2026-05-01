package com.testhub.modules.ai_generation.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.domain.ProjectEnvironment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface ProjectEnvironmentMapper extends BaseMapper<ProjectEnvironment> {

    /**
     * 查询项目的环境列表
     */
    List<ProjectEnvironment> selectByProjectId(@Param("projectId") Long projectId);

    /**
     * 查询项目的默认环境
     */
    ProjectEnvironment selectDefaultByProjectId(@Param("projectId") Long projectId);
}
