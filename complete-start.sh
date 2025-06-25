#!/bin/bash

echo "=== 微服务架构启动脚本 ==="

# 设置基础目录
BASE_DIR="/Users/zhangmingda/Desktop/期末大作业/elm_springcloud/springcloud_elm"
NACOS_DIR="/Users/zhangmingda/Desktop/期末大作业/nacos/nacos"

# 1. 清理旧进程
echo "1. 停止所有运行的服务..."
pkill -f "nacos" || true
pkill -f "spring-boot:run" || true
sleep 3

# 2. 修复Nacos配置并启动
echo -e "\n2. 启动Nacos服务器..."
cd "$NACOS_DIR"
# 创建临时目录
mkdir -p "$NACOS_DIR/temp"
# 设置Nacos属性，指定临时目录
export NACOS_OPTS="-Dserver.tomcat.basedir=$NACOS_DIR/temp"
nohup bin/startup.sh -m standalone > /tmp/nacos-startup.log 2>&1 &
echo "等待Nacos启动..."
sleep 25

# 检查Nacos是否启动
if curl -s http://localhost:9666/nacos/ | grep -q "Nacos"; then
    echo "✓ Nacos已成功启动"
else
    echo "✗ Nacos启动失败，请检查日志"
    exit 1
fi

# 3. 启动所有微服务
echo -e "\n3. 启动微服务..."

# 用户服务
echo "启动 user-server..."
cd "$BASE_DIR/user_server_10100"
nohup mvn spring-boot:run > user.log 2>&1 &
sleep 10

# 食品服务
echo "启动 food-server..."
cd "$BASE_DIR/food_server_10200"
nohup mvn spring-boot:run > food.log 2>&1 &
sleep 10

# 商家服务
echo "启动 business-server..."
cd "$BASE_DIR/business_server_10300"
nohup mvn spring-boot:run > business.log 2>&1 &
sleep 10

# 购物车服务
echo "启动 cart-server..."
cd "$BASE_DIR/cart_server_10400"
nohup mvn spring-boot:run > cart.log 2>&1 &
sleep 10

# 地址服务
echo "启动 deliveryaddress-server..."
cd "$BASE_DIR/deliveryaddress_server_10500"
nohup mvn spring-boot:run > address.log 2>&1 &
sleep 10

# 订单服务
echo "启动 orders-server..."
cd "$BASE_DIR/orders_server_10600"
nohup mvn spring-boot:run > orders.log 2>&1 &
sleep 10

# 积分服务
echo "启动 credit-server..."
cd "$BASE_DIR/credit_server_10700"
nohup mvn spring-boot:run > credit.log 2>&1 &
sleep 10

# GPT服务
echo "启动 gpt-server..."
cd "$BASE_DIR/gpt_server_10900"
nohup mvn spring-boot:run > gpt.log 2>&1 &
sleep 10

# 4. 检查服务注册情况
echo -e "\n4. 检查服务注册情况..."
SERVICES=$(curl -s "http://localhost:9666/nacos/v1/ns/service/list?pageNo=1&pageSize=100" | grep -o '"doms":\[[^]]*\]' | grep -o '\["[^"]*"' | wc -l)
echo "已注册服务数量: $SERVICES"

# 5. 启动网关
echo -e "\n5. 启动网关服务..."
cd "$BASE_DIR/gateway_server_14000"
nohup mvn spring-boot:run > gateway.log 2>&1 &
sleep 15

# 6. 测试网关
echo -e "\n6. 测试网关连接..."
if curl -s http://localhost:14000/UserController/listUser | grep -q "success"; then
    echo "✓ 网关正常工作"
else
    echo "✗ 网关连接失败"
fi

# 7. 前端已经在运行
echo -e "\n=== 启动完成 ==="
echo "访问地址："
echo "- Nacos控制台: http://localhost:9666/nacos (用户名/密码: nacos/nacos)"
echo "- 前端应用: http://localhost:8083"
echo "- 网关地址: http://localhost:14000"
echo ""
echo "查看服务状态："
echo "curl -s 'http://localhost:9666/nacos/v1/ns/service/list?pageNo=1&pageSize=100' | python3 -m json.tool"