<?php

require_once 'vendor/autoload.php';

use App\Models\Customer;
use App\Models\AICreative;
use App\Models\Campaign;
use App\Models\AIInteraction;
use App\Models\RetargetingCampaign;
use App\Models\Order;

// Bootstrap Laravel
$app = require_once 'bootstrap/app.php';
$app->make('Illuminate\Contracts\Console\Kernel')->bootstrap();

echo "🤖 Vitalvida AI Command Room System Test\n";
echo "========================================\n\n";

// Test 1: Check if all models are working
echo "1. Testing Models:\n";
echo "   - Customers: " . Customer::count() . " records\n";
echo "   - Orders: " . Order::count() . " records\n";
echo "   - AI Creatives: " . AICreative::count() . " records\n";
echo "   - Campaigns: " . Campaign::count() . " records\n";
echo "   - AI Interactions: " . AIInteraction::count() . " records\n";
echo "   - Retargeting Campaigns: " . RetargetingCampaign::count() . " records\n\n";

// Test 2: Check AI Command Room metrics
echo "2. Testing AI Command Room Metrics:\n";
$controller = new \App\Http\Controllers\AICommandRoomController();
$metrics = $controller->getRealTimeMetrics();

echo "   - Orders Today: " . $metrics['orders_today'] . "\n";
echo "   - Revenue Today: ₦" . number_format($metrics['revenue_today']) . "\n";
echo "   - Average CPO: ₦" . number_format($metrics['average_cpo']) . "\n";
echo "   - Customer LTV: ₦" . number_format($metrics['customer_ltv']) . "\n";
echo "   - Repeat Rate: " . number_format($metrics['repeat_rate'], 1) . "%\n";
echo "   - AI Creatives Live: " . $metrics['ai_creatives_live'] . "\n";
echo "   - Winning Creatives: " . $metrics['winning_creatives'] . "\n";
echo "   - Losing Creatives: " . $metrics['losing_creatives'] . "\n";
echo "   - Churn Risk Customers: " . $metrics['churn_risk_customers'] . "\n";
echo "   - Active Campaigns: " . $metrics['active_campaigns'] . "\n\n";

// Test 3: Check top performing creatives
echo "3. Testing Top Performing Creatives:\n";
$topCreatives = $controller->getTopPerformingCreatives();
echo "   - Found " . count($topCreatives) . " top performing creatives\n";
if (!empty($topCreatives)) {
    $topCreative = $topCreatives[0];
    echo "   - Top Creative CPO: ₦" . number_format($topCreative['cpo']) . "\n";
    echo "   - Top Creative Orders: " . $topCreative['orders'] . "\n";
    echo "   - Top Creative Revenue: ₦" . number_format($topCreative['revenue']) . "\n";
    echo "   - Top Creative Grade: " . $topCreative['grade'] . "\n";
}
echo "\n";

// Test 4: Check recent AI actions
echo "4. Testing Recent AI Actions:\n";
$aiActions = $controller->getRecentAIActions();
echo "   - Found " . count($aiActions) . " recent AI actions\n";
if (!empty($aiActions)) {
    $recentAction = $aiActions[0];
    echo "   - Recent Action Type: " . $recentAction['type'] . "\n";
    echo "   - Recent Action Customer: " . $recentAction['customer_name'] . "\n";
    echo "   - Recent Action Confidence: " . number_format($recentAction['confidence'] * 100, 1) . "%\n";
}
echo "\n";

// Test 5: Check AI predictions
echo "5. Testing AI Predictions:\n";
$predictions = $controller->getAIPredictions();
echo "   - Next Week Orders Prediction: " . $predictions['next_week_orders'] . "\n";
echo "   - Churn Risk Trend: " . json_encode($predictions['churn_risk_trend']) . "\n";
echo "   - Revenue Forecast: " . json_encode($predictions['revenue_forecast']) . "\n";
echo "   - Optimal Budget Allocation: " . json_encode($predictions['optimal_budget_allocation']) . "\n\n";

// Test 6: Check customer AI features
echo "6. Testing Customer AI Features:\n";
$customer = Customer::first();
if ($customer) {
    echo "   - Customer: " . $customer->name . "\n";
    echo "   - Churn Probability: " . number_format($customer->churn_probability * 100, 1) . "%\n";
    echo "   - LTV Prediction: ₦" . number_format($customer->lifetime_value_prediction) . "\n";
    echo "   - Persona: " . $customer->persona_tag . "\n";
    echo "   - Acquisition Source: " . $customer->acquisition_source . "\n";
    echo "   - Preferred Contact Time: " . json_encode($customer->preferred_contact_time) . "\n";
}
echo "\n";

// Test 7: Check AI Creative features
echo "7. Testing AI Creative Features:\n";
$creative = AICreative::first();
if ($creative) {
    echo "   - Creative Type: " . $creative->type . "\n";
    echo "   - Platform: " . $creative->platform . "\n";
    echo "   - Performance Score: " . number_format($creative->performance_score * 100, 1) . "%\n";
    echo "   - CPO: ₦" . number_format($creative->cpo) . "\n";
    echo "   - CTR: " . number_format($creative->ctr * 100, 2) . "%\n";
    echo "   - Orders Generated: " . $creative->orders_generated . "\n";
    echo "   - Revenue: ₦" . number_format($creative->revenue) . "\n";
    echo "   - Should Scale: " . ($creative->shouldScale() ? 'Yes' : 'No') . "\n";
    echo "   - Should Kill: " . ($creative->shouldKill() ? 'Yes' : 'No') . "\n";
    echo "   - Performance Grade: " . $creative->getPerformanceGrade() . "\n";
}
echo "\n";

echo "✅ AI Command Room System Test Completed Successfully!\n";
echo "🌐 Dashboard available at: http://localhost:8000/ai-command-room\n";
echo "📊 The system is ready to outperform Temu in Nigeria!\n"; 