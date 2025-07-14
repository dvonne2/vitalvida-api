<?php
echo json_encode([
    'status' => 'PHP is working',
    'timestamp' => date('Y-m-d H:i:s'),
    'APP_KEY' => $_ENV['APP_KEY'] ?? 'NOT SET',
    'env_vars' => array_keys($_ENV)
]);
?>
