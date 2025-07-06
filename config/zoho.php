<?php

return [
    'inventory' => [
        'base_url' => 'https://inventory.zoho.com/api/v1',
        'access_token' => env('ZOHO_ACCESS_TOKEN'),
        'organization_id' => env('ZOHO_ORGANIZATION_ID'),
        'client_id' => env('ZOHO_CLIENT_ID'),
        'client_secret' => env('ZOHO_CLIENT_SECRET'),
        'api_domain' => env('ZOHO_API_DOMAIN', 'https://www.zohoapis.com'),
        'refresh_token' => env('ZOHO_REFRESH_TOKEN'),
    ]
];
