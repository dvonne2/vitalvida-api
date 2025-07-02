<?php

namespace Database\Seeders;

use App\Models\User;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // Create superadmin user
        $this->call([
            SuperAdminSeeder::class,
        ]);

        // Create some test users for different roles (optional)
        User::factory()->create([
            'name' => 'CEO User',
            'email' => 'ceo@vitalvida.com',
            'role' => 'ceo',
            'is_active' => true,
            'email_verified_at' => now(),
            'kyc_status' => 'approved',
        ]);

        User::factory()->create([
            'name' => 'Production Manager',
            'email' => 'production@vitalvida.com',
            'role' => 'production',
            'is_active' => true,
            'email_verified_at' => now(),
            'kyc_status' => 'approved',
        ]);

        User::factory()->create([
            'name' => 'Telesales Agent',
            'email' => 'telesales@vitalvida.com',
            'role' => 'telesales',
            'is_active' => true,
            'email_verified_at' => now(),
            'kyc_status' => 'approved',
        ]);
    }
}
