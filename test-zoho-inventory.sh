#!/bin/bash

# Test script for Zoho Inventory Service
echo "🧪 Testing Zoho Inventory Service"
echo "=================================="

BASE_URL="http://127.0.0.1:8000/api"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to make API calls
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "\n${YELLOW}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL$endpoint" \
            -H "Content-Type: application/json" \
            -H "Accept: application/json" \
            -d "$data")
    fi
    
    http_code=$(echo "$response" | tail -n1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "200" ]; then
        echo -e "${GREEN}✅ Success (HTTP $http_code)${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    else
        echo -e "${RED}❌ Failed (HTTP $http_code)${NC}"
        echo "$body" | jq '.' 2>/dev/null || echo "$body"
    fi
}

# Test 1: Health Check
test_endpoint "GET" "/zoho-inventory/health" "" "Zoho Inventory Health Check"

# Test 2: Get sync statistics
test_endpoint "GET" "/zoho-inventory/stats" "" "Get Sync Statistics"

# Test 3: Get low stock DAs
test_endpoint "GET" "/zoho-inventory/low-stock" "" "Get Low Stock DAs"

# Test 4: Get all DA summaries
test_endpoint "GET" "/zoho-inventory/all-summaries" "" "Get All DA Inventory Summaries"

# Test 5: Sync all inventory (this might take time)
echo -e "\n${YELLOW}Testing: Sync All DA Inventory (may take time)${NC}"
echo "This test will be skipped in demo mode to avoid long wait times"
# test_endpoint "POST" "/zoho-inventory/sync-all" "" "Sync All DA Inventory"

# Test 6: Get specific DA summary (using DA ID 1 if exists)
test_endpoint "GET" "/zoho-inventory/da-summary?da_id=1" "" "Get Specific DA Summary"

# Test 7: Sync specific DA (using DA ID 1 if exists)
echo -e "\n${YELLOW}Testing: Sync Specific DA Inventory${NC}"
echo "This test will be skipped in demo mode to avoid API calls"
# test_endpoint "POST" "/zoho-inventory/sync-da" '{"da_id": 1}' "Sync Specific DA Inventory"

echo -e "\n${GREEN}🎉 Zoho Inventory Service tests completed!${NC}"
echo "Note: Some tests were skipped to avoid making actual API calls to Zoho"
echo "To run full tests, uncomment the sync operations in this script" 