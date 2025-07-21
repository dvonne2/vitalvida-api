# Zoho Inventory Service Documentation

## Overview

The **Zoho Inventory Service** is a comprehensive solution for synchronizing delivery agent (DA) inventory data from Zoho Inventory as the single source of truth. This service ensures accurate inventory tracking, automated stock monitoring, and seamless integration with the VitalVida system.

## Features

### 🔄 Inventory Synchronization
- **Source of Truth**: Zoho Inventory is the authoritative source for all inventory data
- **Automated Sync**: Scheduled synchronization every 4 hours
- **Manual Sync**: On-demand synchronization for specific DAs or all DAs
- **Real-time Updates**: Local database updated with latest Zoho data

### 📊 Stock Monitoring
- **Low Stock Detection**: Automatic identification of DAs with insufficient inventory
- **Minimum Stock Threshold**: 3:3:3 (Shampoo:Pomade:Conditioner) requirement
- **Stock Alerts**: Daily low stock reports at 8 AM
- **Available Sets Calculation**: Automatic calculation of complete product sets

### 🎯 API Endpoints
- **Health Check**: Service status and operational metrics
- **Sync Operations**: Bulk and individual DA synchronization
- **Inventory Summaries**: Detailed inventory reports for DAs
- **Statistics**: Sync performance and success rates

### 🛠️ Console Commands
- **Flexible CLI**: Multiple command options for different use cases
- **Dry Run Mode**: Preview changes without making modifications
- **Detailed Reporting**: Comprehensive sync results and statistics

## Architecture

### Service Structure
```
ZohoInventoryService
├── syncAllDaInventory()          # Sync all active DAs
├── syncSingleDaInventory()       # Sync specific DA
├── fetchZohoBinData()            # Get data from Zoho API
├── parseZohoInventoryData()      # Parse Zoho response
├── updateLocalBinInventory()     # Update local database
├── getDaInventorySummary()       # Get DA inventory summary
├── getDasWithLowStock()          # Find DAs with low stock
├── forceSyncDaInventory()        # Force sync specific DA
└── getSyncStatistics()           # Get sync performance metrics
```

### Data Flow
1. **Zoho API Call**: Fetch bin data from Zoho Inventory
2. **Data Parsing**: Extract inventory counts by product type
3. **Local Update**: Update bin metadata and Zobin records
4. **Audit Logging**: Log all sync operations
5. **Status Reporting**: Provide real-time sync status

## Installation & Setup

### 1. Service Registration
The service is automatically registered in Laravel's service container and can be injected into controllers and commands.

### 2. Configuration
Ensure these environment variables are set:
```env
ZOHO_CLIENT_ID=your_client_id
ZOHO_CLIENT_SECRET=your_client_secret
ZOHO_REFRESH_TOKEN=your_refresh_token
ZOHO_ORGANIZATION_ID=your_org_id
```

### 3. Database Requirements
- `bins` table with Zoho integration fields
- `zoho_operation_logs` table for audit trails
- `delivery_agents` table with bin relationships

## API Endpoints

### Health Check
```http
GET /api/zoho-inventory/health
```

**Response:**
```json
{
  "success": true,
  "message": "Zoho Inventory Service is healthy",
  "data": {
    "service_status": "operational",
    "last_sync": "2025-07-18T18:00:00Z",
    "active_das": 15,
    "sync_success_rate": 98.5
  }
}
```

### Sync All DA Inventory
```http
POST /api/zoho-inventory/sync-all
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "message": "All DA inventory synced successfully",
  "data": {
    "results": [...],
    "summary": {
      "total": 15,
      "successful": 14,
      "failed": 1
    }
  }
}
```

### Sync Specific DA
```http
POST /api/zoho-inventory/sync-da
Authorization: Bearer {token}
Content-Type: application/json

{
  "da_id": 123
}
```

### Get DA Inventory Summary
```http
GET /api/zoho-inventory/da-summary?da_id=123
Authorization: Bearer {token}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "da_id": 123,
    "da_code": "DA001",
    "bin_name": "BIN-DA001",
    "inventory": {
      "shampoo_count": 15,
      "pomade_count": 12,
      "conditioner_count": 18,
      "total_items": 45
    },
    "available_sets": 12,
    "has_minimum_stock": true,
    "status": "adequate"
  }
}
```

### Get Low Stock DAs
```http
GET /api/zoho-inventory/low-stock
Authorization: Bearer {token}
```

### Get All DA Summaries
```http
GET /api/zoho-inventory/all-summaries
Authorization: Bearer {token}
```

### Get Sync Statistics
```http
GET /api/zoho-inventory/stats
Authorization: Bearer {token}
```

## Console Commands

### Basic Sync
```bash
# Sync all DAs
php artisan zoho:sync-inventory

# Sync specific DA
php artisan zoho:sync-inventory --da-id=123

# Dry run (preview only)
php artisan zoho:sync-inventory --dry-run
```

### Monitoring Commands
```bash
# Check low stock DAs
php artisan zoho:sync-inventory --low-stock

# View sync statistics
php artisan zoho:sync-inventory --stats
```

### Command Options
- `--da-id=ID`: Sync specific DA by ID
- `--low-stock`: Show only DAs with low stock
- `--stats`: Display sync statistics
- `--dry-run`: Preview changes without making them

## Scheduled Tasks

### Automatic Synchronization
```php
// In app/Console/Kernel.php
$schedule->command('zoho:sync-inventory')
    ->everyFourHours()
    ->withoutOverlapping()
    ->runInBackground();
```

### Daily Low Stock Check
```php
$schedule->command('zoho:sync-inventory --low-stock')
    ->dailyAt('08:00')
    ->withoutOverlapping();
```

## Data Models

### Bin Model Integration
The service integrates with the existing `Bin` model:
```php
// Bin metadata structure
{
  "inventory": {
    "shampoo_count": 15,
    "pomade_count": 12,
    "conditioner_count": 18,
    "total_items": 45
  },
  "last_zoho_sync": "2025-07-18T18:00:00Z"
}
```

### Zobin Model Updates
Updates the legacy `Zobin` model for backward compatibility:
```php
// Zobin fields updated
- shampoo_count
- pomade_count  
- conditioner_count
- last_updated
```

## Error Handling

### API Errors
- **401 Unauthorized**: Automatic token refresh
- **404 Not Found**: Graceful handling with error logging
- **500 Server Error**: Retry mechanism with exponential backoff

### Data Validation
- **Missing Bins**: Skip DAs without assigned bins
- **Invalid Responses**: Parse errors logged and handled
- **Network Issues**: Timeout handling and retry logic

## Logging & Monitoring

### Operation Logs
All sync operations are logged in `zoho_operation_logs`:
```php
- operation_type: 'inventory_sync'
- operation_id: 'da_123'
- zoho_endpoint: 'warehouses/bins'
- status: 'success'|'failed'
- response_data: {...}
- completed_at: timestamp
```

### Performance Metrics
- **Sync Success Rate**: Percentage of successful syncs
- **Response Times**: API call performance tracking
- **Error Rates**: Failed sync monitoring
- **Data Accuracy**: Inventory consistency checks

## Security

### Authentication
- **Zoho OAuth**: Secure token-based authentication
- **Token Refresh**: Automatic token renewal
- **API Rate Limits**: Respectful API usage patterns

### Data Protection
- **Encrypted Storage**: Sensitive data encryption
- **Audit Trails**: Complete operation logging
- **Access Control**: Role-based API access

## Testing

### Unit Tests
```bash
# Run service tests
php artisan test --filter=ZohoInventoryService
```

### Integration Tests
```bash
# Test API endpoints
./test-zoho-inventory.sh
```

### Manual Testing
```bash
# Health check
curl http://localhost:8000/api/zoho-inventory/health

# Console command test
php artisan zoho:sync-inventory --dry-run
```

## Troubleshooting

### Common Issues

#### 1. Token Expiration
**Problem**: 401 Unauthorized errors
**Solution**: Check Zoho token configuration
```bash
# Verify token status
php artisan zoho:sync-inventory --stats
```

#### 2. Missing Bins
**Problem**: DAs without assigned bins
**Solution**: Ensure proper bin assignment
```sql
-- Check DA-bin relationships
SELECT da.id, da.da_code, b.name as bin_name 
FROM delivery_agents da 
LEFT JOIN bins b ON b.assigned_to_da = da.da_code;
```

#### 3. Sync Failures
**Problem**: High failure rates
**Solution**: Check logs and network connectivity
```bash
# View recent logs
tail -f storage/logs/laravel.log | grep "Zoho"
```

### Performance Optimization

#### 1. Batch Processing
- Process DAs in batches to avoid timeouts
- Use queue jobs for large sync operations

#### 2. Caching Strategy
- Cache frequently accessed data
- Implement intelligent cache invalidation

#### 3. Database Optimization
- Index frequently queried fields
- Optimize bin-DA relationship queries

## Monitoring & Alerts

### Health Checks
- **Service Status**: Regular health endpoint monitoring
- **Sync Success Rate**: Alert on low success rates
- **Data Freshness**: Monitor last sync timestamps

### Alert Thresholds
- **Low Stock**: Alert when DAs have < 3 sets
- **Sync Failures**: Alert on > 10% failure rate
- **Service Downtime**: Alert on health check failures

## Future Enhancements

### Planned Features
1. **Real-time Webhooks**: Instant inventory updates
2. **Predictive Analytics**: Stock forecasting
3. **Mobile App Integration**: DA mobile inventory access
4. **Advanced Reporting**: Custom inventory reports
5. **Multi-warehouse Support**: Extended warehouse management

### Roadmap
- **Q3 2025**: Webhook integration
- **Q4 2025**: Predictive analytics
- **Q1 2026**: Mobile app integration

## Support

### Documentation
- **API Reference**: Complete endpoint documentation
- **Code Examples**: Implementation samples
- **Best Practices**: Usage guidelines

### Contact
- **Technical Support**: VitalVida Development Team
- **Bug Reports**: GitHub Issues
- **Feature Requests**: Product Management

---

**Version**: 1.0.0  
**Last Updated**: July 18, 2025  
**Maintainer**: VitalVida Development Team 