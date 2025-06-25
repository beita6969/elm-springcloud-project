#!/bin/bash

echo "启动饿了么Spring Cloud微服务项目..."

cd /Users/zhangmingda/Desktop/期末大作业/elm_springcloud/springcloud_elm

# 1. 启动Eureka服务注册中心
echo "启动Eureka服务注册中心..."
java -jar eureka_server_13000/target/eureka_server_13000-0.0.1-SNAPSHOT.jar > eureka1.log 2>&1 &
sleep 10
java -jar eureka_server_13001/target/eureka_server_13001-0.0.1-SNAPSHOT.jar > eureka2.log 2>&1 &
sleep 10

# 2. 启动配置中心
echo "启动配置中心..."
java -jar config_server_15000/target/config_server_15000-0.0.1-SNAPSHOT.jar > config1.log 2>&1 &
sleep 10
java -jar config_server_15001/target/config_server_15001-0.0.1-SNAPSHOT.jar > config2.log 2>&1 &
sleep 10

# 3. 启动网关服务
echo "启动网关服务..."
java -jar gateway_server_14000/target/gateway_server_14000-0.0.1-SNAPSHOT.jar > gateway.log 2>&1 &
sleep 10

# 4. 启动业务微服务
echo "启动用户服务..."
java -jar user_server_10100/target/user_server_10100-0.0.1-SNAPSHOT.jar > user.log 2>&1 &
sleep 5

echo "启动商家服务..."
java -jar business_server_10300/target/business_server_10300-0.0.1-SNAPSHOT.jar > business1.log 2>&1 &
java -jar business_server_10301/target/business_server_10301-0.0.1-SNAPSHOT.jar > business2.log 2>&1 &
sleep 5

echo "启动食品服务..."
java -jar food_server_10200/target/food_server_10200-0.0.1-SNAPSHOT.jar > food1.log 2>&1 &
java -jar food_server_10201/target/food_server_10201-0.0.1-SNAPSHOT.jar > food2.log 2>&1 &
sleep 5

echo "启动购物车服务..."
java -jar cart_server_10400/target/cart_server_10400-0.0.1-SNAPSHOT.jar > cart1.log 2>&1 &
java -jar cart_server_10401/target/cart_server_10401-0.0.1-SNAPSHOT.jar > cart2.log 2>&1 &
sleep 5

echo "启动收货地址服务..."
java -jar deliveryaddress_server_10500/target/deliveryaddress_server_10500-0.0.1-SNAPSHOT.jar > deliveryaddress.log 2>&1 &
sleep 5

echo "启动订单服务..."
java -jar orders_server_10600/target/orders_server_10600-0.0.1-SNAPSHOT.jar > orders1.log 2>&1 &
java -jar orders_server_10601/target/orders_server_10601-0.0.1-SNAPSHOT.jar > orders2.log 2>&1 &
sleep 5

echo "启动积分服务..."
java -jar credit_server_10700/target/credit_server_10700-0.0.1-SNAPSHOT.jar > credit.log 2>&1 &
sleep 5

echo "启动GPT服务..."
java -jar gpt_server_10900/target/gpt_server_10900-0.0.1-SNAPSHOT.jar > gpt.log 2>&1 &

echo ""
echo "所有服务已启动！"
echo ""
echo "服务访问地址："
echo "Eureka监控面板: http://localhost:13000"
echo "网关地址: http://localhost:14000"
echo ""
echo "查看服务日志："
echo "tail -f *.log"
echo ""
echo "停止所有服务："
echo "jps -l | grep 'SNAPSHOT.jar' | awk '{print \$1}' | xargs kill -9"