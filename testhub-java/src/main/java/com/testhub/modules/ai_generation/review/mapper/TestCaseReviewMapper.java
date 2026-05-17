package com.testhub.modules.ai_generation.review.mapper;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.testhub.modules.ai_generation.review.domain.TestCaseReview;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface TestCaseReviewMapper extends BaseMapper<TestCaseReview> {
}