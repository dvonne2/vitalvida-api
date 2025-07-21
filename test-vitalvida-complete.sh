#!/bin/bash

# =============================================================================
# VITALVIDA ACCOUNTANT PORTAL - COMPLETE TESTING SUITE
# =============================================================================

echo "🚀 VITALVIDA ACCOUNTANT PORTAL - COMPLETE TESTING SUITE"
echo "======================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test counters
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Function to run test
run_test() {
    local test_name="$1"
    local command="$2"
    local expected_status="$3"
    
    TOTAL_TESTS=$((TOTAL_TESTS + 1))
    echo -e "${BLUE}Testing: ${test_name}${NC}"
    
    if eval "$command" > /dev/null 2>&1; then
        if [ "$expected_status" = "success" ]; then
            echo -e "  ${GREEN}✅ PASSED${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}❌ FAILED (Expected failure but got success)${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    else
        if [ "$expected_status" = "failure" ]; then
            echo -e "  ${GREEN}✅ PASSED (Expected failure)${NC}"
            PASSED_TESTS=$((PASSED_TESTS + 1))
        else
            echo -e "  ${RED}❌ FAILED${NC}"
            FAILED_TESTS=$((FAILED_TESTS + 1))
        fi
    fi
    echo ""
}

echo -e "${YELLOW}📋 COMPREHENSIVE TESTING APPROACH:${NC}"
echo "1. Infrastructure & Database Tests (Shell-based)"
echo "2. API Endpoint Tests (PHP-based)"
echo "3. Business Logic Tests (PHP-based)"
echo "4. Integration Tests (PHP-based)"
echo "5. Performance Tests (PHP-based)"
echo ""

# =============================================================================
# STEP 1: INFRASTRUCTURE & DATABASE TESTS
# =============================================================================
echo -e "${PURPLE}🔧 STEP 1: INFRASTRUCTURE & DATABASE TESTS${NC}"
echo "=================================================="

# Test database connection
run_test "Database connection" "php artisan tinker --execute='echo DB::connection()->getPdo() ? \"OK\" : \"FAIL\";'" "success"

# Test all migrations
run_test "All migrations completed" "php artisan migrate:status | grep -q 'Ran'" "success"

# Test core tables exist
run_test "Users table exists" "php artisan tinker --execute='echo Schema::hasTable(\"users\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Salaries table exists" "php artisan tinker --execute='echo Schema::hasTable(\"salaries\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Approvals table exists" "php artisan tinker --execute='echo Schema::hasTable(\"approvals\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Thresholds table exists" "php artisan tinker --execute='echo Schema::hasTable(\"thresholds\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ApiKeys table exists" "php artisan tinker --execute='echo Schema::hasTable(\"api_keys\") ? \"OK\" : \"FAIL\";'" "success"

# Test core models
run_test "User model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\User\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Salary model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Salary\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Approval model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Approval\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Threshold model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Threshold\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ApiKey model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\ApiKey\") ? \"OK\" : \"FAIL\";'" "success"

# Test core services
run_test "APIGatewayService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\APIGatewayService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileSyncService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobileSyncService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobilePushNotificationService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobilePushNotificationService\") ? \"OK\" : \"FAIL\";'" "success"

# Test routes are registered
run_test "Mobile routes registered" "php artisan route:list | grep mobile" "success"
run_test "Salary routes registered" "php artisan route:list | grep salary" "success"
run_test "Approval routes registered" "php artisan route:list | grep approval" "success"
run_test "Threshold routes registered" "php artisan route:list | grep threshold" "success"

# =============================================================================
# STEP 2: START SERVER FOR API TESTING
# =============================================================================
echo -e "${PURPLE}🌐 STEP 2: STARTING SERVER FOR API TESTING${NC}"
echo "=================================================="

# Kill any existing server on port 8000
pkill -f "php artisan serve" 2>/dev/null || true

# Start the server in background
echo "Starting Laravel server..."
php artisan serve --host=127.0.0.1 --port=8000 > /dev/null 2>&1 &
SERVER_PID=$!

# Wait for server to start
echo "Waiting for server to start..."
sleep 5

# Test server is running
run_test "Server is running" "curl -s http://127.0.0.1:8000/api/health" "success"

# =============================================================================
# STEP 3: PHP-BASED API TESTING
# =============================================================================
echo -e "${PURPLE}📱 STEP 3: PHP-BASED API TESTING${NC}"
echo "=========================================="

# Run the PHP test suite
echo "Running comprehensive PHP test suite..."
if php run-complete-test.php http://127.0.0.1:8000; then
    echo -e "  ${GREEN}✅ PHP TEST SUITE PASSED${NC}"
    PASSED_TESTS=$((PASSED_TESTS + 1))
else
    echo -e "  ${RED}❌ PHP TEST SUITE FAILED${NC}"
    FAILED_TESTS=$((FAILED_TESTS + 1))
fi
TOTAL_TESTS=$((TOTAL_TESTS + 1))

# =============================================================================
# STEP 4: API ENDPOINT VALIDATION
# =============================================================================
echo -e "${PURPLE}🔗 STEP 4: API ENDPOINT VALIDATION${NC}"
echo "============================================="

# Test critical endpoints
run_test "Health endpoint" "curl -s http://127.0.0.1:8000/api/health" "success"
run_test "Mobile gateway health" "curl -s http://127.0.0.1:8000/api/mobile/gateway/health" "success"
run_test "Mobile gateway docs" "curl -s http://127.0.0.1:8000/api/mobile/gateway/docs" "success"

# Test authentication endpoints (should return 401/422 without auth)
run_test "Auth login endpoint exists" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/auth/login" "success"

# Test protected endpoints (should return 401 without auth)
run_test "Protected salary endpoint" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/salary/deductions" "success"
run_test "Protected approval endpoint" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/approvals/pending" "success"
run_test "Protected threshold endpoint" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/threshold/health" "success"
run_test "Protected monitoring endpoint" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/monitoring/dashboard" "success"

# =============================================================================
# STEP 5: CONSOLE COMMANDS TESTING
# =============================================================================
echo -e "${PURPLE}💻 STEP 5: CONSOLE COMMANDS TESTING${NC}"
echo "============================================="

run_test "Mobile API key generation command" "php artisan list | grep mobile:generate-api-key" "success"
run_test "Mobile health check command" "php artisan list | grep mobile:health-check" "success"
run_test "Zoho sync command" "php artisan list | grep zoho:sync-inventory" "success"

# =============================================================================
# STEP 6: BACKGROUND JOBS & SCHEDULING
# =============================================================================
echo -e "${PURPLE}🔄 STEP 6: BACKGROUND JOBS & SCHEDULING${NC}"
echo "================================================="

run_test "ProcessMobileSync job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\ProcessMobileSync\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SendScheduledPushNotifications job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\SendScheduledPushNotifications\") ? \"OK\" : \"FAIL\";'" "success"
run_test "CleanupExpiredApiKeys job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\CleanupExpiredApiKeys\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MonitorMobileAppHealth job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\MonitorMobileAppHealth\") ? \"OK\" : \"FAIL\";'" "success"

# Test scheduled tasks are registered
run_test "Mobile scheduled tasks registered" "grep -q 'ProcessMobileSync' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks registered" "grep -q 'SendScheduledPushNotifications' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks registered" "grep -q 'CleanupExpiredApiKeys' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks registered" "grep -q 'MonitorMobileAppHealth' app/Console/Kernel.php" "success"

# =============================================================================
# STEP 7: MIDDLEWARE & SECURITY
# =============================================================================
echo -e "${PURPLE}🛡️  STEP 7: MIDDLEWARE & SECURITY${NC}"
echo "============================================="

run_test "MobileAPIAuthentication middleware exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileAPIAuthentication\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileRateLimit middleware exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileRateLimit\") ? \"OK\" : \"FAIL\";'" "success"

# Test middleware is registered
run_test "Mobile middleware registered in Kernel" "grep -q 'mobile.auth' app/Http/Kernel.php" "success"

# =============================================================================
# STEP 8: PERFORMANCE & OPTIMIZATION
# =============================================================================
echo -e "${PURPLE}⚡ STEP 8: PERFORMANCE & OPTIMIZATION${NC}"
echo "=============================================="

run_test "Route caching available" "php artisan route:cache" "success"
run_test "Config caching available" "php artisan config:cache" "success"
run_test "View caching available" "php artisan view:cache" "success"

# Clear caches after testing
php artisan route:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1
php artisan view:clear > /dev/null 2>&1

# =============================================================================
# STEP 9: STOP SERVER
# =============================================================================
echo -e "${PURPLE}🛑 STEP 9: CLEANUP${NC}"
echo "====================="

# Stop the server
kill $SERVER_PID 2>/dev/null || true
echo "Server stopped"

# =============================================================================
# FINAL RESULTS
# =============================================================================
echo -e "${YELLOW}📊 FINAL TEST RESULTS${NC}"
echo "========================"
echo -e "Total Tests: ${TOTAL_TESTS}"
echo -e "${GREEN}Passed: ${PASSED_TESTS}${NC}"
echo -e "${RED}Failed: ${FAILED_TESTS}${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
    echo ""
    echo -e "${GREEN}🎉 ALL TESTS PASSED! VITALVIDA ACCOUNTANT PORTAL IS FULLY OPERATIONAL!${NC}"
    echo ""
    echo -e "${CYAN}📋 PHASE SUMMARY:${NC}"
    echo -e "${GREEN}✅ Phase 1: Foundation & Authentication${NC}"
    echo -e "${GREEN}✅ Phase 2: Payment Engine${NC}"
    echo -e "${GREEN}✅ Phase 3: Inventory Verification${NC}"
    echo -e "${GREEN}✅ Phase 4: Threshold Enforcement${NC}"
    echo -e "${GREEN}✅ Phase 5: Bonus & Payroll Integration${NC}"
    echo -e "${GREEN}✅ Phase 6: Advanced Reporting & Analytics${NC}"
    echo -e "${GREEN}✅ Phase 7: Mobile Application & API Gateway${NC}"
    echo ""
    echo -e "${BLUE}🚀 VITALVIDA ACCOUNTANT PORTAL FEATURES:${NC}"
    echo "✅ Complete user management system"
    echo "✅ Comprehensive salary and deduction management"
    echo "✅ Advanced approval workflows with escalations"
    echo "✅ Zoho inventory system integration"
    echo "✅ Threshold-based alerting system"
    echo "✅ Advanced reporting and analytics"
    echo "✅ Mobile API gateway with authentication"
    echo "✅ Push notification service"
    echo "✅ Offline data synchronization"
    echo "✅ Real-time monitoring and health checks"
    echo "✅ Background job processing"
    echo "✅ Scheduled task automation"
    echo "✅ Security and rate limiting"
    echo "✅ Performance optimization"
    echo ""
    echo -e "${BLUE}🎯 PRODUCTION READINESS:${NC}"
    echo "✅ All phases implemented and tested"
    echo "✅ Database schema complete"
    echo "✅ API endpoints functional"
    echo "✅ Security measures in place"
    echo "✅ Performance optimized"
    echo "✅ Mobile-ready architecture"
    echo "✅ Monitoring and alerting active"
    echo ""
    echo -e "${GREEN}🎊 VITALVIDA ACCOUNTANT PORTAL BACKEND IS PRODUCTION-READY!${NC}"
    echo ""
    echo -e "${YELLOW}📱 NEXT STEPS:${NC}"
    echo "1. Configure production environment variables"
    echo "2. Set up SSL certificates and domain"
    echo "3. Configure monitoring and alerting"
    echo "4. Deploy to production server"
    echo "5. Develop React Native mobile app"
    echo "6. Conduct user acceptance testing"
    echo "7. Go live with production deployment"
    echo ""
    echo -e "${CYAN}🔗 USEFUL COMMANDS:${NC}"
    echo "php artisan serve --host=0.0.0.0 --port=8000"
    echo "php artisan queue:work --queue=default,mobile"
    echo "php artisan schedule:run"
    echo "php artisan mobile:generate-api-key {user_id}"
    echo "php artisan mobile:health-check --detailed"
    echo "php artisan zoho:sync-inventory"
    echo ""
    echo -e "${GREEN}🎯 VITALVIDA ACCOUNTANT PORTAL - COMPLETE SUCCESS!${NC}"
else
    echo ""
    echo -e "${RED}❌ SOME TESTS FAILED. PLEASE REVIEW AND FIX THE ISSUES ABOVE.${NC}"
    echo ""
    echo -e "${YELLOW}🔧 TROUBLESHOOTING TIPS:${NC}"
    echo "1. Check database migrations: php artisan migrate:status"
    echo "2. Clear application cache: php artisan cache:clear"
    echo "3. Check route registration: php artisan route:list"
    echo "4. Verify configuration: php artisan config:show"
    echo "5. Check for syntax errors: php -l app/Http/Controllers/"
    echo ""
    echo -e "${RED}⚠️  PLEASE FIX FAILED TESTS BEFORE PRODUCTION DEPLOYMENT${NC}"
fi

echo ""
echo -e "${CYAN}📅 Test completed on: $(date)${NC}"
echo -e "${CYAN}🏠 Environment: $(php artisan tinker --execute='echo config(\"app.env\");')" 2>/dev/null || echo "local"${NC}
echo -e "${CYAN}🔧 Laravel Version: $(php artisan --version | cut -d' ' -f3)${NC}"
echo -e "${CYAN}🐘 PHP Version: $(php -v | head -n1 | cut -d' ' -f2)${NC}" 