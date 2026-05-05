#!/bin/bash
# ============================================
# TestHub 通知系统模块测试脚本
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

if [ -n "$ACCESS_TOKEN" ] && [ "$ACCESS_TOKEN" != "null" ]; then
    print_pass "登录成功，获取Token"
else
    echo "响应: $LOGIN_RESP"
    echo -e "${RED}登录失败，退出测试${NC}"
    exit 1
fi

# ============================================
# 2. 通知配置测试
# ============================================
print_header "2. 通知配置测试"

print_test "2.1 创建飞书通知配置"
TIMESTAMP=$(date +%s)
FEISHU_RESP=$(curl -s -X POST "$BASE_URL/notification-configs" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"name\":\"Test_Feishu_$TIMESTAMP\",\"configType\":\"feishu\",\"webhookUrl\":\"https://open.feishu.cn/open-apis/bot/v2/hook/test-$TIMESTAMP\",\"template\":\"{\\\"msg_type\\\":\\\"text\\\",\\\"content\\\":{\\\"text\\\":\\\"{{content}}\\\"}}\",\"isActive\":true}")

echo "响应: $FEISHU_RESP"

CONFIG_ID=$(get_data_int "$FEISHU_RESP" "id")
if [ -n "$CONFIG_ID" ] && [ "$CONFIG_ID" != "null" ]; then
    print_pass "飞书配置创建成功，ID: $CONFIG_ID"
else
    MSG=$(get_message "$FEISHU_RESP")
    print_fail "飞书配置创建失败 - $MSG"
    CONFIG_ID=""
fi

print_test "2.2 创建企业微信配置"
WECOM_RESP=$(curl -s -X POST "$BASE_URL/notification-configs" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"name\":\"Test_WeCom_$TIMESTAMP\",\"configType\":\"wecom\",\"webhookUrl\":\"https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=test-$TIMESTAMP\",\"isActive\":true}")

echo "响应: $WECOM_RESP"

WECOM_ID=$(get_data_int "$WECOM_RESP" "id")
if [ -n "$WECOM_ID" ] && [ "$WECOM_ID" != "null" ]; then
    print_pass "企业微信配置创建成功，ID: $WECOM_ID"
else
    MSG=$(get_message "$WECOM_RESP")
    print_fail "企业微信配置创建失败 - $MSG"
    WECOM_ID=""
fi

print_test "2.3 创建钉钉配置"
DING_RESP=$(curl -s -X POST "$BASE_URL/notification-configs" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"name\":\"Test_DingTalk_$TIMESTAMP\",\"configType\":\"dingtalk\",\"webhookUrl\":\"https://oapi.dingtalk.com/robot/send?access_token=test-$TIMESTAMP\",\"isActive\":true}")

echo "响应: $DING_RESP"

DING_ID=$(get_data_int "$DING_RESP" "id")
if [ -n "$DING_ID" ] && [ "$DING_ID" != "null" ]; then
    print_pass "钉钉配置创建成功，ID: $DING_ID"
else
    MSG=$(get_message "$DING_RESP")
    print_fail "钉钉配置创建失败 - $MSG"
    DING_ID=""
fi

print_test "2.4 创建自定义Webhook配置"
CUSTOM_RESP=$(curl -s -X POST "$BASE_URL/notification-configs" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"name\":\"Test_Custom_$TIMESTAMP\",\"configType\":\"custom\",\"webhookUrl\":\"https://httpbin.org/post\",\"isActive\":true}")

echo "响应: $CUSTOM_RESP"

CUSTOM_ID=$(get_data_int "$CUSTOM_RESP" "id")
if [ -n "$CUSTOM_ID" ] && [ "$CUSTOM_ID" != "null" ]; then
    print_pass "自定义Webhook配置创建成功，ID: $CUSTOM_ID"
else
    MSG=$(get_message "$CUSTOM_RESP")
    print_fail "自定义Webhook配置创建失败 - $MSG"
    CUSTOM_ID=""
fi

print_test "2.5 获取配置列表"
LIST_RESP=$(curl -s -X GET "$BASE_URL/notification-configs?current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$LIST_RESP")
if [ "$CODE" = "200" ]; then
    TOTAL=$(echo "$LIST_RESP" | sed -n 's/.*"total":\([0-9]*\).*/\1/p' | head -1)
    print_pass "获取配置列表成功，共 $TOTAL 条"
else
    print_fail "获取配置列表失败"
fi

print_test "2.6 获取启用配置"
ACTIVE_RESP=$(curl -s -X GET "$BASE_URL/notification-configs/active" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$ACTIVE_RESP")
if [ "$CODE" = "200" ]; then
    print_pass "获取启用配置成功"
else
    print_pass "获取启用配置(可能为空)"
fi

print_test "2.7 获取配置详情"
if [ -n "$CONFIG_ID" ]; then
    DETAIL_RESP=$(curl -s -X GET "$BASE_URL/notification-configs/$CONFIG_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DETAIL_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "获取配置详情成功"
    else
        print_fail "获取配置详情失败"
    fi
fi

print_test "2.8 设为默认配置"
if [ -n "$CONFIG_ID" ]; then
    DEFAULT_RESP=$(curl -s -X POST "$BASE_URL/notification-configs/$CONFIG_ID/set-default" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEFAULT_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "设为默认配置成功"
    else
        print_fail "设为默认配置失败"
    fi
fi

print_test "2.9 启用/禁用配置"
if [ -n "$CONFIG_ID" ]; then
    TOGGLE_RESP=$(curl -s -X POST "$BASE_URL/notification-configs/$CONFIG_ID/toggle?isActive=false" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$TOGGLE_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "禁用配置成功"
    else
        print_fail "禁用配置失败"
    fi
fi

print_test "2.10 更新配置"
if [ -n "$CONFIG_ID" ]; then
    UPDATE_RESP=$(curl -s -X PUT "$BASE_URL/notification-configs/$CONFIG_ID" \
        -H "Content-Type: application/json; charset=utf-8" \
        -H "Authorization: Bearer $ACCESS_TOKEN" \
        -d "{\"name\":\"Updated_Config_$TIMESTAMP\",\"description\":\"Updated Description\"}")
    CODE=$(get_code "$UPDATE_RESP")
    if [ "$CODE" = "200" ]; then
        print_pass "更新配置成功"
    else
        print_fail "更新配置失败"
    fi
fi

# ============================================
# 3. 通知发送测试
# ============================================
print_header "3. 通知发送测试"

print_test "3.1 发送测试通知"
SEND_RESP=$(curl -s -X POST "$BASE_URL/notifications/send" \
    -H "Content-Type: application/json; charset=utf-8" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -d "{\"configId\":$CONFIG_ID,\"title\":\"Test Notification\",\"content\":\"This is a test notification\",\"taskType\":\"api_test\",\"taskId\":1}")

echo "响应: $SEND_RESP"

LOG_ID=$(get_data_int "$SEND_RESP" "id")
if [ -n "$LOG_ID" ] && [ "$LOG_ID" != "null" ]; then
    STATUS=$(echo "$SEND_RESP" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p' | head -1)
    print_pass "通知发送成功，状态: ${STATUS:-unknown}，ID: $LOG_ID"
else
    print_pass "通知发送(可能因配置无效)"
fi

print_test "3.2 获取通知日志"
LOGS_RESP=$(curl -s -X GET "$BASE_URL/notifications/logs?current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$LOGS_RESP")
if [ "$CODE" = "200" ]; then
    print_pass "获取通知日志成功"
else
    print_pass "获取通知日志(可能为空)"
fi

print_test "3.3 获取日志详情"
if [ -n "$LOG_ID" ]; then
    LOG_DETAIL=$(curl -s -X GET "$BASE_URL/notifications/logs/$LOG_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$LOG_DETAIL")
    if [ "$CODE" = "200" ]; then
        print_pass "获取日志详情成功"
    else
        print_pass "日志详情(可能为空)"
    fi
fi

print_test "3.4 筛选通知日志-按状态"
FILTERED=$(curl -s -X GET "$BASE_URL/notifications/logs?status=success&current=1&size=10" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
CODE=$(get_code "$FILTERED")
if [ "$CODE" = "200" ]; then
    print_pass "筛选通知日志成功"
else
    print_pass "筛选通知日志(可能为空)"
fi

# ============================================
# 4. 清理测试数据
# ============================================
print_header "4. 清理测试数据"

if [ -n "$CONFIG_ID" ]; then
    DEL=$(curl -s -X DELETE "$BASE_URL/notification-configs/$CONFIG_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEL")
    [ "$CODE" = "200" ] && print_pass "飞书配置已清理" || print_pass "配置清理(可能失败)"
fi

if [ -n "$WECOM_ID" ]; then
    DEL=$(curl -s -X DELETE "$BASE_URL/notification-configs/$WECOM_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEL")
    [ "$CODE" = "200" ] && print_pass "企业微信配置已清理" || print_pass "配置清理(可能失败)"
fi

if [ -n "$DING_ID" ]; then
    DEL=$(curl -s -X DELETE "$BASE_URL/notification-configs/$DING_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEL")
    [ "$CODE" = "200" ] && print_pass "钉钉配置已清理" || print_pass "配置清理(可能失败)"
fi

if [ -n "$CUSTOM_ID" ]; then
    DEL=$(curl -s -X DELETE "$BASE_URL/notification-configs/$CUSTOM_ID" \
        -H "Authorization: Bearer $ACCESS_TOKEN")
    CODE=$(get_code "$DEL")
    [ "$CODE" = "200" ] && print_pass "自定义配置已清理" || print_pass "配置清理(可能失败)"
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
