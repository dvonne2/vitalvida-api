<?php
/**
 * VITALVIDA ACCOUNTANT PORTAL - COMPLETE TEST RUNNER
 * 
 * This script runs the complete test suite for all 7 phases
 * Usage: php run-complete-test.php [base_url]
 */

require_once __DIR__ . '/tests/CompletePortalTestSuite.php';

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Get base URL from command line argument or use default
$baseUrl = isset($argv[1]) ? $argv[1] : 'http://localhost:8000';

echo "🚀 VITALVIDA ACCOUNTANT PORTAL - COMPLETE SYSTEM TESTING\n";
echo "========================================================\n";
echo "Base URL: {$baseUrl}\n";
echo "Date: " . date('Y-m-d H:i:s') . "\n";
echo "PHP Version: " . PHP_VERSION . "\n\n";

// Check if server is running
echo "🔍 Checking server availability...\n";
$ch = curl_init($baseUrl . '/api/health');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_TIMEOUT, 10);
curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode !== 200) {
    echo "❌ Server is not responding at {$baseUrl}\n";
    echo "Please start the Laravel server with: php artisan serve --host=0.0.0.0 --port=8000\n";
    exit(1);
}

echo "✅ Server is responding at {$baseUrl}\n\n";

// Run the complete test suite
$testSuite = new CompletePortalTestSuite($baseUrl);
$success = $testSuite->runCompleteTestSuite();

// Exit with appropriate code
exit($success ? 0 : 1); 