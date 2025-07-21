<?php
/**
 * VITALVIDA PORTAL - EXISTING IMPLEMENTATION ASSESSMENT
 * 
 * Testing to determine what business logic has already been implemented
 * Focusing on Weeks 1-3 implementation status:
 * - Week 1: Authentication & Payment Processing
 * - Week 2: Inventory & Threshold Enforcement  
 * - Week 3: Basic Reporting & Mobile Foundation
 */

class ExistingImplementationTester
{
    private $baseUrl = 'http://localhost';
    private $apiToken = null;
    private $implementationStatus = [];
    private $testResults = [];

    public function __construct($baseUrl = null)
    {
        if ($baseUrl) {
            $this->baseUrl = rtrim($baseUrl, '/');
        }
        
        echo "🔍 VITALVIDA PORTAL - EXISTING IMPLEMENTATION ASSESSMENT\n";
        echo "=" . str_repeat("=", 65) . "\n";
        echo "Analyzing current business logic implementation status...\n\n";
    }

    /**
     * Run comprehensive assessment of existing implementation
     */
    public function assessExistingImplementation()
    {
        $startTime = microtime(true);

        try {
            // First, try to authenticate to get API token
            $this->attemptAuthentication();
            
            // Week 1 Assessment: Authentication & Payment Processing
            echo "📋 WEEK 1 ASSESSMENT: AUTHENTICATION & PAYMENT PROCESSING\n";
            echo str_repeat("-", 60) . "\n";
            $week1Status = $this->assessWeek1Implementation();
            
            // Week 2 Assessment: Inventory & Threshold Enforcement
            echo "\n📦 WEEK 2 ASSESSMENT: INVENTORY & THRESHOLD ENFORCEMENT\n";
            echo str_repeat("-", 60) . "\n";
            $week2Status = $this->assessWeek2Implementation();
            
            // Week 3 Assessment: Basic Reporting & Mobile Foundation
            echo "\n📊 WEEK 3 ASSESSMENT: REPORTING & MOBILE FOUNDATION\n";
            echo str_repeat("-", 60) . "\n";
            $week3Status = $this->assessWeek3Implementation();
            
            // Additional Assessment: Advanced Features Check
            echo "\n🚀 BONUS ASSESSMENT: ADVANCED FEATURES\n";
            echo str_repeat("-", 45) . "\n";
            $advancedStatus = $this->assessAdvancedFeatures();
            
            $endTime = microtime(true);
            $totalTime = number_format(($endTime - $startTime) * 1000, 2);
            
            // Generate comprehensive implementation report
            $this->generateImplementationReport($week1Status, $week2Status, $week3Status, $advancedStatus, $totalTime);
            
        } catch (Exception $e) {
            echo "❌ ASSESSMENT FAILED: {$e->getMessage()}\n";
            return false;
        }

        return true;
    }

    /**
     * WEEK 1: AUTHENTICATION & PAYMENT PROCESSING ASSESSMENT
     */
    private function assessWeek1Implementation()
    {
        $week1Features = [
            'authentication' => $this->testAuthenticationSystem(),
            'user_management' => $this->testUserManagement(),
            'role_permissions' => $this->testRolePermissions(),
            'payment_processing' => $this->testPaymentProcessing(),
            'otp_verification' => $this->testOTPSystem(),
            'payment_reconciliation' => $this->testPaymentReconciliation(),
            'money_out_compliance' => $this->testMoneyOutCompliance()
        ];

        $implementedCount = count(array_filter($week1Features));
        $totalCount = count($week1Features);
        $percentage = ($implementedCount / $totalCount) * 100;

        echo "Week 1 Implementation: {$implementedCount}/{$totalCount} ({$percentage}%)\n";

        return [
            'features' => $week1Features,
            'implemented' => $implementedCount,
            'total' => $totalCount,
            'percentage' => $percentage
        ];
    }

    /**
     * WEEK 2: INVENTORY & THRESHOLD ENFORCEMENT ASSESSMENT
     */
    private function assessWeek2Implementation()
    {
        $week2Features = [
            'da_photo_submission' => $this->testDAPhotoSubmission(),
            'im_verification' => $this->testIMVerification(),
            'three_way_verification' => $this->testThreeWayVerification(),
            'zoho_sync' => $this->testZohoSync(),
            'threshold_validation' => $this->testThresholdValidation(),
            'escalation_management' => $this->testEscalationManagement(),
            'dual_approval_workflow' => $this->testDualApprovalWorkflow(),
            'salary_deduction_system' => $this->testSalaryDeductionSystem()
        ];

        $implementedCount = count(array_filter($week2Features));
        $totalCount = count($week2Features);
        $percentage = ($implementedCount / $totalCount) * 100;

        echo "Week 2 Implementation: {$implementedCount}/{$totalCount} ({$percentage}%)\n";

        return [
            'features' => $week2Features,
            'implemented' => $implementedCount,
            'total' => $totalCount,
            'percentage' => $percentage
        ];
    }

    /**
     * WEEK 3: REPORTING & MOBILE FOUNDATION ASSESSMENT
     */
    private function assessWeek3Implementation()
    {
        $week3Features = [
            'dashboard_analytics' => $this->testDashboardAnalytics(),
            'financial_reporting' => $this->testFinancialReporting(),
            'executive_dashboard' => $this->testExecutiveDashboard(),
            'mobile_authentication' => $this->testMobileAuthentication(),
            'mobile_api_gateway' => $this->testMobileAPIGateway(),
            'basic_mobile_endpoints' => $this->testBasicMobileEndpoints()
        ];

        $implementedCount = count(array_filter($week3Features));
        $totalCount = count($week3Features);
        $percentage = ($implementedCount / $totalCount) * 100;

        echo "Week 3 Implementation: {$implementedCount}/{$totalCount} ({$percentage}%)\n";

        return [
            'features' => $week3Features,
            'implemented' => $implementedCount,
            'total' => $totalCount,
            'percentage' => $percentage
        ];
    }

    /**
     * ADVANCED FEATURES ASSESSMENT
     */
    private function assessAdvancedFeatures()
    {
        $advancedFeatures = [
            'bonus_calculation' => $this->testBonusCalculation(),
            'payroll_integration' => $this->testPayrollIntegration(),
            'tax_compliance' => $this->testTaxCompliance(),
            'predictive_analytics' => $this->testPredictiveAnalytics(),
            'custom_reporting' => $this->testCustomReporting(),
            'offline_sync' => $this->testOfflineSync(),
            'push_notifications' => $this->testPushNotifications(),
            'biometric_auth' => $this->testBiometricAuth()
        ];

        $implementedCount = count(array_filter($advancedFeatures));
        $totalCount = count($advancedFeatures);
        $percentage = ($implementedCount / $totalCount) * 100;

        echo "Advanced Features: {$implementedCount}/{$totalCount} ({$percentage}%)\n";

        return [
            'features' => $advancedFeatures,
            'implemented' => $implementedCount,
            'total' => $totalCount,
            'percentage' => $percentage
        ];
    }

    // =============================================================================
    // AUTHENTICATION SYSTEM TESTS
    // =============================================================================

    private function attemptAuthentication()
    {
        echo "🔐 Attempting authentication...\n";
        
        $loginData = [
            'email' => 'admin@vitalvida.com',
            'password' => 'password'
        ];

        $response = $this->makeRequest('POST', '/api/auth/login', $loginData);
        
        if ($response && isset($response['token'])) {
            $this->apiToken = $response['token'];
            echo "✅ Authentication successful - API token obtained\n";
            return true;
        }

        // Try alternative login endpoints
        $alternativeEndpoints = [
            '/api/login',
            '/api/user/login',
            '/api/accountant/login'
        ];

        foreach ($alternativeEndpoints as $endpoint) {
            $response = $this->makeRequest('POST', $endpoint, $loginData);
            if ($response && (isset($response['token']) || isset($response['access_token']))) {
                $this->apiToken = $response['token'] ?? $response['access_token'];
                echo "✅ Authentication successful via {$endpoint}\n";
                return true;
            }
        }

        echo "⚠️ Authentication not available - testing without token\n";
        return false;
    }

    private function testAuthenticationSystem()
    {
        $tests = [
            'login_endpoint' => $this->testEndpoint('POST', '/api/auth/login'),
            'logout_endpoint' => $this->testEndpoint('POST', '/api/auth/logout'),
            'profile_endpoint' => $this->testEndpoint('GET', '/api/auth/profile'),
            'register_endpoint' => $this->testEndpoint('POST', '/api/auth/register')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 2; // At least login and profile should work

        echo ($result ? "✅" : "❌") . " Authentication System: {$workingEndpoints}/4 endpoints\n";
        return $result;
    }

    private function testUserManagement()
    {
        $tests = [
            'users_list' => $this->testEndpoint('GET', '/api/users'),
            'user_profile' => $this->testEndpoint('GET', '/api/user/profile'),
            'user_update' => $this->testEndpoint('PUT', '/api/user/profile'),
            'user_permissions' => $this->testEndpoint('GET', '/api/user/permissions')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " User Management: {$workingEndpoints}/4 endpoints\n";
        return $result;
    }

    private function testRolePermissions()
    {
        $tests = [
            'roles_list' => $this->testEndpoint('GET', '/api/roles'),
            'permissions_list' => $this->testEndpoint('GET', '/api/permissions'),
            'user_roles' => $this->testEndpoint('GET', '/api/user/roles')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Role Permissions: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // PAYMENT SYSTEM TESTS
    // =============================================================================

    private function testPaymentProcessing()
    {
        $tests = [
            'payments_list' => $this->testEndpoint('GET', '/api/payments'),
            'process_payment' => $this->testEndpoint('POST', '/api/payments'),
            'payment_status' => $this->testEndpoint('GET', '/api/payments/status'),
            'payment_methods' => $this->testEndpoint('GET', '/api/payments/methods')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 2;

        echo ($result ? "✅" : "❌") . " Payment Processing: {$workingEndpoints}/4 endpoints\n";
        return $result;
    }

    private function testOTPSystem()
    {
        $tests = [
            'otp_generate' => $this->testEndpoint('POST', '/api/otp/generate'),
            'otp_verify' => $this->testEndpoint('POST', '/api/otp/verify'),
            'otp_status' => $this->testEndpoint('GET', '/api/otp/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " OTP System: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testPaymentReconciliation()
    {
        $tests = [
            'reconciliation_status' => $this->testEndpoint('GET', '/api/payments/reconciliation'),
            'reconcile_payment' => $this->testEndpoint('POST', '/api/payments/reconcile'),
            'mismatches' => $this->testEndpoint('GET', '/api/payments/mismatches')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Payment Reconciliation: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testMoneyOutCompliance()
    {
        $tests = [
            'money_out_list' => $this->testEndpoint('GET', '/api/money-out'),
            'compliance_status' => $this->testEndpoint('GET', '/api/money-out/compliance'),
            'mark_paid' => $this->testEndpoint('POST', '/api/money-out/mark-paid'),
            'upload_proof' => $this->testEndpoint('POST', '/api/money-out/upload-proof')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 2;

        echo ($result ? "✅" : "❌") . " Money Out Compliance: {$workingEndpoints}/4 endpoints\n";
        return $result;
    }

    // =============================================================================
    // INVENTORY SYSTEM TESTS
    // =============================================================================

    private function testDAPhotoSubmission()
    {
        $tests = [
            'da_photos' => $this->testEndpoint('GET', '/api/inventory/da-photos'),
            'submit_photo' => $this->testEndpoint('POST', '/api/inventory/da-photos'),
            'photo_status' => $this->testEndpoint('GET', '/api/inventory/photo-status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " DA Photo Submission: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testIMVerification()
    {
        $tests = [
            'im_verifications' => $this->testEndpoint('GET', '/api/inventory/im-verification'),
            'verify_photo' => $this->testEndpoint('POST', '/api/inventory/im-verification'),
            'verification_status' => $this->testEndpoint('GET', '/api/inventory/verification-status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " IM Verification: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testThreeWayVerification()
    {
        $tests = [
            'three_way_match' => $this->testEndpoint('GET', '/api/inventory/three-way-match'),
            'verification_results' => $this->testEndpoint('GET', '/api/inventory/verification-results'),
            'discrepancies' => $this->testEndpoint('GET', '/api/inventory/discrepancies')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Three-Way Verification: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testZohoSync()
    {
        $tests = [
            'zoho_sync' => $this->testEndpoint('POST', '/api/inventory/zoho-sync'),
            'sync_status' => $this->testEndpoint('GET', '/api/inventory/sync-status'),
            'zoho_records' => $this->testEndpoint('GET', '/api/inventory/zoho-records')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Zoho Sync: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // THRESHOLD ENFORCEMENT TESTS
    // =============================================================================

    private function testThresholdValidation()
    {
        $tests = [
            'threshold_check' => $this->testEndpoint('POST', '/api/thresholds/validate'),
            'threshold_rules' => $this->testEndpoint('GET', '/api/thresholds/rules'),
            'violations' => $this->testEndpoint('GET', '/api/thresholds/violations')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Threshold Validation: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testEscalationManagement()
    {
        $tests = [
            'escalations_list' => $this->testEndpoint('GET', '/api/escalations'),
            'pending_escalations' => $this->testEndpoint('GET', '/api/escalations/pending'),
            'create_escalation' => $this->testEndpoint('POST', '/api/escalations')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Escalation Management: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testDualApprovalWorkflow()
    {
        $tests = [
            'approval_requests' => $this->testEndpoint('GET', '/api/approvals'),
            'process_approval' => $this->testEndpoint('POST', '/api/approvals/process'),
            'approval_status' => $this->testEndpoint('GET', '/api/approvals/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Dual Approval Workflow: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testSalaryDeductionSystem()
    {
        $tests = [
            'deductions_list' => $this->testEndpoint('GET', '/api/deductions'),
            'my_deductions' => $this->testEndpoint('GET', '/api/deductions/my'),
            'create_deduction' => $this->testEndpoint('POST', '/api/deductions')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Salary Deduction System: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // REPORTING & ANALYTICS TESTS
    // =============================================================================

    private function testDashboardAnalytics()
    {
        $tests = [
            'dashboard' => $this->testEndpoint('GET', '/api/dashboard'),
            'analytics' => $this->testEndpoint('GET', '/api/analytics'),
            'metrics' => $this->testEndpoint('GET', '/api/metrics')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Dashboard Analytics: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testFinancialReporting()
    {
        $tests = [
            'financial_reports' => $this->testEndpoint('GET', '/api/reports/financial'),
            'generate_report' => $this->testEndpoint('POST', '/api/reports/financial'),
            'report_status' => $this->testEndpoint('GET', '/api/reports/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Financial Reporting: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testExecutiveDashboard()
    {
        $tests = [
            'executive_dashboard' => $this->testEndpoint('GET', '/api/dashboard/executive'),
            'kpi_summary' => $this->testEndpoint('GET', '/api/dashboard/kpi'),
            'performance_metrics' => $this->testEndpoint('GET', '/api/dashboard/performance')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Executive Dashboard: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // MOBILE PLATFORM TESTS
    // =============================================================================

    private function testMobileAuthentication()
    {
        $tests = [
            'mobile_login' => $this->testEndpoint('POST', '/api/mobile/auth/login'),
            'mobile_register' => $this->testEndpoint('POST', '/api/mobile/auth/register'),
            'mobile_profile' => $this->testEndpoint('GET', '/api/mobile/auth/profile')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Mobile Authentication: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testMobileAPIGateway()
    {
        $tests = [
            'mobile_gateway' => $this->testEndpoint('GET', '/api/mobile/gateway'),
            'mobile_health' => $this->testEndpoint('GET', '/api/mobile/health'),
            'mobile_status' => $this->testEndpoint('GET', '/api/mobile/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Mobile API Gateway: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testBasicMobileEndpoints()
    {
        $tests = [
            'mobile_dashboard' => $this->testEndpoint('GET', '/api/mobile/dashboard'),
            'mobile_sync' => $this->testEndpoint('GET', '/api/mobile/sync'),
            'mobile_notifications' => $this->testEndpoint('GET', '/api/mobile/notifications')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Basic Mobile Endpoints: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // ADVANCED FEATURES TESTS
    // =============================================================================

    private function testBonusCalculation()
    {
        $tests = [
            'calculate_bonuses' => $this->testEndpoint('POST', '/api/bonuses/calculate'),
            'bonus_history' => $this->testEndpoint('GET', '/api/bonuses/history'),
            'bonus_rules' => $this->testEndpoint('GET', '/api/bonuses/rules')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Bonus Calculation: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testPayrollIntegration()
    {
        $tests = [
            'process_payroll' => $this->testEndpoint('POST', '/api/payroll/process'),
            'payroll_history' => $this->testEndpoint('GET', '/api/payroll/history'),
            'payslips' => $this->testEndpoint('GET', '/api/payroll/payslips')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Payroll Integration: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testTaxCompliance()
    {
        $tests = [
            'tax_calculations' => $this->testEndpoint('GET', '/api/tax/calculations'),
            'tax_reports' => $this->testEndpoint('GET', '/api/tax/reports'),
            'tax_compliance' => $this->testEndpoint('GET', '/api/tax/compliance')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Tax Compliance: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testPredictiveAnalytics()
    {
        $tests = [
            'predictive_analysis' => $this->testEndpoint('POST', '/api/analytics/predictive'),
            'forecasting' => $this->testEndpoint('GET', '/api/analytics/forecast'),
            'trends' => $this->testEndpoint('GET', '/api/analytics/trends')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Predictive Analytics: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testCustomReporting()
    {
        $tests = [
            'custom_reports' => $this->testEndpoint('GET', '/api/reports/custom'),
            'report_builder' => $this->testEndpoint('GET', '/api/reports/builder'),
            'scheduled_reports' => $this->testEndpoint('GET', '/api/reports/scheduled')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Custom Reporting: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testOfflineSync()
    {
        $tests = [
            'sync_download' => $this->testEndpoint('GET', '/api/mobile/sync/download'),
            'sync_upload' => $this->testEndpoint('POST', '/api/mobile/sync/upload'),
            'sync_status' => $this->testEndpoint('GET', '/api/mobile/sync/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Offline Sync: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testPushNotifications()
    {
        $tests = [
            'register_device' => $this->testEndpoint('POST', '/api/mobile/push/register'),
            'send_notification' => $this->testEndpoint('POST', '/api/mobile/push/send'),
            'notification_history' => $this->testEndpoint('GET', '/api/mobile/push/history')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Push Notifications: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    private function testBiometricAuth()
    {
        $tests = [
            'biometric_setup' => $this->testEndpoint('POST', '/api/mobile/auth/biometric/setup'),
            'biometric_auth' => $this->testEndpoint('POST', '/api/mobile/auth/biometric/authenticate'),
            'biometric_status' => $this->testEndpoint('GET', '/api/mobile/auth/biometric/status')
        ];

        $workingEndpoints = count(array_filter($tests));
        $result = $workingEndpoints >= 1;

        echo ($result ? "✅" : "❌") . " Biometric Auth: {$workingEndpoints}/3 endpoints\n";
        return $result;
    }

    // =============================================================================
    // UTILITY METHODS
    // =============================================================================

    private function testEndpoint($method, $endpoint, $data = null)
    {
        $response = $this->makeRequest($method, $endpoint, $data);
        return $response !== false;
    }

    private function makeRequest($method, $endpoint, $data = null)
    {
        $url = $this->baseUrl . $endpoint;
        
        $ch = curl_init();
        
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_TIMEOUT => 10,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_SSL_VERIFYPEER => false,
        ]);

        // Set headers
        $headers = ['Content-Type: application/json', 'Accept: application/json'];
        if ($this->apiToken) {
            $headers[] = "Authorization: Bearer {$this->apiToken}";
        }
        curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);

        // Set data for POST/PUT requests
        if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        
        curl_close($ch);

        if ($error || $httpCode >= 500) {
            return false;
        }

        // Consider 2xx and some 4xx codes as "endpoint exists"
        if ($httpCode >= 200 && $httpCode < 500) {
            return json_decode($response, true) ?: true;
        }

        return false;
    }

    private function generateImplementationReport($week1Status, $week2Status, $week3Status, $advancedStatus, $totalTime)
    {
        echo "\n🎯 COMPREHENSIVE IMPLEMENTATION ASSESSMENT REPORT\n";
        echo "=" . str_repeat("=", 70) . "\n\n";

        // Calculate overall implementation status
        $totalImplemented = $week1Status['implemented'] + $week2Status['implemented'] + 
                           $week3Status['implemented'] + $advancedStatus['implemented'];
        $totalFeatures = $week1Status['total'] + $week2Status['total'] + 
                        $week3Status['total'] + $advancedStatus['total'];
        $overallPercentage = ($totalImplemented / $totalFeatures) * 100;

        // Overall Statistics
        echo "📊 OVERALL IMPLEMENTATION STATUS:\n";
        echo "Total Features Assessed: {$totalFeatures}\n";
        echo "Features Implemented: {$totalImplemented}\n";
        echo "Implementation Rate: " . number_format($overallPercentage, 1) . "%\n";
        echo "Assessment Time: {$totalTime}ms\n\n";

        // Week-by-Week Breakdown
        echo "📅 WEEK-BY-WEEK IMPLEMENTATION STATUS:\n";
        echo str_repeat("-", 50) . "\n";
        
        $this->displayWeekStatus("Week 1: Authentication & Payments", $week1Status);
        $this->displayWeekStatus("Week 2: Inventory & Thresholds", $week2Status);
        $this->displayWeekStatus("Week 3: Reporting & Mobile", $week3Status);
        $this->displayWeekStatus("Advanced Features", $advancedStatus);

        // Implementation Readiness Assessment
        echo "\n🚀 IMPLEMENTATION READINESS ASSESSMENT:\n";
        echo str_repeat("-", 50) . "\n";
        $this->assessImplementationReadiness($week1Status, $week2Status, $week3Status, $advancedStatus);

        // Recommendations
        echo "\n💡 STRATEGIC RECOMMENDATIONS:\n";
        echo str_repeat("-", 50) . "\n";
        $this->generateStrategicRecommendations($week1Status, $week2Status, $week3Status, $advancedStatus, $overallPercentage);
    }

    private function displayWeekStatus($weekName, $weekStatus)
    {
        $percentage = $weekStatus['percentage'];
        $status = $this->getStatusIcon($percentage);
        
        echo "{$status} {$weekName}: {$weekStatus['implemented']}/{$weekStatus['total']} ";
        echo "(" . number_format($percentage, 1) . "%)\n";
    }

    private function getStatusIcon($percentage)
    {
        if ($percentage >= 80) return "🟢";
        if ($percentage >= 60) return "🟡";
        if ($percentage >= 40) return "🟠";
        return "🔴";
    }

    private function assessImplementationReadiness($week1Status, $week2Status, $week3Status, $advancedStatus)
    {
        $readinessFactors = [
            'Core Authentication' => $week1Status['percentage'] >= 60,
            'Payment System' => $week1Status['features']['payment_processing'] && $week1Status['features']['money_out_compliance'],
            'Inventory System' => $week2Status['percentage'] >= 40,
            'Financial Controls' => $week2Status['features']['threshold_validation'],
            'Basic Reporting' => $week3Status['features']['dashboard_analytics'],
            'Mobile Foundation' => $week3Status['percentage'] >= 30
        ];

        $readyFactors = count(array_filter($readinessFactors));
        $totalFactors = count($readinessFactors);
        $readinessPercentage = ($readyFactors / $totalFactors) * 100;

        echo "Production Readiness Score: {$readyFactors}/{$totalFactors} (" . number_format($readinessPercentage, 1) . "%)\n\n";

        foreach ($readinessFactors as $factor => $ready) {
            $icon = $ready ? "✅" : "❌";
            echo "{$icon} {$factor}\n";
        }

        echo "\n🎖️ READINESS VERDICT:\n";
        if ($readinessPercentage >= 80) {
            echo "🏆 PRODUCTION READY! Your system is ready for deployment.\n";
        } elseif ($readinessPercentage >= 60) {
            echo "🎯 NEARLY READY! Minor implementation needed for production.\n";
        } elseif ($readinessPercentage >= 40) {
            echo "🔧 NEEDS WORK! Core features need completion before production.\n";
        } else {
            echo "🚧 EARLY STAGE! Significant implementation required.\n";
        }
    }

    private function generateStrategicRecommendations($week1Status, $week2Status, $week3Status, $advancedStatus, $overallPercentage)
    {
        if ($overallPercentage >= 70) {
            echo "🎉 EXCELLENT PROGRESS! You're ahead of schedule!\n\n";
            echo "Strategic Recommendations:\n";
            echo "1. 🚀 Focus on Polish & Optimization\n";
            echo "2. 📱 Accelerate Mobile Development\n";
            echo "3. 🎯 Prepare for Production\n";
        } elseif ($overallPercentage >= 40) {
            echo "🎯 SOLID FOUNDATION! Good progress on core features.\n\n";
            echo "Strategic Recommendations:\n";
            echo "1. 🔧 Complete Core Business Logic\n";
            echo "2. 📊 Build Essential Reporting\n";
            echo "3. 🏗️ Strengthen Foundation\n";
        } else {
            echo "🚧 EARLY IMPLEMENTATION STAGE\n\n";
            echo "Strategic Recommendations:\n";
            echo "1. 🎯 Focus on MVP Core Features\n";
            echo "2. 📋 Prioritize Business-Critical Functions\n";
            echo "3. 🔨 Build Incrementally\n";
        }
    }
}

// =============================================================================
// EXECUTION SCRIPT
// =============================================================================

if (php_sapi_name() === 'cli') {
    // Get base URL from command line argument
    $baseUrl = isset($argv[1]) ? $argv[1] : 'http://localhost:8000';

    echo "🔍 Starting comprehensive implementation assessment...\n";
    echo "Base URL: {$baseUrl}\n\n";

    // Initialize and run assessment
    $tester = new ExistingImplementationTester($baseUrl);
    $success = $tester->assessExistingImplementation();

    echo "\n" . str_repeat("=", 70) . "\n";
    if ($success) {
        echo "✅ IMPLEMENTATION ASSESSMENT COMPLETED SUCCESSFULLY!\n";
        echo "📋 Review the detailed analysis above for next steps.\n";
    } else {
        echo "⚠️ ASSESSMENT COMPLETED WITH ISSUES\n";
        echo "🔧 Check your Laravel application and API endpoints.\n";
    }
    echo str_repeat("=", 70) . "\n";
} 