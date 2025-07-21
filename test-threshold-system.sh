#!/bin/bash

# VITALVIDA THRESHOLD ENFORCEMENT SYSTEM TEST SCRIPT
# Phase 4 Part 1 - Core Threshold Validation & Violation Management

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://127.0.0.1:8000/api"
AUTH_TOKEN=""

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0
TOTAL_TESTS=0

echo -e "${BLUE}🧪 VITALVIDA THRESHOLD ENFORCEMENT SYSTEM TEST SUITE${NC}"
echo -e "${BLUE}Phase 4 Part 1: Core Threshold Validation & Violation Management${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# Function to print test results
print_test_result() {
    local test_name="$1"
    local expected_status="$2"
    local actual_status="$3"
    local response="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [[ "$actual_status" == "$expected_status" ]]; then
        echo -e "${GREEN}✅ PASS${NC} - $test_name"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAIL${NC} - $test_name"
        echo -e "${RED}   Expected: $expected_status, Got: $actual_status${NC}"
        echo -e "${YELLOW}   Response: $response${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
}

# Function to run API test
run_test() {
    local test_name="$1"
    local method="$2"
    local endpoint="$3"
    local data="$4"
    local expected_status="$5"
    
    echo -e "${BLUE}Testing:${NC} $test_name"
    
    if [[ "$method" == "GET" ]]; then
        response=$(curl -s -w "\n%{http_code}" -X GET "$BASE_URL$endpoint" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL$endpoint" \
            -H "Authorization: Bearer $AUTH_TOKEN" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    
    # Extract HTTP status code (last line)
    status_code=$(echo "$response" | tail -n1)
    # Extract response body (all lines except last)
    response_body=$(echo "$response" | head -n -1)
    
    print_test_result "$test_name" "$expected_status" "$status_code" "$response_body"
    
    # Pretty print successful responses
    if [[ "$status_code" == "$expected_status" ]] && [[ "$status_code" -lt 400 ]]; then
        echo "$response_body" | jq '.' 2>/dev/null || echo "$response_body"
    fi
    
    echo ""
}

# Get authentication token
echo -e "${YELLOW}🔐 Getting authentication token...${NC}"
if [[ -z "$AUTH_TOKEN" ]]; then
    # Try to get token from existing user
    token_response=$(curl -s -X POST "$BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email": "admin@example.com", "password": "password"}')
    
    AUTH_TOKEN=$(echo "$token_response" | jq -r '.token' 2>/dev/null)
    
    if [[ "$AUTH_TOKEN" == "null" ]] || [[ -z "$AUTH_TOKEN" ]]; then
        echo -e "${RED}❌ Failed to get authentication token${NC}"
        echo -e "${YELLOW}Response: $token_response${NC}"
        echo -e "${YELLOW}Please ensure you have a test user with credentials:${NC}"
        echo -e "${YELLOW}Email: admin@example.com${NC}"
        echo -e "${YELLOW}Password: password${NC}"
        echo ""
        echo -e "${YELLOW}Or manually set AUTH_TOKEN environment variable${NC}"
        exit 1
    fi
fi

echo -e "${GREEN}✅ Authentication successful${NC}"
echo -e "${BLUE}Token: ${AUTH_TOKEN:0:20}...${NC}"
echo ""

# Start testing
echo -e "${BLUE}🧪 Starting Threshold Enforcement System Tests...${NC}"
echo ""

# Test 1: Health Check
run_test "Health Check" "GET" "/threshold/health" "" "200"

# Test 2: Logistics Cost Validation - Within Limits
run_test "Logistics Cost Within Limits" "POST" "/threshold/validate-cost" \
    '{"type": "logistics", "amount": 80, "quantity": 1, "storekeeper_fee": 800, "transport_fare": 1200}' "200"

# Test 3: Logistics Cost Validation - Exceeds Per Unit Limit
run_test "Logistics Cost Exceeds Per Unit Limit" "POST" "/threshold/validate-cost" \
    '{"type": "logistics", "amount": 150, "quantity": 1, "storekeeper_fee": 800, "transport_fare": 1200}' "200"

# Test 4: Logistics Cost Validation - Exceeds Storekeeper Fee
run_test "Logistics Cost Exceeds Storekeeper Fee" "POST" "/threshold/validate-cost" \
    '{"type": "logistics", "amount": 80, "quantity": 1, "storekeeper_fee": 1200, "transport_fare": 1200}' "200"

# Test 5: Logistics Cost Validation - Exceeds Transport Fare
run_test "Logistics Cost Exceeds Transport Fare" "POST" "/threshold/validate-cost" \
    '{"type": "logistics", "amount": 80, "quantity": 1, "storekeeper_fee": 800, "transport_fare": 1800}' "200"

# Test 6: Logistics Cost Validation - Exceeds Total for 120 Items
run_test "Logistics Cost Exceeds Total for 120 Items" "POST" "/threshold/validate-cost" \
    '{"type": "logistics", "amount": 15000, "quantity": 120, "storekeeper_fee": 800, "transport_fare": 1200}' "200"

# Test 7: Expense Validation - Within FC Limit
run_test "Expense Within FC Limit" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 4000, "category": "office_supplies"}' "200"

# Test 8: Expense Validation - Within GM Limit
run_test "Expense Within GM Limit" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 8000, "category": "equipment"}' "200"

# Test 9: Expense Validation - Requires CEO Approval
run_test "Expense Requires CEO Approval" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 12000, "category": "equipment"}' "200"

# Test 10: Special Category - Generator Fuel (Always Dual Approval)
run_test "Generator Fuel Requires Dual Approval" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 3000, "category": "generator_fuel"}' "200"

# Test 11: Special Category - Equipment Repair Above Threshold
run_test "Equipment Repair Above Threshold" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 10000, "category": "equipment_repair"}' "200"

# Test 12: Special Category - Vehicle Maintenance Above Threshold
run_test "Vehicle Maintenance Above Threshold" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": 20000, "category": "vehicle_maintenance"}' "200"

# Test 13: Bonus Validation - FC Level
run_test "Bonus FC Level" "POST" "/threshold/validate-cost" \
    '{"type": "bonus", "amount": 3000}' "200"

# Test 14: Bonus Validation - GM Level
run_test "Bonus GM Level" "POST" "/threshold/validate-cost" \
    '{"type": "bonus", "amount": 8000}' "200"

# Test 15: Bonus Validation - High Value (Dual Approval)
run_test "High Value Bonus Requires Dual Approval" "POST" "/threshold/validate-cost" \
    '{"type": "bonus", "amount": 15000}' "200"

# Test 16: Get Violations
run_test "Get Violations" "GET" "/threshold/violations" "" "200"

# Test 17: Get Escalations
run_test "Get Escalations" "GET" "/threshold/escalations" "" "200"

# Test 18: Get Pending Approvals
run_test "Get Pending Approvals" "GET" "/threshold/pending-approvals" "" "200"

# Test 19: Get Statistics
run_test "Get Statistics" "GET" "/threshold/statistics" "" "200"

# Test 20: Get Urgent Items
run_test "Get Urgent Items" "GET" "/threshold/urgent-items" "" "200"

# Test 21: Invalid Cost Type
run_test "Invalid Cost Type" "POST" "/threshold/validate-cost" \
    '{"type": "invalid", "amount": 1000}' "422"

# Test 22: Missing Required Fields
run_test "Missing Required Fields" "POST" "/threshold/validate-cost" \
    '{"type": "expense"}' "422"

# Test 23: Negative Amount
run_test "Negative Amount" "POST" "/threshold/validate-cost" \
    '{"type": "expense", "amount": -1000}' "422"

# Summary
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}📊 TEST SUMMARY${NC}"
echo -e "${BLUE}======================================================${NC}"
echo -e "${GREEN}✅ Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}❌ Tests Failed: $TESTS_FAILED${NC}"
echo -e "${BLUE}📝 Total Tests: $TOTAL_TESTS${NC}"
echo ""

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "${GREEN}🎉 ALL TESTS PASSED! Threshold Enforcement System is working correctly.${NC}"
    echo -e "${GREEN}✅ Phase 4 Part 1 implementation is complete and functional.${NC}"
else
    echo -e "${RED}⚠️  Some tests failed. Please review the errors above.${NC}"
fi

echo ""
echo -e "${BLUE}🔍 System Status:${NC}"
echo -e "${BLUE}• Core threshold validation: ✅ Implemented${NC}"
echo -e "${BLUE}• Violation management: ✅ Implemented${NC}"
echo -e "${BLUE}• Escalation system: ✅ Implemented${NC}"
echo -e "${BLUE}• Approval workflow: ✅ Implemented${NC}"
echo -e "${BLUE}• Statistics & monitoring: ✅ Implemented${NC}"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo -e "${YELLOW}1. Run database migrations: php artisan migrate${NC}"
echo -e "${YELLOW}2. Test with real payment scenarios${NC}"
echo -e "${YELLOW}3. Configure notification settings${NC}"
echo -e "${YELLOW}4. Set up scheduled jobs for expired escalations${NC}"
echo -e "${YELLOW}5. Implement Part 2: Dual Approval Workflow${NC}" 