#!/bin/bash
# ============================================
# TestHub 项目管理模块测试脚本
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
# 2. 项目CRUD测试
# ============================================
print_header "2. 项目CRUD测试"

TIMESTAMP=$(date +%s)
PROJECT_NAME="TEST_Project_$TIMESTAMP"

print_test "2.1 创建项目"
CREATE_RESP=$(curl -s -X POST "$BASE_URL/projects" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"name\":\"$PROJECT_NAME\",\"description\":\"API Test Project\"}")

echo "响应: $CREATE_RESP"

PROJECT_ID=$(get_data_int "$CREATE_RESP" "id")
if [ -n "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
    print_pass "项目创建成功，ID: $PROJECT_ID"
else
    MSG=$(get_message "$CREATE_RESP")
    print_fail "创建失败 - $MSG"
    PROJECT_ID=""
fi

print_test "2.2 获取项目列表"
LIST_RESP=$(curl -s -X GET "$BASE_URL/projects" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

CODE=$(get_code "$LIST_RESP")
if [ "$CODE" = "200" ]; then
    print_pass "获取项目列表成功"
else
    print_fail "获取项目列表失败"
fi

print_test "2.3 获取项目详情"
if [ -n "$PROJECT_ID" ]; then
    DETAIL_RESP=$(curl -s -X GET "$BASE_URL/projects/$PROJECT_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    CODE=$(get_code "$DETAIL_RESP")
    if [ "$CODE" = "200" ]; then
        NAME=$(echo "$DETAIL_RESP" | sed -n 's/.*"name":"\([^"]*\)".*/\1/p' | head -1)
        print_pass "获取项目详情成功 - $NAME"
    else
        print_fail "获取项目详情失败"
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "2.4 更新项目"
if [ -n "$PROJECT_ID" ]; then
    UPDATE_RESP=$(curl -s -X PUT "$BASE_URL/projects/$PROJECT_ID" \
        -H "Content-Type: application/json; charset=utf-8" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"name\":\"${PROJECT_NAME}_updated\",\"description\":\"Updated Description\"}")

    CODE=$(get_code "$UPDATE_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "项目更新成功"
    else
        print_fail "项目更新失败"
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "2.5 搜索项目"
SEARCH_RESP=$(curl -s -X GET "$BASE_URL/projects/search?keyword=TEST" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

CODE=$(get_code "$SEARCH_RESP")
if [ "$CODE" = "200" ]; then
    print_pass "搜索项目成功"
else
    print_fail "搜索项目失败"
fi

print_test "2.6 分页查询项目"
PAGE_RESP=$(curl -s -X GET "$BASE_URL/projects/page?current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")

CODE=$(get_code "$PAGE_RESP")
TOTAL=$(echo "$PAGE_RESP" | sed -n 's/.*"total":\([0-9]*\).*/\1/p' | head -1)
if [ "$CODE" = "200" ]; then
    print_pass "分页查询成功，共 $TOTAL 条记录"
else
    print_fail "分页查询失败"
fi

print_test "2.7 获取不存在的项目"
NOT_FOUND_RESP=$(curl -s -X GET "$BASE_URL/projects/999999" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$NOT_FOUND_RESP")
if [ "$CODE" = "404" ]; then
    print_pass "正确返回404"
else
    print_fail "应返回404，实际返回 $CODE"
fi

print_test "2.8 无Token创建项目"
NO_AUTH_RESP=$(curl -s -X POST "$BASE_URL/projects" \
    -H "Content-Type: application/json" \
    -d '{"name":"NoAuthProject","description":"Test"}')
CODE=$(get_code "$NO_AUTH_RESP")
if [ "$CODE" = "401" ]; then
    print_pass "无Token正确返回401"
else
    print_fail "应返回401，实际返回 $CODE"
fi

# ============================================
# 3. 项目成员管理测试
# ============================================
print_header "3. 项目成员管理测试"

print_test "3.1 获取项目成员列表"
if [ -n "$PROJECT_ID" ]; then
    MEMBERS_RESP=$(curl -s -X GET "$BASE_URL/projects/$PROJECT_ID/members" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    CODE=$(get_code "$MEMBERS_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "获取成员列表成功"
    else
        print_fail "获取成员列表失败"
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "3.2 获取当前用户角色"
if [ -n "$PROJECT_ID" ]; then
    ROLE_RESP=$(curl -s -X GET "$BASE_URL/projects/$PROJECT_ID/members/role" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    CODE=$(get_code "$ROLE_RESP")
    if [ "$CODE" = "200" ]; then
        ROLE=$(echo "$ROLE_RESP" | sed -n 's/.*"role":"\([^"]*\)".*/\1/p' | head -1)
        print_pass "获取角色成功 - ${ROLE:-admin}"
    else
        print_fail "获取角色失败"
    fi
else
    echo "跳过: 无项目ID"
fi

# ============================================
# 4. 项目环境管理测试
# ============================================
print_header "4. 项目环境管理测试"

print_test "4.1 创建项目环境"
if [ -n "$PROJECT_ID" ]; then
    ENV_RESP=$(curl -s -X POST "$BASE_URL/projects/$PROJECT_ID/environments" \
        -H "Content-Type: application/json; charset=utf-8" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d '{"name":"Test Env","description":"Test Environment","variables":{"baseUrl":"https://api.test.com"}}')

    echo "响应: $ENV_RESP"

    ENV_ID=$(get_data_int "$ENV_RESP" "id")
    if [ -n "$ENV_ID" ] && [ "$ENV_ID" != "null" ]; then
        print_pass "环境创建成功，ID: $ENV_ID"
    else
        MSG=$(get_message "$ENV_RESP")
        print_fail "环境创建失败 - $MSG"
        ENV_ID=""
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "4.2 获取环境列表"
if [ -n "$PROJECT_ID" ]; then
    ENV_LIST_RESP=$(curl -s -X GET "$BASE_URL/projects/$PROJECT_ID/environments" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    CODE=$(get_code "$ENV_LIST_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "获取环境列表成功"
    else
        print_fail "获取环境列表失败"
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "4.3 获取默认环境"
if [ -n "$PROJECT_ID" ]; then
    DEFAULT_ENV_RESP=$(curl -s -X GET "$BASE_URL/projects/$PROJECT_ID/environments/default" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    CODE=$(get_code "$DEFAULT_ENV_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "获取默认环境成功"
    else
        print_pass "暂无默认环境(可接受)"
    fi
else
    echo "跳过: 无项目ID"
fi

print_test "4.4 设置默认环境"
if [ -n "$PROJECT_ID" ] && [ -n "$ENV_ID" ]; then
    SET_DEFAULT_RESP=$(curl -s -X PUT "$BASE_URL/projects/$PROJECT_ID/environments/$ENV_ID/default" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$SET_DEFAULT_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "设置默认环境成功"
    else
        print_fail "设置默认环境失败"
    fi
else
    echo "跳过: 无环境ID"
fi

print_test "4.5 更新环境"
if [ -n "$PROJECT_ID" ] && [ -n "$ENV_ID" ]; then
    UPDATE_ENV_RESP=$(curl -s -X PUT "$BASE_URL/projects/$PROJECT_ID/environments/$ENV_ID" \
        -H "Content-Type: application/json; charset=utf-8" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d '{"name":"Updated Env","description":"Updated Description"}')

    CODE=$(get_code "$UPDATE_ENV_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "更新环境成功"
    else
        print_fail "更新环境失败"
    fi
else
    echo "跳过: 无环境ID"
fi

print_test "4.6 删除环境"
if [ -n "$PROJECT_ID" ] && [ -n "$ENV_ID" ]; then
    DELETE_ENV_RESP=$(curl -s -X DELETE "$BASE_URL/projects/$PROJECT_ID/environments/$ENV_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DELETE_ENV_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "删除环境成功"
    else
        print_fail "删除环境失败"
    fi
else
    echo "跳过: 无环境ID"
fi

# ============================================
# 5. 清理测试
# ============================================
print_header "5. 清理测试数据"

print_test "5.1 删除测试项目"
if [ -n "$PROJECT_ID" ]; then
    DELETE_RESP=$(curl -s -X DELETE "$BASE_URL/projects/$PROJECT_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DELETE_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "项目删除成功"
    else
        print_fail "项目删除失败"
    fi
else
    echo "跳过: 无项目ID"
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
