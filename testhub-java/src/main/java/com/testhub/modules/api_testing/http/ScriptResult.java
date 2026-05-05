package com.testhub.modules.api_testing.http;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 脚本执行结果
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class ScriptResult {
    private boolean success;
    private String error;
    private List<String> logs;        // console输出的日志
    private Map<String, Boolean> testResults; // tests的结果
    private Map<String, String> variables;   // 更新的变量
    private boolean abort;

    public static ScriptResult success() {
        return ScriptResult.builder()
                .success(true)
                .logs(new ArrayList<>())
                .testResults(new HashMap<>())
                .variables(new HashMap<>())
                .build();
    }

    public static ScriptResult fail(String error) {
        return ScriptResult.builder()
                .success(false)
                .error(error)
                .logs(new ArrayList<>())
                .testResults(new HashMap<>())
                .variables(new HashMap<>())
                .build();
    }

    public void addLog(String log) {
        if (this.logs == null) {
            this.logs = new ArrayList<>();
        }
        this.logs.add(log);
    }

    public void setTestResult(String name, boolean passed) {
        if (this.testResults == null) {
            this.testResults = new HashMap<>();
        }
        this.testResults.put(name, passed);
    }
}
