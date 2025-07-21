#!/bin/bash

# =============================================================================
# ENHANCED BONUS MANAGEMENT TEST SCRIPT
# =============================================================================
# Tests enhanced bonus calculation, approval workflows, and analytics
# =============================================================================

set -e

# Configuration
BASE_URL="http://localhost:8000/api"
TOKEN=""
USER_ID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local test_name=$5
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    
    log_info "Testing: $test_name"
    log_info "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" "$BASE_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    fi
    
    # Extract response body and status code
    http_code=$(echo "$response" | tail -n1)
    response_body=$(echo "$response" | head -n -1)
    
    if [ "$http_code" = "$expected_status" ]; then
        log_success "$test_name - Status: $http_code"
        echo "Response: $response_body" | head -c 200
        echo "..."
    else
        log_error "$test_name - Expected: $expected_status, Got: $http_code"
        echo "Response: $response_body"
    fi
    
    echo ""
}

# Authentication
authenticate() {
    log_info "Authenticating..."
    
    response=$(curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
        -d '{"email": "admin@vitalvida.com", "password": "password123"}' \
        "$BASE_URL/auth/login")
    
    TOKEN=$(echo "$response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    USER_ID=$(echo "$response" | grep -o '"id":[0-9]*' | cut -d':' -f2)
    
    if [ -z "$TOKEN" ]; then
        log_error "Authentication failed"
        echo "Response: $response"
        exit 1
    fi
    
    log_success "Authentication successful - Token: ${TOKEN:0:20}..."
}

# =============================================================================
# ENHANCED BONUS CALCULATION TESTS
# =============================================================================

test_enhanced_bonus_calculation() {
    log_info "=== TESTING ENHANCED BONUS CALCULATION ==="
    
    # Test monthly bonus calculation with dry run
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": false, "dry_run": true}' \
        "200" \
        "Monthly Bonus Calculation with Dry Run"
    
    # Test monthly bonus calculation with recalculate
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": true, "dry_run": false}' \
        "200" \
        "Monthly Bonus Calculation with Recalculate"
    
    # Test monthly bonus calculation with department filter
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "department": "logistics", "dry_run": true}' \
        "200" \
        "Monthly Bonus Calculation with Department Filter"
    
    # Test invalid month format
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-13", "dry_run": true}' \
        "422" \
        "Invalid Month Format Validation"
    
    # Test duplicate calculation without recalculate flag
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": false, "dry_run": false}' \
        "422" \
        "Duplicate Calculation Prevention"
}

# =============================================================================
# BONUS CALCULATION RESULTS TESTS
# =============================================================================

test_bonus_calculation_results() {
    log_info "=== TESTING BONUS CALCULATION RESULTS ==="
    
    # Test get bonus calculations for specific month
    test_endpoint "GET" "/bonuses/calculations?month=2024-12" \
        "" \
        "200" \
        "Get Bonus Calculations for Specific Month"
    
    # Test get bonus calculations with user filter
    test_endpoint "GET" "/bonuses/calculations?month=2024-12&user_id=1" \
        "" \
        "200" \
        "Get Bonus Calculations with User Filter"
    
    # Test get bonus calculations with status filter
    test_endpoint "GET" "/bonuses/calculations?month=2024-12&status=approved" \
        "" \
        "200" \
        "Get Bonus Calculations with Status Filter"
    
    # Test get bonus calculations with invalid month
    test_endpoint "GET" "/bonuses/calculations?month=2024-13" \
        "" \
        "422" \
        "Invalid Month Format in Calculations Query"
}

# =============================================================================
# ENHANCED BONUS ANALYTICS TESTS
# =============================================================================

test_enhanced_bonus_analytics() {
    log_info "=== TESTING ENHANCED BONUS ANALYTICS ==="
    
    # Test basic analytics
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31" \
        "" \
        "200" \
        "Basic Bonus Analytics"
    
    # Test multi-dimensional analytics
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=multi_dimensional&dimensions=department,role" \
        "" \
        "200" \
        "Multi-Dimensional Bonus Analytics"
    
    # Test performance correlation analytics
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=performance_correlation&correlation_type=individual" \
        "" \
        "200" \
        "Performance Correlation Bonus Analytics"
    
    # Test trend analysis
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=trend_analysis&trend_period=6" \
        "" \
        "200" \
        "Bonus Trend Analysis"
    
    # Test top performers analysis
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=top_performers&limit=10&sort_by=total_bonus" \
        "" \
        "200" \
        "Top Performers Bonus Analysis"
    
    # Test analytics with invalid date range
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-12-31&end_date=2024-01-01" \
        "" \
        "422" \
        "Invalid Date Range in Analytics"
}

# =============================================================================
# ENHANCED APPROVAL WORKFLOW TESTS
# =============================================================================

test_enhanced_approval_workflow() {
    log_info "=== TESTING ENHANCED APPROVAL WORKFLOW ==="
    
    # Test get pending approvals
    test_endpoint "GET" "/bonuses/pending-approvals" \
        "" \
        "200" \
        "Get Pending Bonus Approvals"
    
    # Test approve bonus request
    test_endpoint "POST" "/bonuses/approval-request/1" \
        '{"action": "approve", "comments": "Approved based on performance", "adjusted_amount": 12000}' \
        "200" \
        "Approve Bonus Request with Adjustment"
    
    # Test reject bonus request
    test_endpoint "POST" "/bonuses/approval-request/2" \
        '{"action": "reject", "comments": "Rejected due to insufficient justification"}' \
        "200" \
        "Reject Bonus Request"
    
    # Test approve without adjustment
    test_endpoint "POST" "/bonuses/approval-request/3" \
        '{"action": "approve", "comments": "Approved as requested"}' \
        "200" \
        "Approve Bonus Request without Adjustment"
    
    # Test invalid action
    test_endpoint "POST" "/bonuses/approval-request/1" \
        '{"action": "invalid", "comments": "Test"}' \
        "422" \
        "Invalid Action Validation"
    
    # Test invalid approval request ID
    test_endpoint "POST" "/bonuses/approval-request/99999" \
        '{"action": "approve", "comments": "Test"}' \
        "404" \
        "Invalid Approval Request ID"
}

# =============================================================================
# EMPLOYEE BONUS SUMMARY TESTS
# =============================================================================

test_employee_bonus_summary() {
    log_info "=== TESTING EMPLOYEE BONUS SUMMARY ==="
    
    # Test get employee bonus summary
    test_endpoint "GET" "/bonuses/employee/1/summary" \
        "" \
        "200" \
        "Get Employee Bonus Summary"
    
    # Test get employee bonus summary for non-existent user
    test_endpoint "GET" "/bonuses/employee/99999/summary" \
        "" \
        "404" \
        "Employee Bonus Summary for Non-existent User"
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test_integration_features() {
    log_info "=== TESTING INTEGRATION FEATURES ==="
    
    # Test bonus calculation with threshold enforcement integration
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": true, "dry_run": true}' \
        "200" \
        "Bonus Calculation with Threshold Enforcement"
    
    # Test analytics with enhanced features
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=multi_dimensional&dimensions=department,role,month" \
        "" \
        "200" \
        "Enhanced Analytics with Multi-Dimensional Analysis"
}

# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

test_error_handling() {
    log_info "=== TESTING ERROR HANDLING ==="
    
    # Test unauthorized access to bonus calculations
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "dry_run": true}' \
        "403" \
        "Unauthorized Access to Bonus Calculations"
    
    # Test invalid month format
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "invalid", "dry_run": true}' \
        "422" \
        "Invalid Month Format"
    
    # Test missing required fields
    test_endpoint "POST" "/bonuses/calculate" \
        '{"dry_run": true}' \
        "422" \
        "Missing Required Fields"
    
    # Test invalid date range in analytics
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=invalid&end_date=2024-12-31" \
        "" \
        "422" \
        "Invalid Date Format in Analytics"
}

# =============================================================================
# PERFORMANCE TESTS
# =============================================================================

test_performance() {
    log_info "=== TESTING PERFORMANCE ==="
    
    # Test bulk bonus calculation performance
    start_time=$(date +%s.%N)
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": false, "dry_run": true}' \
        "200" \
        "Bulk Bonus Calculation Performance"
    end_time=$(date +%s.%N)
    
    execution_time=$(echo "$end_time - $start_time" | bc)
    log_info "Bulk bonus calculation took: ${execution_time}s"
    
    # Test analytics performance
    start_time=$(date +%s.%N)
    test_endpoint "GET" "/bonuses/analytics?period=month&start_date=2024-01-01&end_date=2024-12-31&analysis_type=multi_dimensional" \
        "" \
        "200" \
        "Enhanced Analytics Performance"
    end_time=$(date +%s.%N)
    
    execution_time=$(echo "$end_time - $start_time" | bc)
    log_info "Enhanced analytics calculation took: ${execution_time}s"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "============================================================================="
    echo "ENHANCED BONUS MANAGEMENT TEST SCRIPT"
    echo "============================================================================="
    echo "Testing enhanced bonus calculation, approval workflows, and analytics"
    echo "============================================================================="
    echo ""
    
    # Authenticate
    authenticate
    
    # Run all test suites
    test_enhanced_bonus_calculation
    test_bonus_calculation_results
    test_enhanced_bonus_analytics
    test_enhanced_approval_workflow
    test_employee_bonus_summary
    test_integration_features
    test_error_handling
    test_performance
    
    # Print summary
    echo "============================================================================="
    echo "TEST SUMMARY"
    echo "============================================================================="
    echo "Total Tests: $TOTAL_TESTS"
    echo "Passed: $PASSED_TESTS"
    echo "Failed: $FAILED_TESTS"
    echo "Success Rate: $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
    echo "============================================================================="
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "All tests passed! Enhanced bonus management features are working correctly."
        exit 0
    else
        log_error "Some tests failed. Please check the implementation."
        exit 1
    fi
}

# Run main function
main "$@" 