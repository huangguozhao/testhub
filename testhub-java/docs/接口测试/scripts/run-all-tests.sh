#!/bin/bash
# ============================================
# TestHub 批量测试执行脚本
# 执行所有模块的测试
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="$(dirname "$SCRIPT_DIR")"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试结果目录
RESULTS_DIR="$DOCS_DIR/results/$(date +%Y-%m-%d_%H-%M)"
mkdir -p "$RESULTS_DIR"

# 测试结果统计
TOTAL_PASS=0
TOTAL_FAIL=0
TOTAL_SKIP=0
TOTAL_MODULES=0
PASSED_MODULES=0

echo "=========================================="
echo "  TestHub Java版本 接口测试"
echo "  测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# 打印模块信息
print_module() {
    echo ""
    echo -e "${BLUE}=========================================="
    echo -e "  $1"
    echo -e "==========================================${NC}"
}

# 执行测试并记录结果
run_test() {
    local module_name=$1
    local script=$2

    TOTAL_MODULES=$((TOTAL_MODULES + 1))

    print_module "$module_name 测试"

    if [ -f "$script" ]; then
        echo "执行中..."
        echo "----------------------------------------"

        # 执行测试并捕获结果
        local output_file="$RESULTS_DIR/${module_name}.log"
        local test_result

        # 执行脚本，捕获退出码
        bash "$script" 2>&1 | tee "$output_file"
        test_result=${PIPESTATUS[0]}

        echo "----------------------------------------"

        if [ $test_result -eq 0 ]; then
            echo -e "${GREEN}✓ $module_name 测试通过${NC}"
            PASSED_MODULES=$((PASSED_MODULES + 1))
        else
            echo -e "${RED}✗ $module_name 测试失败${NC}"
        fi
    else
        echo -e "${YELLOW}跳过: 测试脚本不存在${NC}"
        echo "  $script"
    fi
    echo ""
}

# ============================================
# 检查环境
# ============================================
print_module "环境检查"

echo "检查后端服务..."

HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:8080/api/auth/login -X POST -H "Content-Type: application/json" -d '{"username":"test","password":"test"}' 2>/dev/null || echo "000")

if [ "$HEALTH_CHECK" != "000" ]; then
    echo -e "${GREEN}✓ 后端服务运行正常 (http://127.0.0.1:8080)${NC}"
else
    echo -e "${RED}✗ 后端服务未启动或无法访问${NC}"
    echo "请先启动后端服务: cd testhub-java && mvn spring-boot:run"
    exit 1
fi

# 检查jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}警告: jq 未安装，部分输出可能无法美化${NC}"
fi

# ============================================
# 执行各模块测试
# ============================================

# 1. 认证模块测试
run_test "认证模块" "$DOCS_DIR/01-认证模块测试/curl/Auth-Module-Test.sh"

# 2. 项目管理测试
run_test "项目管理" "$DOCS_DIR/02-项目管理测试/curl/Project-Module-Test.sh"

# 3. APITesting模块测试
run_test "APITesting" "$DOCS_DIR/03-APITesting模块测试/curl/APITesting-Module-Test.sh"

# 4. 通知系统测试
run_test "通知系统" "$DOCS_DIR/04-通知系统测试/curl/Notification-Module-Test.sh"

# 5. 操作日志测试
run_test "操作日志" "$DOCS_DIR/05-操作日志测试/curl/OperationLog-Module-Test.sh"

# ============================================
# 生成测试报告
# ============================================
print_module "测试汇总"

echo ""
echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "测试模块总数: ${BLUE}$TOTAL_MODULES${NC}"
echo -e "测试通过模块: ${GREEN}$PASSED_MODULES${NC}"
echo -e "测试失败模块: ${RED}$((TOTAL_MODULES - PASSED_MODULES))${NC}"
echo ""

# 计算通过率
if [ $TOTAL_MODULES -gt 0 ]; then
    PASS_RATE=$((PASSED_MODULES * 100 / TOTAL_MODULES))
    echo -e "模块通过率: ${PASS_RATE}%"
fi

echo ""
echo "详细日志: $RESULTS_DIR"

# 生成Markdown报告
REPORT_DATE=$(date +%Y-%m-%d_%H-%M)
REPORT_FILE="$DOCS_DIR/reports/测试报告_$REPORT_DATE.md"
mkdir -p "$(dirname "$REPORT_FILE")"

cat > "$REPORT_FILE" << EOF
# TestHub Java版本 接口测试报告

## 测试概况

| 项目 | 内容 |
|-----|------|
| 测试日期 | $(date '+%Y-%m-%d %H:%M:%S') |
| 测试环境 | http://127.0.0.1:8080 |
| 通过模块 | $PASSED_MODULES / $TOTAL_MODULES |
| 模块通过率 | $([ $TOTAL_MODULES -gt 0 ] && echo "$((PASSED_MODULES * 100 / TOTAL_MODULES))%" || echo "N/A") |

## 模块测试结果

| 模块 | 状态 | 日志文件 |
|-----|------|---------|
| 认证模块 | $([ $? -eq 0 ] 2>/dev/null && echo '✓ 通过' || echo '✗ 失败') | ${RESULTS_DIR##*/}/认证模块.log |
| 项目管理 | $([ $? -eq 0 ] 2>/dev/null && echo '✓ 通过' || echo '✗ 失败') | ${RESULTS_DIR##*/}/项目管理.log |
| APITesting | 待验证 | ${RESULTS_DIR##*/}/APITesting.log |
| 通知系统 | 待验证 | ${RESULTS_DIR##*/}/通知系统.log |
| 操作日志 | 待验证 | ${RESULTS_DIR##*/}/操作日志.log |

## 测试日志

详细测试日志位于: \`$RESULTS_DIR/\`

## 附录

### 环境信息
- 后端服务: http://127.0.0.1:8080
- 数据库: MySQL (localhost:3306)
- Redis: localhost:6379

### 测试账号
- 管理员: test_admin / Test123456
- 普通用户: test_user / Test123456

---

*报告生成时间: $(date '+%Y-%m-%d %H:%M:%S')*
EOF

echo -e "${GREEN}测试报告已生成: $REPORT_FILE${NC}"

# 返回最终状态
if [ $((TOTAL_MODULES - PASSED_MODULES)) -eq 0 ]; then
    echo ""
    echo -e "${GREEN}所有模块测试通过!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}有 $((TOTAL_MODULES - PASSED_MODULES)) 个模块测试失败${NC}"
    exit 1
fi
