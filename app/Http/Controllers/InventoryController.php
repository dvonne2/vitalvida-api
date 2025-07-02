<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;
use Exception;

class InventoryController extends Controller
{
    public function items()
    {
        return response()->json([
            "success" => true,
            "data" => [
                ["id" => 1, "name" => "Sample Product A", "sku" => "PROD001", "stock" => 50],
                ["id" => 2, "name" => "Sample Product B", "sku" => "PROD002", "stock" => 25],
                ["id" => 3, "name" => "Sample Product C", "sku" => "PROD003", "stock" => 100]
            ],
            "message" => "Products retrieved successfully"
        ]);
    }

    public function overview()
    {
        return response()->json([
            "success" => true,
            "data" => [
                "total_products" => 150,
                "low_stock_count" => 5,
                "out_of_stock_count" => 2,
                "total_value" => 45000
            ]
        ]);
    }

    public function binStock($binId)
    {
        return response()->json([
            "success" => true,
            "data" => [
                "bin_id" => $binId,
                "products" => [
                    ["product_id" => 1, "quantity" => 25],
                    ["product_id" => 2, "quantity" => 15]
                ]
            ]
        ]);
    }

    public function transfer(Request $request)
    {
        return response()->json([
            "success" => true,
            "message" => "Transfer completed successfully"
        ]);
    }

    public function createPackage(Request $request)
    {
        return response()->json([
            "success" => true,
            "message" => "Package created successfully"
        ]);
    }
}
