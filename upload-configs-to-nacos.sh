#!/bin/bash

echo "=== 上传配置文件到Nacos ==="

NACOS_URL="http://localhost:8848"
CONFIG_DIR="/Users/zhangmingda/Desktop/期末大作业/nacos-config"

# 上传配置文件到Nacos
upload_config() {
    local dataId=$1
    local file=$2
    
    echo "上传配置: $dataId"
    
    # 读取文件内容
    content=$(cat "$file")
    
    # URL编码内容
    encoded_content=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$content'''))")
    
    # 上传到Nacos
    curl -X POST "$NACOS_URL/nacos/v1/cs/configs" \
        -d "dataId=$dataId&group=DEFAULT_GROUP&content=$encoded_content" \
        -s -o /dev/null
    
    if [ $? -eq 0 ]; then
        echo "✓ $dataId 上传成功"
    else
        echo "✗ $dataId 上传失败"
    fi
}

# 上传所有配置文件
upload_config "user-server.yml" "$CONFIG_DIR/user-server.yml"
upload_config "food-server.yml" "$CONFIG_DIR/food-server.yml"
upload_config "business-server.yml" "$CONFIG_DIR/business-server.yml"
upload_config "cart-server.yml" "$CONFIG_DIR/cart-server.yml"
upload_config "deliveryaddress-server.yml" "$CONFIG_DIR/deliveryaddress-server.yml"
upload_config "orders-server.yml" "$CONFIG_DIR/orders-server.yml"
upload_config "credit-server.yml" "$CONFIG_DIR/credit-server.yml"
upload_config "gpt-server.yml" "$CONFIG_DIR/gpt-server.yml"
upload_config "gateway-server.yml" "$CONFIG_DIR/gateway-server.yml"

echo -e "\n配置上传完成！"