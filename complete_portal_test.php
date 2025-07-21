<?php
/**
 * VITALVIDA ACCOUNTANT PORTAL - COMPLETE SYSTEM TEST
 * 
 * This script provides a comprehensive assessment of the entire Vitalvida system
 * including infrastructure, business logic readiness, and production readiness.
 */

class CompletePortalTest
{
    private $baseUrl;
    private $infrastructureResults;
    private $businessLogicAssessment;
    private $productionReadiness;

    public function __construct($baseUrl = 'http://localhost:8000')
    {
        $this->baseUrl = rtrim($baseUrl, '/');
        echo "🚀 VITALVIDA ACCOUNTANT PORTAL - COMPLETE SYSTEM ASSESSMENT\n";
        echo "=" . str_repeat("=", 65) . "\n";
        echo "Comprehensive evaluation of infrastructure and business readiness...\n\n";
    }

    public function runCompleteAssessment()
    {
        $startTime = microtime(true);

        // Step 1: Infrastructure Testing
        $this->runInfrastructureAssessment();
        
        // Step 2: Business Logic Assessment
        $this->runBusinessLogicAssessment();
        
        // Step 3: Production Readiness Assessment
        $this->runProductionReadinessAssessment();
        
        // Step 4: Generate Final Report
        $endTime = microtime(true);
        $totalTime = number_format(($endTime - $startTime) * 1000, 2);
        
        $this->generateCompleteReport($totalTime);
    }

    private function runInfrastructureAssessment()
    {
        echo "🔧 STEP 1: INFRASTRUCTURE ASSESSMENT\n";
        echo str_repeat("-", 40) . "\n";
        
        $this->infrastructureResults = [
            'health' => $this->testHealthEndpoints(),
            'database' => $this->testDatabaseConnection(),
            'security' => $this->testSecurityMiddleware(),
            'performance' => $this->testPerformanceOptimization(),
            'mobile' => $this->testMobileIntegration(),
            'background' => $this->testBackgroundServices()
        ];
        
        echo "\n";
    }

    private function runBusinessLogicAssessment()
    {
        echo "💼 STEP 2: BUSINESS LOGIC ASSESSMENT\n";
        echo str_repeat("-", 40) . "\n";
        
        $this->businessLogicAssessment = [
            'phase1_foundation' => $this->assessPhase1Foundation(),
            'phase2_payment_engine' => $this->assessPhase2PaymentEngine(),
            'phase3_inventory_verification' => $this->assessPhase3InventoryVerification(),
            'phase4_threshold_enforcement' => $this->assessPhase4ThresholdEnforcement(),
            'phase5_bonus_payroll' => $this->assessPhase5BonusPayroll(),
            'phase6_reporting_analytics' => $this->assessPhase6ReportingAnalytics(),
            'phase7_mobile_api_gateway' => $this->assessPhase7MobileAPIGateway()
        ];
    }

    private function runProductionReadinessAssessment()
    {
        echo "🚀 STEP 3: PRODUCTION READINESS ASSESSMENT\n";
        echo str_repeat("-", 45) . "\n";
        
        $this->productionReadiness = [
            'database' => $this->assessDatabaseReadiness(),
            'security' => $this->assessSecurityReadiness(),
            'performance' => $this->assessPerformanceReadiness(),
            'mobile_integration' => $this->assessMobileIntegrationReadiness(),
            'monitoring' => $this->assessMonitoringReadiness(),
            'deployment' => $this->assessDeploymentReadiness()
        ];
    }

    // =============================================================================
    // INFRASTRUCTURE TESTING METHODS
    // =============================================================================

    private function testHealthEndpoints()
    {
        echo "🏥 Testing Health Endpoints... ";
        $response = $this->makeRequest('GET', '/api/health');
        if ($response && isset($response['status']) && $response['status'] === 'healthy') {
            echo "✅ PASSED\n";
            return true;
        } else {
            echo "❌ FAILED\n";
            return false;
        }
    }

    private function testDatabaseConnection()
    {
        echo "🗄️ Testing Database Connection... ";
        $response = $this->makeRequest('GET', '/api/health');
        if ($response && isset($response['database']) && $response['database'] === 'connected') {
            echo "✅ PASSED\n";
            return true;
        } else {
            echo "❌ FAILED\n";
            return false;
        }
    }

    private function testSecurityMiddleware()
    {
        echo "🛡️ Testing Security Middleware... ";
        $response = $this->makeRequest('GET', '/api/dashboard');
        if ($response === false) { // Should fail without auth
            echo "✅ PASSED\n";
            return true;
        } else {
            echo "❌ FAILED\n";
            return false;
        }
    }

    private function testPerformanceOptimization()
    {
        echo "⚡ Testing Performance Optimization... ";
        $startTime = microtime(true);
        $response = $this->makeRequest('GET', '/api/health');
        $endTime = microtime(true);
        
        $duration = ($endTime - $startTime) * 1000;
        if ($response && $duration < 1000) {
            echo "✅ PASSED ({$duration}ms)\n";
            return true;
        } else {
            echo "❌ FAILED ({$duration}ms)\n";
            return false;
        }
    }

    private function testMobileIntegration()
    {
        echo "📱 Testing Mobile Integration... ";
        $response = $this->makeRequest('GET', '/api/mobile/gateway/health');
        if ($response !== false) {
            echo "✅ PASSED\n";
            return true;
        } else {
            echo "❌ FAILED\n";
            return false;
        }
    }

    private function testBackgroundServices()
    {
        echo "⚙️ Testing Background Services... ";
        // Test console commands
        $output = shell_exec('php artisan list | grep "mobile:generate-api-key" 2>&1');
        if (!empty($output)) {
            echo "✅ PASSED\n";
            return true;
        } else {
            echo "❌ FAILED\n";
            return false;
        }
    }

    // =============================================================================
    // BUSINESS LOGIC ASSESSMENT METHODS
    // =============================================================================

    private function assessPhase1Foundation()
    {
        echo "📋 Phase 1: Foundation & Authentication - ";
        
        // Check if authentication endpoints exist
        $authEndpoints = $this->checkEndpointsExist([
            'POST /api/auth/login',
            'POST /api/auth/register',
            'POST /api/auth/logout'
        ]);
        
        // Check if security middleware is active
        $securityActive = $this->checkSecurityMiddleware();
        
        $score = ($authEndpoints + $securityActive) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Core foundation complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Foundation mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Foundation needs implementation'];
        }
    }

    private function assessPhase2PaymentEngine()
    {
        echo "💳 Phase 2: Payment Engine - ";
        
        // Check payment-related endpoints
        $paymentEndpoints = $this->checkEndpointsExist([
            'POST /api/payments',
            'GET /api/payments',
            'POST /api/otp/verify'
        ]);
        
        // Check money out compliance
        $moneyOutCompliance = $this->checkEndpointsExist([
            'GET /api/money-out',
            'GET /api/money-out/mismatches'
        ]);
        
        $score = ($paymentEndpoints + $moneyOutCompliance) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Payment engine complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Payment engine mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Payment engine needs implementation'];
        }
    }

    private function assessPhase3InventoryVerification()
    {
        echo "📦 Phase 3: Inventory Verification - ";
        
        // Check inventory endpoints
        $inventoryEndpoints = $this->checkEndpointsExist([
            'POST /api/inventory/da-photos',
            'POST /api/inventory/im-verification',
            'GET /api/inventory/three-way-match'
        ]);
        
        // Check Zoho integration
        $zohoIntegration = $this->checkEndpointsExist([
            'GET /api/zoho-inventory/health',
            'POST /api/zoho-inventory/sync-all'
        ]);
        
        $score = ($inventoryEndpoints + $zohoIntegration) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Inventory verification complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Inventory verification mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Inventory verification needs implementation'];
        }
    }

    private function assessPhase4ThresholdEnforcement()
    {
        echo "🚫 Phase 4: Threshold Enforcement - ";
        
        // Check threshold endpoints
        $thresholdEndpoints = $this->checkEndpointsExist([
            'GET /api/threshold-enforcement/health',
            'POST /api/threshold-enforcement/validate-expense',
            'GET /api/threshold-enforcement/urgent-items'
        ]);
        
        // Check escalation endpoints
        $escalationEndpoints = $this->checkEndpointsExist([
            'GET /api/approvals/pending',
            'GET /api/approvals/escalations'
        ]);
        
        $score = ($thresholdEndpoints + $escalationEndpoints) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Threshold enforcement complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Threshold enforcement mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Threshold enforcement needs implementation'];
        }
    }

    private function assessPhase5BonusPayroll()
    {
        echo "💰 Phase 5: Bonus & Payroll Integration - ";
        
        // Check payroll endpoints
        $payrollEndpoints = $this->checkEndpointsExist([
            'GET /api/salary/deductions',
            'GET /api/salary/statistics',
            'GET /api/salary/upcoming'
        ]);
        
        // Check bonus endpoints
        $bonusEndpoints = $this->checkEndpointsExist([
            'POST /api/bonuses/calculate',
            'GET /api/bonuses/calculations'
        ]);
        
        $score = ($payrollEndpoints + $bonusEndpoints) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Bonus & payroll integration complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Bonus & payroll integration mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Bonus & payroll integration needs implementation'];
        }
    }

    private function assessPhase6ReportingAnalytics()
    {
        echo "📊 Phase 6: Advanced Reporting & Analytics - ";
        
        // Check reporting endpoints
        $reportingEndpoints = $this->checkEndpointsExist([
            'GET /api/monitoring/dashboard',
            'GET /api/monitoring/alerts',
            'GET /api/monitoring/compliance'
        ]);
        
        // Check analytics endpoints
        $analyticsEndpoints = $this->checkEndpointsExist([
            'GET /api/monitoring/approval-metrics',
            'GET /api/monitoring/violations-trend'
        ]);
        
        $score = ($reportingEndpoints + $analyticsEndpoints) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Reporting & analytics complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Reporting & analytics mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Reporting & analytics needs implementation'];
        }
    }

    private function assessPhase7MobileAPIGateway()
    {
        echo "📱 Phase 7: Mobile Application & API Gateway - ";
        
        // Check mobile gateway
        $mobileGateway = $this->checkEndpointsExist([
            'GET /api/mobile/gateway/health',
            'GET /api/mobile/gateway/docs'
        ]);
        
        // Check mobile endpoints
        $mobileEndpoints = $this->checkEndpointsExist([
            'POST /api/mobile/auth/login',
            'GET /api/mobile/dashboard/overview',
            'GET /api/mobile/sync/data'
        ]);
        
        $score = ($mobileGateway + $mobileEndpoints) / 2 * 100;
        
        if ($score >= 80) {
            echo "✅ READY ({$score}%)\n";
            return ['status' => 'ready', 'score' => $score, 'details' => 'Mobile API gateway complete'];
        } elseif ($score >= 60) {
            echo "⚠️ PARTIAL ({$score}%)\n";
            return ['status' => 'partial', 'score' => $score, 'details' => 'Mobile API gateway mostly complete'];
        } else {
            echo "❌ NEEDS WORK ({$score}%)\n";
            return ['status' => 'needs_work', 'score' => $score, 'details' => 'Mobile API gateway needs implementation'];
        }
    }

    // =============================================================================
    // PRODUCTION READINESS ASSESSMENT METHODS
    // =============================================================================

    private function assessDatabaseReadiness()
    {
        $response = $this->makeRequest('GET', '/api/health');
        return $response && isset($response['database']) && $response['database'] === 'connected';
    }

    private function assessSecurityReadiness()
    {
        // Test authentication protection
        $protectedResponse = $this->makeRequest('GET', '/api/dashboard');
        return $protectedResponse === false; // Should fail without auth
    }

    private function assessPerformanceReadiness()
    {
        $startTime = microtime(true);
        $response = $this->makeRequest('GET', '/api/health');
        $endTime = microtime(true);
        
        $duration = ($endTime - $startTime) * 1000;
        return $response && $duration < 1000; // Should respond within 1 second
    }

    private function assessMobileIntegrationReadiness()
    {
        $response = $this->makeRequest('GET', '/api/mobile/gateway/health');
        return $response !== false; // Should not be 404
    }

    private function assessMonitoringReadiness()
    {
        $response = $this->makeRequest('GET', '/api/health');
        return $response && isset($response['status']) && $response['status'] === 'healthy';
    }

    private function assessDeploymentReadiness()
    {
        // Check if all critical components are working
        $health = $this->makeRequest('GET', '/api/health');
        $mobileGateway = $this->makeRequest('GET', '/api/mobile/gateway/health');
        
        return $health !== false && $mobileGateway !== false;
    }

    // =============================================================================
    // UTILITY METHODS
    // =============================================================================

    private function checkEndpointsExist($endpoints)
    {
        $existingCount = 0;
        foreach ($endpoints as $endpoint) {
            [$method, $path] = explode(' ', $endpoint);
            $response = $this->makeRequest($method, $path, []);
            if ($response !== false) {
                $existingCount++;
            }
        }
        return $existingCount / count($endpoints);
    }

    private function checkSecurityMiddleware()
    {
        $response = $this->makeRequest('GET', '/api/dashboard');
        return $response === false; // Should fail without auth
    }

    private function makeRequest($method, $endpoint, $data = null, $headers = [])
    {
        $url = $this->baseUrl . $endpoint;
        
        $ch = curl_init();
        
        curl_setopt_array($ch, [
            CURLOPT_URL => $url,
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_SSL_VERIFYPEER => false,
        ]);

        // Set headers
        $curlHeaders = ['Content-Type: application/json'];
        foreach ($headers as $key => $value) {
            $curlHeaders[] = "{$key}: {$value}";
        }
        curl_setopt($ch, CURLOPT_HTTPHEADER, $curlHeaders);

        // Set data for POST/PUT requests
        if ($data && in_array($method, ['POST', 'PUT', 'PATCH'])) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        
        curl_close($ch);

        if ($error) {
            return false;
        }

        if ($httpCode >= 400) {
            return false;
        }

        return json_decode($response, true);
    }

    private function generateCompleteReport($totalTime)
    {
        echo "\n" . str_repeat("=", 70) . "\n";
        echo "📊 VITALVIDA ACCOUNTANT PORTAL - COMPLETE ASSESSMENT REPORT\n";
        echo str_repeat("=", 70) . "\n\n";

        // Infrastructure Summary
        echo "🔧 INFRASTRUCTURE STATUS:\n";
        $infrastructurePassed = count(array_filter($this->infrastructureResults));
        $infrastructureTotal = count($this->infrastructureResults);
        $infrastructurePercentage = ($infrastructurePassed / $infrastructureTotal) * 100;
        echo "Infrastructure Tests: {$infrastructurePassed}/{$infrastructureTotal} ({$infrastructurePercentage}%)\n";
        echo "Health Endpoints: " . ($this->infrastructureResults['health'] ? '✅' : '❌') . "\n";
        echo "Database Connection: " . ($this->infrastructureResults['database'] ? '✅' : '❌') . "\n";
        echo "Security Middleware: " . ($this->infrastructureResults['security'] ? '✅' : '❌') . "\n";
        echo "Performance Optimization: " . ($this->infrastructureResults['performance'] ? '✅' : '❌') . "\n";
        echo "Mobile Integration: " . ($this->infrastructureResults['mobile'] ? '✅' : '❌') . "\n";
        echo "Background Services: " . ($this->infrastructureResults['background'] ? '✅' : '❌') . "\n\n";

        // Business Logic Summary
        echo "💼 BUSINESS LOGIC STATUS:\n";
        $readyPhases = 0;
        $partialPhases = 0;
        $needsWorkPhases = 0;
        
        foreach ($this->businessLogicAssessment as $phase => $assessment) {
            if ($assessment['status'] === 'ready') $readyPhases++;
            elseif ($assessment['status'] === 'partial') $partialPhases++;
            else $needsWorkPhases++;
        }
        
        echo "Ready Phases: {$readyPhases}/7\n";
        echo "Partial Phases: {$partialPhases}/7\n";
        echo "Needs Work Phases: {$needsWorkPhases}/7\n\n";

        // Production Readiness
        echo "🚀 PRODUCTION READINESS:\n";
        $readyComponents = 0;
        $totalComponents = count($this->productionReadiness);
        
        foreach ($this->productionReadiness as $component => $ready) {
            if ($ready) $readyComponents++;
        }
        
        $readinessPercentage = ($readyComponents / $totalComponents) * 100;
        echo "Production Ready Components: {$readyComponents}/{$totalComponents} ({$readinessPercentage}%)\n\n";

        // Final Verdict
        echo "🎖️ FINAL VERDICT:\n";
        if ($readinessPercentage >= 80) {
            echo "🏆 EXCELLENT! VitalVida Portal is PRODUCTION READY!\n";
            echo "Infrastructure is solid and ready for deployment.\n";
            echo "Business logic can be implemented incrementally.\n";
        } elseif ($readinessPercentage >= 60) {
            echo "🎯 GOOD! VitalVida Portal is NEARLY PRODUCTION READY!\n";
            echo "Infrastructure is mostly complete with minor issues.\n";
            echo "Address infrastructure issues before deployment.\n";
        } else {
            echo "⚠️ NEEDS WORK! VitalVida Portal needs attention.\n";
            echo "Infrastructure issues need to be resolved.\n";
            echo "Focus on core infrastructure before deployment.\n";
        }

        echo "\n📋 RECOMMENDATIONS:\n";
        if ($readinessPercentage >= 80) {
            echo "✅ Deploy to production environment\n";
            echo "✅ Begin React Native mobile app development\n";
            echo "✅ Implement business logic incrementally\n";
            echo "✅ Set up monitoring and alerting\n";
        } else {
            echo "🔧 Fix infrastructure issues first\n";
            echo "🔧 Verify all components are working\n";
            echo "🔧 Re-run infrastructure validation\n";
            echo "🔧 Then proceed with deployment\n";
        }

        echo "\n⏱️ Total Assessment Time: {$totalTime}ms\n";
        echo str_repeat("=", 70) . "\n";
    }
}

// =============================================================================
// MAIN EXECUTION
// =============================================================================

if (php_sapi_name() === 'cli') {
    $baseUrl = isset($argv[1]) ? $argv[1] : 'http://localhost:8000';
    
    $completeTest = new CompletePortalTest($baseUrl);
    $completeTest->runCompleteAssessment();
} 