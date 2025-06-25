#!/bin/bash

echo "Stopping Elm Spring Cloud Services..."

# Set the base directory
BASE_DIR="/Users/zhangmingda/Desktop/期末大作业"
NACOS_DIR="$BASE_DIR/nacos/nacos"

# Function to stop a service
stop_service() {
    SERVICE_NAME=$1
    echo "Stopping $SERVICE_NAME..."
    
    # Find and kill the process
    PID=$(ps aux | grep "$SERVICE_NAME" | grep -v grep | awk '{print $2}')
    if [ ! -z "$PID" ]; then
        kill $PID
        echo "$SERVICE_NAME stopped (PID: $PID)"
    else
        echo "$SERVICE_NAME is not running"
    fi
}

# Stop all microservices
echo "========================================="
echo "Stopping Microservices..."
echo "========================================="

# Stop gateway first
stop_service "gateway_server_14000"

# Stop other services
stop_service "user_server_10100"
stop_service "business_server_10300"
stop_service "business_server_10301"
stop_service "food_server_10200"
stop_service "food_server_10201"
stop_service "cart_server_10400"
stop_service "cart_server_10401"
stop_service "deliveryaddress_server_10500"
stop_service "orders_server_10600"
stop_service "orders_server_10601"
stop_service "credit_server_10700"
stop_service "gpt_server_10900"

# Stop Nacos Server
echo "========================================="
echo "Stopping Nacos Server..."
echo "========================================="
cd "$NACOS_DIR"
sh bin/shutdown.sh

echo "========================================="
echo "All services stopped!"
echo "========================================="