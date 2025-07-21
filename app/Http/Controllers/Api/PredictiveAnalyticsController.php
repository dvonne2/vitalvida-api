<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\PredictiveAnalyticsService;
use App\Models\PredictiveModel;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\Log;
use Carbon\Carbon;

class PredictiveAnalyticsController extends Controller
{
    protected $predictiveService;

    public function __construct(PredictiveAnalyticsService $predictiveService)
    {
        $this->predictiveService = $predictiveService;
    }

    /**
     * Get cost forecast
     */
    public function getCostForecast(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'forecast_period' => 'required|integer|min:1|max:12',
                'confidence_level' => 'nullable|numeric|min:0.8|max:0.99',
                'include_breakdown' => 'nullable|boolean'
            ]);

            $cacheKey = 'cost_forecast_' . $data['forecast_period'] . '_' . ($data['confidence_level'] ?? 0.95);
            
            $forecast = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->generateCostForecast(
                    $data['forecast_period'],
                    $data['confidence_level'] ?? 0.95,
                    $data['include_breakdown'] ?? false
                );
            });

            return response()->json([
                'success' => true,
                'data' => $forecast
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to generate cost forecast: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate cost forecast',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get demand forecast
     */
    public function getDemandForecast(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'forecast_period' => 'required|integer|min:1|max:12',
                'product_category' => 'nullable|string',
                'geographic_region' => 'nullable|string',
                'include_seasonality' => 'nullable|boolean'
            ]);

            $cacheKey = 'demand_forecast_' . $data['forecast_period'] . '_' . ($data['product_category'] ?? 'all');
            
            $forecast = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->generateDemandForecast(
                    $data['forecast_period'],
                    $data['product_category'] ?? null,
                    $data['geographic_region'] ?? null,
                    $data['include_seasonality'] ?? true
                );
            });

            return response()->json([
                'success' => true,
                'data' => $forecast
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to generate demand forecast: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate demand forecast',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get employee performance forecast
     */
    public function getPerformanceForecast(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'forecast_period' => 'required|integer|min:1|max:6',
                'employee_id' => 'nullable|integer|exists:users,id',
                'department' => 'nullable|string',
                'include_risk_factors' => 'nullable|boolean'
            ]);

            $cacheKey = 'performance_forecast_' . $data['forecast_period'] . '_' . ($data['employee_id'] ?? 'all');
            
            $forecast = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->generateEmployeePerformanceForecast(
                    $data['forecast_period'],
                    $data['employee_id'] ?? null,
                    $data['department'] ?? null,
                    $data['include_risk_factors'] ?? true
                );
            });

            return response()->json([
                'success' => true,
                'data' => $forecast
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to generate performance forecast: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate performance forecast',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get risk assessment
     */
    public function getRiskAssessment(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'assessment_type' => 'required|string|in:financial,operational,compliance,market',
                'time_horizon' => 'required|integer|min:1|max:12',
                'include_mitigation' => 'nullable|boolean'
            ]);

            $cacheKey = 'risk_assessment_' . $data['assessment_type'] . '_' . $data['time_horizon'];
            
            $assessment = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->generateRiskAssessment(
                    $data['assessment_type'],
                    $data['time_horizon'],
                    $data['include_mitigation'] ?? true
                );
            });

            return response()->json([
                'success' => true,
                'data' => $assessment
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to generate risk assessment: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to generate risk assessment',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get trend analysis
     */
    public function getTrendAnalysis(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'metric_type' => 'required|string',
                'analysis_period' => 'required|integer|min:1|max:24',
                'trend_type' => 'nullable|string|in:linear,exponential,seasonal',
                'include_forecast' => 'nullable|boolean'
            ]);

            $cacheKey = 'trend_analysis_' . $data['metric_type'] . '_' . $data['analysis_period'];
            
            $analysis = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->analyzeTrends(
                    $data['metric_type'],
                    $data['analysis_period'],
                    $data['trend_type'] ?? 'linear',
                    $data['include_forecast'] ?? false
                );
            });

            return response()->json([
                'success' => true,
                'data' => $analysis
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to analyze trends: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to analyze trends',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get seasonality analysis
     */
    public function getSeasonalityAnalysis(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'metric_type' => 'required|string',
                'analysis_period' => 'required|integer|min:6|max:48',
                'seasonality_type' => 'nullable|string|in:daily,weekly,monthly,quarterly',
                'include_decomposition' => 'nullable|boolean'
            ]);

            $cacheKey = 'seasonality_analysis_' . $data['metric_type'] . '_' . $data['analysis_period'];
            
            $analysis = Cache::remember($cacheKey, 3600, function () use ($data) {
                return $this->predictiveService->analyzeSeasonality(
                    $data['metric_type'],
                    $data['analysis_period'],
                    $data['seasonality_type'] ?? 'monthly',
                    $data['include_decomposition'] ?? true
                );
            });

            return response()->json([
                'success' => true,
                'data' => $analysis
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to analyze seasonality: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to analyze seasonality',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get model performance metrics
     */
    public function getModelPerformance(Request $request): JsonResponse
    {
        try {
            $query = PredictiveModel::query();

            if ($request->model_type) {
                $query->where('model_type', $request->model_type);
            }

            if ($request->status) {
                $query->where('status', $request->status);
            }

            $models = $query->with('performanceMetrics')
                ->orderBy('created_at', 'desc')
                ->paginate($request->per_page ?? 20);

            return response()->json([
                'success' => true,
                'data' => $models
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to retrieve model performance: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrieve model performance',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    /**
     * Retrain predictive models
     */
    public function retrainModels(Request $request): JsonResponse
    {
        try {
            $data = $request->validate([
                'model_types' => 'nullable|array',
                'force_retrain' => 'nullable|boolean',
                'include_validation' => 'nullable|boolean'
            ]);

            $result = $this->predictiveService->retrainModels(
                $data['model_types'] ?? null,
                $data['force_retrain'] ?? false,
                $data['include_validation'] ?? true
            );

            return response()->json([
                'success' => true,
                'message' => 'Models retraining initiated successfully',
                'data' => $result
            ]);
        } catch (\Exception $e) {
            Log::error('Failed to retrain models: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Failed to retrain models',
                'error' => $e->getMessage()
            ], 500);
        }
    }
} 