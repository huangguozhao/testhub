package com.testhub.modules.api_testing.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.*;
import java.net.URI;
import java.nio.file.*;
import java.util.zip.ZipEntry;
import java.util.zip.ZipInputStream;

/**
 * Allure 报告生成服务
 * 自动下载 allure-commandline 并生成 HTML 报告
 */
@Slf4j
@Service
public class AllureReportGenerator {

    private static final String ALLURE_VERSION = "2.32.0";
    private static final String DOWNLOAD_URL = "https://github.com/allure-framework/allure-commandline/releases/download/"
            + ALLURE_VERSION + "/allure-" + ALLURE_VERSION + ".zip";

    private final String basePath;
    private final String toolsDir;
    private volatile boolean allureAvailable = false;

    public AllureReportGenerator() {
        this.basePath = System.getProperty("user.dir");
        this.toolsDir = basePath + "/tools";
    }

    /**
     * 生成 Allure HTML 报告
     *
     * @param resultsDir 包含 Allure JSON 结果文件的目录
     * @param reportDir  输出 HTML 报告的目录
     * @return true 如果成功生成 Allure 报告
     */
    public boolean generateReport(String resultsDir, String reportDir) {
        try {
            Path allureCmd = findAllureExecutable();
            if (allureCmd == null) {
                log.warn("Allure CLI 不可用，尝试自动下载...");
                if (!downloadAndExtractAllure()) {
                    log.error("Allure CLI 下载失败");
                    return false;
                }
                allureCmd = findAllureExecutable();
                if (allureCmd == null) {
                    log.error("Allure CLI 下载后仍不可用");
                    return false;
                }
            }

            // 清理旧报告
            Path reportPath = Path.of(reportDir);
            if (Files.exists(reportPath)) {
                deleteDirectory(reportPath);
            }
            Files.createDirectories(reportPath);

            // 执行 allure generate
            ProcessBuilder pb = new ProcessBuilder(
                    allureCmd.toString(),
                    "generate",
                    "--clean",
                    "--output", reportDir,
                    resultsDir
            );
            pb.redirectErrorStream(true);
            pb.environment().put("JAVA_HOME", System.getProperty("java.home"));

            Process process = pb.start();

            // 读取输出
            StringBuilder output = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    output.append(line).append("\n");
                    log.info("[Allure] {}", line);
                }
            }

            int exitCode = process.waitFor();
            if (exitCode == 0) {
                log.info("Allure 报告生成成功");
                allureAvailable = true;
                return true;
            } else {
                log.warn("Allure 命令执行失败，exitCode={}, output={}", exitCode, output);
                return false;
            }

        } catch (Exception e) {
            log.error("Allure 报告生成异常: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * 查找 Allure 可执行文件
     */
    private Path findAllureExecutable() {
        boolean isWindows = System.getProperty("os.name").toLowerCase().contains("win");
        String executable = isWindows ? "allure.bat" : "allure";

        // 优先检查项目 tools 目录
        Path toolsPath = Path.of(toolsDir, "allure", "bin", executable);
        if (Files.exists(toolsPath)) {
            return toolsPath;
        }

        // 检查系统 PATH
        try {
            ProcessBuilder pb = new ProcessBuilder(isWindows ? "where" : "which", "allure");
            pb.redirectErrorStream(true);
            Process process = pb.start();
            try (BufferedReader reader = new BufferedReader(new InputStreamReader(process.getInputStream()))) {
                String line = reader.readLine();
                if (line != null && !line.isBlank() && Files.exists(Path.of(line.trim()))) {
                    return Path.of(line.trim());
                }
            }
            process.waitFor();
        } catch (Exception ignored) {
        }

        return null;
    }

    /**
     * 下载并解压 Allure CLI
     */
    private boolean downloadAndExtractAllure() {
        try {
            Files.createDirectories(Path.of(toolsDir));

            String zipFileName = "allure-commandline-" + ALLURE_VERSION + ".zip";
            Path zipPath = Path.of(toolsDir, zipFileName);

            // 下载
            if (!Files.exists(zipPath)) {
                log.info("正在下载 Allure CLI v{}...", ALLURE_VERSION);
                log.info("下载地址: {}", DOWNLOAD_URL);

                java.net.URL url = URI.create(DOWNLOAD_URL).toURL();
                try (InputStream in = url.openStream()) {
                    Files.copy(in, zipPath, StandardCopyOption.REPLACE_EXISTING);
                }
                log.info("下载完成: {}", zipPath);
            } else {
                log.info("使用已下载的 Allure CLI: {}", zipPath);
            }

            // 解压
            log.info("正在解压 Allure CLI...");
            Path extractDir = Path.of(toolsDir);
            unzip(zipPath.toString(), extractDir.toString());

            // 验证解压结果
            Path allureBin = findAllureExecutable();
            if (allureBin != null) {
                log.info("Allure CLI 安装成功: {}", allureBin);
                // Linux/Mac 需要添加执行权限
                if (!System.getProperty("os.name").toLowerCase().contains("win")) {
                    allureBin.toFile().setExecutable(true);
                }
                return true;
            } else {
                log.error("Allure CLI 解压后未找到可执行文件");
                return false;
            }

        } catch (Exception e) {
            log.error("下载/解压 Allure CLI 失败: {}", e.getMessage(), e);
            return false;
        }
    }

    /**
     * 解压 ZIP 文件
     */
    private void unzip(String zipFilePath, String destDir) throws IOException {
        try (ZipInputStream zis = new ZipInputStream(new FileInputStream(zipFilePath))) {
            ZipEntry entry;
            while ((entry = zis.getNextEntry()) != null) {
                Path entryPath = Path.of(destDir, entry.getName());

                // 防止 Zip Slip 攻击
                if (!entryPath.normalize().startsWith(Path.of(destDir).normalize())) {
                    throw new IOException("ZIP entry outside target dir: " + entry.getName());
                }

                if (entry.isDirectory()) {
                    Files.createDirectories(entryPath);
                } else {
                    Files.createDirectories(entryPath.getParent());
                    try (OutputStream os = Files.newOutputStream(entryPath)) {
                        zis.transferTo(os);
                    }
                }
                zis.closeEntry();
            }
        }
    }

    /**
     * 递归删除目录
     */
    private void deleteDirectory(Path dir) throws IOException {
        if (Files.isDirectory(dir)) {
            try (var entries = Files.list(dir)) {
                for (Path entry : (Iterable<Path>) entries::iterator) {
                    deleteDirectory(entry);
                }
            }
        }
        Files.deleteIfExists(dir);
    }
}
