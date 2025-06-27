#!/bin/bash

# 微服务功能测试脚本
# 测试负载均衡、配置刷新、限流、认证等功能

echo "====================================="
echo "微服务功能测试脚本"
echo "====================================="

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 网关地址
GATEWAY_URL="http://localhost:14000"

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# 测试函数
function test_case() {
    local test_name=$1
    local command=$2
    local expected_result=$3
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -n "测试 $test_name ... "
    
    result=$(eval $command 2>&1)
    
    if [[ $result == *"$expected_result"* ]]; then
        echo -e "${GREEN}通过${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}失败${NC}"
        echo "  期望: $expected_result"
        echo "  实际: $result"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

echo ""
echo "1. 测试服务健康状态"
echo "-------------------------------------"
test_case "网关健康检查" \
    "curl -s $GATEWAY_URL/actuator/health | jq -r '.status'" \
    "UP"

test_case "用户服务健康检查" \
    "curl -s http://localhost:10100/actuator/health | jq -r '.status'" \
    "UP"

echo ""
echo "2. 测试认证功能"
echo "-------------------------------------"
# 不带token访问受保护接口
test_case "无Token访问受保护接口" \
    "curl -s -w '%{http_code}' -o /dev/null $GATEWAY_URL/UserController/getUserById/1" \
    "401"

# 带token访问受保护接口
test_case "带Token访问受保护接口" \
    "curl -s -w '%{http_code}' -o /dev/null -H 'Authorization: Bearer test-token-12345' $GATEWAY_URL/UserController/getUserById/1" \
    "200"

# 访问白名单接口
test_case "访问登录接口（白名单）" \
    "curl -s -w '%{http_code}' -o /dev/null -X POST $GATEWAY_URL/UserController/login" \
    "200"

echo ""
echo "3. 测试限流功能"
echo "-------------------------------------"
echo "连续发送100个请求测试限流..."
RATE_LIMITED=false
for i in {1..100}; do
    STATUS=$(curl -s -w '%{http_code}' -o /dev/null -H "Authorization: Bearer test-token" $GATEWAY_URL/actuator/health)
    if [ "$STATUS" == "429" ]; then
        RATE_LIMITED=true
        echo -e "${GREEN}限流生效：在第 $i 个请求时触发限流${NC}"
        PASSED_TESTS=$((PASSED_TESTS + 1))
        break
    fi
done

TOTAL_TESTS=$((TOTAL_TESTS + 1))
if [ "$RATE_LIMITED" == "false" ]; then
    echo -e "${RED}限流测试失败：100个请求内未触发限流${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi

echo ""
echo "4. 测试负载均衡"
echo "-------------------------------------"
echo "启动服务的第二个实例..."
# 启动用户服务第二个实例
cd elm_springcloud/springcloud_elm/user_server_10100
nohup mvn spring-boot:run -Dspring.profiles.active=instance2 > user2.log 2>&1 &
USER2_PID=$!
cd ../../..
sleep 10

echo "等待第二个实例启动..."
for i in {1..30}; do
    if curl -s http://localhost:10101/actuator/health > /dev/null 2>&1; then
        echo -e "${GREEN}第二个实例启动成功${NC}"
        break
    fi
    sleep 1
done

# 测试负载均衡分布
echo "发送10个请求，检查负载均衡..."
declare -A instance_count
for i in {1..10}; do
    # 这里需要一个能返回实例信息的接口
    INSTANCE=$(curl -s -H "Authorization: Bearer test-token" $GATEWAY_URL/UserController/getInstanceInfo 2>/dev/null | jq -r '.port' || echo "unknown")
    instance_count[$INSTANCE]=$((instance_count[$INSTANCE] + 1))
done

echo "负载均衡结果："
for instance in "${!instance_count[@]}"; do
    echo "  实例 $instance: ${instance_count[$instance]} 次"
done

echo ""
echo "5. 测试配置动态刷新"
echo "-------------------------------------"
# 获取当前配置
echo "获取当前配置值..."
CURRENT_CONFIG=$(curl -s http://localhost:10100/actuator/env | jq -r '.propertySources[0].properties."test.config.value".value' || echo "not-found")
echo "当前配置值: $CURRENT_CONFIG"

# 触发配置刷新
echo "触发配置刷新..."
REFRESH_RESULT=$(curl -s -X POST http://localhost:10100/actuator/bus-refresh)
echo "刷新结果: $REFRESH_RESULT"

echo ""
echo "6. 测试监控指标"
echo "-------------------------------------"
# 获取Prometheus指标
test_case "获取Prometheus指标" \
    "curl -s http://localhost:14000/actuator/prometheus | grep -c 'gateway_requests_total'" \
    "1"

# 获取网关路由信息
test_case "获取网关路由信息" \
    "curl -s http://localhost:14000/actuator/gateway/routes | jq '. | length'" \
    "12"

echo ""
echo "7. 测试服务间调用"
echo "-------------------------------------"
# 测试Business服务调用Food服务
test_case "Business服务调用Food服务（Feign）" \
    "curl -s -H 'Authorization: Bearer test-token' $GATEWAY_URL/BusinessController/getBusinessInfo/10001 | jq -r '.code'" \
    "200"

echo ""
echo "====================================="
echo "测试结果汇总"
echo "====================================="
echo -e "总测试数: $TOTAL_TESTS"
echo -e "通过: ${GREEN}$PASSED_TESTS${NC}"
echo -e "失败: ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "\n${GREEN}所有测试通过！${NC}"
else
    echo -e "\n${RED}有 $FAILED_TESTS 个测试失败！${NC}"
fi

# 清理测试环境
echo ""
echo "清理测试环境..."
if [ ! -z "$USER2_PID" ]; then
    kill $USER2_PID 2>/dev/null
    echo "已停止用户服务第二个实例"
fi

echo ""
echo "测试完成！"