namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\Http;

class DiscoverZohoWarehouses extends Command
{
    protected $signature = 'app:discover-zoho-warehouses';
    protected $description = 'Fetches all warehouses from Zoho Inventory';

    public function handle()
    {
        $token = config('services.zoho.access_token');
        $orgId = config('services.zoho.organization_id');

        $response = Http::withHeaders([
            'Authorization' => "Zoho-oauthtoken {$token}"
        ])->get("https://inventory.zohoapis.com/inventory/v1/warehouses", [
            'organization_id' => $orgId
        ]);

        if ($response->successful()) {
            $warehouses = $response->json()['warehouses'];
            foreach ($warehouses as $warehouse) {
                $this->info("📦 {$warehouse['warehouse_name']} — ID: {$warehouse['warehouse_id']}");
            }
        } else {
            $this->error("❌ Failed to fetch warehouses: " . $response->body());
        }
    }
}


