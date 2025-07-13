<?php
require_once 'vendor/autoload.php';

$app = require_once 'bootstrap/app.php';
$app->make(Illuminate\Contracts\Console\Kernel::class)->bootstrap();

echo "🔍 Test 3: Testing authentication...\n";

// Test user creation
echo "Creating test user...\n";
$user = App\Models\User::updateOrCreate(
    ['email' => 'test@example.com'],
    [
        'name' => 'Test User',
        'password' => bcrypt('password'),
        'is_active' => true
    ]
);
echo "✅ Test user created/updated\n";

// Test login via API
$loginData = [
    'email' => 'test@example.com',
    'password' => 'password',
    'device_name' => 'hour5_test'
];

$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api/auth/login');
curl_setopt($ch, CURLOPT_POST, 1);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($loginData));
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    'Content-Type: application/json',
    'Accept: application/json'
]);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

echo "Login Response (HTTP $httpCode):\n";
echo $response . "\n";

$data = json_decode($response, true);
if (isset($data['data']['token'])) {
    echo "✅ Authentication successful - Token obtained\n";
    $token = $data['data']['token'];
    
    // Test profile endpoint
    echo "\n🔍 Test 4: Testing profile view...\n";
    $ch = curl_init();
    curl_setopt($ch, CURLOPT_URL, 'http://localhost:8000/api/test/profile');
    curl_setopt($ch, CURLOPT_HTTPHEADER, [
        'Authorization: Bearer ' . $token,
        'Accept: application/json'
    ]);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    
    $profileResponse = curl_exec($ch);
    curl_close($ch);
    
    echo "Profile Response:\n";
    echo $profileResponse . "\n";
    
} else {
    echo "❌ Authentication failed\n";
}
