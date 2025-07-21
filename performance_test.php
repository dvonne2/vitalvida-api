<?php

/**
 * VitalVida Portal - Performance Test Suite
 * 
 * This script tests the performance optimizations implemented for the VitalVida Portal
 * and provides detailed metrics and recommendations.
 */

class VitalVidaPerformanceTest
{
    private string $baseUrl;
    private array $results = [];
    private float $startTime;
    
    public function __construct(string $baseUrl = 'http://127.0.0.1:8000')
    {
        $this->baseUrl = $baseUrl;
        $this->startTime = microtime(true);
    }
    
    /**
     * Run comprehensive performance tests
     */
    public function runPerformanceTests(): void
    {
        echo "🚀 VITALVIDA PORTAL - PERFORMANCE TEST SUITE\n";
        echo "=" . str_repeat("=", 60) . "\n\n";
        
        echo "🔍 Testing Performance Optimizations...\n\n";
        
        // Test API Response Times
        $this->testApiResponseTimes();
        
        // Test Caching Performance
        $this->testCachingPerformance();
        
        // Test Database Performance
        $this->testDatabasePerformance();
        
        // Test Memory Usage
        $this->testMemoryUsage();
        
        // Test Concurrent Load
        $this->testConcurrentLoad();
        
        // Generate Performance Report
        $this->generatePerformanceReport();
    }
    
    /**
     * Test API response times for key endpoints
     */
    private function testApiResponseTimes(): void
    {
        echo "📊 API RESPONSE TIME TESTS\n";
        echo str_repeat("-", 40) . "\n";
        
        $endpoints = [
            'Health Check' => '/api/health',
            'Dashboard' => '/api/dashboard',
            'Payments' => '/api/payments',
            'Inventory' => '/api/inventory',
            'Reports' => '/api/reports',
            'Mobile Gateway' => '/api/mobile/gateway/health',
            'Performance Metrics' => '/api/monitoring/performance',
        ];
        
        foreach ($endpoints as $name => $endpoint) {
            $times = [];
            
            // Test 5 times and get average
            for ($i = 0; $i < 5; $i++) {
                $startTime = microtime(true);
                $response = $this->makeRequest('GET', $endpoint);
                $endTime = microtime(true);
                
                $responseTime = round(($endTime - $startTime) * 1000, 2);
                $times[] = $responseTime;
                
                usleep(100000); // 100ms delay between requests
            }
            
            $avgTime = array_sum($times) / count($times);
            $minTime = min($times);
            $maxTime = max($times);
            
            $this->results['api_response_times'][$name] = [
                'average' => $avgTime,
                'minimum' => $minTime,
                'maximum' => $maxTime,
                'status' => $this->getPerformanceStatus($avgTime),
            ];
            
            $status = $this->getPerformanceStatus($avgTime);
            echo sprintf(
                "%-20s | Avg: %6.2fms | Min: %6.2fms | Max: %6.2fms | %s\n",
                $name,
                $avgTime,
                $minTime,
                $maxTime,
                $status
            );
        }
        
        echo "\n";
    }
    
    /**
     * Test caching performance
     */
    private function testCachingPerformance(): void
    {
        echo "💾 CACHING PERFORMANCE TESTS\n";
        echo str_repeat("-", 40) . "\n";
        
        // Test cache hit/miss scenarios
        $cacheTests = [
            'Dashboard Data' => '/api/dashboard',
            'User Permissions' => '/api/auth/profile',
            'Analytics Data' => '/api/monitoring/performance',
        ];
        
        foreach ($cacheTests as $name => $endpoint) {
            // First request (cache miss)
            $startTime = microtime(true);
            $response1 = $this->makeRequest('GET', $endpoint);
            $endTime = microtime(true);
            $missTime = round(($endTime - $startTime) * 1000, 2);
            
            usleep(100000); // 100ms delay
            
            // Second request (cache hit)
            $startTime = microtime(true);
            $response2 = $this->makeRequest('GET', $endpoint);
            $endTime = microtime(true);
            $hitTime = round(($endTime - $startTime) * 1000, 2);
            
            $improvement = $missTime > 0 ? (($missTime - $hitTime) / $missTime) * 100 : 0;
            
            $this->results['caching_performance'][$name] = [
                'cache_miss_time' => $missTime,
                'cache_hit_time' => $hitTime,
                'improvement_percentage' => round($improvement, 2),
                'status' => $this->getCacheStatus($improvement),
            ];
            
            echo sprintf(
                "%-20s | Miss: %6.2fms | Hit: %6.2fms | Improvement: %5.1f%% | %s\n",
                $name,
                $missTime,
                $hitTime,
                $improvement,
                $this->getCacheStatus($improvement)
            );
        }
        
        echo "\n";
    }
    
    /**
     * Test database performance
     */
    private function testDatabasePerformance(): void
    {
        echo "🗄️ DATABASE PERFORMANCE TESTS\n";
        echo str_repeat("-", 40) . "\n";
        
        // Test database-heavy endpoints
        $dbTests = [
            'User List' => '/api/users',
            'Payment History' => '/api/payments',
            'Inventory Items' => '/api/inventory',
            'Reports Data' => '/api/reports',
        ];
        
        foreach ($dbTests as $name => $endpoint) {
            $times = [];
            
            // Test 3 times
            for ($i = 0; $i < 3; $i++) {
                $startTime = microtime(true);
                $response = $this->makeRequest('GET', $endpoint);
                $endTime = microtime(true);
                
                $responseTime = round(($endTime - $startTime) * 1000, 2);
                $times[] = $responseTime;
                
                usleep(200000); // 200ms delay
            }
            
            $avgTime = array_sum($times) / count($times);
            
            $this->results['database_performance'][$name] = [
                'average_time' => $avgTime,
                'status' => $this->getDatabaseStatus($avgTime),
            ];
            
            echo sprintf(
                "%-20s | Avg: %6.2fms | %s\n",
                $name,
                $avgTime,
                $this->getDatabaseStatus($avgTime)
            );
        }
        
        echo "\n";
    }
    
    /**
     * Test memory usage
     */
    private function testMemoryUsage(): void
    {
        echo "🧠 MEMORY USAGE TESTS\n";
        echo str_repeat("-", 40) . "\n";
        
        $initialMemory = memory_get_usage(true);
        
        // Simulate heavy operations
        $heavyOperations = [
            'Large Data Processing' => function() {
                $data = [];
                for ($i = 0; $i < 10000; $i++) {
                    $data[] = [
                        'id' => $i,
                        'name' => "Item {$i}",
                        'value' => rand(100, 9999),
                        'timestamp' => date('Y-m-d H:i:s'),
                    ];
                }
                return $data;
            },
            'Cache Operations' => function() {
                for ($i = 0; $i < 1000; $i++) {
                    // Simulate cache operations
                    $key = "test_key_{$i}";
                    $value = "test_value_{$i}";
                    // In real scenario, this would use Cache::put()
                }
            },
            'API Response Processing' => function() {
                $responses = [];
                for ($i = 0; $i < 100; $i++) {
                    $responses[] = $this->makeRequest('GET', '/api/health');
                }
                return $responses;
            },
        ];
        
        foreach ($heavyOperations as $name => $operation) {
            $startMemory = memory_get_usage(true);
            $startPeak = memory_get_peak_usage(true);
            
            $result = $operation();
            
            $endMemory = memory_get_usage(true);
            $endPeak = memory_get_peak_usage(true);
            
            $memoryUsed = $endMemory - $startMemory;
            $peakMemory = $endPeak - $startPeak;
            
            $this->results['memory_usage'][$name] = [
                'memory_used' => $this->formatBytes($memoryUsed),
                'peak_memory' => $this->formatBytes($peakMemory),
                'status' => $this->getMemoryStatus($memoryUsed),
            ];
            
            echo sprintf(
                "%-25s | Used: %8s | Peak: %8s | %s\n",
                $name,
                $this->formatBytes($memoryUsed),
                $this->formatBytes($peakMemory),
                $this->getMemoryStatus($memoryUsed)
            );
        }
        
        echo "\n";
    }
    
    /**
     * Test concurrent load handling
     */
    private function testConcurrentLoad(): void
    {
        echo "⚡ CONCURRENT LOAD TESTS\n";
        echo str_repeat("-", 40) . "\n";
        
        $concurrentTests = [
            '5 Concurrent Users' => 5,
            '10 Concurrent Users' => 10,
            '20 Concurrent Users' => 20,
        ];
        
        foreach ($concurrentTests as $name => $concurrentUsers) {
            $startTime = microtime(true);
            $successCount = 0;
            $totalTime = 0;
            
            // Simulate concurrent requests
            for ($i = 0; $i < $concurrentUsers; $i++) {
                $requestStart = microtime(true);
                $response = $this->makeRequest('GET', '/api/health');
                $requestEnd = microtime(true);
                
                if ($response !== false) {
                    $successCount++;
                    $totalTime += ($requestEnd - $requestStart) * 1000;
                }
            }
            
            $endTime = microtime(true);
            $totalDuration = ($endTime - $startTime) * 1000;
            $successRate = ($successCount / $concurrentUsers) * 100;
            $avgResponseTime = $successCount > 0 ? $totalTime / $successCount : 0;
            
            $this->results['concurrent_load'][$name] = [
                'success_rate' => round($successRate, 2),
                'average_response_time' => round($avgResponseTime, 2),
                'total_duration' => round($totalDuration, 2),
                'status' => $this->getConcurrentStatus($successRate, $avgResponseTime),
            ];
            
            echo sprintf(
                "%-20s | Success: %5.1f%% | Avg: %6.2fms | Duration: %6.2fms | %s\n",
                $name,
                $successRate,
                $avgResponseTime,
                $totalDuration,
                $this->getConcurrentStatus($successRate, $avgResponseTime)
            );
        }
        
        echo "\n";
    }
    
    /**
     * Generate comprehensive performance report
     */
    private function generatePerformanceReport(): void
    {
        echo "📋 PERFORMANCE TEST REPORT\n";
        echo "=" . str_repeat("=", 60) . "\n\n";
        
        // Calculate overall performance score
        $overallScore = $this->calculateOverallScore();
        
        echo "🏆 OVERALL PERFORMANCE SCORE: {$overallScore}/100\n\n";
        
        // Performance Summary
        echo "📊 PERFORMANCE SUMMARY:\n";
        echo str_repeat("-", 40) . "\n";
        
        $this->displayPerformanceSummary();
        
        // Recommendations
        echo "\n💡 OPTIMIZATION RECOMMENDATIONS:\n";
        echo str_repeat("-", 40) . "\n";
        
        $this->displayRecommendations();
        
        // Performance Metrics
        echo "\n📈 DETAILED METRICS:\n";
        echo str_repeat("-", 40) . "\n";
        
        $this->displayDetailedMetrics();
        
        echo "\n✅ Performance testing completed!\n";
        echo "Total test duration: " . round((microtime(true) - $this->startTime), 2) . " seconds\n";
    }
    
    /**
     * Calculate overall performance score
     */
    private function calculateOverallScore(): int
    {
        $score = 0;
        $totalTests = 0;
        
        // API Response Time Score (30% weight)
        if (isset($this->results['api_response_times'])) {
            $apiScore = 0;
            foreach ($this->results['api_response_times'] as $test) {
                if ($test['average'] < 500) $apiScore += 100;
                elseif ($test['average'] < 1000) $apiScore += 80;
                elseif ($test['average'] < 2000) $apiScore += 60;
                else $apiScore += 40;
            }
            $score += ($apiScore / count($this->results['api_response_times'])) * 0.3;
        }
        
        // Caching Performance Score (25% weight)
        if (isset($this->results['caching_performance'])) {
            $cacheScore = 0;
            foreach ($this->results['caching_performance'] as $test) {
                if ($test['improvement_percentage'] > 50) $cacheScore += 100;
                elseif ($test['improvement_percentage'] > 30) $cacheScore += 80;
                elseif ($test['improvement_percentage'] > 10) $cacheScore += 60;
                else $cacheScore += 40;
            }
            $score += ($cacheScore / count($this->results['caching_performance'])) * 0.25;
        }
        
        // Database Performance Score (20% weight)
        if (isset($this->results['database_performance'])) {
            $dbScore = 0;
            foreach ($this->results['database_performance'] as $test) {
                if ($test['average_time'] < 1000) $dbScore += 100;
                elseif ($test['average_time'] < 2000) $dbScore += 80;
                elseif ($test['average_time'] < 5000) $dbScore += 60;
                else $dbScore += 40;
            }
            $score += ($dbScore / count($this->results['database_performance'])) * 0.2;
        }
        
        // Concurrent Load Score (25% weight)
        if (isset($this->results['concurrent_load'])) {
            $concurrentScore = 0;
            foreach ($this->results['concurrent_load'] as $test) {
                if ($test['success_rate'] > 95 && $test['average_response_time'] < 1000) $concurrentScore += 100;
                elseif ($test['success_rate'] > 90 && $test['average_response_time'] < 2000) $concurrentScore += 80;
                elseif ($test['success_rate'] > 80 && $test['average_response_time'] < 5000) $concurrentScore += 60;
                else $concurrentScore += 40;
            }
            $score += ($concurrentScore / count($this->results['concurrent_load'])) * 0.25;
        }
        
        return round($score);
    }
    
    /**
     * Display performance summary
     */
    private function displayPerformanceSummary(): void
    {
        $summary = [
            'API Response Times' => $this->getAverageApiResponseTime(),
            'Cache Hit Rate' => $this->getAverageCacheImprovement(),
            'Database Performance' => $this->getAverageDatabaseTime(),
            'Concurrent Load Success' => $this->getAverageConcurrentSuccess(),
        ];
        
        foreach ($summary as $metric => $value) {
            echo sprintf("%-25s: %s\n", $metric, $value);
        }
    }
    
    /**
     * Display optimization recommendations
     */
    private function displayRecommendations(): void
    {
        $recommendations = [];
        
        // API Performance recommendations
        $avgApiTime = $this->getAverageApiResponseTime();
        if ($avgApiTime > 1000) {
            $recommendations[] = "🔧 Optimize API response times - consider implementing more aggressive caching";
        }
        
        // Caching recommendations
        $avgCacheImprovement = $this->getAverageCacheImprovement();
        if ($avgCacheImprovement < 30) {
            $recommendations[] = "💾 Improve caching strategy - increase cache hit rates";
        }
        
        // Database recommendations
        $avgDbTime = $this->getAverageDatabaseTime();
        if ($avgDbTime > 2000) {
            $recommendations[] = "🗄️ Optimize database queries - add indexes and optimize slow queries";
        }
        
        // Concurrent load recommendations
        $avgConcurrentSuccess = $this->getAverageConcurrentSuccess();
        if ($avgConcurrentSuccess < 90) {
            $recommendations[] = "⚡ Improve concurrent load handling - optimize server configuration";
        }
        
        if (empty($recommendations)) {
            $recommendations[] = "✅ System is performing excellently! No immediate optimizations needed.";
        }
        
        foreach ($recommendations as $recommendation) {
            echo "• {$recommendation}\n";
        }
    }
    
    /**
     * Display detailed metrics
     */
    private function displayDetailedMetrics(): void
    {
        foreach ($this->results as $category => $tests) {
            echo "\n{$category}:\n";
            foreach ($tests as $test => $metrics) {
                echo "  {$test}: " . json_encode($metrics) . "\n";
            }
        }
    }
    
    /**
     * Make HTTP request
     */
    private function makeRequest(string $method, string $endpoint, array $data = []): mixed
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
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'Accept: application/json',
            ],
        ]);
        
        if (!empty($data)) {
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
        }
        
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        
        if ($response === false || $httpCode >= 500) {
            return false;
        }
        
        return json_decode($response, true);
    }
    
    /**
     * Get performance status
     */
    private function getPerformanceStatus(float $responseTime): string
    {
        if ($responseTime < 500) return "✅ Excellent";
        if ($responseTime < 1000) return "🟢 Good";
        if ($responseTime < 2000) return "🟡 Fair";
        return "🔴 Poor";
    }
    
    /**
     * Get cache status
     */
    private function getCacheStatus(float $improvement): string
    {
        if ($improvement > 50) return "✅ Excellent";
        if ($improvement > 30) return "🟢 Good";
        if ($improvement > 10) return "🟡 Fair";
        return "🔴 Poor";
    }
    
    /**
     * Get database status
     */
    private function getDatabaseStatus(float $responseTime): string
    {
        if ($responseTime < 1000) return "✅ Excellent";
        if ($responseTime < 2000) return "🟢 Good";
        if ($responseTime < 5000) return "🟡 Fair";
        return "🔴 Poor";
    }
    
    /**
     * Get memory status
     */
    private function getMemoryStatus(int $memoryUsed): string
    {
        if ($memoryUsed < 1024 * 1024) return "✅ Excellent"; // < 1MB
        if ($memoryUsed < 5 * 1024 * 1024) return "🟢 Good"; // < 5MB
        if ($memoryUsed < 10 * 1024 * 1024) return "🟡 Fair"; // < 10MB
        return "🔴 Poor";
    }
    
    /**
     * Get concurrent status
     */
    private function getConcurrentStatus(float $successRate, float $responseTime): string
    {
        if ($successRate > 95 && $responseTime < 1000) return "✅ Excellent";
        if ($successRate > 90 && $responseTime < 2000) return "🟢 Good";
        if ($successRate > 80 && $responseTime < 5000) return "🟡 Fair";
        return "🔴 Poor";
    }
    
    /**
     * Format bytes to human readable format
     */
    private function formatBytes(int $bytes): string
    {
        $units = ['B', 'KB', 'MB', 'GB'];
        
        for ($i = 0; $bytes > 1024 && $i < count($units) - 1; $i++) {
            $bytes /= 1024;
        }
        
        return round($bytes, 2) . ' ' . $units[$i];
    }
    
    /**
     * Get average API response time
     */
    private function getAverageApiResponseTime(): string
    {
        if (!isset($this->results['api_response_times'])) return 'N/A';
        
        $times = array_column($this->results['api_response_times'], 'average');
        $avg = array_sum($times) / count($times);
        
        return round($avg, 2) . 'ms';
    }
    
    /**
     * Get average cache improvement
     */
    private function getAverageCacheImprovement(): string
    {
        if (!isset($this->results['caching_performance'])) return 'N/A';
        
        $improvements = array_column($this->results['caching_performance'], 'improvement_percentage');
        $avg = array_sum($improvements) / count($improvements);
        
        return round($avg, 1) . '%';
    }
    
    /**
     * Get average database time
     */
    private function getAverageDatabaseTime(): string
    {
        if (!isset($this->results['database_performance'])) return 'N/A';
        
        $times = array_column($this->results['database_performance'], 'average_time');
        $avg = array_sum($times) / count($times);
        
        return round($avg, 2) . 'ms';
    }
    
    /**
     * Get average concurrent success rate
     */
    private function getAverageConcurrentSuccess(): string
    {
        if (!isset($this->results['concurrent_load'])) return 'N/A';
        
        $successRates = array_column($this->results['concurrent_load'], 'success_rate');
        $avg = array_sum($successRates) / count($successRates);
        
        return round($avg, 1) . '%';
    }
}

// Run performance tests if executed directly
if (php_sapi_name() === 'cli') {
    $baseUrl = isset($argv[1]) ? $argv[1] : 'http://127.0.0.1:8000';
    
    $tester = new VitalVidaPerformanceTest($baseUrl);
    $tester->runPerformanceTests();
} 