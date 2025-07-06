<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class QuickTestSeeder extends Seeder
{
    public function run(): void
    {
        // Use raw DB inserts to avoid model issues
        DB::table('warehouses')->insert([
            'name' => 'Test Warehouse',
            'code' => 'TEST01',
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        DB::table('products')->insert([
            'name' => 'Test Product',
            'sku' => 'TEST-001',
            'price' => 100.00,
            'stock_quantity' => 0,
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        DB::table('users')->insert([
            'name' => 'Delivery Agent',
            'email' => 'agent@test.com',
            'phone' => '1234567890',
            'password' => Hash::make('password123'),
            'role' => 'delivery_agent',
            'is_active' => 1,
            'created_at' => now(),
            'updated_at' => now()
        ]);

        echo "✅ Quick test data inserted!\n";
    }
}
