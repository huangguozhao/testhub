#!/bin/bash
# ============================================
# 环境管理模块完整测试脚本
# 测试范围：CRUD、作用域、激活、变量格式、关联功能
# ============================================

BASE_URL="http://127.0.0.1:8080/api"

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 测试计数
PASS=0
FAIL=0
TOTAL=0

# 测试结果记录
test_pass() {
    PASS=$((PASS + 1))
    TOTAL=$((TOTAL + 1))
    echo -e "${GREEN}  ✓ $1${NC}"
}

test_fail() {
    FAIL=$((FAIL + 1))
    TOTAL=$((TOTAL + 1))
    echo -e "${RED}  ✗ $1${NC}"
    if [ -n "$2" ]; then
        echo -e "${RED}    原因: $2${NC}"
    fi
}

echo "=========================================="
echo "  环境管理模块完整测试"
echo "  测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "=========================================="

# ============================================
# 0. 登录获取 Token
# ============================================
echo -e "\n${BLUE}[0/8] 登录获取 Token${NC}"

LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"test_admin","password":"Test123456"}')

TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)

if [ -z "$TOKEN" ]; then
    echo -e "${RED}登录失败，尝试其他账号...${NC}"
    LOGIN_RESPONSE=$(curl -s -X POST "$BASE_URL/auth/login" \
      -H "Content-Type: application/json" \
      -d '{"username":"admin","password":"admin123"}')
    TOKEN=$(echo $LOGIN_RESPONSE | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
fi

if [ -z "$TOKEN" ]; then
    echo -e "${RED}所有登录尝试失败，退出测试${NC}"
    exit 1
fi
echo -e "${GREEN}登录成功${NC}"

# 获取项目列表（后续需要 projectId）
PROJECTS_RESPONSE=$(curl -s -X GET "$BASE_URL/api-projects" \
  -H "Authorization: Bearer $TOKEN")
PROJECT_ID=$(echo $PROJECTS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$PROJECT_ID" ]; then
    echo -e "${YELLOW}没有找到项目，创建测试项目...${NC}"
    CREATE_PROJECT=$(curl -s -X POST "$BASE_URL/api-projects" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"name":"环境测试项目","description":"用于测试环境管理","projectType":"HTTP","status":"IN_PROGRESS"}')
    PROJECT_ID=$(echo $CREATE_PROJECT | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)
fi
echo "使用项目ID: $PROJECT_ID"

# ============================================
# 1. 创建全局环境
# ============================================
echo -e "\n${BLUE}[1/8] 测试创建全局环境${NC}"

GLOBAL_ENV_RESPONSE=$(curl -s -X POST "$BASE_URL/api-environments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"全局测试环境\",
    \"scope\": \"GLOBAL\",
    \"description\": \"全局环境测试\",
    \"variables\": {
      \"base_url\": {\"initialValue\": \"https://api.example.com\", \"currentValue\": \"https://staging.example.com\"},
      \"api_key\": {\"initialValue\": \"test-key-123\", \"currentValue\": \"test-key-123\"}
    }
  }")

GLOBAL_ENV_ID=$(echo $GLOBAL_ENV_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -n "$GLOBAL_ENV_ID" ]; then
    test_pass "创建全局环境成功 (ID: $GLOBAL_ENV_ID)"
    # 验证 scope 字段
    SCOPE=$(echo $GLOBAL_ENV_RESPONSE | grep -o '"scope":"[^"]*"' | cut -d'"' -f4)
    if [ "$SCOPE" = "GLOBAL" ]; then
        test_pass "scope 字段正确: GLOBAL"
    else
        test_fail "scope 字段不正确" "期望 GLOBAL，实际 $SCOPE"
    fi
    # 验证 project_id 为 null
    if echo $GLOBAL_ENV_RESPONSE | grep -q '"projectId":null\|"project_id":null'; then
        test_pass "全局环境 projectId 为 null"
    else
        test_fail "全局环境 projectId 应为 null"
    fi
else
    test_fail "创建全局环境失败" "$GLOBAL_ENV_RESPONSE"
fi

# ============================================
# 2. 创建本地环境
# ============================================
echo -e "\n${BLUE}[2/8] 测试创建本地环境${NC}"

LOCAL_ENV_RESPONSE=$(curl -s -X POST "$BASE_URL/api-environments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"本地测试环境\",
    \"scope\": \"LOCAL\",
    \"project\": $PROJECT_ID,
    \"variables\": {
      \"base_url\": {\"initialValue\": \"http://localhost:3000\", \"currentValue\": \"http://localhost:3000\"},
      \"db_host\": {\"initialValue\": \"localhost\", \"currentValue\": \"127.0.0.1\"}
    }
  }")

LOCAL_ENV_ID=$(echo $LOCAL_ENV_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)

if [ -n "$LOCAL_ENV_ID" ]; then
    test_pass "创建本地环境成功 (ID: $LOCAL_ENV_ID)"
    # 验证 scope 字段
    SCOPE=$(echo $LOCAL_ENV_RESPONSE | grep -o '"scope":"[^"]*"' | cut -d'"' -f4)
    if [ "$SCOPE" = "LOCAL" ]; then
        test_pass "scope 字段正确: LOCAL"
    else
        test_fail "scope 字段不正确" "期望 LOCAL，实际 $SCOPE"
    fi
    # 验证 projectId
    if echo $LOCAL_ENV_RESPONSE | grep -q "\"projectId\":$PROJECT_ID"; then
        test_pass "本地环境 projectId 正确: $PROJECT_ID"
    else
        test_fail "本地环境 projectId 不正确"
    fi
else
    test_fail "创建本地环境失败" "$LOCAL_ENV_RESPONSE"
fi

# ============================================
# 3. 测试 scope=LOCAL 时 projectId 不能为空
# ============================================
echo -e "\n${BLUE}[3/8] 测试验证规则：scope=LOCAL 时 projectId 不能为空${NC}"

INVALID_ENV_RESPONSE=$(curl -s -X POST "$BASE_URL/api-environments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "无效环境",
    "scope": "LOCAL",
    "variables": {}
  }')

if echo $INVALID_ENV_RESPONSE | grep -q '"code":500\|"code":400\|必须关联项目\|error'; then
    test_pass "scope=LOCAL 时无 projectId 正确返回错误"
else
    test_fail "scope=LOCAL 时无 projectId 应返回错误" "$INVALID_ENV_RESPONSE"
fi

# ============================================
# 4. 测试按 scope 过滤
# ============================================
echo -e "\n${BLUE}[4/8] 测试按 scope 过滤环境列表${NC}"

# 获取全局环境列表
GLOBAL_LIST=$(curl -s -X GET "$BASE_URL/api-environments?scope=GLOBAL" \
  -H "Authorization: Bearer $TOKEN")
GLOBAL_COUNT=$(echo $GLOBAL_LIST | grep -o '"id":[0-9]*' | wc -l)

if [ "$GLOBAL_COUNT" -ge 1 ]; then
    test_pass "scope=GLOBAL 过滤成功，返回 $GLOBAL_COUNT 条记录"
else
    test_fail "scope=GLOBAL 过滤失败" "$GLOBAL_LIST"
fi

# 获取本地环境列表
LOCAL_LIST=$(curl -s -X GET "$BASE_URL/api-environments?scope=LOCAL&projectId=$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN")
LOCAL_COUNT=$(echo $LOCAL_LIST | grep -o '"id":[0-9]*' | wc -l)

if [ "$LOCAL_COUNT" -ge 1 ]; then
    test_pass "scope=LOCAL&projectId 过滤成功，返回 $LOCAL_COUNT 条记录"
else
    test_fail "scope=LOCAL&projectId 过滤失败" "$LOCAL_LIST"
fi

# 获取所有环境（不带过滤参数）
ALL_LIST=$(curl -s -X GET "$BASE_URL/api-environments" \
  -H "Authorization: Bearer $TOKEN")
ALL_COUNT=$(echo $ALL_LIST | grep -o '"id":[0-9]*' | wc -l)

if [ "$ALL_COUNT" -ge 2 ]; then
    test_pass "无过滤参数返回所有环境，共 $ALL_COUNT 条"
else
    test_fail "无过滤参数应返回所有环境"
fi

# ============================================
# 5. 测试激活功能
# ============================================
echo -e "\n${BLUE}[5/8] 测试环境激活功能${NC}"

# 激活全局环境
ACTIVATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api-environments/$GLOBAL_ENV_ID/activate" \
  -H "Authorization: Bearer $TOKEN")

if echo $ACTIVATE_RESPONSE | grep -q '"code":200\|成功'; then
    test_pass "激活全局环境成功"
else
    test_fail "激活全局环境失败" "$ACTIVATE_RESPONSE"
fi

# 验证激活状态
GLOBAL_DETAIL=$(curl -s -X GET "$BASE_URL/api-environments/$GLOBAL_ENV_ID" \
  -H "Authorization: Bearer $TOKEN")

if echo $GLOBAL_DETAIL | grep -q '"isActive":true\|"is_active":true'; then
    test_pass "全局环境 isActive 状态正确: true"
else
    test_fail "全局环境 isActive 状态不正确"
fi

# 激活本地环境
ACTIVATE_LOCAL=$(curl -s -X POST "$BASE_URL/api-environments/$LOCAL_ENV_ID/activate" \
  -H "Authorization: Bearer $TOKEN")

if echo $ACTIVATE_LOCAL | grep -q '"code":200\|成功'; then
    test_pass "激活本地环境成功"
else
    test_fail "激活本地环境失败" "$ACTIVATE_LOCAL"
fi

# ============================================
# 6. 测试更新环境
# ============================================
echo -e "\n${BLUE}[6/8] 测试更新环境${NC}"

UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api-environments/$LOCAL_ENV_ID" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"更新后的本地环境\",
    \"scope\": \"LOCAL\",
    \"project\": $PROJECT_ID,
    \"variables\": {
      \"base_url\": {\"initialValue\": \"http://localhost:8080\", \"currentValue\": \"http://localhost:8080\"},
      \"new_var\": {\"initialValue\": \"hello\", \"currentValue\": \"world\"}
    }
  }")

if echo $UPDATE_RESPONSE | grep -q '"code":200\|"id":'; then
    test_pass "更新环境成功"
    # 验证更新后的名称
    if echo $UPDATE_RESPONSE | grep -q '更新后的本地环境'; then
        test_pass "环境名称更新正确"
    else
        test_fail "环境名称未更新"
    fi
else
    test_fail "更新环境失败" "$UPDATE_RESPONSE"
fi

# ============================================
# 7. 测试环境变量在请求执行中的使用
# ============================================
echo -e "\n${BLUE}[7/8] 测试环境变量在请求执行中的使用${NC}"

# 先创建一个使用环境变量的请求
COLLECTIONS_RESPONSE=$(curl -s -X GET "$BASE_URL/api-collections?projectId=$PROJECT_ID" \
  -H "Authorization: Bearer $TOKEN")
COLLECTION_ID=$(echo $COLLECTIONS_RESPONSE | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)

if [ -z "$COLLECTION_ID" ]; then
    CREATE_COL=$(curl -s -X POST "$BASE_URL/api-collections" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"name\":\"环境测试集合\",\"projectId\":$PROJECT_ID}")
    COLLECTION_ID=$(echo $CREATE_COL | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)
fi

# 创建使用 {{base_url}} 变量的请求
CREATE_REQ=$(curl -s -X POST "$BASE_URL/api-requests" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"collectionId\": $COLLECTION_ID,
    \"name\": \"环境变量测试请求\",
    \"method\": \"GET\",
    \"url\": \"{{base_url}}/get\",
    \"headers\": \"[{\\\"key\\\": \\\"Content-Type\\\", \\\"value\\\": \\\"application/json\\\"}]\"
  }")

REQUEST_ID=$(echo $CREATE_REQ | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)

if [ -n "$REQUEST_ID" ]; then
    # 使用本地环境执行请求
    EXECUTE_RESPONSE=$(curl -s -X POST "$BASE_URL/api-requests/$REQUEST_ID/execute" \
      -H "Authorization: Bearer $TOKEN" \
      -H "Content-Type: application/json" \
      -d "{\"requestId\": $REQUEST_ID, \"environmentId\": $LOCAL_ENV_ID}")

    if echo $EXECUTE_RESPONSE | grep -q '"success":true\|"statusCode":'; then
        test_pass "使用环境变量执行请求成功"
        # 检查 URL 是否被正确替换
        if echo $EXECUTE_RESPONSE | grep -q 'localhost:8080\|localhost:3000'; then
            test_pass "环境变量 {{base_url}} 被正确替换"
        else
            test_fail "环境变量 {{base_url}} 未被替换"
        fi
    else
        test_fail "使用环境变量执行请求失败" "$EXECUTE_RESPONSE"
    fi
else
    test_fail "创建测试请求失败"
fi

# ============================================
# 8. 测试删除环境
# ============================================
echo -e "\n${BLUE}[8/8] 测试删除环境${NC}"

# 创建一个临时环境用于删除测试
TEMP_ENV=$(curl -s -X POST "$BASE_URL/api-environments" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "临时环境-待删除",
    "scope": "GLOBAL",
    "variables": {}
  }')

TEMP_ENV_ID=$(echo $TEMP_ENV | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f4)

if [ -n "$TEMP_ENV_ID" ]; then
    DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api-environments/$TEMP_ENV_ID" \
      -H "Authorization: Bearer $TOKEN")

    if echo $DELETE_RESPONSE | grep -q '"code":200\|成功'; then
        test_pass "删除环境成功"
        # 验证确实被删除
        GET_DELETED=$(curl -s -X GET "$BASE_URL/api-environments/$TEMP_ENV_ID" \
          -H "Authorization: Bearer $TOKEN")
        if echo $GET_DELETED | grep -q '"code":404\|不存在\|null'; then
            test_pass "删除后查询返回 404"
        else
            test_fail "删除后仍能查询到该环境"
        fi
    else
        test_fail "删除环境失败" "$DELETE_RESPONSE"
    fi
fi

# 清理测试数据
echo -e "\n${BLUE}[清理] 删除测试创建的环境...${NC}"
[ -n "$GLOBAL_ENV_ID" ] && curl -s -X DELETE "$BASE_URL/api-environments/$GLOBAL_ENV_ID" -H "Authorization: Bearer $TOKEN" > /dev/null
[ -n "$LOCAL_ENV_ID" ] && curl -s -X DELETE "$BASE_URL/api-environments/$LOCAL_ENV_ID" -H "Authorization: Bearer $TOKEN" > /dev/null
[ -n "$REQUEST_ID" ] && curl -s -X DELETE "$BASE_URL/api-requests/$REQUEST_ID" -H "Authorization: Bearer $TOKEN" > /dev/null
echo "清理完成"

# ============================================
# 测试汇总
# ============================================
echo ""
echo "=========================================="
echo "  测试结果汇总"
echo "=========================================="
echo ""
echo -e "总测试数: ${BLUE}$TOTAL${NC}"
echo -e "通过: ${GREEN}$PASS${NC}"
echo -e "失败: ${RED}$FAIL${NC}"
echo ""

PASS_RATE=0
if [ $TOTAL -gt 0 ]; then
    PASS_RATE=$((PASS * 100 / TOTAL))
fi
echo -e "通过率: ${PASS_RATE}%"

if [ $FAIL -eq 0 ]; then
    echo ""
    echo -e "${GREEN}所有测试通过!${NC}"
    exit 0
else
    echo ""
    echo -e "${RED}有 $FAIL 个测试失败${NC}"
    exit 1
fi
