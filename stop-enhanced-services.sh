#!/bin/bash

echo "====================================="
echo "停止增强版微服务系统"
echo "====================================="

# 定义颜色
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# 基础目录
BASE_DIR="elm_springcloud/springcloud_elm"

# 停止服务函数
stop_service() {
    local pid_file=$1
    local service_name=$2
    
    if [ -f "$pid_file" ]; then
        PID=$(cat "$pid_file")
        if ps -p $PID > /dev/null 2>&1; then
            echo -n "停止 $service_name (PID: $PID)..."
            kill $PID
            sleep 2
            
            # 如果还在运行，强制终止
            if ps -p $PID > /dev/null 2>&1; then
                kill -9 $PID
            fi
            
            echo -e " ${GREEN}已停止${NC}"
        else
            echo "$service_name 未运行"
        fi
        rm -f "$pid_file"
    else
        echo "$service_name PID文件不存在"
    fi
}

# 停止所有服务
echo "停止微服务..."
stop_service "$BASE_DIR/user_server_10100_instance2.pid" "用户服务(实例2)"
stop_service "$BASE_DIR/deliveryaddress_server_10500.pid" "地址服务"
stop_service "$BASE_DIR/orders_server_10601.pid" "订单服务"
stop_service "$BASE_DIR/cart_server_10400.pid" "购物车服务"
stop_service "$BASE_DIR/food_server_10200.pid" "菜品服务"
stop_service "$BASE_DIR/business_server_10300.pid" "商家服务"
stop_service "$BASE_DIR/user_server_10100.pid" "用户服务"
stop_service "$BASE_DIR/gateway_server_14000.pid" "网关服务"
stop_service "$BASE_DIR/shared_kernel.pid" "共享内核"

# 清理残留的Java进程
echo ""
echo "清理残留进程..."
ps aux | grep "[s]pring-boot:run" | awk '{print $2}' | xargs -r kill -9 2>/dev/null

echo ""
echo "清理日志文件..."
find "$BASE_DIR" -name "*.log" -type f -delete
find "logs" -name "*.log" -type f -delete 2>/dev/null

echo ""
echo -e "${GREEN}所有服务已停止！${NC}"