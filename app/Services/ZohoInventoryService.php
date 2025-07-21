<?php

namespace App\Services;

use App\Models\DeliveryAgent;
use App\Models\Bin;
use App\Models\Product;
use App\Models\ZohoOperationLog;
use GuzzleHttp\Client;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;
use Exception;

class ZohoInventoryService
{
    protected $client;
    protected $organizationId;
    protected $zohoService;

    public function __construct(ZohoService $zohoService)
    {
        $this->zohoService = $zohoService;
        $this->organizationId = config('services.zoho.organization_id');
        
        // Initialize HTTP client with base configuration
        $this->client = new Client([
            'base_uri' => 'https://www.zohoapis.com/inventory/v1/',
            'timeout' => 30,
            'verify' => true,
        ]);
    }

    /**
     * Sync all DA inventory from Zoho (source of truth)
     */
    public function syncAllDaInventory(): array
    {
        try {
            $deliveryAgents = DeliveryAgent::where('status', 'active')->get();
            $syncResults = [];

            foreach ($deliveryAgents as $da) {
                $result = $this->syncSingleDaInventory($da);
                $syncResults[] = [
                    'da_id' => $da->id,
                    'da_code' => $da->da_code,
                    'bin_name' => $da->zobin->name ?? 'N/A',
                    'success' => $result['success'],
                    'data' => $result['data'] ?? null,
                    'error' => $result['error'] ?? null
                ];
            }

            Log::info('Zoho inventory sync completed', [
                'total_das' => $deliveryAgents->count(),
                'successful_syncs' => collect($syncResults)->where('success', true)->count(),
                'failed_syncs' => collect($syncResults)->where('success', false)->count()
            ]);

            return [
                'success' => true,
                'results' => $syncResults,
                'summary' => [
                    'total' => $deliveryAgents->count(),
                    'successful' => collect($syncResults)->where('success', true)->count(),
                    'failed' => collect($syncResults)->where('success', false)->count()
                ]
            ];

        } catch (Exception $e) {
            Log::error('Zoho inventory sync failed', [
                'error' => $e->getMessage(),
                'trace' => $e->getTraceAsString()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Sync inventory for a single DA (ZOBIN data)
     */
    public function syncSingleDaInventory(DeliveryAgent $deliveryAgent): array
    {
        try {
            // Get DA's bin (ZOBIN)
            $bin = $deliveryAgent->zobin;
            
            if (!$bin) {
                return [
                    'success' => false,
                    'error' => 'No bin assigned to delivery agent'
                ];
            }

            // Get ZOBIN data from Zoho
            $zohoBinData = $this->fetchZohoBinData($bin);

            if (!$zohoBinData['success']) {
                return [
                    'success' => false,
                    'error' => $zohoBinData['error']
                ];
            }

            // Parse inventory counts from Zoho response
            $inventoryCounts = $this->parseZohoInventoryData($zohoBinData['data']);

            // Update local bin data with Zoho data (source of truth)
            $this->updateLocalBinInventory($bin, $inventoryCounts);

            // Log the sync operation
            $this->logInventorySync($deliveryAgent, $inventoryCounts);

            return [
                'success' => true,
                'data' => [
                    'bin_id' => $bin->id,
                    'bin_name' => $bin->name,
                    'inventory_counts' => $inventoryCounts,
                    'synced_at' => now()
                ]
            ];

        } catch (Exception $e) {
            Log::error('Single DA inventory sync failed', [
                'da_id' => $deliveryAgent->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Fetch bin data from Zoho Inventory API
     */
    protected function fetchZohoBinData(Bin $bin): array
    {
        try {
            // Get access token from ZohoService
            $accessToken = $this->zohoService->getAccessToken();
            
            if (!$accessToken) {
                throw new Exception('Unable to get Zoho access token');
            }

            // Build request URL for bin inventory
            $url = "warehouses/{$bin->zoho_warehouse_id}/bins/{$bin->zoho_bin_id}";
            
            $response = $this->client->get($url, [
                'headers' => [
                    'Authorization' => 'Zoho-oauthtoken ' . $accessToken,
                    'Content-Type' => 'application/json',
                ],
                'query' => [
                    'organization_id' => $this->organizationId,
                    'include_items' => 'true'
                ]
            ]);

            if ($response->getStatusCode() !== 200) {
                throw new Exception('Zoho API returned status: ' . $response->getStatusCode());
            }

            $data = json_decode($response->getBody()->getContents(), true);

            return [
                'success' => true,
                'data' => $data
            ];

        } catch (Exception $e) {
            Log::error('Failed to fetch Zoho bin data', [
                'bin_id' => $bin->id,
                'error' => $e->getMessage()
            ]);

            return [
                'success' => false,
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Parse Zoho inventory data into standard format
     */
    protected function parseZohoInventoryData(array $zohoData): array
    {
        $inventoryCounts = [
            'shampoo_count' => 0,
            'pomade_count' => 0,
            'conditioner_count' => 0,
            'total_items' => 0
        ];

        // Parse bin items from Zoho response
        if (isset($zohoData['bin']['items']) && is_array($zohoData['bin']['items'])) {
            foreach ($zohoData['bin']['items'] as $item) {
                $itemName = strtolower($item['item_name'] ?? '');
                $quantity = intval($item['quantity_on_hand'] ?? 0);

                // Map Zoho item names to our product categories
                if (strpos($itemName, 'shampoo') !== false) {
                    $inventoryCounts['shampoo_count'] += $quantity;
                } elseif (strpos($itemName, 'pomade') !== false) {
                    $inventoryCounts['pomade_count'] += $quantity;
                } elseif (strpos($itemName, 'conditioner') !== false) {
                    $inventoryCounts['conditioner_count'] += $quantity;
                }

                $inventoryCounts['total_items'] += $quantity;
            }
        }

        return $inventoryCounts;
    }

    /**
     * Update local bin inventory with Zoho data (source of truth)
     */
    protected function updateLocalBinInventory(Bin $bin, array $inventoryCounts): void
    {
        DB::beginTransaction();

        try {
            // Update bin metadata with inventory counts
            $metadata = $bin->metadata ?? [];
            $metadata['inventory'] = $inventoryCounts;
            $metadata['last_zoho_sync'] = now()->toISOString();

            $bin->update([
                'metadata' => $metadata
            ]);

            // Update related Zobin model if exists
            if ($bin->deliveryAgent && $bin->deliveryAgent->zobin) {
                $zobin = $bin->deliveryAgent->zobin;
                $zobin->update([
                    'shampoo_count' => $inventoryCounts['shampoo_count'],
                    'pomade_count' => $inventoryCounts['pomade_count'],
                    'conditioner_count' => $inventoryCounts['conditioner_count'],
                    'last_updated' => now()
                ]);
            }

            DB::commit();

        } catch (Exception $e) {
            DB::rollBack();
            throw $e;
        }
    }

    /**
     * Log inventory sync operation
     */
    protected function logInventorySync(DeliveryAgent $deliveryAgent, array $inventoryCounts): void
    {
        ZohoOperationLog::create([
            'operation_type' => 'inventory_sync',
            'operation_id' => 'da_' . $deliveryAgent->id,
            'zoho_endpoint' => 'warehouses/bins',
            'http_method' => 'GET',
            'request_payload' => [
                'da_id' => $deliveryAgent->id,
                'bin_id' => $deliveryAgent->zobin->id ?? null
            ],
            'response_data' => $inventoryCounts,
            'response_status_code' => 200,
            'status' => 'success',
            'completed_at' => now(),
            'metadata' => [
                'sync_type' => 'single_da',
                'da_code' => $deliveryAgent->da_code
            ]
        ]);
    }

    /**
     * Get DA inventory summary
     */
    public function getDaInventorySummary(DeliveryAgent $deliveryAgent): array
    {
        $bin = $deliveryAgent->zobin;
        
        if (!$bin) {
            return [
                'success' => false,
                'error' => 'No bin assigned to delivery agent'
            ];
        }

        $metadata = $bin->metadata ?? [];
        $inventory = $metadata['inventory'] ?? [
            'shampoo_count' => 0,
            'pomade_count' => 0,
            'conditioner_count' => 0,
            'total_items' => 0
        ];

        $availableSets = min(
            $inventory['shampoo_count'],
            $inventory['pomade_count'],
            $inventory['conditioner_count']
        );

        return [
            'success' => true,
            'data' => [
                'da_id' => $deliveryAgent->id,
                'da_code' => $deliveryAgent->da_code,
                'bin_name' => $bin->name,
                'inventory' => $inventory,
                'available_sets' => $availableSets,
                'has_minimum_stock' => $availableSets >= 3,
                'last_sync' => $metadata['last_zoho_sync'] ?? null,
                'status' => $availableSets >= 3 ? 'adequate' : 'low_stock'
            ]
        ];
    }

    /**
     * Get all DAs with low stock
     */
    public function getDasWithLowStock(): array
    {
        $deliveryAgents = DeliveryAgent::where('status', 'active')->get();
        $lowStockDas = [];

        foreach ($deliveryAgents as $da) {
            $summary = $this->getDaInventorySummary($da);
            
            if ($summary['success'] && !$summary['data']['has_minimum_stock']) {
                $lowStockDas[] = $summary['data'];
            }
        }

        return [
            'success' => true,
            'data' => $lowStockDas,
            'count' => count($lowStockDas)
        ];
    }

    /**
     * Force sync specific DA inventory
     */
    public function forceSyncDaInventory(int $deliveryAgentId): array
    {
        $deliveryAgent = DeliveryAgent::find($deliveryAgentId);
        
        if (!$deliveryAgent) {
            return [
                'success' => false,
                'error' => 'Delivery agent not found'
            ];
        }

        return $this->syncSingleDaInventory($deliveryAgent);
    }

    /**
     * Get sync statistics
     */
    public function getSyncStatistics(): array
    {
        $recentSyncs = ZohoOperationLog::where('operation_type', 'inventory_sync')
            ->where('created_at', '>=', now()->subHours(24))
            ->get();

        $totalSyncs = $recentSyncs->count();
        $successfulSyncs = $recentSyncs->where('status', 'success')->count();
        $failedSyncs = $recentSyncs->where('status', 'failed')->count();

        return [
            'success' => true,
            'data' => [
                'last_24_hours' => [
                    'total_syncs' => $totalSyncs,
                    'successful_syncs' => $successfulSyncs,
                    'failed_syncs' => $failedSyncs,
                    'success_rate' => $totalSyncs > 0 ? round(($successfulSyncs / $totalSyncs) * 100, 2) : 0
                ],
                'last_sync' => $recentSyncs->sortByDesc('created_at')->first()?->created_at,
                'active_das' => DeliveryAgent::where('status', 'active')->count()
            ]
        ];
    }
}

