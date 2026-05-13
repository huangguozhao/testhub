package com.testhub.modules.report.service;

import java.util.List;
import java.util.Map;

public interface ReportService {

    Map<String, Object> getDashboard(Long projectId);

    Map<String, Integer> getStatusDistribution(Long projectId, Long versionId);

    List<Map<String, Object>> getExecutionTrend(Long projectId, int days);

    List<Map<String, Object>> getDefectDistribution(Long projectId);

    List<Map<String, Object>> getFailedCasesTop(Long projectId);

    Map<String, Object> getAiEfficiency(Long projectId);

    List<Map<String, Object>> getTeamWorkload(Long projectId);
}
