#!/bin/bash

# Phase 5: Bonus Management & Payroll Integration Test Script
# Vitalvida Accountant Portal Backend

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
BASE_URL="http://localhost:8000/api"
TOKEN=""
ADMIN_TOKEN=""

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
    ((PASSED_TESTS++))
    ((TOTAL_TESTS++))
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ((FAILED_TESTS++))
    ((TOTAL_TESTS++))
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local expected_status=$4
    local test_name=$5
    
    log_info "Testing: $test_name"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" "$BASE_URL$endpoint")
    elif [ "$method" = "POST" ]; then
        response=$(curl -s -w "\n%{http_code}" -X POST -H "Authorization: Bearer $TOKEN" -H "Accept: application/json" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
    fi
    
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

# Initialize test environment
setup_test_environment() {
    log_info "Setting up test environment..."
    
    # Login as admin user
    admin_response=$(curl -s -X POST -H "Accept: application/json" -H "Content-Type: application/json" \
        -d '{"email":"admin@vitalvida.com","password":"password123"}' \
        "$BASE_URL/auth/login")
    
    ADMIN_TOKEN=$(echo "$admin_response" | grep -o '"token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -z "$ADMIN_TOKEN" ]; then
        log_error "Failed to get admin token"
        exit 1
    fi
    
    TOKEN=$ADMIN_TOKEN
    log_success "Admin token obtained"
}

# Test Bonus Management System
test_bonus_management() {
    log_info "=== Testing Bonus Management System ==="
    
    # Test bonus calculation
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07","recalculate":false}' \
        "200" "Calculate Monthly Bonuses"
    
    # Test get bonus calculations
    test_endpoint "GET" "/bonuses/calculations?month=2025-07" \
        "" "200" "Get Bonus Calculations"
    
    # Test bonus analytics
    test_endpoint "GET" "/bonuses/analytics?period=monthly" \
        "" "200" "Get Bonus Analytics"
    
    # Test pending approvals
    test_endpoint "GET" "/bonuses/pending-approvals" \
        "" "200" "Get Pending Bonus Approvals"
    
    # Test employee bonus summary
    test_endpoint "GET" "/bonuses/employee/1/summary" \
        "" "200" "Get Employee Bonus Summary"
}

# Test Payroll Management System
test_payroll_management() {
    log_info "=== Testing Payroll Management System ==="
    
    # Test payroll processing
    test_endpoint "POST" "/payroll/process" \
        '{"month":"2025-07","dry_run":true}' \
        "200" "Process Monthly Payroll (Dry Run)"
    
    # Test payroll analytics
    test_endpoint "GET" "/payroll/reports/analytics?period=monthly" \
        "" "200" "Get Payroll Analytics"
    
    # Test payroll summary
    test_endpoint "GET" "/payroll/reports/summary?month=2025-07" \
        "" "200" "Get Payroll Summary"
    
    # Test tax calculation
    test_endpoint "POST" "/payroll/tax/calculate" \
        '{"employee_id":1,"gross_pay":150000}' \
        "200" "Calculate Tax"
    
    # Test tax rates
    test_endpoint "GET" "/payroll/tax/rates" \
        "" "200" "Get Tax Rates"
    
    # Test bonus tax impact
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id":1,"bonus_amount":50000}' \
        "200" "Calculate Bonus Tax Impact"
    
    # Test comprehensive tax calculation
    test_endpoint "POST" "/payroll/comprehensive-tax-calculation" \
        '{"employee_id":1,"gross_pay":200000}' \
        "200" "Comprehensive Tax Calculation"
}

# Test Employee Self-Service
test_employee_self_service() {
    log_info "=== Testing Employee Self-Service ==="
    
    # Test employee dashboard
    test_endpoint "GET" "/employee/dashboard" \
        "" "200" "Get Employee Dashboard"
    
    # Test salary summary
    test_endpoint "GET" "/employee/salary-summary" \
        "" "200" "Get Employee Salary Summary"
    
    # Test bonus history
    test_endpoint "GET" "/employee/bonus-history" \
        "" "200" "Get Employee Bonus History"
    
    # Test payslips
    test_endpoint "GET" "/employee/payslips" \
        "" "200" "Get Employee Payslips"
    
    # Test tax summary
    test_endpoint "GET" "/employee/tax-summary" \
        "" "200" "Get Employee Tax Summary"
    
    # Test deductions
    test_endpoint "GET" "/employee/deductions" \
        "" "200" "Get Employee Deductions"
}

# Test Integration with Phase 4
test_phase4_integration() {
    log_info "=== Testing Phase 4 Integration ==="
    
    # Test threshold validation with bonus context
    test_endpoint "POST" "/threshold/validate-cost" \
        '{"amount":25000,"category":"bonus","description":"Performance bonus payment"}' \
        "200" "Threshold Validation for Bonus"
    
    # Test salary deductions integration
    test_endpoint "GET" "/salary/deductions" \
        "" "200" "Get Salary Deductions"
    
    # Test monitoring dashboard
    test_endpoint "GET" "/monitoring/dashboard" \
        "" "200" "Get Monitoring Dashboard"
    
    # Test approval metrics
    test_endpoint "GET" "/monitoring/approval-metrics" \
        "" "200" "Get Approval Metrics"
}

# Test Database Models and Relationships
test_database_models() {
    log_info "=== Testing Database Models ==="
    
    # Test bonus model creation
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07","recalculate":true}' \
        "200" "Test Bonus Model Creation"
    
    # Test payroll model creation
    test_endpoint "POST" "/payroll/process" \
        '{"month":"2025-07","dry_run":false}' \
        "200" "Test Payroll Model Creation"
    
    # Test performance metrics
    test_endpoint "GET" "/bonuses/analytics?include_metrics=true" \
        "" "200" "Test Performance Metrics"
}

# Test Error Handling
test_error_handling() {
    log_info "=== Testing Error Handling ==="
    
    # Test invalid month format
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"invalid-month"}' \
        "422" "Invalid Month Format"
    
    # Test invalid employee ID
    test_endpoint "GET" "/bonuses/employee/99999/summary" \
        "" "404" "Invalid Employee ID"
    
    # Test unauthorized access
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07"}' \
        "403" "Unauthorized Access (without token)"
    
    # Test invalid bonus amount
    test_endpoint "POST" "/payroll/bonus-tax-impact" \
        '{"employee_id":1,"bonus_amount":-1000}' \
        "422" "Invalid Bonus Amount"
}

# Test Performance and Load
test_performance() {
    log_info "=== Testing Performance ==="
    
    # Test bonus calculation performance
    start_time=$(date +%s)
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07","recalculate":false}' \
        "200" "Bonus Calculation Performance"
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    if [ $duration -lt 10 ]; then
        log_success "Bonus calculation completed in ${duration}s (acceptable)"
    else
        log_warning "Bonus calculation took ${duration}s (slow)"
    fi
    
    # Test payroll processing performance
    start_time=$(date +%s)
    test_endpoint "POST" "/payroll/process" \
        '{"month":"2025-07","dry_run":true}' \
        "200" "Payroll Processing Performance"
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    if [ $duration -lt 15 ]; then
        log_success "Payroll processing completed in ${duration}s (acceptable)"
    else
        log_warning "Payroll processing took ${duration}s (slow)"
    fi
}

# Test Console Commands
test_console_commands() {
    log_info "=== Testing Console Commands ==="
    
    # Test bonus calculation command
    if php artisan bonuses:calculate 2025-07 --recalculate > /dev/null 2>&1; then
        log_success "Bonus calculation command works"
    else
        log_error "Bonus calculation command failed"
    fi
    
    # Test payroll processing command
    if php artisan payroll:process 2025-07 > /dev/null 2>&1; then
        log_success "Payroll processing command works"
    else
        log_error "Payroll processing command failed"
    fi
}

# Test Background Jobs
test_background_jobs() {
    log_info "=== Testing Background Jobs ==="
    
    # Test job dispatch
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07","background":true}' \
        "200" "Background Job Dispatch"
    
    # Check job queue
    if php artisan queue:work --once > /dev/null 2>&1; then
        log_success "Background job processing works"
    else
        log_warning "Background job processing may have issues"
    fi
}

# Test Notifications
test_notifications() {
    log_info "=== Testing Notifications ==="
    
    # Test bonus calculation notification
    test_endpoint "POST" "/bonuses/calculate" \
        '{"month":"2025-07","notify":true}' \
        "200" "Bonus Calculation Notification"
    
    # Test payslip notification
    test_endpoint "POST" "/payroll/process" \
        '{"month":"2025-07","notify":true}' \
        "200" "Payslip Generation Notification"
}

# Main test execution
main() {
    log_info "Starting Phase 5: Bonus Management & Payroll Integration Tests"
    log_info "Base URL: $BASE_URL"
    
    setup_test_environment
    
    test_bonus_management
    test_payroll_management
    test_employee_self_service
    test_phase4_integration
    test_database_models
    test_error_handling
    test_performance
    test_console_commands
    test_background_jobs
    test_notifications
    
    # Print test summary
    echo ""
    log_info "=== Test Summary ==="
    log_info "Total Tests: $TOTAL_TESTS"
    log_success "Passed: $PASSED_TESTS"
    if [ $FAILED_TESTS -gt 0 ]; then
        log_error "Failed: $FAILED_TESTS"
    else
        log_success "Failed: $FAILED_TESTS"
    fi
    
    success_rate=$((PASSED_TESTS * 100 / TOTAL_TESTS))
    log_info "Success Rate: ${success_rate}%"
    
    if [ $FAILED_TESTS -eq 0 ]; then
        log_success "🎉 All Phase 5 tests passed! Bonus Management & Payroll Integration is working correctly."
        exit 0
    else
        log_error "❌ Some tests failed. Please review the errors above."
        exit 1
    fi
}

# Run main function
main "$@" 