#!/bin/bash
# ============================================
# TestHub 认证模块测试脚本
# ============================================

BASE_URL="http://127.0.0.1:8080/api"
TEST_USERNAME="test_admin"
TEST_PASSWORD="Test123456"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 测试结果计数
PASS=0
FAIL=0

# 全局变量
ACCESS_TOKEN=""
REFRESH_TOKEN=""
USER_ID=""

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
    echo "$json" | sed -n "s/.*\"$field\":\"\([^\"]*\)\".*/\1/p" | head -1
}

get_nested_data_field() {
    local json="$1"
    local field="$2"
    # 匹配 "field":"value" 或 "field": value
    echo "$json" | sed -n "s/.*\"$field\":\s*\([^{},]*\).*/\1/p" | head -1 | sed 's/[" ]//g'
}

# ============================================
# 1. 登录测试
# ============================================
print_header "1. 登录测试"

print_test "1.1 正常登录 - test_admin"
LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"username\":\"$TEST_USERNAME\",\"password\":\"$TEST_PASSWORD\"}")

echo "响应: $LOGIN_RESP"

CODE=$(get_code "$LOGIN_RESP")
if [ "$CODE" = "200" ]; then
    ACCESS_TOKEN=$(get_data_field "$LOGIN_RESP" "accessToken")
    REFRESH_TOKEN=$(get_data_field "$LOGIN_RESP" "refreshToken")
    # 获取user.id
    USER_ID=$(echo "$LOGIN_RESP" | sed -n 's/.*"user":{[^}]*"id":\([0-9]*\).*/\1/p' | head -1)

    if [ -n "$ACCESS_TOKEN" ]; then
        print_pass "登录成功，获取到Token"
        echo "  User ID: $USER_ID"
        echo "  Access Token: ${ACCESS_TOKEN:0:50}..."
    else
        print_fail "Token未找到"
    fi
else
    MSG=$(get_message "$LOGIN_RESP")
    print_fail "登录失败 - code: $CODE, message: $MSG"
fi

print_test "1.2 登录 - 用户名错误"
LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"nonexistent_user_xxx","password":"Test123456"}')
CODE=$(get_code "$LOGIN_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "用户名错误正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

print_test "1.3 登录 - 密码错误"
LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$TEST_USERNAME\",\"password\":\"WrongPassword123\"}")
CODE=$(get_code "$LOGIN_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "密码错误正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

print_test "1.4 登录 - 用户名为空"
LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d '{"username":"","password":"Test123456"}')
CODE=$(get_code "$LOGIN_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "用户名为空正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

print_test "1.5 登录 - 密码为空"
LOGIN_RESP=$(curl -s -X POST "$BASE_URL/auth/login" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$TEST_USERNAME\",\"password\":\"\"}")
CODE=$(get_code "$LOGIN_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "密码为空正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

# ============================================
# 2. 注册测试
# ============================================
print_header "2. 注册测试"

TIMESTAMP=$(date +%s)
NEW_USERNAME="newuser_$TIMESTAMP"

print_test "2.1 正常注册 - 新用户"
REG_RESP=$(curl -s -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json; charset=utf-8" \
    -d "{\"username\":\"$NEW_USERNAME\",\"password\":\"Test123456\",\"email\":\"$NEW_USERNAME@test.com\",\"realName\":\"TestUser\"}")

echo "响应: $REG_RESP"
CODE=$(get_code "$REG_RESP")

if [ "$CODE" = "200" ]; then
    NEW_TOKEN=$(get_data_field "$REG_RESP" "accessToken")
    if [ -n "$NEW_TOKEN" ]; then
        print_pass "注册成功并获取Token"
    else
        print_pass "注册成功"
    fi
else
    MSG=$(get_message "$REG_RESP")
    print_fail "注册失败 - code: $CODE, message: $MSG"
fi

print_test "2.2 注册 - 用户名已存在"
REG_RESP=$(curl -s -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$TEST_USERNAME\",\"password\":\"Test123456\",\"email\":\"another@test.com\",\"realName\":\"Test\"}")
CODE=$(get_code "$REG_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "用户名已存在正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

print_test "2.3 注册 - 邮箱已使用"
REG_RESP=$(curl -s -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"new_user_test_xxx\",\"password\":\"Test123456\",\"email\":\"test_admin@test.com\",\"realName\":\"Test\"}")
CODE=$(get_code "$REG_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "邮箱已使用正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

print_test "2.4 注册 - 用户名为空"
REG_RESP=$(curl -s -X POST "$BASE_URL/auth/register" \
    -H "Content-Type: application/json" \
    -d '{"username":"","password":"Test123456","email":"test@test.com"}')
CODE=$(get_code "$REG_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "用户名为空正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

# ============================================
# 3. Token刷新测试
# ============================================
print_header "3. Token刷新测试"

if [ -n "$REFRESH_TOKEN" ] && [ "$REFRESH_TOKEN" != "null" ]; then
    print_test "3.1 正常刷新Token"
    REFRESH_RESP=$(curl -s -X POST "$BASE_URL/auth/refresh" \
        -H "Content-Type: application/json" \
        -d "{\"refreshToken\":\"$REFRESH_TOKEN\"}")

    echo "响应: $REFRESH_RESP"
    CODE=$(get_code "$REFRESH_RESP")

    if [ "$CODE" = "200" ]; then
        NEW_ACCESS=$(get_data_field "$REFRESH_RESP" "accessToken")
        if [ -n "$NEW_ACCESS" ]; then
            ACCESS_TOKEN=$NEW_ACCESS
            print_pass "Token刷新成功"
        else
            print_pass "Token刷新请求成功"
        fi
    else
        print_fail "Token刷新失败 - code: $CODE"
    fi
else
    echo "跳过: 无refreshToken"
fi

print_test "3.2 刷新Token - 无效Token"
REFRESH_RESP=$(curl -s -X POST "$BASE_URL/auth/refresh" \
    -H "Content-Type: application/json" \
    -d '{"refreshToken":"invalid_token_here_xxx"}')
CODE=$(get_code "$REFRESH_RESP")
if [ "$CODE" != "200" ]; then
    print_pass "无效Token正确返回错误"
else
    print_fail "应该返回错误但返回成功"
fi

# ============================================
# 4. 获取用户信息测试
# ============================================
print_header "4. 获取用户信息测试"

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    print_test "4.1 获取当前用户信息"
    ME_RESP=$(curl -s -X GET "$BASE_URL/auth/me" \
        -H "Authorization: Bearer $ACCESS_TOKEN")

    echo "响应: $ME_RESP"
    CODE=$(get_code "$ME_RESP")

    if [ "$CODE" = "200" ]; then
        USERNAME=$(get_nested_data_field "$ME_RESP" "username")
        if [ -n "$USERNAME" ]; then
            print_pass "获取用户信息成功 - $USERNAME"
        else
            print_pass "获取用户信息成功"
        fi
    else
        print_fail "获取用户信息失败 - code: $CODE"
    fi

    print_test "4.2 无Token获取用户信息"
    ME_RESP=$(curl -s -X GET "$BASE_URL/auth/me")
    CODE=$(get_code "$ME_RESP")
    if [ "$CODE" = "401" ]; then
        print_pass "无Token正确返回401"
    else
        print_fail "应该返回401但返回 $CODE"
    fi

    print_test "4.3 无效Token获取用户信息"
    ME_RESP=$(curl -s -X GET "$BASE_URL/auth/me" \
        -H "Authorization: Bearer invalid_token_12345_xxx")
    CODE=$(get_code "$ME_RESP")
    if [ "$CODE" = "401" ]; then
        print_pass "无效Token正确返回401"
    else
        print_fail "应该返回401但返回 $CODE"
    fi
else
    echo "跳过: 无accessToken"
fi

# ============================================
# 5. 登出测试
# ============================================
print_header "5. 登出测试"

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    print_test "5.1 正常登出"
    LOGOUT_RESP=$(curl -s -X POST "$BASE_URL/auth/logout" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$LOGOUT_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "登出成功"
    else
        print_fail "登出失败 - code: $CODE"
    fi

    print_test "5.2 登出后使用原Token访问"
    ME_RESP=$(curl -s -X GET "$BASE_URL/auth/me" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$ME_RESP")
    if [ "$CODE" != "200" ]; then
        print_pass "登出后Token失效"
    else
        print_fail "登出后Token仍然有效"
    fi
else
    echo "跳过: 无accessToken"
fi

# ============================================
# 测试结果汇总
# ============================================
print_header "测试结果汇总"
echo ""
echo -e "${GREEN}通过: $PASS${NC}"
echo -e "${RED}失败: $FAIL${NC}"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}所有测试通过!${NC}"
    exit 0
else
    echo -e "${RED}有 $FAIL 个测试失败${NC}"
    exit 1
fi
