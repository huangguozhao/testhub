package com.testhub.modules.ai_generation.report.service.impl;

import com.baomidou.mybatisplus.core.conditions.query.LambdaQueryWrapper;
import com.testhub.modules.ai_generation.domain.TestPlan;
import com.testhub.modules.ai_generation.domain.TestRun;
import com.testhub.modules.ai_generation.domain.TestRunCase;
import com.testhub.modules.ai_generation.mapper.TestCaseMapper;
import com.testhub.modules.ai_generation.mapper.TestPlanMapper;
import com.testhub.modules.ai_generation.mapper.TestRunCaseMapper;
import com.testhub.modules.ai_generation.mapper.TestRunMapper;
import com.testhub.modules.ai_generation.report.service.ReportService;
import com.testhub.modules.system.domain.User;
import com.testhub.modules.system.mapper.UserMapper;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Service
@RequiredArgsConstructor
public class ReportServiceImpl implements ReportService {

    private final TestPlanMapper testPlanMapper;
    private final TestRunMapper testRunMapper;
    private final TestRunCaseMapper testRunCaseMapper;
    private final TestCaseMapper testCaseMapper;
    private final UserMapper userMapper;

    @Override
    public Map<String, Object> getDashboard(Long projectId) {
        // 活跃计划数
        LambdaQueryWrapper<TestPlan> planWrapper = new LambdaQueryWrapper<>();
        planWrapper.eq(TestPlan::getStatus, "in_progress");
        if (projectId != null) {
            planWrapper.eq(TestPlan::getProjectId, projectId);
        }
        long activePlans = testPlanMapper.selectCount(planWrapper);

        // 用例总数
        LambdaQueryWrapper<TestPlan> caseWrapper = new LambdaQueryWrapper<>();
        if (projectId != null) {
            caseWrapper.eq(TestPlan::getProjectId, projectId);
        }
        long totalCases = testCaseMapper.selectCount(null);

        // 获取最近的执行记录统计通过率
        LambdaQueryWrapper<TestRunCase> rcWrapper = new LambdaQueryWrapper<>();
        rcWrapper.isNotNull(TestRunCase::getExecutedAt);
        List<TestRunCase> recentCases = testRunCaseMapper.selectList(rcWrapper);
        long totalExecuted = recentCases.size();
        long totalPassed = recentCases.stream().filter(c -> "passed".equals(c.getStatus())).count();
        double passRate = totalExecuted > 0 ? Math.round((double) totalPassed / totalExecuted * 1000) / 10.0 : 0;

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("active_plans", activePlans);
        result.put("plan_progress", 0);
        result.put("total_cases", totalCases);
        result.put("total_defects", 0);
        result.put("pass_rate", passRate);
        return result;
    }

    @Override
    public Map<String, Integer> getStatusDistribution(Long projectId, Long versionId) {
        LambdaQueryWrapper<TestRunCase> wrapper = new LambdaQueryWrapper<>();
        if (projectId != null) {
            // 通过run关联plan再关联project
            List<TestRun> runs = getRunsByProject(projectId);
            if (runs.isEmpty()) {
                return emptyStatusMap();
            }
            wrapper.in(TestRunCase::getRunId, runs.stream().map(TestRun::getId).collect(Collectors.toList()));
        }
        List<TestRunCase> cases = testRunCaseMapper.selectList(wrapper);

        Map<String, Integer> result = new LinkedHashMap<>();
        result.put("passed", 0);
        result.put("failed", 0);
        result.put("blocked", 0);
        result.put("retest", 0);
        result.put("untested", 0);

        for (TestRunCase c : cases) {
            result.merge(c.getStatus(), 1, Integer::sum);
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> getExecutionTrend(Long projectId, int days) {
        LocalDate today = LocalDate.now();
        LocalDate startDate = today.minusDays(days - 1);
        LocalDateTime startDateTime = LocalDateTime.of(startDate, LocalTime.MIN);

        LambdaQueryWrapper<TestRunCase> wrapper = new LambdaQueryWrapper<>();
        wrapper.ge(TestRunCase::getExecutedAt, startDateTime);
        wrapper.isNotNull(TestRunCase::getExecutedAt);
        wrapper.in(TestRunCase::getStatus, "passed", "failed", "blocked", "retest");

        if (projectId != null) {
            List<TestRun> runs = getRunsByProject(projectId);
            if (runs.isEmpty()) {
                return emptyTrend(startDate, days);
            }
            wrapper.in(TestRunCase::getRunId, runs.stream().map(TestRun::getId).collect(Collectors.toList()));
        }

        List<TestRunCase> cases = testRunCaseMapper.selectList(wrapper);

        // 按日期聚合
        Map<String, Long> dateMap = new HashMap<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (TestRunCase c : cases) {
            if (c.getExecutedAt() != null) {
                String dateStr = c.getExecutedAt().toLocalDate().format(fmt);
                dateMap.merge(dateStr, 1L, Long::sum);
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        for (int i = 0; i < days; i++) {
            String dateStr = startDate.plusDays(i).format(fmt);
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", dateStr);
            item.put("count", dateMap.getOrDefault(dateStr, 0L));
            result.add(item);
        }
        return result;
    }

    @Override
    public List<Map<String, Object>> getDefectDistribution(Long projectId) {
        LambdaQueryWrapper<TestRunCase> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TestRunCase::getStatus, "failed");
        if (projectId != null) {
            List<TestRun> runs = getRunsByProject(projectId);
            if (runs.isEmpty()) {
                return new ArrayList<>();
            }
            wrapper.in(TestRunCase::getRunId, runs.stream().map(TestRun::getId).collect(Collectors.toList()));
        }
        List<TestRunCase> failedCases = testRunCaseMapper.selectList(wrapper);

        // 按bugIds统计（有bug的算缺陷）
        Map<String, Integer> dist = new LinkedHashMap<>();
        dist.put("高", 0);
        dist.put("中", 0);
        dist.put("低", 0);

        for (TestRunCase c : failedCases) {
            if (c.getBugIds() != null && !c.getBugIds().isEmpty()) {
                dist.merge("中", 1, Integer::sum);
            } else {
                dist.merge("低", 1, Integer::sum);
            }
        }

        List<Map<String, Object>> result = new ArrayList<>();
        dist.forEach((k, v) -> {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("name", k);
            item.put("value", v);
            result.add(item);
        });
        return result;
    }

    @Override
    public List<Map<String, Object>> getFailedCasesTop(Long projectId) {
        LambdaQueryWrapper<TestRunCase> wrapper = new LambdaQueryWrapper<>();
        wrapper.eq(TestRunCase::getStatus, "failed");
        if (projectId != null) {
            List<TestRun> runs = getRunsByProject(projectId);
            if (runs.isEmpty()) {
                return new ArrayList<>();
            }
            wrapper.in(TestRunCase::getRunId, runs.stream().map(TestRun::getId).collect(Collectors.toList()));
        }
        List<TestRunCase> failedCases = testRunCaseMapper.selectList(wrapper);

        // 按testCaseId分组统计
        Map<Long, Long> countMap = failedCases.stream()
                .collect(Collectors.groupingBy(TestRunCase::getTestCaseId, Collectors.counting()));

        // 获取用例标题
        List<Map<String, Object>> result = new ArrayList<>();
        countMap.entrySet().stream()
                .sorted(Map.Entry.<Long, Long>comparingByValue().reversed())
                .limit(10)
                .forEach(entry -> {
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("testcase__id", entry.getKey());
                    // 获取用例标题
                    var testCase = testCaseMapper.selectById(entry.getKey());
                    item.put("testcase__title", testCase != null ? testCase.getTitle() : "未知");
                    item.put("fail_count", entry.getValue());
                    result.add(item);
                });
        return result;
    }

    @Override
    public Map<String, Object> getAiEfficiency(Long projectId) {
        long totalCases = testCaseMapper.selectCount(null);

        Map<String, Object> aiVsManual = new LinkedHashMap<>();
        aiVsManual.put("ai", 0);
        aiVsManual.put("manual", totalCases);

        Map<String, Object> result = new LinkedHashMap<>();
        result.put("ai_vs_manual", aiVsManual);
        result.put("adoption_rate", 0);
        result.put("requirement_coverage", 0);
        result.put("saved_hours", 0);
        return result;
    }

    @Override
    public List<Map<String, Object>> getTeamWorkload(Long projectId) {
        LambdaQueryWrapper<TestRunCase> wrapper = new LambdaQueryWrapper<>();
        wrapper.isNotNull(TestRunCase::getExecutorId);
        wrapper.in(TestRunCase::getStatus, "passed", "failed", "blocked", "retest");

        if (projectId != null) {
            List<TestRun> runs = getRunsByProject(projectId);
            if (runs.isEmpty()) {
                return new ArrayList<>();
            }
            wrapper.in(TestRunCase::getRunId, runs.stream().map(TestRun::getId).collect(Collectors.toList()));
        }

        List<TestRunCase> cases = testRunCaseMapper.selectList(wrapper);

        // 按executorId分组
        Map<Long, List<TestRunCase>> grouped = cases.stream()
                .collect(Collectors.groupingBy(TestRunCase::getExecutorId));

        List<Map<String, Object>> result = new ArrayList<>();
        grouped.entrySet().stream()
                .sorted((a, b) -> Long.compare(b.getValue().size(), a.getValue().size()))
                .limit(10)
                .forEach(entry -> {
                    User user = userMapper.selectById(entry.getKey());
                    long defectCount = entry.getValue().stream()
                            .filter(c -> "failed".equals(c.getStatus()) || "blocked".equals(c.getStatus()))
                            .count();
                    Map<String, Object> item = new LinkedHashMap<>();
                    item.put("username", user != null ? user.getUsername() : "用户" + entry.getKey());
                    item.put("execution_count", entry.getValue().size());
                    item.put("defect_count", defectCount);
                    result.add(item);
                });
        return result;
    }

    private List<TestRun> getRunsByProject(Long projectId) {
        // 先获取项目下的计划
        LambdaQueryWrapper<TestPlan> planWrapper = new LambdaQueryWrapper<>();
        planWrapper.eq(TestPlan::getProjectId, projectId);
        List<TestPlan> plans = testPlanMapper.selectList(planWrapper);
        if (plans.isEmpty()) {
            return Collections.emptyList();
        }

        LambdaQueryWrapper<TestRun> runWrapper = new LambdaQueryWrapper<>();
        runWrapper.in(TestRun::getPlanId, plans.stream().map(TestPlan::getId).collect(Collectors.toList()));
        return testRunMapper.selectList(runWrapper);
    }

    private Map<String, Integer> emptyStatusMap() {
        Map<String, Integer> result = new LinkedHashMap<>();
        result.put("passed", 0);
        result.put("failed", 0);
        result.put("blocked", 0);
        result.put("retest", 0);
        result.put("untested", 0);
        return result;
    }

    private List<Map<String, Object>> emptyTrend(LocalDate startDate, int days) {
        List<Map<String, Object>> result = new ArrayList<>();
        DateTimeFormatter fmt = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        for (int i = 0; i < days; i++) {
            Map<String, Object> item = new LinkedHashMap<>();
            item.put("date", startDate.plusDays(i).format(fmt));
            item.put("count", 0);
            result.add(item);
        }
        return result;
    }
}