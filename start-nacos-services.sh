#!/bin/bash

echo "Starting Elm Spring Cloud Services with Nacos..."

# Set the base directory
BASE_DIR="/Users/zhangmingda/Desktop/期末大作业"
NACOS_DIR="$BASE_DIR/nacos/nacos"
PROJECT_DIR="$BASE_DIR/elm_springcloud/springcloud_elm"

# Function to start a service
start_service() {
    SERVICE_NAME=$1
    SERVICE_DIR="$PROJECT_DIR/$SERVICE_NAME"
    
    echo "Starting $SERVICE_NAME..."
    cd "$SERVICE_DIR"
    nohup java -jar target/*.jar > "$SERVICE_NAME.log" 2>&1 &
    echo "$SERVICE_NAME started with PID $!"
    sleep 5
}

# Step 1: Start Nacos Server
echo "========================================="
echo "Starting Nacos Server..."
echo "========================================="
cd "$NACOS_DIR"
sh bin/startup.sh -m standalone

# Wait for Nacos to fully start
echo "Waiting for Nacos to start..."
sleep 20

# Check if Nacos is running
curl -s http://localhost:8848/nacos/ > /dev/null
if [ $? -eq 0 ]; then
    echo "Nacos Server started successfully!"
    echo "Nacos Console: http://localhost:8848/nacos"
    echo "Default username/password: nacos/nacos"
else
    echo "Failed to start Nacos Server!"
    exit 1
fi

# Step 2: Build all services
echo "========================================="
echo "Building all microservices..."
echo "========================================="
cd "$PROJECT_DIR"
mvn clean package -DskipTests

# Step 3: Start microservices in order
echo "========================================="
echo "Starting Microservices..."
echo "========================================="

# Start core services first
start_service "user_server_10100"
start_service "gpt_server_10900"
start_service "credit_server_10700"
start_service "deliveryaddress_server_10500"

# Start business services
start_service "business_server_10300"
start_service "business_server_10301"

# Start food services
start_service "food_server_10200"
start_service "food_server_10201"

# Start cart services
start_service "cart_server_10400"
start_service "cart_server_10401"

# Start order services
start_service "orders_server_10600"
start_service "orders_server_10601"

# Start gateway last
echo "Waiting for all services to register with Nacos..."
sleep 10
start_service "gateway_server_14000"

echo "========================================="
echo "All services started!"
echo "========================================="
echo "Service URLs:"
echo "- Nacos Console: http://localhost:8848/nacos"
echo "- Gateway: http://localhost:14000"
echo "- User Service: http://localhost:10100"
echo "- Business Services: http://localhost:10300, http://localhost:10301"
echo "- Food Services: http://localhost:10200, http://localhost:10201"
echo "- Cart Services: http://localhost:10400, http://localhost:10401"
echo "- Delivery Address Service: http://localhost:10500"
echo "- Order Services: http://localhost:10600, http://localhost:10601"
echo "- Credit Service: http://localhost:10700"
echo "- GPT Service: http://localhost:10900"
echo "========================================="

# Show service status
echo "Checking service registration in Nacos..."
sleep 5
curl -s http://localhost:8848/nacos/v1/ns/service/list | jq