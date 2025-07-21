# 🤖 Vitalvida AI Command Room

A comprehensive AI-powered marketing command room designed to outperform Temu by 100,000,000% in the Nigerian market. This system provides real-time analytics, AI-powered creative generation, omnichannel retargeting, and automated customer lifecycle management.

## 🚀 Features

### Core AI Capabilities
- **Real-time Dashboard**: Live metrics, performance tracking, and AI predictions
- **AI Content Generation**: Claude/GPT-powered ad copy, video scripts, and messaging
- **Omnichannel Retargeting**: Automated campaigns across 15+ platforms
- **Predictive Analytics**: Churn prediction, LTV forecasting, and next purchase dates
- **Performance Optimization**: Auto-scaling winners, killing losers, budget optimization

### Platform Integrations
- **Meta Ads** (Facebook/Instagram)
- **TikTok Ads**
- **Google Ads**
- **YouTube Ads**
- **WhatsApp Business**
- **SMS (Termii)**
- **Email (Zoho Campaigns)**

### Customer Lifecycle Management
- **Abandoned Cart Recovery**: Multi-platform sequence
- **Reorder Reminders**: AI-timed reorder campaigns
- **Churn Prevention**: High-risk customer intervention
- **Viral Amplification**: Referral and social sharing campaigns

## 📊 Performance Targets

- **5,000+ orders per day**
- **CPO under ₦1,200**
- **80% repeat purchase rate**
- **Real-time decision making (sub-second)**
- **99.9% uptime**

## 🛠️ Installation & Setup

### 1. Prerequisites
```bash
# PHP 8.1+ and Composer
php -v
composer -V

# Node.js and npm
node -v
npm -v

# Redis (for queues)
redis-server --version
```

### 2. Clone and Install Dependencies
```bash
# Clone the repository
git clone <repository-url>
cd vitalvida-api

# Install PHP dependencies
composer install

# Install Node.js dependencies
npm install
npm run build
```

### 3. Environment Configuration
```bash
# Copy environment file
cp .env.example .env

# Generate application key
php artisan key:generate
```

### 4. Configure Environment Variables
Add the following to your `.env` file:

```env
# AI Services
OPENAI_API_KEY=your_openai_key
CLAUDE_API_KEY=your_anthropic_key
GEMINI_API_KEY=your_google_key

# Social Media APIs
META_ACCESS_TOKEN=your_meta_token
META_APP_ID=your_meta_app_id
META_APP_SECRET=your_meta_app_secret
META_PIXEL_ID=your_meta_pixel_id
META_AD_ACCOUNT_ID=your_meta_ad_account_id

TIKTOK_ACCESS_TOKEN=your_tiktok_token
TIKTOK_APP_ID=your_tiktok_app_id
TIKTOK_APP_SECRET=your_tiktok_app_secret
TIKTOK_ADVERTISER_ID=your_tiktok_advertiser_id

GOOGLE_ADS_DEVELOPER_TOKEN=your_google_ads_token
GOOGLE_ADS_CLIENT_ID=your_google_ads_client_id
GOOGLE_ADS_CLIENT_SECRET=your_google_ads_client_secret
GOOGLE_ADS_REFRESH_TOKEN=your_google_ads_refresh_token
GOOGLE_ADS_CUSTOMER_ID=your_google_ads_customer_id

# Messaging Services
WHATSAPP_TOKEN=your_whatsapp_business_token
WHATSAPP_PHONE_NUMBER_ID=your_whatsapp_phone_number_id
WHATSAPP_WEBHOOK_VERIFY_TOKEN=your_whatsapp_webhook_token
WHATSAPP_BUSINESS_ACCOUNT_ID=your_whatsapp_business_account_id

TERMII_API_KEY=your_termii_key
TERMII_SENDER_ID=Vitalvida

# Email Marketing
ZOHO_CLIENT_ID=your_zoho_client_id
ZOHO_CLIENT_SECRET=your_zoho_client_secret
ZOHO_REFRESH_TOKEN=your_zoho_refresh_token

# Creative Tools
MIDJOURNEY_API_KEY=your_midjourney_key
RUNWAY_API_KEY=your_runway_key
CANVA_API_KEY=your_canva_key

# Analytics & Attribution
MADGICX_API_KEY=your_madgicx_key
HYROS_API_KEY=your_hyros_key

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=vitalvida_ai
DB_USERNAME=your_db_username
DB_PASSWORD=your_db_password

# Queue Configuration
QUEUE_CONNECTION=redis
REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379
```

### 5. Database Setup
```bash
# Run migrations
php artisan migrate

# Seed the database with sample data
php artisan db:seed --class=AICommandRoomSeeder
```

### 6. Queue Setup
```bash
# Start the queue worker
php artisan queue:work --queue=high,default,low

# For production, use Supervisor
sudo apt-get install supervisor
sudo systemctl enable supervisor
sudo systemctl start supervisor
```

### 7. Start the Application
```bash
# Development server
php artisan serve

# Or use Laravel Sail (Docker)
./vendor/bin/sail up
```

## 🎯 Usage

### Accessing the AI Command Room
Navigate to: `http://your-domain/ai-command-room`

### Key Features

#### 1. Real-Time Dashboard
- Live order tracking
- Cost per order monitoring
- Customer LTV analysis
- AI creative performance

#### 2. AI Control Panel
- **Generate 50 Creatives**: AI-powered ad copy generation
- **Scale Winners 5x**: Automatically scale high-performing campaigns
- **Kill Underperformers**: Pause low-performing campaigns
- **Reorder Blast**: Trigger reorder sequences for 10k customers
- **Optimize Budgets**: AI-powered budget allocation
- **Churn Prevention**: Launch retention campaigns

#### 3. AI Actions Feed
Real-time feed of all AI-powered actions:
- Creative generation
- Retargeting campaigns
- Churn prevention
- Performance optimizations

## 📈 API Endpoints

### AI Command Room API
```bash
# Get real-time metrics
GET /ai-command-room/metrics

# Trigger AI action
POST /ai-command-room/trigger-action
{
    "action": "generate_creatives",
    "parameters": {
        "audience": "Nigerian women 25-45",
        "platform": "meta",
        "pain_point": "thin edges"
    }
}

# Get top performing creatives
GET /ai-command-room/creatives/top

# Get recent AI actions
GET /ai-command-room/ai-actions/recent
```

### Automation Triggers
```bash
# Cart abandonment flow
POST /automation/cart-abandoned

# Reorder reminder
POST /automation/reorder-reminder

# Churn prevention
POST /automation/churn-prevention

# Viral amplification
POST /automation/viral-amplification
```

## 🔧 Configuration

### AI Services Configuration
Edit `config/ai-services.php` to customize:
- Performance targets
- AI optimization thresholds
- Platform priorities
- Customer segmentation rules

### Performance Targets
```php
'performance_targets' => [
    'target_cpo' => 1200,        // ₦1,200 target cost per order
    'target_ctr' => 0.015,       // 1.5% target click-through rate
    'target_roi' => 200,         // 200% target ROI
    'target_repeat_rate' => 80,  // 80% target repeat purchase rate
    'daily_orders_target' => 5000, // 5,000 orders per day target
],
```

## 📊 Monitoring & Analytics

### Key Metrics Tracked
- **Orders Today**: Real-time order count vs target
- **Cost Per Order**: Average CPO across all platforms
- **Customer LTV**: Predicted lifetime value
- **Repeat Rate**: Percentage of repeat customers
- **AI Creatives Live**: Active AI-generated campaigns
- **Churn Risk**: High-risk customers count

### Performance Grades
- **A+**: CPO ≤ ₦1,000, CTR ≥ 2.0%
- **A**: CPO ≤ ₦1,200, CTR ≥ 1.5%
- **B**: CPO ≤ ₦1,500, CTR ≥ 1.0%
- **C**: CPO ≤ ₦2,000, CTR ≥ 0.8%
- **D**: Below C grade

## 🚀 Deployment

### Production Deployment
```bash
# Optimize for production
composer install --optimize-autoloader --no-dev
npm run build

# Cache configuration
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set up queue workers
php artisan queue:work --daemon --queue=high,default,low

# Set up cron jobs
* * * * * cd /path-to-your-project && php artisan schedule:run >> /dev/null 2>&1
```

### Docker Deployment
```bash
# Build and run with Docker
docker-compose up -d

# Or use Laravel Sail
./vendor/bin/sail up -d
```

## 🔒 Security

### API Security
- Rate limiting on all endpoints
- CSRF protection for web routes
- API key authentication for external integrations
- Input validation and sanitization

### Data Protection
- Encrypted API keys and sensitive data
- GDPR-compliant data handling
- Secure customer data storage
- Audit logging for all AI actions

## 🧪 Testing

### Run Tests
```bash
# Run all tests
php artisan test

# Run specific test suite
php artisan test --filter=AICommandRoomTest

# Run with coverage
php artisan test --coverage
```

### Manual Testing
```bash
# Test AI content generation
php artisan tinker
>>> app(\App\Services\AIContentGenerator::class)->generateAdCopy(['audience' => 'Nigerian women 25-45'])

# Test retargeting service
>>> app(\App\Services\OmnichannelRetargeting::class)->triggerAbandonedCartSequence($customer, [])
```

## 📝 Troubleshooting

### Common Issues

#### 1. Queue Jobs Not Processing
```bash
# Check queue status
php artisan queue:work --verbose

# Clear failed jobs
php artisan queue:flush

# Restart queue workers
php artisan queue:restart
```

#### 2. AI API Errors
- Verify API keys in `.env`
- Check API rate limits
- Ensure proper network connectivity
- Review error logs in `storage/logs/laravel.log`

#### 3. Database Performance
```bash
# Optimize database
php artisan migrate:status
php artisan db:monitor

# Check slow queries
php artisan db:show-slow-queries
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests
5. Submit a pull request

## 📄 License

This project is proprietary software for Vitalvida. All rights reserved.

## 🆘 Support

For support and questions:
- Email: support@vitalvida.com
- Documentation: [Internal Wiki]
- Issues: [GitHub Issues]

---

**🚀 Ready to dominate the Nigerian e-commerce market with AI-powered precision!** 