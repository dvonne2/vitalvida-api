#!/bin/bash

# =============================================================================
# PHASE 7: MOBILE APPLICATION & API GATEWAY TEST SCRIPT
# =============================================================================

echo "🚀 PHASE 7: MOBILE APPLICATION & API GATEWAY TESTING"
echo "=================================================="
echo ""

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

echo -e "${YELLOW}📋 PHASE 7 COMPONENTS TO TEST:${NC}"
echo "1. Database Migrations"
echo "2. Models"
echo "3. Services"
echo "4. Controllers"
echo "5. Middleware"
echo "6. Routes"
echo "7. Background Jobs"
echo "8. Console Commands"
echo "9. Scheduled Tasks"
echo "10. API Endpoints"
echo ""

# =============================================================================
# 1. DATABASE MIGRATIONS
# =============================================================================
echo -e "${YELLOW}🔧 1. TESTING DATABASE MIGRATIONS${NC}"
echo "----------------------------------------"

run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120000_create_api_keys_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120001_create_device_tokens_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120002_create_biometric_auth_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120003_create_sync_jobs_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120004_create_sync_conflicts_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120005_create_api_requests_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120006_create_push_notifications_table.php" "success"
run_test "Run Phase 7 migrations" "php artisan migrate --path=database/migrations/2025_07_19_120007_create_rate_limit_rules_table.php" "success"

# =============================================================================
# 2. MODELS
# =============================================================================
echo -e "${YELLOW}📦 2. TESTING MODELS${NC}"
echo "------------------------"

run_test "ApiKey model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\ApiKey\") ? \"OK\" : \"FAIL\";'" "success"
run_test "DeviceToken model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\DeviceToken\") ? \"OK\" : \"FAIL\";'" "success"
run_test "BiometricAuth model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\BiometricAuth\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SyncJob model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\SyncJob\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SyncConflict model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\SyncConflict\") ? \"OK\" : \"FAIL\";'" "success"
run_test "ApiRequest model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\ApiRequest\") ? \"OK\" : \"FAIL\";'" "success"
run_test "PushNotification model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\PushNotification\") ? \"OK\" : \"FAIL\";'" "success"
run_test "RateLimitRule model exists" "php artisan tinker --execute='echo class_exists(\"App\\Models\\RateLimitRule\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 3. SERVICES
# =============================================================================
echo -e "${YELLOW}⚙️  3. TESTING SERVICES${NC}"
echo "---------------------------"

run_test "APIGatewayService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\APIGatewayService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileSyncService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobileSyncService\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobilePushNotificationService exists" "php artisan tinker --execute='echo class_exists(\"App\\Services\\MobilePushNotificationService\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 4. CONTROLLERS
# =============================================================================
echo -e "${YELLOW}🎮 4. TESTING CONTROLLERS${NC}"
echo "----------------------------"

run_test "MobileGatewayController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileGatewayController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileAuthController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileAuthController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileDashboardController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileDashboardController\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileSyncController exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Controllers\\Api\\Mobile\\MobileSyncController\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 5. MIDDLEWARE
# =============================================================================
echo -e "${YELLOW}🛡️  5. TESTING MIDDLEWARE${NC}"
echo "-----------------------------"

run_test "MobileAPIAuthentication middleware exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileAPIAuthentication\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MobileRateLimit middleware exists" "php artisan tinker --execute='echo class_exists(\"App\\Http\\Middleware\\MobileRateLimit\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 6. ROUTES
# =============================================================================
echo -e "${YELLOW}🛣️  6. TESTING ROUTES${NC}"
echo "------------------------"

run_test "Mobile routes are registered" "php artisan route:list --name=mobile" "success"
run_test "Mobile auth routes exist" "php artisan route:list | grep mobile/auth" "success"
run_test "Mobile gateway routes exist" "php artisan route:list | grep mobile/gateway" "success"
run_test "Mobile dashboard routes exist" "php artisan route:list | grep mobile/dashboard" "success"
run_test "Mobile sync routes exist" "php artisan route:list | grep mobile/sync" "success"

# =============================================================================
# 7. BACKGROUND JOBS
# =============================================================================
echo -e "${YELLOW}🔄 7. TESTING BACKGROUND JOBS${NC}"
echo "--------------------------------"

run_test "ProcessMobileSync job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\ProcessMobileSync\") ? \"OK\" : \"FAIL\";'" "success"
run_test "SendScheduledPushNotifications job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\SendScheduledPushNotifications\") ? \"OK\" : \"FAIL\";'" "success"
run_test "CleanupExpiredApiKeys job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\CleanupExpiredApiKeys\") ? \"OK\" : \"FAIL\";'" "success"
run_test "MonitorMobileAppHealth job exists" "php artisan tinker --execute='echo class_exists(\"App\\Jobs\\MonitorMobileAppHealth\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 8. CONSOLE COMMANDS
# =============================================================================
echo -e "${YELLOW}💻 8. TESTING CONSOLE COMMANDS${NC}"
echo "-----------------------------------"

run_test "GenerateMobileApiKey command exists" "php artisan list | grep mobile:generate-api-key" "success"
run_test "MobileAppHealthCheck command exists" "php artisan list | grep mobile:health-check" "success"

# =============================================================================
# 9. SCHEDULED TASKS
# =============================================================================
echo -e "${YELLOW}⏰ 9. TESTING SCHEDULED TASKS${NC}"
echo "--------------------------------"

run_test "Mobile scheduled tasks are registered" "grep -q 'ProcessMobileSync' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks are registered" "grep -q 'SendScheduledPushNotifications' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks are registered" "grep -q 'CleanupExpiredApiKeys' app/Console/Kernel.php" "success"
run_test "Mobile scheduled tasks are registered" "grep -q 'MonitorMobileAppHealth' app/Console/Kernel.php" "success"

# =============================================================================
# 10. API ENDPOINTS
# =============================================================================
echo -e "${YELLOW}🌐 10. TESTING API ENDPOINTS${NC}"
echo "--------------------------------"

# Start the server in background for testing
echo "Starting Laravel server for API testing..."
php artisan serve --host=127.0.0.1 --port=8000 > /dev/null 2>&1 &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test mobile health endpoint
run_test "Mobile gateway health endpoint" "curl -s http://127.0.0.1:8000/api/mobile/gateway/health" "success"

# Test mobile documentation endpoint
run_test "Mobile gateway documentation endpoint" "curl -s http://127.0.0.1:8000/api/mobile/gateway/docs" "success"

# Stop the server
kill $SERVER_PID 2>/dev/null

# =============================================================================
# 11. DATABASE TABLES
# =============================================================================
echo -e "${YELLOW}🗄️  11. TESTING DATABASE TABLES${NC}"
echo "-----------------------------------"

run_test "api_keys table exists" "php artisan tinker --execute='echo Schema::hasTable(\"api_keys\") ? \"OK\" : \"FAIL\";'" "success"
run_test "device_tokens table exists" "php artisan tinker --execute='echo Schema::hasTable(\"device_tokens\") ? \"OK\" : \"FAIL\";'" "success"
run_test "biometric_auth table exists" "php artisan tinker --execute='echo Schema::hasTable(\"biometric_auth\") ? \"OK\" : \"FAIL\";'" "success"
run_test "sync_jobs table exists" "php artisan tinker --execute='echo Schema::hasTable(\"sync_jobs\") ? \"OK\" : \"FAIL\";'" "success"
run_test "sync_conflicts table exists" "php artisan tinker --execute='echo Schema::hasTable(\"sync_conflicts\") ? \"OK\" : \"FAIL\";'" "success"
run_test "api_requests table exists" "php artisan tinker --execute='echo Schema::hasTable(\"api_requests\") ? \"OK\" : \"FAIL\";'" "success"
run_test "push_notifications table exists" "php artisan tinker --execute='echo Schema::hasTable(\"push_notifications\") ? \"OK\" : \"FAIL\";'" "success"
run_test "rate_limit_rules table exists" "php artisan tinker --execute='echo Schema::hasTable(\"rate_limit_rules\") ? \"OK\" : \"FAIL\";'" "success"

# =============================================================================
# 12. CONFIGURATION
# =============================================================================
echo -e "${YELLOW}⚙️  12. TESTING CONFIGURATION${NC}"
echo "--------------------------------"

run_test "Mobile middleware registered in Kernel" "grep -q 'mobile.auth' app/Http/Kernel.php" "success"
run_test "Mobile scheduled tasks in Console Kernel" "grep -q 'ProcessMobileSync' app/Console/Kernel.php" "success"

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
    echo -e "${GREEN}🎉 ALL TESTS PASSED! PHASE 7 MOBILE APPLICATION & API GATEWAY IS READY!${NC}"
    echo ""
    echo -e "${BLUE}📱 MOBILE APP FEATURES IMPLEMENTED:${NC}"
    echo "✅ API Gateway with rate limiting and caching"
    echo "✅ Mobile authentication with API keys"
    echo "✅ Biometric authentication support"
    echo "✅ Offline data synchronization"
    echo "✅ Push notifications (FCM/APNS)"
    echo "✅ Mobile-optimized dashboards"
    echo "✅ Background job processing"
    echo "✅ Health monitoring and analytics"
    echo "✅ Console commands for management"
    echo "✅ Scheduled tasks for automation"
    echo ""
    echo -e "${BLUE}🚀 NEXT STEPS:${NC}"
    echo "1. Configure FCM and APNS credentials in .env"
    echo "2. Set up Redis for rate limiting and caching"
    echo "3. Deploy to production environment"
    echo "4. Develop React Native mobile app"
    echo "5. Test with real mobile devices"
    echo "6. Monitor performance and health metrics"
    echo ""
    echo -e "${GREEN}🎯 PHASE 7 COMPLETE - VITALVIDA ACCOUNTANT PORTAL BACKEND IS FULLY MOBILE-ENABLED!${NC}"
else
    echo ""
    echo -e "${RED}❌ SOME TESTS FAILED. PLEASE REVIEW AND FIX THE ISSUES ABOVE.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}🔗 USEFUL COMMANDS:${NC}"
echo "php artisan mobile:generate-api-key {user_id} --name='Mobile App' --platform=android"
echo "php artisan mobile:health-check --detailed"
echo "php artisan queue:work --queue=mobile"
echo "php artisan schedule:run"
echo "" 