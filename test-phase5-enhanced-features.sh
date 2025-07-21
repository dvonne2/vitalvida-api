#!/bin/bash

# =============================================================================
# PHASE 5 ENHANCED FEATURES TEST SCRIPT
# =============================================================================
# Tests enhanced tax calculations, employee self-service, and bonus management
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
# ENHANCED TAX CALCULATION TESTS
# =============================================================================

test_enhanced_tax_calculations() {
    log_info "=== TESTING ENHANCED TAX CALCULATIONS ==="
    
    # Test comprehensive tax calculation
    test_endpoint "POST" "/payroll/comprehensive-tax-calculation" \
        '{"gross_pay": 75000}' \
        "200" \
        "Comprehensive Tax Calculation"
    
    # Test bonus tax impact calculation
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id": 1, "bonus_amount": 15000}' \
        "200" \
        "Bonus Tax Impact Calculation"
    
    # Test tax rates endpoint
    test_endpoint "GET" "/payroll/tax/rates" \
        "" \
        "200" \
        "Get Current Tax Rates"
}

# =============================================================================
# EMPLOYEE SELF-SERVICE TESTS
# =============================================================================

test_employee_self_service() {
    log_info "=== TESTING EMPLOYEE SELF-SERVICE ==="
    
    # Test employee dashboard
    test_endpoint "GET" "/employee/dashboard" \
        "" \
        "200" \
        "Employee Dashboard"
    
    # Test salary summary
    test_endpoint "GET" "/employee/salary-summary" \
        "" \
        "200" \
        "Employee Salary Summary"
    
    # Test bonus history
    test_endpoint "GET" "/employee/bonus-history" \
        "" \
        "200" \
        "Employee Bonus History"
    
    # Test bonus history with filters
    test_endpoint "GET" "/employee/bonus-history?year=2024&status=pending" \
        "" \
        "200" \
        "Employee Bonus History with Filters"
    
    # Test payslips
    test_endpoint "GET" "/employee/payslips" \
        "" \
        "200" \
        "Employee Payslips"
    
    # Test payslips with filters
    test_endpoint "GET" "/employee/payslips?year=2024&month=12" \
        "" \
        "200" \
        "Employee Payslips with Filters"
    
    # Test payslip details (if exists)
    test_endpoint "GET" "/employee/payslips/1" \
        "" \
        "200" \
        "Employee Payslip Details"
    
    # Test tax summary
    test_endpoint "GET" "/employee/tax-summary" \
        "" \
        "200" \
        "Employee Tax Summary"
    
    # Test tax summary with year parameter
    test_endpoint "GET" "/employee/tax-summary?year=2024" \
        "" \
        "200" \
        "Employee Tax Summary for Specific Year"
    
    # Test deductions
    test_endpoint "GET" "/employee/deductions" \
        "" \
        "200" \
        "Employee Deductions"
    
    # Test deductions with filters
    test_endpoint "GET" "/employee/deductions?year=2024&status=active" \
        "" \
        "200" \
        "Employee Deductions with Filters"
}

# =============================================================================
# ENHANCED BONUS MANAGEMENT TESTS
# =============================================================================

test_enhanced_bonus_management() {
    log_info "=== TESTING ENHANCED BONUS MANAGEMENT ==="
    
    # Test bonus calculations with enhanced features
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month": "2024-12", "recalculate": true, "dry_run": true}' \
        "200" \
        "Enhanced Bonus Calculation with Recalculate and Dry Run"
    
    # Test bonus analytics with custom date range
    test_endpoint "GET" "/bonuses/analytics?start_date=2024-01-01&end_date=2024-12-31&group_by=department" \
        "" \
        "200" \
        "Enhanced Bonus Analytics with Custom Date Range"
    
    # Test bonus analytics with multi-dimensional analysis
    test_endpoint "GET" "/bonuses/analytics?analysis_type=multi_dimensional&dimensions=department,role,month" \
        "" \
        "200" \
        "Multi-Dimensional Bonus Analytics"
    
    # Test bonus analytics with performance correlation
    test_endpoint "GET" "/bonuses/analytics?analysis_type=performance_correlation&correlation_type=individual" \
        "" \
        "200" \
        "Performance Correlation Bonus Analytics"
    
    # Test bonus analytics with trend analysis
    test_endpoint "GET" "/bonuses/analytics?analysis_type=trend_analysis&trend_period=6" \
        "" \
        "200" \
        "Bonus Trend Analysis"
    
    # Test top performers analysis
    test_endpoint "GET" "/bonuses/analytics?analysis_type=top_performers&limit=10&sort_by=total_bonus" \
        "" \
        "200" \
        "Top Performers Bonus Analysis"
}

# =============================================================================
# ENHANCED PAYROLL INTEGRATION TESTS
# =============================================================================

test_enhanced_payroll_integration() {
    log_info "=== TESTING ENHANCED PAYROLL INTEGRATION ==="
    
    # Test payroll processing with enhanced features
    test_endpoint "POST" "/payroll/process" \
        '{"period_start": "2024-12-01", "period_end": "2024-12-31", "dry_run": true}' \
        "200" \
        "Enhanced Payroll Processing with Dry Run"
    
    # Test payroll analytics with enhanced features
    test_endpoint "GET" "/payroll/reports/analytics?period=year&year=2024&include_bonuses=true&include_tax_analysis=true" \
        "" \
        "200" \
        "Enhanced Payroll Analytics with Tax Analysis"
    
    # Test payroll summary with enhanced features
    test_endpoint "GET" "/payroll/reports/summary?period=month&year=2024&month=12&include_ytd=true" \
        "" \
        "200" \
        "Enhanced Payroll Summary with YTD"
}

# =============================================================================
# INTEGRATION TESTS
# =============================================================================

test_integration_features() {
    log_info "=== TESTING INTEGRATION FEATURES ==="
    
    # Test bonus approval workflow integration
    test_endpoint "POST" "/bonuses/approval-request/1" \
        '{"decision": "approved", "adjusted_amount": 12000, "comments": "Approved with adjustment"}' \
        "200" \
        "Bonus Approval Workflow Integration"
    
    # Test threshold enforcement integration
    test_endpoint "POST" "/threshold/validate-cost" \
        '{"type": "bonus", "amount": 25000, "category": "performance", "user_id": 1, "reference_type": "App\\Models\\BonusLog", "justification": "Performance bonus"}' \
        "200" \
        "Threshold Enforcement Integration for Bonuses"
    
    # Test salary deduction integration
    test_endpoint "GET" "/salary/deductions?user_id=1&status=active" \
        "" \
        "200" \
        "Salary Deduction Integration"
}

# =============================================================================
# ERROR HANDLING TESTS
# =============================================================================

test_error_handling() {
    log_info "=== TESTING ERROR HANDLING ==="
    
    # Test invalid bonus amount
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id": 1, "bonus_amount": -1000}' \
        "422" \
        "Invalid Bonus Amount Validation"
    
    # Test invalid employee ID
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id": 99999, "bonus_amount": 10000}' \
        "404" \
        "Invalid Employee ID"
    
    # Test invalid payslip ID
    test_endpoint "GET" "/employee/payslips/99999" \
        "" \
        "404" \
        "Invalid Payslip ID"
    
    # Test unauthorized access
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id": 2, "bonus_amount": 10000}' \
        "403" \
        "Unauthorized Access to Other Employee Data"
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
    test_endpoint "GET" "/bonuses/analytics?start_date=2024-01-01&end_date=2024-12-31" \
        "" \
        "200" \
        "Analytics Performance"
    end_time=$(date +%s.%N)
    
    execution_time=$(echo "$end_time - $start_time" | bc)
    log_info "Analytics calculation took: ${execution_time}s"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    echo "============================================================================="
    echo "PHASE 5 ENHANCED FEATURES TEST SCRIPT"
    echo "============================================================================="
    echo "Testing enhanced tax calculations, employee self-service, and bonus management"
    echo "============================================================================="
    echo ""
    
    # Authenticate
    authenticate
    
    # Run all test suites
    test_enhanced_tax_calculations
    test_employee_self_service
    test_enhanced_bonus_management
    test_enhanced_payroll_integration
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
        log_success "All tests passed! Phase 5 enhanced features are working correctly."
        exit 0
    else
        log_error "Some tests failed. Please check the implementation."
        exit 1
    fi
}

# Run main function
main "$@" 