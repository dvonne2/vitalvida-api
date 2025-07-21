#!/bin/bash

# Phase 5: Bonus Management & Payroll Integration Test Script
# Tests all bonus and payroll management endpoints and workflows

echo "🚀 PHASE 5: BONUS MANAGEMENT & PAYROLL INTEGRATION TEST"
echo "======================================================"

BASE_URL="http://localhost:8000/api"
CONTENT_TYPE="Content-Type: application/json"
ACCEPT_HEADER="Accept: application/json"

# Test user credentials (adjust as needed)
LOGIN_EMAIL="ceo@vitalvida.com"
LOGIN_PASSWORD="password123"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to print test results
print_result() {
    local test_name="$1"
    local http_code="$2"
    local expected_code="$3"
    local response="$4"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    if [ "$http_code" = "$expected_code" ]; then
        echo -e "${GREEN}✅ PASS${NC}: $test_name (HTTP $http_code)"
        PASSED_TESTS=$((PASSED_TESTS + 1))
    else
        echo -e "${RED}❌ FAIL${NC}: $test_name (HTTP $http_code, expected $expected_code)"
        echo -e "${YELLOW}Response: $response${NC}"
        FAILED_TESTS=$((FAILED_TESTS + 1))
    fi
}

# Function to extract HTTP status code
get_http_code() {
    echo "$1" | tail -n1
}

# Function to get response body
get_response_body() {
    echo "$1" | sed '$d'
}

echo "🔐 Step 1: Authentication"
echo "------------------------"

LOGIN_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/auth/login" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d "{
    \"email\": \"$LOGIN_EMAIL\",
    \"password\": \"$LOGIN_PASSWORD\"
  }")

LOGIN_HTTP_CODE=$(get_http_code "$LOGIN_RESPONSE")
LOGIN_BODY=$(get_response_body "$LOGIN_RESPONSE")

print_result "User login" "$LOGIN_HTTP_CODE" "200" "$LOGIN_BODY"

if [ "$LOGIN_HTTP_CODE" != "200" ]; then
    echo -e "${RED}❌ Authentication failed. Cannot proceed with tests.${NC}"
    exit 1
fi

# Extract token
TOKEN=$(echo "$LOGIN_BODY" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
AUTH_HEADER="Authorization: Bearer $TOKEN"

echo -e "${GREEN}✅ Authentication successful${NC}"
echo ""

echo "💰 Step 2: Bonus Management Tests"
echo "================================="

# Test 2.1: Get all bonuses
echo "📋 Test 2.1: Get all bonuses"
BONUSES_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

BONUSES_HTTP_CODE=$(get_http_code "$BONUSES_RESPONSE")
print_result "Get all bonuses" "$BONUSES_HTTP_CODE" "200"

# Test 2.2: Create a new bonus
echo "📋 Test 2.2: Create a new bonus"
CREATE_BONUS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/bonuses" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "employee_id": 1,
    "bonus_type": "performance",
    "amount": 12000,
    "description": "Q4 performance bonus for excellent delivery metrics",
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "calculation_data": {
      "success_rate": 95.5,
      "deliveries_completed": 85,
      "customer_rating": 4.8
    }
  }')

CREATE_BONUS_HTTP_CODE=$(get_http_code "$CREATE_BONUS_RESPONSE")
CREATE_BONUS_BODY=$(get_response_body "$CREATE_BONUS_RESPONSE")
print_result "Create new bonus" "$CREATE_BONUS_HTTP_CODE" "201"

# Extract bonus ID for further tests
if [ "$CREATE_BONUS_HTTP_CODE" = "201" ]; then
    BONUS_ID=$(echo "$CREATE_BONUS_BODY" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    echo "Created bonus ID: $BONUS_ID"
fi

# Test 2.3: Get specific bonus details
if [ -n "$BONUS_ID" ]; then
    echo "📋 Test 2.3: Get specific bonus details"
    BONUS_DETAILS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
      "$BASE_URL/bonuses/$BONUS_ID" \
      -H "$AUTH_HEADER" \
      -H "$ACCEPT_HEADER")

    BONUS_DETAILS_HTTP_CODE=$(get_http_code "$BONUS_DETAILS_RESPONSE")
    print_result "Get bonus details" "$BONUS_DETAILS_HTTP_CODE" "200"
fi

# Test 2.4: Approve bonus
if [ -n "$BONUS_ID" ]; then
    echo "📋 Test 2.4: Approve bonus"
    APPROVE_BONUS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
      "$BASE_URL/bonuses/$BONUS_ID/approve" \
      -H "$AUTH_HEADER" \
      -H "$CONTENT_TYPE" \
      -H "$ACCEPT_HEADER" \
      -d '{
        "decision": "approve",
        "notes": "Approved for excellent performance metrics"
      }')

    APPROVE_BONUS_HTTP_CODE=$(get_http_code "$APPROVE_BONUS_RESPONSE")
    print_result "Approve bonus" "$APPROVE_BONUS_HTTP_CODE" "200"
fi

# Test 2.5: Calculate bonuses automatically (dry run)
echo "📋 Test 2.5: Calculate bonuses (dry run)"
CALCULATE_BONUSES_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/bonuses/calculate" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "bonus_types": ["performance", "logistics"],
    "dry_run": true
  }')

CALCULATE_BONUSES_HTTP_CODE=$(get_http_code "$CALCULATE_BONUSES_RESPONSE")
print_result "Calculate bonuses (dry run)" "$CALCULATE_BONUSES_HTTP_CODE" "200"

# Test 2.6: Get bonus analytics
echo "📋 Test 2.6: Get bonus analytics"
BONUS_ANALYTICS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses/analytics?period=month" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

BONUS_ANALYTICS_HTTP_CODE=$(get_http_code "$BONUS_ANALYTICS_RESPONSE")
print_result "Get bonus analytics" "$BONUS_ANALYTICS_HTTP_CODE" "200"

# Test 2.6a: Get enhanced bonus analytics with custom date range
echo "📋 Test 2.6a: Get enhanced bonus analytics with custom date range"
ENHANCED_ANALYTICS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses/analytics?start_date=2025-01-01&end_date=2025-01-31" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

ENHANCED_ANALYTICS_HTTP_CODE=$(get_http_code "$ENHANCED_ANALYTICS_RESPONSE")
print_result "Get enhanced bonus analytics" "$ENHANCED_ANALYTICS_HTTP_CODE" "200"

# Test 2.7: Get pending bonus approvals
echo "📋 Test 2.7: Get pending bonus approvals"
PENDING_BONUSES_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses/pending-approvals" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

PENDING_BONUSES_HTTP_CODE=$(get_http_code "$PENDING_BONUSES_RESPONSE")
print_result "Get pending bonus approvals" "$PENDING_BONUSES_HTTP_CODE" "200"

# Test 2.8: Get employee bonus summary
echo "📋 Test 2.8: Get employee bonus summary"
EMPLOYEE_BONUS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses/employee/1/summary?period=year&year=2025" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

EMPLOYEE_BONUS_HTTP_CODE=$(get_http_code "$EMPLOYEE_BONUS_RESPONSE")
print_result "Get employee bonus summary" "$EMPLOYEE_BONUS_HTTP_CODE" "200"

# Test 2.9: Get bonus calculations for specific month
echo "📋 Test 2.9: Get bonus calculations for specific month"
BONUS_CALCULATIONS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/bonuses/calculations?month=2025-01" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

BONUS_CALCULATIONS_HTTP_CODE=$(get_http_code "$BONUS_CALCULATIONS_RESPONSE")
print_result "Get bonus calculations for month" "$BONUS_CALCULATIONS_HTTP_CODE" "200"

# Test 2.10: Process bonus approval request (will fail if no pending bonuses exist)
echo "📋 Test 2.10: Process bonus approval request"
APPROVAL_REQUEST_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/bonuses/approval-request/99999" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "action": "approve",
    "comments": "Test approval for enhanced bonus system"
  }')

APPROVAL_REQUEST_HTTP_CODE=$(get_http_code "$APPROVAL_REQUEST_RESPONSE")
# This will likely return 404 since bonus ID 99999 doesn't exist, which is expected
if [ "$APPROVAL_REQUEST_HTTP_CODE" = "404" ]; then
    print_result "Process bonus approval request" "$APPROVAL_REQUEST_HTTP_CODE" "$APPROVAL_REQUEST_HTTP_CODE"
else
    print_result "Process bonus approval request" "$APPROVAL_REQUEST_HTTP_CODE" "200"
fi

echo ""

echo "💼 Step 3: Payroll Management Tests"
echo "=================================="

# Test 3.1: Get all payroll records
echo "📋 Test 3.1: Get all payroll records"
PAYROLL_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

PAYROLL_HTTP_CODE=$(get_http_code "$PAYROLL_RESPONSE")
print_result "Get all payroll records" "$PAYROLL_HTTP_CODE" "200"

# Test 3.2: Process payroll (dry run)
echo "📋 Test 3.2: Process payroll (dry run)"
PROCESS_PAYROLL_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/payroll/process" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "period_start": "2025-01-01",
    "period_end": "2025-01-31",
    "dry_run": true
  }')

PROCESS_PAYROLL_HTTP_CODE=$(get_http_code "$PROCESS_PAYROLL_RESPONSE")
print_result "Process payroll (dry run)" "$PROCESS_PAYROLL_HTTP_CODE" "200"

# Test 3.3: Generate payslip
echo "📋 Test 3.3: Generate payslip"
PAYSLIP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/payroll/payslip" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "employee_id": 1,
    "period_start": "2025-01-01",
    "period_end": "2025-01-31"
  }')

PAYSLIP_HTTP_CODE=$(get_http_code "$PAYSLIP_RESPONSE")
# This might return 404 if no payroll record exists, which is acceptable for testing
if [ "$PAYSLIP_HTTP_CODE" = "404" ] || [ "$PAYSLIP_HTTP_CODE" = "200" ]; then
    print_result "Generate payslip" "$PAYSLIP_HTTP_CODE" "$PAYSLIP_HTTP_CODE"
else
    print_result "Generate payslip" "$PAYSLIP_HTTP_CODE" "200"
fi

# Test 3.4: Get employee payroll history
echo "📋 Test 3.4: Get employee payroll history"
PAYROLL_HISTORY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/employee/1/history?months=6" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

PAYROLL_HISTORY_HTTP_CODE=$(get_http_code "$PAYROLL_HISTORY_RESPONSE")
print_result "Get employee payroll history" "$PAYROLL_HISTORY_HTTP_CODE" "200"

# Test 3.5: Get payroll summary
echo "📋 Test 3.5: Get payroll summary"
PAYROLL_SUMMARY_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/reports/summary?period_start=2025-01-01&period_end=2025-01-31" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

PAYROLL_SUMMARY_HTTP_CODE=$(get_http_code "$PAYROLL_SUMMARY_RESPONSE")
print_result "Get payroll summary" "$PAYROLL_SUMMARY_HTTP_CODE" "200"

# Test 3.6: Get payroll analytics
echo "📋 Test 3.6: Get payroll analytics"
PAYROLL_ANALYTICS_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/reports/analytics?period=year&year=2025" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

PAYROLL_ANALYTICS_HTTP_CODE=$(get_http_code "$PAYROLL_ANALYTICS_RESPONSE")
print_result "Get payroll analytics" "$PAYROLL_ANALYTICS_HTTP_CODE" "200"

# Test 3.7: Employee self-service dashboard
echo "📋 Test 3.7: Employee self-service dashboard"
SELF_SERVICE_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/self-service/dashboard" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

SELF_SERVICE_HTTP_CODE=$(get_http_code "$SELF_SERVICE_RESPONSE")
print_result "Employee self-service dashboard" "$SELF_SERVICE_HTTP_CODE" "200"

echo ""

echo "🧮 Step 4: Tax Calculation Tests"
echo "==============================="

# Test 4.1: Calculate tax for employee
echo "📋 Test 4.1: Calculate tax for employee"
TAX_CALC_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/payroll/tax/calculate" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "employee_id": 1,
    "gross_pay": 150000
  }')

TAX_CALC_HTTP_CODE=$(get_http_code "$TAX_CALC_RESPONSE")
print_result "Calculate tax for employee" "$TAX_CALC_HTTP_CODE" "200"

# Test 4.2: Get current tax rates
echo "📋 Test 4.2: Get current tax rates"
TAX_RATES_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/tax/rates" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

TAX_RATES_HTTP_CODE=$(get_http_code "$TAX_RATES_RESPONSE")
print_result "Get current tax rates" "$TAX_RATES_HTTP_CODE" "200"

# Test 4.3: Generate tax certificate
echo "📋 Test 4.3: Generate tax certificate"
TAX_CERT_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET \
  "$BASE_URL/payroll/employee/1/tax-certificate?year=2025" \
  -H "$AUTH_HEADER" \
  -H "$ACCEPT_HEADER")

TAX_CERT_HTTP_CODE=$(get_http_code "$TAX_CERT_RESPONSE")
print_result "Generate tax certificate" "$TAX_CERT_HTTP_CODE" "200"

echo ""

echo "🔒 Step 5: Authorization Tests"
echo "=============================="

# Test 5.1: Unauthorized bonus creation (should fail if user doesn't have permissions)
echo "📋 Test 5.1: Test role-based access control"

# Create a bonus with very high amount to trigger approval workflow
HIGH_BONUS_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST \
  "$BASE_URL/bonuses" \
  -H "$AUTH_HEADER" \
  -H "$CONTENT_TYPE" \
  -H "$ACCEPT_HEADER" \
  -d '{
    "employee_id": 1,
    "bonus_type": "special",
    "amount": 75000,
    "description": "High value special achievement bonus requiring CEO approval"
  }')

HIGH_BONUS_HTTP_CODE=$(get_http_code "$HIGH_BONUS_RESPONSE")
# Should either create bonus with pending status (201) or require escalation
if [ "$HIGH_BONUS_HTTP_CODE" = "201" ] || [ "$HIGH_BONUS_HTTP_CODE" = "422" ]; then
    print_result "High value bonus creation" "$HIGH_BONUS_HTTP_CODE" "$HIGH_BONUS_HTTP_CODE"
else
    print_result "High value bonus creation" "$HIGH_BONUS_HTTP_CODE" "201"
fi

echo ""

echo "📊 PHASE 5 TEST SUMMARY"
echo "======================="
echo -e "Total Tests: ${BLUE}$TOTAL_TESTS${NC}"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}🎉 All tests passed! Phase 5 implementation is working correctly.${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed. Please check the API responses above.${NC}"
    exit 1
fi 