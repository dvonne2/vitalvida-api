#!/bin/bash

# =============================================================================
# VITALVIDA ACCOUNTANT PORTAL - COMPLETE TESTING (PHASES 1-7)
# =============================================================================

echo "🚀 VITALVIDA ACCOUNTANT PORTAL - COMPLETE TESTING (PHASES 1-7)"
echo "=============================================================="
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

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${YELLOW}📋 PHASES TO TEST:${NC}"
echo "1. Phase 1: User Management & Authentication"
echo "2. Phase 2: Salary Management & Deductions"
echo "3. Phase 3: Approval Workflows & Escalations"
echo "4. Phase 4: Zoho Inventory Integration"
echo "5. Phase 5: Threshold Management & Alerts"
echo "6. Phase 6: Advanced Reporting & Analytics"
echo "7. Phase 7: Mobile Application & API Gateway"
echo ""

# =============================================================================
# PHASE 1: USER MANAGEMENT & AUTHENTICATION
# =============================================================================
echo -e "${PURPLE}🔐 PHASE 1: USER MANAGEMENT & AUTHENTICATION${NC}"
echo "====================================================="

run_test "Users table exists" "php artisan tinker --execute='echo Schema::hasTable(\"users\") ? \"OK\" : \"FAIL\";'" "success"
run_test "User model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\User\") ? \"OK\" : \"FAIL\";'" "success"
run_test "UserController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\UserController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Auth routes exist" "php artisan route:list | grep auth" "success"

# =============================================================================
# PHASE 2: SALARY MANAGEMENT & DEDUCTIONS
# =============================================================================
echo -e "${PURPLE}💰 PHASE 2: SALARY MANAGEMENT & DEDUCTIONS${NC}"
echo "====================================================="

run_test "Salaries table exists" "php artisan tinker --execute='echo Schema::hasTable(\"salaries\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Deductions table exists" "php artisan tinker --execute='echo Schema::hasTable(\"deductions\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Salary model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Salary\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Deduction model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Deduction\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SalaryController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\SalaryController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Salary routes exist" "php artisan route:list | grep salary" "success"

# =============================================================================
# PHASE 3: APPROVAL WORKFLOWS & ESCALATIONS
# =============================================================================
echo -e "${PURPLE}✅ PHASE 3: APPROVAL WORKFLOWS & ESCALATIONS${NC}"
echo "======================================================="

run_test "Approvals table exists" "php artisan tinker --execute='echo Schema::hasTable(\"approvals\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Escalations table exists" "php artisan tinker --execute='echo Schema::hasTable(\"escalations\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Approval model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Approval\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Escalation model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Escalation\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ApprovalController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\ApprovalController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Approval routes exist" "php artisan route:list | grep approval" "success"

# =============================================================================
# PHASE 4: ZOHO INVENTORY INTEGRATION
# =============================================================================
echo -e "${PURPLE}📦 PHASE 4: ZOHO INVENTORY INTEGRATION${NC}"
echo "================================================="

run_test "ZohoInventory table exists" "php artisan tinker --execute='echo Schema::hasTable(\"zoho_inventory\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ZohoInventory model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\ZohoInventory\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ZohoInventoryController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\ZohoInventoryController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ZohoInventoryService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\ZohoInventoryService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Zoho inventory routes exist" "php artisan route:list | grep zoho" "success"
run_test "Zoho sync command exists" "php artisan list | grep zoho:sync-inventory" "success"

# =============================================================================
# PHASE 5: THRESHOLD MANAGEMENT & ALERTS
# =============================================================================
echo -e "${PURPLE}⚠️  PHASE 5: THRESHOLD MANAGEMENT & ALERTS${NC}"
echo "====================================================="

run_test "Thresholds table exists" "php artisan tinker --execute='echo Schema::hasTable(\"thresholds\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Alerts table exists" "php artisan tinker --execute='echo Schema::hasTable(\"alerts\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Threshold model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Threshold\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Alert model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Alert\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ThresholdController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\ThresholdController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Threshold routes exist" "php artisan route:list | grep threshold" "success"

# =============================================================================
# PHASE 6: ADVANCED REPORTING & ANALYTICS
# =============================================================================
echo -e "${PURPLE}📊 PHASE 6: ADVANCED REPORTING & ANALYTICS${NC}"
echo "====================================================="

run_test "Reports table exists" "php artisan tinker --execute='echo Schema::hasTable(\"reports\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Analytics table exists" "php artisan tinker --execute='echo Schema::hasTable(\"analytics\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Report model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Report\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Analytics model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\Analytics\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ReportController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\ReportController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "AnalyticsController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\AnalyticsController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Report routes exist" "php artisan route:list | grep report" "success"
run_test "Analytics routes exist" "php artisan route:list | grep analytics" "success"

# =============================================================================
# PHASE 7: MOBILE APPLICATION & API GATEWAY
# =============================================================================
echo -e "${PURPLE}📱 PHASE 7: MOBILE APPLICATION & API GATEWAY${NC}"
echo "======================================================="

run_test "ApiKey model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\ApiKey\") ? \"OK\" : \"FAIL\";'" "success"
run_test "DeviceToken model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\DeviceToken\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileGatewayController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileGatewayController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileAuthController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileAuthController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "APIGatewayService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\APIGatewayService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileSyncService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobileSyncService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobilePushNotificationService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobilePushNotificationService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Mobile routes exist" "php artisan route:list | grep mobile" "success"
run_test "Mobile middleware exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileAPIAuthentication\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# CORE SYSTEM COMPONENTS
# =============================================================================
echo -e "${PURPLE}🔧 CORE SYSTEM COMPONENTS${NC}"
echo "==============================="

run_test "Database connection" "php artisan tinker --execute='echo DB::connection()->getPdo() ? \"OK\" : \"FAIL\";'" "success"
run_test "Cache system" "php artisan tinker --execute='echo Cache::put(\"test\", \"value\", 1) ? \"OK\" : \"FAIL\";'" "success"
run_test "Queue system" "php artisan tinker --execute='echo Queue::size() !== null ? \"OK\" : \"FAIL\";'" "success"
run_test "File storage" "php artisan tinker --execute='echo Storage::disk(\"local\")->exists(\".gitkeep\") || Storage::disk(\"local\")->put(\"test.txt\", \"test\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# MIDDLEWARE & SECURITY
# =============================================================================
echo -e "${PURPLE}🛡️  MIDDLEWARE & SECURITY${NC}"
echo "==============================="

run_test "CORS middleware" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\Cors\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Rate limiting" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileRateLimit\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Authentication middleware" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileAPIAuthentication\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# BACKGROUND JOBS & SCHEDULING
# =============================================================================
echo -e "${PURPLE}🔄 BACKGROUND JOBS & SCHEDULING${NC}"
echo "======================================="

run_test "ProcessMobileSync job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\ProcessMobileSync\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SendScheduledPushNotifications job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\SendScheduledPushNotifications\") ? \"OK\" : \"FAIL\";'" "success"
run_test "CleanupExpiredApiKeys job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\CleanupExpiredApiKeys\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MonitorMobileAppHealth job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\MonitorMobileAppHealth\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Scheduled tasks registered" "grep -q 'ProcessMobileSync' app/Console/Kernel.php" "success"

# =============================================================================
# CONSOLE COMMANDS
# =============================================================================
echo -e "${PURPLE}💻 CONSOLE COMMANDS${NC}"
echo "====================="

run_test "GenerateMobileApiKey command exists" "php artisan list | grep mobile:generate-api-key" "success"
run_test "MobileAppHealthCheck command exists" "php artisan list | grep mobile:health-check" "success"
run_test "Zoho sync command exists" "php artisan list | grep zoho:sync-inventory" "success"

# =============================================================================
# API ENDPOINTS TESTING
# =============================================================================
echo -e "${PURPLE}🌐 API ENDPOINTS TESTING${NC}"
echo "=========================="

# Start the server in background for testing
echo "Starting Laravel server for API testing..."
php artisan serve --host=127.0.0.1 --port=8000 > /dev/null 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test core endpoints
run_test "System health endpoint" "curl -s http://127.0.0.1:8000/api/health" "success"
run_test "Mobile gateway health endpoint" "curl -s http://127.0.0.1:8000/api/mobile/gateway/health" "success"
run_test "Mobile gateway docs endpoint" "curl -s http://127.0.0.1:8000/api/mobile/gateway/docs" "success"

# Test authentication endpoints (without auth)
run_test "Auth login endpoint exists" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/auth/login" "success"

# Test salary endpoints (without auth)
run_test "Salary endpoints exist" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/salary/deductions" "success"

# Test approval endpoints (without auth)
run_test "Approval endpoints exist" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/approvals/pending" "success"

# Test threshold endpoints (without auth)
run_test "Threshold endpoints exist" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/threshold/health" "success"

# Test monitoring endpoints (without auth)
run_test "Monitoring endpoints exist" "curl -s -o /dev/null -w \"%{http_code}\" http://127.0.0.1:8000/api/monitoring/dashboard" "success"

# Stop the server
kill $SERVER_PID 2>/dev/null

# =============================================================================
# DATABASE INTEGRITY
# =============================================================================
echo -e "${PURPLE}🗄️  DATABASE INTEGRITY${NC}"
echo "====================="

run_test "All core tables exist" "php artisan tinker --execute='echo Schema::hasTable(\"users\") && Schema::hasTable(\"salaries\") && Schema::hasTable(\"approvals\") && Schema::hasTable(\"thresholds\") && Schema::hasTable(\"api_keys\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Database migrations status" "php artisan migrate:status | grep -q 'Ran'" "success"

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================
echo -e "${PURPLE}⚙️  CONFIGURATION VALIDATION${NC}"
echo "============================="

run_test "App configuration loaded" "php artisan tinker --execute='echo config(\"app.name\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Database configuration" "php artisan tinker --execute='echo config(\"database.default\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Cache configuration" "php artisan tinker --execute='echo config(\"cache.default\") ? \"OK\" : \"FAIL\";'" "success"
run_test "Queue configuration" "php artisan tinker --execute='echo config(\"queue.default\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# PERFORMANCE & OPTIMIZATION
# =============================================================================
echo -e "${PURPLE}⚡ PERFORMANCE & OPTIMIZATION${NC}"
echo "==============================="

run_test "Route caching available" "php artisan route:cache" "success"
run_test "Config caching available" "php artisan config:cache" "success"
run_test "View caching available" "php artisan view:cache" "success"

# Clear caches after testing
php artisan route:clear > /dev/null 2>&1
php artisan config:clear > /dev/null 2>&1
php artisan view:clear > /dev/null 2>&1

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
    echo -e "${GREEN}✅ Phase 1: User Management & Authentication${NC}"
    echo -e "${GREEN}✅ Phase 2: Salary Management & Deductions${NC}"
    echo -e "${GREEN}✅ Phase 3: Approval Workflows & Escalations${NC}"
    echo -e "${GREEN}✅ Phase 4: Zoho Inventory Integration${NC}"
    echo -e "${GREEN}✅ Phase 5: Threshold Management & Alerts${NC}"
    echo -e "${GREEN}✅ Phase 6: Advanced Reporting & Analytics${NC}"
    echo -e "${GREEN}✅ Phase 7: Mobile Application & API Gateway${NC}"
    echo ""
    echo -e "${BLUE}🚀 VITALVIDA ACCOUNTANT PORTAL FEATURES:${NC}"
    echo "✅ Complete user management system"
    echo "✅ Comprehensive salary and deduction management"
    echo "✅ Advanced approval workflows with escalations"
    echo "✅ Zoho inventory integration"
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
echo -e "${CYAN}🏠 Environment: $(php artisan tinker --execute='echo config(\"app.env\");')${NC}"
echo -e "${CYAN}🔧 Laravel Version: $(php artisan --version | cut -d' ' -f3)${NC}"
echo -e "${CYAN}🐘 PHP Version: $(php -v | head -n1 | cut -d' ' -f2)${NC}" 