#!/bin/bash

# Threshold Enforcement System Test Script
# This script tests all the Threshold Enforcement API endpoints

# Configuration
BASE_URL="http://127.0.0.1:8000"
AUTH_TOKEN="16|zd9dpJJrmRSdDEao7jILZ0cByF42i3V2Xme48ZOa07a8e33e"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🚨 Testing Threshold Enforcement System"
echo "========================================"
echo ""

# Function to test an endpoint
test_endpoint() {
    local description="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local use_auth="$5"
    
    echo "Testing: $description"
    echo "Endpoint: $method $endpoint"
    
    # Prepare curl command
    local curl_cmd="curl -s -X $method \"$BASE_URL$endpoint\""
    
    if [ "$use_auth" = "true" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $AUTH_TOKEN\""
    fi
    
    if [ "$method" = "POST" ] && [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H \"Content-Type: application/json\" -d '$data'"
    fi
    
    # Execute curl command and capture response
    local response=$(eval $curl_cmd)
    local http_code=$(eval "$curl_cmd -w '%{http_code}'" | tail -c 3)
    
    # Check if response is successful
    if [[ "$http_code" =~ ^2[0-9][0-9]$ ]]; then
        echo -e "${GREEN}✅ Success (HTTP $http_code)${NC}"
    else
        echo -e "${RED}❌ Failed (HTTP $http_code)${NC}"
    fi
    
    # Pretty print JSON response
    echo "$response" | jq '.' 2>/dev/null || echo "$response"
    echo ""
}

# Test 1: Health Check (Public endpoint)
test_endpoint "Threshold Enforcement Health Check" "GET" "/api/threshold-enforcement/health" "" "false"

# Test 2: Validate Expense Within Limits
test_endpoint "Validate Expense Within Limits (₦500 storekeeper fee)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 500, "category": "logistics", "subcategory": "storekeeper_fee", "context": {"items": 10}}' "true"

# Test 3: Validate Expense Exceeding Limits
test_endpoint "Validate Expense Exceeding Limits (₦1,500 storekeeper fee - exceeds ₦1,000)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 1500, "category": "logistics", "subcategory": "storekeeper_fee", "context": {"items": 10}}' "true"

# Test 4: Validate Cost Per Unit Within Limits
test_endpoint "Validate Cost Per Unit Within Limits (₦80 per unit)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 80, "category": "logistics", "subcategory": "cost_per_unit", "context": {"items": 10}}' "true"

# Test 5: Validate Cost Per Unit Exceeding Limits
test_endpoint "Validate Cost Per Unit Exceeding Limits (₦150 per unit - exceeds ₦100)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 150, "category": "logistics", "subcategory": "cost_per_unit", "context": {"items": 10}}' "true"

# Test 6: Validate Transport Fare Within Limits
test_endpoint "Validate Transport Fare Within Limits (₦1,200 round trip)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 1200, "category": "logistics", "subcategory": "transport_fare", "context": {"origin": "Lagos", "destination": "Abuja"}}' "true"

# Test 7: Validate Transport Fare Exceeding Limits
test_endpoint "Validate Transport Fare Exceeding Limits (₦2,000 round trip - exceeds ₦1,500)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 2000, "category": "logistics", "subcategory": "transport_fare", "context": {"origin": "Lagos", "destination": "Abuja"}}' "true"

# Test 8: Validate Generator Fuel (Always requires FC+GM dual approval)
test_endpoint "Validate Generator Fuel (Always requires FC+GM dual approval)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 5000, "category": "expenses", "subcategory": "generator_fuel", "context": {"location": "Lagos"}}' "true"

# Test 9: Validate Equipment Repairs Within Limits
test_endpoint "Validate Equipment Repairs Within Limits (₦5,000)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 5000, "category": "expenses", "subcategory": "equipment_repairs", "context": {"equipment": "printer"}}' "true"

# Test 10: Validate Equipment Repairs Exceeding Limits
test_endpoint "Validate Equipment Repairs Exceeding Limits (₦10,000 - requires GM+CEO)" "POST" "/api/threshold-enforcement/validate-expense" \
    '{"amount": 10000, "category": "expenses", "subcategory": "equipment_repairs", "context": {"equipment": "server"}}' "true"

# Test 11: Get Threshold Statistics
test_endpoint "Get Threshold Statistics" "GET" "/api/threshold-enforcement/statistics" "" "true"

# Test 12: Get Urgent Items
test_endpoint "Get Urgent Items" "GET" "/api/threshold-enforcement/urgent-items" "" "true"

# Test 13: Get Threshold Violations
test_endpoint "Get Threshold Violations" "GET" "/api/threshold-enforcement/violations" "" "true"

# Test 14: Get Approval Workflows
test_endpoint "Get Approval Workflows" "GET" "/api/threshold-enforcement/approval-workflows" "" "true"

# Test 15: Get Salary Deductions
test_endpoint "Get Salary Deductions" "GET" "/api/threshold-enforcement/salary-deductions" "" "true"

echo "🎉 Threshold Enforcement System tests completed!"
echo "Note: Some tests may show errors if no violations exist yet"
echo "The system is designed to block unauthorized expenses and require approvals" 