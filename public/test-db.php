<?php

// Test database connection
try {
    $pdo = new PDO('sqlite:' . __DIR__ . '/../database/database.sqlite');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Test a simple query
    $stmt = $pdo->query('SELECT COUNT(*) as count FROM sqlite_master WHERE type="table"');
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    
    echo json_encode([
        'status' => 'success',
        'database' => 'connected',
        'tables_count' => $result['count'],
        'timestamp' => date('c'),
        'message' => 'Database connection successful'
    ]);
} catch (Exception $e) {
    echo json_encode([
        'status' => 'error',
        'database' => 'failed',
        'error' => $e->getMessage(),
        'timestamp' => date('c'),
        'message' => 'Database connection failed'
    ]);
} 