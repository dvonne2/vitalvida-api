<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class SuperAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Check if superadmin already exists
        if (User::where('email', 'admin@vitalvida.com')->exists()) {
            $this->command->info('Superadmin user already exists!');
            return;
        }

        // Create superadmin user
        User::create([
            'name' => 'Super Admin',
            'email' => 'admin@vitalvida.com',
            'password' => Hash::make('admin123456'),
            'role' => 'superadmin',
            'is_active' => true,
            'email_verified_at' => now(),
            'kyc_status' => 'approved',
        ]);

        $this->command->info('✅ Superadmin user created successfully!');
        $this->command->info('📧 Email: admin@vitalvida.com');
        $this->command->info('🔑 Password: admin123456');
        $this->command->info('');
        $this->command->info('⚠️  IMPORTANT: Change the password after first login!');
    }
} 