#!/bin/bash

echo "=== 启动所有微服务 ==="

BASE_DIR="/Users/zhangmingda/Desktop/期末大作业/elm_springcloud/springcloud_elm"

# 启动用户服务
echo "启动 user-server..."
cd "$BASE_DIR/user_server_10100"
nohup mvn spring-boot:run > /tmp/user.log 2>&1 &
echo "user-server PID: $!"
sleep 5

# 启动食品服务
echo "启动 food-server..."
cd "$BASE_DIR/food_server_10200"
nohup mvn spring-boot:run > /tmp/food.log 2>&1 &
echo "food-server PID: $!"
sleep 5

# 启动商家服务
echo "启动 business-server..."
cd "$BASE_DIR/business_server_10300"
nohup mvn spring-boot:run > /tmp/business.log 2>&1 &
echo "business-server PID: $!"
sleep 5

# 启动购物车服务
echo "启动 cart-server..."
cd "$BASE_DIR/cart_server_10400"
nohup mvn spring-boot:run > /tmp/cart.log 2>&1 &
echo "cart-server PID: $!"
sleep 5

# 启动地址服务
echo "启动 deliveryaddress-server..."
cd "$BASE_DIR/deliveryaddress_server_10500"
nohup mvn spring-boot:run > /tmp/deliveryaddress.log 2>&1 &
echo "deliveryaddress-server PID: $!"
sleep 5

# 启动订单服务
echo "启动 orders-server..."
cd "$BASE_DIR/orders_server_10600"
nohup mvn spring-boot:run > /tmp/orders.log 2>&1 &
echo "orders-server PID: $!"
sleep 5

# 启动积分服务
echo "启动 credit-server..."
cd "$BASE_DIR/credit_server_10700"
nohup mvn spring-boot:run > /tmp/credit.log 2>&1 &
echo "credit-server PID: $!"
sleep 5

# 启动GPT服务
echo "启动 gpt-server..."
cd "$BASE_DIR/gpt_server_10900"
nohup mvn spring-boot:run > /tmp/gpt.log 2>&1 &
echo "gpt-server PID: $!"
sleep 5

echo "等待服务注册到Nacos..."
sleep 10

# 检查服务注册情况
echo -e "\n检查服务注册情况..."
SERVICES=$(curl -s "http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=100" | grep -o '"dom":"[^"]*"' | wc -l)
echo "已注册服务数量: $SERVICES"

# 启动网关
echo -e "\n启动网关服务..."
cd "$BASE_DIR/gateway_server_14000"
nohup mvn spring-boot:run > /tmp/gateway.log 2>&1 &
echo "gateway-server PID: $!"
sleep 10

echo -e "\n=== 启动完成 ==="
echo "查看服务状态："
echo "curl -s 'http://localhost:8848/nacos/v1/ns/service/list?pageNo=1&pageSize=100' | python3 -m json.tool"