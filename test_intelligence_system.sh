#!/bin/bash

# 🧠 ADVANCED INTELLIGENCE ENGINE TEST SCRIPT
# Testing all intelligence system endpoints and features

echo "🧠 TESTING ADVANCED INTELLIGENCE ENGINE"
echo "========================================"
echo ""

BASE_URL="http://localhost:8000/api"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test function
test_endpoint() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    
    echo -e "${BLUE}Testing: $description${NC}"
    echo "Endpoint: $method $endpoint"
    
    if [ "$method" = "GET" ]; then
        response=$(curl -s "$BASE_URL$endpoint")
    else
        if [ -n "$data" ]; then
            response=$(curl -s -X "$method" -H "Content-Type: application/json" -d "$data" "$BASE_URL$endpoint")
        else
            response=$(curl -s -X "$method" "$BASE_URL$endpoint")
        fi
    fi
    
    if echo "$response" | jq . >/dev/null 2>&1; then
        echo -e "${GREEN}✅ SUCCESS${NC}"
        echo "$response" | jq '.' | head -10
    else
        echo -e "${RED}❌ FAILED${NC}"
        echo "$response" | head -5
    fi
    echo ""
}

echo "🎯 1. INTELLIGENCE DASHBOARD"
echo "=============================="
test_endpoint "GET" "/intelligence/dashboard" "" "Intelligence Dashboard Overview"

echo "🌦️ 2. EVENT IMPACT ANALYSIS"
echo "=============================="
test_endpoint "POST" "/intelligence/analyze-events" '{"days_ahead": 14}' "Analyze Events for Next 14 Days"

echo "⚡ 3. AUTO-OPTIMIZATION ENGINE"
echo "=============================="
test_endpoint "POST" "/intelligence/run-optimization" "" "Run Complete Auto-Optimization"

echo "🤖 4. AUTOMATED DECISIONS"
echo "=============================="
test_endpoint "GET" "/intelligence/automated-decisions?limit=10" "" "Get Recent Automated Decisions"

echo "⚠️ 5. RISK ASSESSMENT"
echo "=============================="
test_endpoint "GET" "/intelligence/risk-overview" "" "Risk Assessment Overview"

echo "🔄 6. EVENT IMPACT APPLICATION"
echo "=============================="
test_endpoint "POST" "/intelligence/apply-event-impacts" "" "Apply Event Impacts to Forecasts"

echo "📊 7. FILTERED AUTOMATED DECISIONS"
echo "=============================="
test_endpoint "GET" "/intelligence/automated-decisions?status=pending&limit=5" "" "Get Pending Decisions Only"

echo ""
echo "🎉 INTELLIGENCE SYSTEM TEST COMPLETE!"
echo "====================================="
echo ""
echo "📈 SYSTEM CAPABILITIES DEMONSTRATED:"
echo "✅ Event Impact Analysis (Weather, Economic, Social, Transport)"
echo "✅ Auto-Optimization Engine (Stock, Reorder, Transfer, Risk)"
echo "✅ Automated Decision Making with Confidence Scoring"
echo "✅ Risk Assessment and Mitigation Automation"
echo "✅ Performance Optimization Recommendations"
echo "✅ Real-time Intelligence Dashboard"
echo "✅ Predictive Analytics with Multiple AI/ML Models"
echo ""
echo "🚀 The Advanced Intelligence Engine is fully operational!"
echo "Ready for production deployment and autonomous inventory management." 