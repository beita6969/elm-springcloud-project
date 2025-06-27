#!/bin/bash

echo "====================================="
echo "启动增强版微服务系统"
echo "====================================="

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 基础目录
BASE_DIR="elm_springcloud/springcloud_elm"

# 检查Nacos是否运行
echo "1. 检查Nacos服务..."
if ! curl -s http://localhost:8848/nacos > /dev/null 2>&1; then
    echo -e "${YELLOW}Nacos未运行，正在启动...${NC}"
    cd nacos/nacos/bin
    sh startup.sh -m standalone
    cd ../../..
    echo "等待Nacos启动..."
    sleep 10
else
    echo -e "${GREEN}Nacos已运行${NC}"
fi

# 检查RabbitMQ是否运行
echo ""
echo "2. 检查RabbitMQ服务..."
if ! curl -s http://localhost:15672 > /dev/null 2>&1; then
    echo -e "${RED}RabbitMQ未运行！${NC}"
    echo "请先启动RabbitMQ："
    echo "  Docker: docker run -d --name rabbitmq -p 5672:5672 -p 15672:15672 rabbitmq:3-management"
    echo "  或使用系统包管理器安装并启动RabbitMQ"
    exit 1
else
    echo -e "${GREEN}RabbitMQ已运行${NC}"
fi

# 启动微服务
echo ""
echo "3. 启动微服务..."

# 定义服务列表
declare -A services=(
    ["shared_kernel"]="共享内核"
    ["gateway_server_14000"]="网关服务"
    ["user_server_10100"]="用户服务"
    ["business_server_10300"]="商家服务"
    ["food_server_10200"]="菜品服务"
    ["cart_server_10400"]="购物车服务"
    ["orders_server_10601"]="订单服务"
    ["deliveryaddress_server_10500"]="地址服务"
)

# 启动服务函数
start_service() {
    local service_dir=$1
    local service_name=$2
    
    echo -n "启动 $service_name..."
    cd "$BASE_DIR/$service_dir"
    
    # 编译项目
    mvn clean compile > /dev/null 2>&1
    
    # 启动服务
    nohup mvn spring-boot:run > "$service_dir.log" 2>&1 &
    local pid=$!
    
    cd - > /dev/null
    
    # 等待服务启动
    sleep 5
    
    # 检查服务是否启动成功
    if ps -p $pid > /dev/null; then
        echo -e " ${GREEN}成功${NC} (PID: $pid)"
        echo $pid > "$BASE_DIR/$service_dir.pid"
    else
        echo -e " ${RED}失败${NC}"
        echo "查看日志: $BASE_DIR/$service_dir/$service_dir.log"
    fi
}

# 按顺序启动服务
for service_dir in shared_kernel gateway_server_14000 user_server_10100 business_server_10300 food_server_10200 cart_server_10400 orders_server_10601 deliveryaddress_server_10500; do
    if [[ -v services[$service_dir] ]]; then
        start_service "$service_dir" "${services[$service_dir]}"
        sleep 3
    fi
done

echo ""
echo "4. 启动多实例（演示负载均衡）..."
echo -n "启动用户服务第二实例..."
cd "$BASE_DIR/user_server_10100"
nohup mvn spring-boot:run -Dspring.profiles.active=instance2 > user_instance2.log 2>&1 &
USER2_PID=$!
cd - > /dev/null
sleep 5

if ps -p $USER2_PID > /dev/null; then
    echo -e " ${GREEN}成功${NC} (PID: $USER2_PID, Port: 10101)"
    echo $USER2_PID > "$BASE_DIR/user_server_10100_instance2.pid"
else
    echo -e " ${RED}失败${NC}"
fi

echo ""
echo "5. 检查服务状态..."
sleep 10

# 检查服务健康状态
echo "检查服务健康状态："
services_to_check=(
    "http://localhost:14000/actuator/health:网关"
    "http://localhost:10100/actuator/health:用户服务"
    "http://localhost:10101/actuator/health:用户服务(实例2)"
    "http://localhost:10300/actuator/health:商家服务"
    "http://localhost:10200/actuator/health:菜品服务"
    "http://localhost:10400/actuator/health:购物车服务"
    "http://localhost:10601/actuator/health:订单服务"
    "http://localhost:10500/actuator/health:地址服务"
)

for service_check in "${services_to_check[@]}"; do
    IFS=':' read -r url name <<< "$service_check"
    if curl -s "$url" | grep -q "UP"; then
        echo -e "  $name: ${GREEN}健康${NC}"
    else
        echo -e "  $name: ${RED}不健康${NC}"
    fi
done

echo ""
echo "====================================="
echo "系统启动完成！"
echo "====================================="
echo ""
echo "可用的端点："
echo "  - Nacos控制台: http://localhost:8848/nacos"
echo "  - RabbitMQ管理: http://localhost:15672"
echo "  - 网关地址: http://localhost:14000"
echo "  - 健康检查: http://localhost:14000/actuator/health"
echo "  - Prometheus指标: http://localhost:14000/actuator/prometheus"
echo "  - 配置刷新: POST http://localhost:14000/actuator/bus-refresh"
echo ""
echo "运行测试: ./test-microservices.sh"
echo "停止服务: ./stop-enhanced-services.sh"