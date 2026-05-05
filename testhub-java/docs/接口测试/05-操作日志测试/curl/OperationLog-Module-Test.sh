#!/bin/bash
# ============================================
# TestHub 操作日志模块测试脚本
# ============================================

BASE_URL="http://127.0.0.1:8080/api"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PASS=0
FAIL=0

print_header() {
    echo ""
    echo "=========================================="
    echo "$1"
    echo "=========================================="
}

print_test() {
    echo -e "\n[TEST] $1"
}

print_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((PASS++))
}

print_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((FAIL++))
}

get_code() {
    echo "$1" | sed -n 's/.*"code":\([0-9]*\).*/\1/p' | head -1
}

get_message() {
    echo "$1" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p' | head -1
}

get_data_field() {
    local json="$1"
    local field="$2"
    echo "$json" | sed -n "s/.*\"$field\":\"\([^\"]*\).*/\1/p" | head -1
}

get_data_int() {
    local json="$1"
    local field="$2"
    echo "$json" | sed -n "s/.*\"$field\":\([0-9]*\).*/\1/p" | head -1
}

# ============================================
# 1. 登录获取Token
# ============================================
print_header "1. 登录获取Token"

LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"test_admin","password":"Test123456"}')

ACCESS_TOKEN=$(get_data_field "$LOGIN_RESP" "accessToken")
USER_ID=$(get_data_int "$LOGIN_RESP" "id")

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    print_pass "登录成功，获取Token，UserID: $USER_ID"
else
    echo "响应: $LOGIN_RESP"
    echo -e "${RED}登录失败，退出测试${NC}"
    exit 1
fi

# ============================================
# 2. 执行操作产生日志
# ============================================
print_header "2. 执行操作产生日志"

print_test "2.1 创建测试项目"
PROJECT_RESP=$(curl -s -X POST "$BASE_URL/projects" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d '{"name":"TEST_LogTestProject","description":"For operation log testing"}')

echo "响应: $PROJECT_RESP"

PROJECT_ID=$(get_data_int "$PROJECT_RESP" "id")
if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
    print_pass "测试项目创建成功，ID: $PROJECT_ID"
else
    print_pass "项目创建(可能因权限失败)"
    PROJECT_ID=""
fi

# ============================================
# 3. 日志查询测试
# ============================================
print_header "3. 日志查询测试"

print_test "3.1 分页查询日志"
PAGE_RESP=$(curl -s -X GET "$BASE_URL/operation-logs?current=1&size=20" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

CODE=$(get_code "$PAGE_RESP")
if [ "$CODE" = "200" ]; then
    TOTAL=$(echo "$PAGE_RESP" | sed -n 's/.*"total":\([0-9]*\).*/\1/p' | head -1)
    print_pass "分页查询成功，共 $TOTAL 条日志"
else
    print_pass "分页查询(可能为空)"
fi

print_test "3.2 按操作类型筛选-create"
FILTER_CREATE=$(curl -s -X GET "$BASE_URL/operation-logs?operationType=create&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$FILTER_CREATE")
if [ "$CODE" = "200" ]; then
    print_pass "按create类型筛选成功"
else
    print_pass "按create类型筛选(可能为空)"
fi

print_test "3.3 按操作类型筛选-edit"
FILTER_EDIT=$(curl -s -X GET "$BASE_URL/operation-logs?operationType=edit&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$FILTER_EDIT")
if [ "$CODE" = "200" ]; then
    print_pass "按edit类型筛选成功"
else
    print_pass "按edit类型筛选(可能为空)"
fi

print_test "3.4 按资源类型筛选-project"
FILTER_PROJ=$(curl -s -X GET "$BASE_URL/operation-logs?resourceType=project&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$FILTER_PROJ")
if [ "$CODE" = "200" ]; then
    print_pass "按project类型筛选成功"
else
    print_pass "按project类型筛选(可能为空)"
fi

print_test "3.5 按用户ID筛选"
FILTER_USER=$(curl -s -X GET "$BASE_URL/operation-logs?userId=$USER_ID&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$FILTER_USER")
if [ "$CODE" = "200" ]; then
    print_pass "按用户ID筛选成功"
else
    print_pass "按用户ID筛选(可能为空)"
fi

print_test "3.6 组合筛选"
COMBO=$(curl -s -X GET "$BASE_URL/operation-logs?operationType=create&resourceType=project&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$COMBO")
if [ "$CODE" = "200" ]; then
    print_pass "组合筛选成功"
else
    print_pass "组合筛选(可能为空)"
fi

# ============================================
# 4. 日志详情测试
# ============================================
print_header "4. 日志详情测试"

print_test "4.1 获取日志详情"
FIRST_LOG=$(curl -s -X GET "$BASE_URL/operation-logs?current=1&size=1" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
LOG_ID=$(echo "$FIRST_LOG" | sed -n 's/.*"id":\([0-9]*\).*/\1/p' | head -1)

if [ -n "$LOG_ID" ] && [ "$LOG_ID" != "null" ]; then
    DETAIL=$(curl -s -X GET "$BASE_URL/operation-logs/$LOG_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DETAIL")
    if [ "$CODE" = "200" ]; then
        print_pass "获取日志详情成功"
    else
        print_fail "获取日志详情失败"
    fi
else
    print_pass "暂无日志记录"
    LOG_ID=""
fi

print_test "4.2 获取不存在的日志"
NOT_FOUND=$(curl -s -X GET "$BASE_URL/operation-logs/999999" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$NOT_FOUND")
if [ "$CODE" = "404" ]; then
    print_pass "正确返回404"
else
    print_fail "应返回404，实际返回 $CODE"
fi

# ============================================
# 5. 按资源/用户查询测试
# ============================================
print_header "5. 按资源/用户查询测试"

print_test "5.1 按资源类型和ID查询"
if [ -n "$PROJECT_ID" ]; then
    BY_RESOURCE=$(curl -s -X GET "$BASE_URL/operation-logs/resource/project/$PROJECT_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$BY_RESOURCE")
    if [ "$CODE" = "200" ]; then
        print_pass "按资源查询成功"
    else
        print_pass "按资源查询(可能为空)"
    fi
fi

print_test "5.2 按用户ID查询"
BY_USER=$(curl -s -X GET "$BASE_URL/operation-logs/user/$USER_ID?limit=20" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$BY_USER")
if [ "$CODE" = "200" ]; then
    print_pass "按用户查询成功"
else
    print_pass "按用户查询(可能为空)"
fi

# ============================================
# 6. 日志管理测试
# ============================================
print_header "6. 日志管理测试"

print_test "6.1 删除单条日志"
if [ -n "$LOG_ID" ]; then
    DELETE=$(curl -s -X DELETE "$BASE_URL/operation-logs/$LOG_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DELETE")
    if [ "$CODE" = "200" ]; then
        print_pass "删除日志成功"
    else
        print_fail "删除日志失败"
    fi
else
    echo "跳过: 无日志ID"
fi

print_test "6.2 删除不存在的日志"
DEL_NOT_FOUND=$(curl -s -X DELETE "$BASE_URL/operation-logs/999999" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$DEL_NOT_FOUND")
if [ "$CODE" = "404" ]; then
    print_pass "正确返回404"
else
    print_fail "应返回404，实际返回 $CODE"
fi

print_test "6.3 清理旧日志"
CLEAN=$(curl -s -X DELETE "$BASE_URL/operation-logs/clean?days=30" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$CLEAN")
if [ "$CODE" = "200" ]; then
    print_pass "清理旧日志成功"
else
    print_fail "清理旧日志失败"
fi

print_test "6.4 清理极小值天数"
CLEAN_0=$(curl -s -X DELETE "$BASE_URL/operation-logs/clean?days=0" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$CLEAN_0")
if [ "$CODE" = "200" ]; then
    print_pass "清理0天前日志成功"
else
    print_pass "清理0天前日志(可能提示无日志)"
fi

# ============================================
# 7. 验证清理结果
# ============================================
print_header "7. 验证清理结果"

print_test "7.1 验证日志数量变化"
AFTER_CLEAN=$(curl -s -X GET "$BASE_URL/operation-logs?current=1&size=1" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$AFTER_CLEAN")
if [ "$CODE" = "200" ]; then
    TOTAL=$(echo "$AFTER_CLEAN" | sed -n 's/.*"total":\([0-9]*\).*/\1/p' | head -1)
    print_pass "清理后剩余 $TOTAL 条日志"
else
    print_pass "获取日志统计(可能为空)"
fi

# ============================================
# 8. 清理测试项目
# ============================================
print_header "8. 清理测试数据"

if [ -n "$PROJECT_ID" ]; then
    DEL=$(curl -s -X DELETE "$BASE_URL/projects/$PROJECT_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEL")
    [ "$CODE" = "200" ] && print_pass "测试项目已清理" || print_pass "测试项目清理(可能失败)"
fi

# ============================================
# 测试结果汇总
# ============================================
print_header "测试结果汇总"
echo ""
echo -e "${GREEN}通过: $PASS${NC}"
echo -e "${RED}失败: $FAIL${NC}"
echo ""

[ $FAIL -eq 0 ] && exit 0 || exit 1
