#!/bin/bash

# Nacos server address
NACOS_SERVER="http://localhost:9666"
NAMESPACE="public"
GROUP="DEFAULT_GROUP"

echo "Importing configurations to Nacos..."

# Function to import a config file
import_config() {
    DATA_ID=$1
    FILE=$2
    
    echo "Importing $DATA_ID from $FILE..."
    
    # Read file content
    CONTENT=$(cat "$FILE")
    
    # URL encode the content
    ENCODED_CONTENT=$(python3 -c "import urllib.parse; import sys; print(urllib.parse.quote(sys.stdin.read()))" <<< "$CONTENT")
    
    # Import to Nacos
    curl -X POST "$NACOS_SERVER/nacos/v1/cs/configs" \
        -d "dataId=$DATA_ID&group=$GROUP&content=$ENCODED_CONTENT&type=yaml" \
        > /dev/null 2>&1
        
    if [ $? -eq 0 ]; then
        echo "✓ $DATA_ID imported successfully"
    else
        echo "✗ Failed to import $DATA_ID"
    fi
}

# Import all configurations
import_config "user-server.yml" "user-server.yml"
import_config "business-server.yml" "business-server.yml"
import_config "food-server.yml" "food-server.yml"
import_config "cart-server.yml" "cart-server.yml"
import_config "deliveryaddress-server.yml" "deliveryaddress-server.yml"
import_config "orders-server.yml" "orders-server.yml"
import_config "credit-server.yml" "credit-server.yml"
import_config "gateway-server.yml" "gateway-server.yml"
import_config "gpt-server.yml" "gpt-server.yml"

echo "Configuration import completed!"
echo "You can view configurations at: $NACOS_SERVER/nacos"