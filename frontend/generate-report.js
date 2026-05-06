const fs = require('fs');

const results = JSON.parse(fs.readFileSync('playwright-report/results.json', 'utf8'));
const tests = results.suites[0].suites[0].specs;

const testMetadata = {
    '1. 验证页面加载和左侧边栏': {
        input: '1. 打开浏览器访问 http://localhost:3001/api-testing/interfaces\n2. 设置localStorage认证信息(access_token, refresh_token, user)',
        expected: '页面加载完成，左侧边栏.sidebar可见，界面元素正常渲染',
        feature: '核心功能'
    },
    '2. 验证项目选择器': {
        input: '1. 等待.sidebar加载完成\n2. 查找.sidebar .el-select第一个元素\n3. 点击项目选择器',
        expected: '项目选择器可见，点击后下拉菜单弹出，选项列表显示',
        feature: '核心功能'
    },
    '3. 创建新集合': {
        input: '1. 等待.sidebar加载\n2. 记录初始树节点数量\n3. 点击第一个创建按钮(.sidebar .el-button)\n4. 等待.el-dialog对话框出现\n5. 输入集合名称"Playwright测试集合"\n6. 点击"创建"按钮',
        expected: '创建对话框出现，输入名称后确认，树节点数量增加，无错误提示',
        feature: '核心功能'
    },
    '4. 创建新接口': {
        input: '1. 等待.sidebar加载\n2. 点击第二个按钮(添加接口按钮)\n3. 等待主内容区加载',
        expected: '主内容区.main-content可见，URL输入框.url-input可见，方法选择器.method-select可见',
        feature: '核心功能'
    },
    '5. 填写接口信息并保存': {
        input: '1. 等待.main-content加载\n2. 查找.url-input input并填写"https://httpbin.org/get"\n3. 查找并点击"保存"按钮',
        expected: 'URL输入框可填写，保存按钮点击后后端返回成功/失败消息，el-message提示出现',
        feature: '核心功能'
    },
    '6. 发送接口请求': {
        input: '1. 等待.main-content加载\n2. 查找"发送"按钮\n3. 点击发送按钮\n4. 等待5秒响应',
        expected: '发送按钮可见，点击后请求发出，响应区域.response-section显示，状态码标签出现',
        feature: '核心功能'
    },
    '7. 树形结构操作': {
        input: '1. 等待.el-tree加载\n2. 记录树节点总数\n3. 查找第一个节点的展开图标.el-tree-node__expand-icon\n4. 点击展开图标\n5. 等待500ms后再次点击',
        expected: '树形节点可以展开和折叠，展开后子节点可见，折叠后子节点隐藏',
        feature: '核心功能'
    },
    '8. 搜索功能': {
        input: '1. 等待.sidebar加载\n2. 查找placeholder包含"搜索"的input\n3. 输入"test"\n4. 等待1500ms\n5. 清空输入框',
        expected: '搜索输入框可见可输入，清空后值为空字符串，搜索触发后端筛选',
        feature: '核心功能'
    },
    '9. 右键菜单': {
        input: '1. 等待.el-tree-node出现\n2. 获取第一个节点文本内容\n3. 对第一个节点进行右键点击\n4. 等待800ms',
        expected: '右键点击后上下文菜单.el-dropdown-menu或.context-menu出现，菜单项数量可统计',
        feature: '核心功能'
    },
    '10. 变量助手': {
        input: '1. 等待.main-content加载\n2. 查找文本包含"变量"的button按钮\n3. 点击变量按钮\n4. 等待1500ms',
        expected: '变量按钮可见，点击后变量面板.variable-panel或包含variable的class元素出现',
        feature: '核心功能'
    },
    '11. 环境切换': {
        input: '1. 等待.main-content加载\n2. 查找.env-select或第一个el-select\n3. 点击环境选择器\n4. 按ESC键关闭',
        expected: '环境选择器可见，点击后下拉菜单出现，按ESC后下拉菜单关闭',
        feature: '核心功能'
    },
    '12. 接口详情标签页切换': {
        input: '1. 等待.main-content可见\n2. 统计.el-tabs数量\n3. 如果有标签页，依次点击Params/Headers/Body/Auth标签',
        expected: '无选中请求时标签页数量为0（预期），有选中请求时标签页可切换',
        feature: '核心功能'
    },
    '13. 响应区域': {
        input: '1. 检查.response-section或.response-panel是否可见\n2. 如果可见，点击Body标签',
        expected: '无请求时响应区域不显示（预期行为），有响应时Body/Headers标签可切换',
        feature: '核心功能'
    },
    '14. 导入CURL功能': {
        input: '1. 等待.sidebar加载\n2. 查找文本包含"导入"的.el-dropdown\n3. 点击导入下拉菜单\n4. 选择"导入CURL"选项\n5. 等待对话框出现\n6. 在textarea输入CURL命令\n7. 点击"解析"按钮',
        expected: '导入下拉菜单出现，导入CURL选项可点击，对话框出现，textarea可输入，解析按钮点击后CURL被解析',
        feature: '导入功能'
    },
    '15. 生成代码功能': {
        input: '1. 点击第一个树节点选中请求\n2. 查找文本包含"生成代码"的.el-dropdown\n3. 点击生成代码下拉菜单\n4. 选择"JavaScript"选项\n5. 等待代码生成对话框\n6. 查看代码区域\n7. 点击"取消"关闭',
        expected: '生成代码下拉菜单可见，JavaScript选项可点击，代码生成对话框出现，代码区域显示代码，取消按钮关闭对话框',
        feature: '代码生成'
    },
    '16. 集合右键菜单操作': {
        input: '1. 等待.el-tree加载\n2. 获取树节点总数\n3. 对第一个节点进行右键点击\n4. 检查右键菜单是否出现',
        expected: '右键点击后菜单出现，菜单类型为el-dropdown-menu或context-menu',
        feature: '其他功能'
    },
    '17. HTTP方法选择': {
        input: '1. 等待.main-content加载\n2. 查找.method-select或其他选择器\n3. 点击方法选择器\n4. 选择POST选项',
        expected: '方法选择器可见，点击后下拉选项出现，POST选项可选择',
        feature: '其他功能'
    },
    '18. 认证类型切换': {
        input: '1. 等待.main-content加载\n2. 点击Auth标签\n3. 查找认证类型选择器(el-select)\n4. 点击选择器并选择None',
        expected: 'Auth标签可见可点击，认证类型选择器存在，None选项可选择',
        feature: '其他功能'
    },
    '19. Body类型切换': {
        input: '1. 等待.main-content加载\n2. 点击Body标签\n3. 依次选择none和JSON单选按钮',
        expected: 'Body标签可见可点击，none和JSON单选按钮存在且可选择',
        feature: '其他功能'
    },
    '20. 断言功能': {
        input: '1. 等待.main-content加载\n2. 查找文本包含"断言"的button\n3. 点击断言按钮\n4. 等待1000ms',
        expected: '断言按钮可见，点击后断言面板.assertions-panel或包含assertion的元素出现',
        feature: '其他功能'
    },
    '21. 前置脚本和后置脚本': {
        input: '1. 等待.main-content加载\n2. 查找文本包含"脚本"的button\n3. 点击脚本按钮\n4. 等待1000ms',
        expected: '脚本按钮可见，点击后脚本面板.script-panel或包含script的元素出现',
        feature: '其他功能'
    }
};

const html = `<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>接口管理页面测试报告</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Helvetica Neue', Helvetica, 'PingFang SC', 'Hiragino Sans GB', 'Microsoft YaHei', Arial, sans-serif;
            background: #f5f7fa;
            padding: 20px;
            color: #303133;
        }
        .container { max-width: 1400px; margin: 0 auto; }

        .header {
            background: linear-gradient(135deg, #409eff 0%, #5046e5 100%);
            color: white;
            padding: 25px 30px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 4px 12px rgba(64, 158, 255, 0.3);
        }
        .header h1 { font-size: 22px; font-weight: 600; margin-bottom: 8px; }
        .header .subtitle { font-size: 13px; opacity: 0.9; }
        .header-info { display: flex; gap: 20px; margin-top: 15px; flex-wrap: wrap; }
        .header-info span { background: rgba(255,255,255,0.15); padding: 6px 14px; border-radius: 4px; font-size: 12px; }

        .summary { display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 20px; }
        .summary-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); text-align: center; }
        .summary-card .number { font-size: 32px; font-weight: bold; color: #409eff; }
        .summary-card .label { color: #909399; font-size: 13px; margin-top: 5px; }
        .summary-card.passed .number { color: #67c23a; }
        .summary-card.failed .number { color: #f56c6c; }
        .summary-card.duration .number { color: #409eff; }

        .legend { display: flex; gap: 25px; margin-bottom: 20px; background: white; padding: 12px 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.06); flex-wrap: wrap; }
        .legend-item { display: flex; align-items: center; gap: 8px; font-size: 13px; color: #606266; }
        .legend-color { width: 14px; height: 14px; border-radius: 3px; }

        .section-title {
            font-size: 16px; font-weight: 600; color: #303133; margin-bottom: 12px;
            padding-left: 12px; border-left: 4px solid #409eff;
            display: flex; align-items: center; gap: 10px;
        }
        .section-tag { background: #409eff; color: white; font-size: 11px; padding: 2px 8px; border-radius: 10px; font-weight: normal; }

        .test-list { background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 8px rgba(0,0,0,0.06); margin-bottom: 25px; }
        .test-item { border-bottom: 1px solid #ebeef5; padding: 20px; transition: background 0.2s; }
        .test-item:hover { background: #fafbfc; }
        .test-item:last-child { border-bottom: none; }

        .test-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 15px; flex-wrap: wrap; gap: 10px; }
        .test-title { display: flex; align-items: center; gap: 12px; }
        .test-id { background: #409eff; color: white; width: 28px; height: 28px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 12px; font-weight: bold; }
        .test-name { font-size: 15px; font-weight: 600; color: #303133; }
        .test-meta { display: flex; align-items: center; gap: 12px; }
        .test-duration { color: #909399; font-size: 12px; background: #f5f7fa; padding: 4px 10px; border-radius: 12px; }
        .test-status { padding: 4px 12px; border-radius: 4px; font-size: 12px; font-weight: 500; display: flex; align-items: center; gap: 4px; }
        .test-status.passed { background: #f0f9eb; color: #67c23a; }
        .test-status.failed { background: #fef0f0; color: #f56c6c; }

        .test-content { display: grid; grid-template-columns: 1fr 1fr; gap: 15px; margin-bottom: 15px; }
        .test-section { background: #f8f9fa; padding: 15px; border-radius: 6px; }
        .test-section h4 { color: #409eff; font-size: 11px; margin-bottom: 10px; text-transform: uppercase; font-weight: 600; letter-spacing: 0.5px; }
        .test-section p { font-size: 12px; color: #606266; line-height: 1.6; white-space: pre-wrap; }

        .test-output { background: #1e1e1e; color: #d4d4d4; padding: 12px; border-radius: 6px; font-family: 'Consolas', 'Monaco', monospace; font-size: 11px; white-space: pre-wrap; line-height: 1.5; margin-top: 10px; border-left: 3px solid #67c23a; }
        .test-output .info { color: #6fa3ef; }
        .test-output .action { color: #98d379; }
        .test-output .result { color: #7ec699; }
        .test-output .warn { color: #e5c07b; }
        .test-output .error { color: #f48771; }

        .test-attachments { display: flex; gap: 10px; margin-top: 12px; flex-wrap: wrap; align-items: center; }
        .attachment-btn { padding: 6px 14px; background: #409eff; color: white; border: none; border-radius: 4px; font-size: 12px; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 5px; transition: background 0.2s; }
        .attachment-btn:hover { background: #66b1ff; }
        .attachment-btn.trace { background: #5046e5; }
        .attachment-btn.trace:hover { background: #6c63ff; }
        .attachment-time { color: #909399; font-size: 11px; margin-left: auto; }

        .footer { text-align: center; margin-top: 25px; color: #909399; font-size: 12px; }
        .footer strong { color: #606266; }

        .icon { width: 14px; height: 14px; display: inline-block; vertical-align: middle; }
        .icon-check { fill: #67c23a; }
        .icon-x { fill: #f56c6c; }
        .icon-video { fill: #409eff; }
        .icon-trace { fill: #5046e5; }

        .summary-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 10px; margin-top: 10px; }
        .summary-item { background: rgba(255,255,255,0.1); padding: 8px 12px; border-radius: 4px; font-size: 12px; }
        .summary-item label { opacity: 0.8; }
        .summary-item span { font-weight: 600; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>接口管理页面全面测试报告</h1>
            <div class="subtitle">Playwright E2E Automation Test Report</div>
            <div class="header-info">
                <span>
                    <svg class="icon" viewBox="0 0 24 24" style="fill: white; margin-right: 5px; vertical-align: middle;">
                        <circle cx="12" cy="12" r="10" stroke="white" stroke-width="2" fill="none"/>
                        <path d="M12 6v6l4 2" stroke="white" stroke-width="2" fill="none"/>
                    </svg>
                    ${new Date(results.stats.startTime).toLocaleString('zh-CN')}
                </span>
                <span>
                    <svg class="icon" viewBox="0 0 24 24" style="fill: white; margin-right: 5px; vertical-align: middle;">
                        <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z"/>
                    </svg>
                    总耗时: ${(results.stats.duration / 1000).toFixed(1)}秒
                </span>
                <span>
                    <svg class="icon" viewBox="0 0 24 24" style="fill: white; margin-right: 5px; vertical-align: middle;">
                        <circle cx="12" cy="12" r="3"/>
                    </svg>
                    Chromium Headless
                </span>
                <span>Playwright ${results.config.version}</span>
            </div>
            <div class="summary-grid">
                <div class="summary-item"><label>测试文件:</label> <span>interface-management.spec.js</span></div>
                <div class="summary-item"><label>测试套件:</label> <span>接口管理页面全面测试</span></div>
            </div>
        </div>

        <div class="summary">
            <div class="summary-card">
                <div class="number">${results.stats.expected}</div>
                <div class="label">总测试数</div>
            </div>
            <div class="summary-card passed">
                <div class="number">${results.stats.expected - results.stats.unexpected}</div>
                <div class="label">通过</div>
            </div>
            <div class="summary-card failed">
                <div class="number">${results.stats.unexpected}</div>
                <div class="label">失败</div>
            </div>
            <div class="summary-card duration">
                <div class="number">${(results.stats.duration / 1000).toFixed(1)}s</div>
                <div class="label">平均 ${(results.stats.duration / 1000 / results.stats.expected).toFixed(1)}s/个</div>
            </div>
        </div>

        <div class="legend">
            <div class="legend-item">
                <div class="legend-color" style="background: #67c23a;"></div>
                <span>passed - 测试通过</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #f56c6c;"></div>
                <span>failed - 测试失败</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #409eff;"></div>
                <span>video - 视频录制</span>
            </div>
            <div class="legend-item">
                <div class="legend-color" style="background: #5046e5;"></div>
                <span>trace - Trace分析</span>
            </div>
        </div>

        ${createTestSection(tests, '核心功能测试', 0, 13, testMetadata)}
        ${createTestSection(tests, '导入CURL功能', 13, 14, testMetadata)}
        ${createTestSection(tests, '代码生成功能', 14, 15, testMetadata)}
        ${createTestSection(tests, '其他功能测试', 15, 21, testMetadata)}

        <div class="footer">
            <p>Generated by Playwright Test Report</p>
            <p style="margin-top: 5px;">
                Report: <strong>playwright-report/test-report.html</strong> |
                JSON: <strong>playwright-report/results.json</strong> |
                Videos: <strong>test-results/</strong>
            </p>
        </div>
    </div>
</body>
</html>`;

function createTestSection(tests, title, startIdx, endIdx, metadata) {
    const sectionTests = tests.slice(startIdx, endIdx);
    const passedCount = sectionTests.filter(t => t.tests[0].results[0].status === 'passed').length;
    return `
    <div class="category">
        <div class="section-title">
            ${title}
            <span class="section-tag">${passedCount}/${endIdx - startIdx} 通过</span>
        </div>
        <div class="test-list">
            ${sectionTests.map((tc, idx) => createTestItem(tc, startIdx + idx + 1, metadata)).join('')}
        </div>
    </div>`;
}

function createTestItem(tc, num, metadata) {
    const result = tc.tests[0].results[0];
    const status = result.status === 'passed' ? 'passed' : 'failed';
    const stdout = result.stdout.map(s => s.text).join('\n');
    const attachments = result.attachments || [];

    const videoPath = attachments.find(a => a.name === 'video')?.path || '';
    const tracePath = attachments.find(a => a.name === 'trace')?.path || '';

    const info = metadata[tc.title] || { input: 'See test title', expected: 'See test title', feature: '未知' };

    const statusIcon = status === 'passed'
        ? `<svg class="icon icon-check" viewBox="0 0 24 24"><path d="M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z"/></svg>`
        : `<svg class="icon icon-x" viewBox="0 0 24 24"><path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/></svg>`;

    const videoIcon = `<svg class="icon icon-video" viewBox="0 0 24 24"><path d="M18 4l2 4h-3l-2-4h-2l2 4h-3l-2-4H8l2 4H7L5 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V4h-4z"/></svg>`;
    const traceIcon = `<svg class="icon icon-trace" viewBox="0 0 24 24"><path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/></svg>`;

    return `
    <div class="test-item">
        <div class="test-header">
            <div class="test-title">
                <span class="test-id">${num}</span>
                <span class="test-name">${tc.title}</span>
            </div>
            <div class="test-meta">
                <span class="test-duration">${(result.duration / 1000).toFixed(3)}s</span>
                <span class="test-status ${status}">
                    ${statusIcon}
                    ${status === 'passed' ? 'passed' : 'failed'}
                </span>
            </div>
        </div>
        <div class="test-content">
            <div class="test-section">
                <h4>Input 输入操作</h4>
                <p>${info.input}</p>
            </div>
            <div class="test-section">
                <h4>Expected 预期结果</h4>
                <p>${info.expected}</p>
            </div>
        </div>
        ${stdout ? `<div class="test-output">${formatOutput(stdout)}</div>` : ''}
        <div class="test-attachments">
            ${videoPath ? `<a href="${videoPath.replace(/\\/g, '/')}" class="attachment-btn" target="_blank">${videoIcon} 视频录制</a>` : ''}
            ${tracePath ? `<a href="${tracePath.replace(/\\/g, '/')}" class="attachment-btn trace" target="_blank">${traceIcon} Trace分析</a>` : ''}
            <span class="attachment-time">Started: ${new Date(result.startTime).toLocaleString('zh-CN')}</span>
        </div>
    </div>`;
}

function formatOutput(text) {
    return text
        .replace(/INFO:/g, '<span class="info">INFO:</span>')
        .replace(/ACTION:/g, '<span class="action">ACTION:</span>')
        .replace(/RESULT:/g, '<span class="result">RESULT:</span>')
        .replace(/WARN:/g, '<span class="warn">WARN:</span>')
        .replace(/ERROR:/g, '<span class="error">ERROR:</span>')
        .replace(/\n/g, '<br>');
}

fs.writeFileSync('playwright-report/test-report.html', html, 'utf8');
console.log('HTML test report generated successfully!');
console.log('Location: playwright-report/test-report.html');