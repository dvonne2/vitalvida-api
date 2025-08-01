<?php

namespace Database\Factories;

use App\Models\User;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;

class UserFactory extends Factory
{
    protected $model = User::class;

    public function definition(): array
    {
        return [
            'name' => $this->faker->name(),
            'email' => $this->faker->unique()->safeEmail(),
            'phone' => $this->faker->unique()->numerify('###########'),
            'email_verified_at' => now(),
            'password' => Hash::make('password'),
            'role' => $this->faker->randomElement(['production', 'inventory', 'telesales', 'DA']),
            'avatar' => $this->faker->imageUrl(200, 200, 'people'),
            'is_active' => true,
            'kyc_status' => $this->faker->randomElement(['pending', 'approved']),
            'state' => $this->faker->state(),
            'city' => $this->faker->city(),
            'address' => $this->faker->address(),
            'last_login_at' => $this->faker->dateTimeBetween('-30 days'),
        ];
    }

    public function deliveryAgent()
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'DA',
            'kyc_status' => 'approved',
        ]);
    }

    public function admin()
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'superadmin',
            'kyc_status' => 'approved',
        ]);
    }

    public function inventoryManager()
    {
        return $this->state(fn (array $attributes) => [
            'role' => 'inventory',
            'kyc_status' => 'approved',
        ]);
    }
}
