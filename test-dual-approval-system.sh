#!/bin/bash

# Test script for Phase 4 Part 2: Dual Approval System & Salary Enforcement
# VitalVida Accountant Portal Backend

# set -e # Removed to allow script to continue on test failures

# Configuration
API_BASE_URL="http://localhost:8000/api"
AUTH_TOKEN="18|9kPhytFc2hmqrkhKYuxCWIVsdBuxJi7f5EWHVlqG9ec60120"  # Valid token
COLORS=1

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper function to print colored output
print_status() {
    local status=$1
    local message=$2
    
    case $status in
        "PASS")
            echo -e "${GREEN}✓ PASS${NC}: $message"
            ((PASSED_TESTS++))
            ;;
        "FAIL")
            echo -e "${RED}✗ FAIL${NC}: $message"
            ((FAILED_TESTS++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ INFO${NC}: $message"
            ;;
        "WARN")
            echo -e "${YELLOW}⚠ WARN${NC}: $message"
            ;;
    esac
}

# Helper function to log detailed responses
log() {
    if [[ -n "$DEBUG" ]]; then
        echo "DEBUG: $1" >&2
    fi
}

# Login function with token management
login() {
    # Check if AUTH_TOKEN is already set
    if [ -n "$AUTH_TOKEN" ]; then
        print_status "INFO" "Using pre-configured authentication token"
        log "Authentication token already set: ${AUTH_TOKEN:0:10}..."
        return 0
    fi

    print_status "INFO" "Attempting to login..."
    
    # Try to login with default credentials
    local login_response=$(curl -s -X POST "$API_BASE_URL/auth/login" \
        -H "Content-Type: application/json" \
        -d '{"email":"admin@vitalvida.com","password":"password"}')
    
    log "Login response: $login_response"
    
    if ! echo "$login_response" | jq -e . >/dev/null 2>&1; then
        print_status "FAIL" "Login failed - Invalid JSON response"
        return 1
    fi
    
    AUTH_TOKEN=$(echo "$login_response" | jq -r '.token // empty')
    
    if [ -z "$AUTH_TOKEN" ] || [ "$AUTH_TOKEN" = "null" ]; then
        print_status "FAIL" "Login failed - No token received"
        return 1
    fi
    
    print_status "PASS" "Login successful"
    log "Auth token obtained: ${AUTH_TOKEN:0:10}..."
    return 0
}

# Generic test function
run_test() {
    local test_name=$1
    local method=$2
    local endpoint=$3
    local data=${4:-""}
    local expected_status=${5:-"200"}
    
    ((TOTAL_TESTS++))
    
    local curl_cmd="curl -s -X $method \"$API_BASE_URL$endpoint\""
    
    if [ -n "$AUTH_TOKEN" ]; then
        curl_cmd="$curl_cmd -H \"Authorization: Bearer $AUTH_TOKEN\""
    fi
    
    curl_cmd="$curl_cmd -H \"Content-Type: application/json\" -H \"Accept: application/json\""
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -d '$data'"
    fi
    
    log "Executing: $curl_cmd"
    
    # Get response and status code separately
    local temp_file=$(mktemp)
    local response=$(eval "$curl_cmd -w '%{http_code}' -o '$temp_file'")
    local http_code="$response"
    local response_body=$(cat "$temp_file")
    rm -f "$temp_file"
    
    log "HTTP Code: $http_code"
    log "Response: $response_body"
    
    if [ "$http_code" = "$expected_status" ]; then
        print_status "PASS" "$test_name (HTTP $http_code)"
        
        # Additional JSON validation if response should be JSON
        if [[ "$http_code" =~ ^2 ]] && ! echo "$response_body" | jq -e . >/dev/null 2>&1; then
            print_status "WARN" "$test_name - Response is not valid JSON"
        fi
        
        return 0
    else
        print_status "FAIL" "$test_name (Expected: $expected_status, Got: $http_code)"
        if [[ "$response_body" =~ "error" ]]; then
            echo "  Error: $(echo "$response_body" | jq -r '.error // .message // "Unknown error"' 2>/dev/null || echo "Could not parse error")"
        fi
        return 1
    fi
}

# Test header function
print_test_header() {
    echo
    echo "=================================================="
    echo "  $1"
    echo "=================================================="
}

# Main test execution
main() {
    echo "🚀 Phase 4 Part 2 Testing: Dual Approval System & Salary Enforcement"
    echo "Testing VitalVida Accountant Portal Backend"
    echo "Base URL: $API_BASE_URL"
    echo "Timestamp: $(date)"
    echo

    # Authentication
    print_test_header "AUTHENTICATION"
    if ! login; then
        echo "❌ Authentication failed - cannot proceed with tests"
        exit 1
    fi

    # Test 1: Dual Approval System
    print_test_header "DUAL APPROVAL SYSTEM"
    
    # Test 1.1: Get Pending Escalations
    run_test "Get Pending Escalations" "GET" "/approvals/pending" "" "200"
    
    # Test 1.2: Get All Escalations
    run_test "Get All Escalations" "GET" "/approvals/escalations" "" "200"
    
    # Test 1.3: Get All Escalations with Filtering
    run_test "Get All Escalations (Filtered)" "GET" "/approvals/escalations?status=pending_approval&priority=high" "" "200"
    
    # Test 1.4: Get Approval Analytics
    run_test "Get Approval Analytics" "GET" "/approvals/analytics" "" "200"
    
    # Test 1.5: Get Approval Analytics (Monthly)
    run_test "Get Approval Analytics (Monthly)" "GET" "/approvals/analytics?period=month" "" "200"

    # Test 2: Salary Deduction Management
    print_test_header "SALARY DEDUCTION MANAGEMENT"
    
    # Test 2.1: Get All Deductions
    run_test "Get All Deductions" "GET" "/salary/deductions" "" "200"
    
    # Test 2.2: Get Deduction Statistics
    run_test "Get Deduction Statistics" "GET" "/salary/statistics" "" "200"
    
    # Test 2.3: Get User Deductions
    run_test "Get User Deductions" "GET" "/salary/user/1/deductions" "" "200"
    
    # Test 2.4: Get Upcoming Deductions
    run_test "Get Upcoming Deductions" "GET" "/salary/upcoming" "" "200"
    
    # Test 2.5: Get Deductions with Filtering
    run_test "Get Deductions (Filtered)" "GET" "/salary/deductions?status=pending&reason=unauthorized_payment" "" "200"
    
    # Test 2.6: Get Statistics with Period
    run_test "Get Statistics (Monthly)" "GET" "/salary/statistics?period=month" "" "200"

    # Test 3: Monitoring Dashboard
    print_test_header "MONITORING DASHBOARD"
    
    # Test 3.1: Get Dashboard Overview
    run_test "Get Dashboard Overview" "GET" "/monitoring/dashboard" "" "200"
    
    # Test 3.2: Get System Alerts
    run_test "Get System Alerts" "GET" "/monitoring/alerts" "" "200"
    
    # Test 3.3: Get System Health
    run_test "Get System Health" "GET" "/monitoring/system-health" "" "200"
    
    # Test 3.4: Get Compliance Report
    run_test "Get Compliance Report" "GET" "/monitoring/compliance" "" "200"
    
    # Test 3.5: Get Violations Trend
    run_test "Get Violations Trend" "GET" "/monitoring/violations-trend" "" "200"
    
    # Test 3.6: Get Approval Metrics
    run_test "Get Approval Metrics" "GET" "/monitoring/approval-metrics" "" "200"
    
    # Test 3.7: Get Dashboard with Period
    run_test "Get Dashboard (Weekly)" "GET" "/monitoring/dashboard?period=week" "" "200"
    
    # Test 3.8: Get Compliance Report with Period
    run_test "Get Compliance Report (Monthly)" "GET" "/monitoring/compliance?period=month" "" "200"

    # Test 4: Integration with Existing Threshold System
    print_test_header "INTEGRATION WITH THRESHOLD SYSTEM"
    
    # Test 4.1: Threshold Health Check
    run_test "Threshold Health Check" "GET" "/threshold/health" "" "200"
    
    # Test 4.2: Get Threshold Violations
    run_test "Get Threshold Violations" "GET" "/threshold/violations" "" "200"
    
    # Test 4.3: Get Threshold Escalations
    run_test "Get Threshold Escalations" "GET" "/threshold/escalations" "" "200"
    
    # Test 4.4: Get Threshold Statistics
    run_test "Get Threshold Statistics" "GET" "/threshold/statistics" "" "200"
    
    # Test 4.5: Get Urgent Items
    run_test "Get Urgent Items" "GET" "/threshold/urgent-items" "" "200"

    # Test 5: Permission and Role-Based Access
    print_test_header "PERMISSION & ROLE-BASED ACCESS"
    
    # Test 5.1: Access Admin-Only Route (should work for admin)
    run_test "Admin Route Access" "GET" "/salary/upcoming" "" "200"
    
    # Test 5.2: Access Monitoring Dashboard (should work for admin)
    run_test "Monitoring Dashboard Access" "GET" "/monitoring/dashboard" "" "200"
    
    # Test 5.3: Access Approval Analytics (should work for admin)
    run_test "Approval Analytics Access" "GET" "/approvals/analytics" "" "200"

    # Test 6: Error Handling and Validation
    print_test_header "ERROR HANDLING & VALIDATION"
    
    # Test 6.1: Invalid Escalation ID
    run_test "Invalid Escalation ID" "GET" "/approvals/escalation/99999" "" "404"
    
    # Test 6.2: Invalid Deduction ID
    run_test "Invalid Deduction ID" "GET" "/salary/deductions/99999" "" "404"
    
    # Test 6.3: Invalid User ID for Deductions
    run_test "Invalid User ID" "GET" "/salary/user/99999/deductions" "" "404"
    
    # Test 6.4: Invalid Period Parameter
    run_test "Invalid Period Parameter" "GET" "/monitoring/dashboard?period=invalid" "" "422"
    
    # Test 6.5: Invalid Status Filter
    run_test "Invalid Status Filter" "GET" "/salary/deductions?status=invalid_status" "" "422"

    # Test Results Summary
    print_test_header "TEST RESULTS SUMMARY"
    
    echo "📊 Test Execution Complete"
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: $(( PASSED_TESTS * 100 / TOTAL_TESTS ))%"
    echo

    if [ $FAILED_TESTS -eq 0 ]; then
        echo "🎉 All tests passed! Phase 4 Part 2 implementation is working correctly."
        exit 0
    else
        echo "❌ $FAILED_TESTS test(s) failed. Please review the implementation."
        exit 1
    fi
}

# Run main function
main "$@" 