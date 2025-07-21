<?php

return [
    'postmark' => [
        'token' => env('POSTMARK_TOKEN'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // Phase 2: Payment Engine Services
    'moniepoint' => [
        'webhook_secret' => env('MONIEPOINT_WEBHOOK_SECRET'),
        'api_url' => env('MONIEPOINT_API_URL', 'https://api.moniepoint.com/v1'),
        'api_key' => env('MONIEPOINT_API_KEY'),
        'merchant_id' => env('MONIEPOINT_MERCHANT_ID'),
        'terminal_id' => env('MONIEPOINT_TERMINAL_ID'),
    ],

    'sms' => [
        'provider' => env('SMS_PROVIDER', 'termii'),
        'api_key' => env('SMS_API_KEY'),
        'sender_id' => env('SMS_SENDER_ID', 'VitalVida'),
        'api_url' => env('SMS_API_URL', 'https://api.termii.com/api/sms/send'),
    ],

    'otp' => [
        'expiry_hours' => env('OTP_EXPIRY_HOURS', 24),
        'length' => env('OTP_LENGTH', 6),
        'max_attempts' => env('OTP_MAX_ATTEMPTS', 3),
    ],

    'payment_engine' => [
        'mismatch_penalty' => env('PAYMENT_MISMATCH_PENALTY', 10000),
        'verification_timeout' => env('PAYMENT_VERIFICATION_TIMEOUT', 30),
        'max_retry_attempts' => env('MAX_PAYMENT_RETRY_ATTEMPTS', 3),
    ],

    'zoho' => [
        'client_id' => env('ZOHO_CLIENT_ID'),
        'client_secret' => env('ZOHO_CLIENT_SECRET'),
        'refresh_token' => env('ZOHO_REFRESH_TOKEN'),
        'organization_id' => env('ZOHO_ORGANIZATION_ID'),
        'region' => env('ZOHO_REGION', 'com'),
        'fhg_location_id' => env('ZOHO_FHG_LOCATION_ID'),
        'fhg_location_name' => env('ZOHO_FHG_LOCATION_NAME'),
    ],

    // Webhook URLs for notifications
    'webhooks' => [
        'slack' => env('WEBHOOK_SLACK_URL'),
        'teams' => env('WEBHOOK_TEAMS_URL'),
        'discord' => env('WEBHOOK_DISCORD_URL'),
        'custom' => env('WEBHOOK_CUSTOM_URL'),
    ],

    // Moniepoint Configuration (for our new system)
    'moniepoint' => [
        'terminal_account' => env('MONIEPOINT_TERMINAL_ACCOUNT'),
        'bank_name' => env('MONIEPOINT_BANK_NAME', 'Moniepoint MFB'),
    ],

    // eBulk SMS Configuration
    'ebulk' => [
        'url' => env('EBULK_URL'),
        'username' => env('EBULK_USERNAME'),
        'apikey' => env('EBULK_APIKEY'),
    ],

    // WAMISION WhatsApp Configuration
    'wamision' => [
        'url' => env('WAMISION_URL'),
        'token' => env('WAMISION_TOKEN'),
    ],
];
