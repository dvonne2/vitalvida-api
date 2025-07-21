CREATE TABLE IF NOT EXISTS "migrations"(
  "id" integer primary key autoincrement not null,
  "migration" varchar not null,
  "batch" integer not null
);
CREATE TABLE IF NOT EXISTS "users"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "email" varchar not null,
  "phone" varchar,
  "password" varchar not null,
  "role" varchar check("role" in('production', 'inventory', 'telesales', 'DA', 'accountant', 'CFO', 'CEO', 'superadmin')) not null default 'production',
  "kyc_status" varchar check("kyc_status" in('pending', 'approved', 'rejected')) not null default 'pending',
  "kyc_data" text,
  "zoho_user_id" varchar,
  "is_active" tinyint(1) not null default '1',
  "email_verified_at" datetime,
  "phone_verified_at" datetime,
  "last_login_at" datetime,
  "last_login_ip" varchar,
  "remember_token" varchar,
  "created_at" datetime,
  "updated_at" datetime,
  "avatar" varchar,
  "fcm_token" varchar,
  "deleted_at" datetime,
  "avatar_url" varchar,
  "date_of_birth" date,
  "gender" varchar check("gender" in('male', 'female', 'other', 'prefer_not_to_say')),
  "address" text,
  "city" varchar,
  "state" varchar,
  "country" varchar,
  "postal_code" varchar,
  "emergency_contact" varchar,
  "emergency_phone" varchar,
  "bio" text,
  "preferences" text
);
CREATE INDEX "users_role_is_active_index" on "users"("role", "is_active");
CREATE INDEX "users_kyc_status_index" on "users"("kyc_status");
CREATE INDEX "users_zoho_user_id_index" on "users"("zoho_user_id");
CREATE UNIQUE INDEX "users_email_unique" on "users"("email");
CREATE UNIQUE INDEX "users_phone_unique" on "users"("phone");
CREATE TABLE IF NOT EXISTS "password_reset_tokens"(
  "email" varchar not null,
  "token" varchar not null,
  "created_at" datetime,
  primary key("email")
);
CREATE TABLE IF NOT EXISTS "sessions"(
  "id" varchar not null,
  "user_id" integer,
  "ip_address" varchar,
  "user_agent" text,
  "payload" text not null,
  "last_activity" integer not null,
  primary key("id")
);
CREATE INDEX "sessions_user_id_index" on "sessions"("user_id");
CREATE INDEX "sessions_last_activity_index" on "sessions"("last_activity");
CREATE TABLE IF NOT EXISTS "cache"(
  "key" varchar not null,
  "value" text not null,
  "expiration" integer not null,
  primary key("key")
);
CREATE TABLE IF NOT EXISTS "cache_locks"(
  "key" varchar not null,
  "owner" varchar not null,
  "expiration" integer not null,
  primary key("key")
);
CREATE TABLE IF NOT EXISTS "jobs"(
  "id" integer primary key autoincrement not null,
  "queue" varchar not null,
  "payload" text not null,
  "attempts" integer not null,
  "reserved_at" integer,
  "available_at" integer not null,
  "created_at" integer not null
);
CREATE INDEX "jobs_queue_index" on "jobs"("queue");
CREATE TABLE IF NOT EXISTS "job_batches"(
  "id" varchar not null,
  "name" varchar not null,
  "total_jobs" integer not null,
  "pending_jobs" integer not null,
  "failed_jobs" integer not null,
  "failed_job_ids" text not null,
  "options" text,
  "cancelled_at" integer,
  "created_at" integer not null,
  "finished_at" integer,
  primary key("id")
);
CREATE TABLE IF NOT EXISTS "failed_jobs"(
  "id" integer primary key autoincrement not null,
  "uuid" varchar not null,
  "connection" text not null,
  "queue" text not null,
  "payload" text not null,
  "exception" text not null,
  "failed_at" datetime not null default CURRENT_TIMESTAMP
);
CREATE UNIQUE INDEX "failed_jobs_uuid_unique" on "failed_jobs"("uuid");
CREATE TABLE IF NOT EXISTS "purchase_orders"(
  "id" integer primary key autoincrement not null,
  "po_number" varchar not null,
  "zoho_po_id" varchar,
  "created_by" integer not null,
  "approved_by" integer,
  "status" varchar check("status" in('draft', 'pending', 'approved', 'in_production', 'completed', 'cancelled')) not null default 'draft',
  "items" text not null,
  "total_amount" numeric not null,
  "notes" text,
  "expected_delivery_date" date not null,
  "actual_delivery_date" date,
  "qc_status" varchar check("qc_status" in('pending', 'passed', 'failed')) not null default 'pending',
  "qc_notes" text,
  "qc_checked_by" integer,
  "handover_date" datetime,
  "handover_to" integer,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("created_by") references "users"("id"),
  foreign key("approved_by") references "users"("id"),
  foreign key("qc_checked_by") references "users"("id"),
  foreign key("handover_to") references "users"("id")
);
CREATE INDEX "purchase_orders_status_created_at_index" on "purchase_orders"(
  "status",
  "created_at"
);
CREATE INDEX "purchase_orders_zoho_po_id_index" on "purchase_orders"(
  "zoho_po_id"
);
CREATE INDEX "purchase_orders_qc_status_index" on "purchase_orders"(
  "qc_status"
);
CREATE UNIQUE INDEX "purchase_orders_po_number_unique" on "purchase_orders"(
  "po_number"
);
CREATE TABLE IF NOT EXISTS "orders"(
  "id" integer primary key autoincrement not null,
  "order_number" varchar not null,
  "zoho_order_id" varchar,
  "customer_id" integer,
  "customer_name" varchar not null,
  "customer_phone" varchar not null,
  "customer_email" varchar,
  "delivery_address" text not null,
  "items" text not null,
  "total_amount" numeric not null,
  "status" varchar check("status" in('pending', 'confirmed', 'processing', 'ready_for_delivery', 'assigned', 'in_transit', 'delivered', 'cancelled')) not null default 'pending',
  "payment_status" varchar check("payment_status" in('pending', 'paid', 'failed', 'refunded')) not null default 'pending',
  "payment_reference" varchar,
  "assigned_da_id" integer,
  "assigned_at" datetime,
  "delivery_date" datetime,
  "delivery_otp" varchar,
  "otp_verified" tinyint(1) not null default '0',
  "otp_verified_at" datetime,
  "delivery_notes" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("customer_id") references "users"("id"),
  foreign key("assigned_da_id") references "users"("id")
);
CREATE INDEX "orders_status_created_at_index" on "orders"(
  "status",
  "created_at"
);
CREATE INDEX "orders_payment_status_created_at_index" on "orders"(
  "payment_status",
  "created_at"
);
CREATE INDEX "orders_zoho_order_id_index" on "orders"("zoho_order_id");
CREATE INDEX "orders_assigned_da_id_index" on "orders"("assigned_da_id");
CREATE INDEX "orders_customer_phone_index" on "orders"("customer_phone");
CREATE UNIQUE INDEX "orders_order_number_unique" on "orders"("order_number");
CREATE TABLE IF NOT EXISTS "delivery_agents"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "da_code" varchar not null,
  "vehicle_number" varchar,
  "vehicle_type" varchar,
  "status" varchar check("status" in('active', 'inactive', 'suspended')) not null default 'active',
  "current_location" varchar,
  "total_deliveries" integer not null default '0',
  "successful_deliveries" integer not null default '0',
  "rating" numeric not null default '0',
  "total_earnings" numeric not null default '0',
  "working_hours" text,
  "service_areas" text,
  "created_at" datetime,
  "updated_at" datetime,
  "state" varchar,
  "city" varchar,
  "commission_rate" numeric not null default '10',
  "strikes_count" integer not null default '0',
  "last_active_at" datetime,
  "delivery_zones" text,
  "vehicle_status" varchar check("vehicle_status" in('available', 'busy', 'maintenance', 'offline')) not null default 'available',
  "current_capacity_used" numeric not null default '0',
  "max_capacity" numeric not null default '50',
  "suspended_at" datetime,
  "suspension_reason" text,
  "deleted_at" datetime,
  "returns_count" integer not null default '0',
  "complaints_count" integer not null default '0',
  "average_delivery_time" numeric,
  "performance_metrics" text,
  foreign key("user_id") references "users"("id")
);
CREATE INDEX "delivery_agents_status_current_location_index" on "delivery_agents"(
  "status",
  "current_location"
);
CREATE INDEX "delivery_agents_da_code_index" on "delivery_agents"("da_code");
CREATE INDEX "delivery_agents_rating_index" on "delivery_agents"("rating");
CREATE UNIQUE INDEX "delivery_agents_da_code_unique" on "delivery_agents"(
  "da_code"
);
CREATE TABLE IF NOT EXISTS "payment_logs"(
  "id" integer primary key autoincrement not null,
  "transaction_id" varchar not null,
  "reference_id" varchar,
  "order_id" integer,
  "user_id" integer,
  "payment_method" varchar check("payment_method" in('moniepoint', 'cash', 'bank_transfer', 'card')) not null default 'moniepoint',
  "status" varchar check("status" in('pending', 'processing', 'completed', 'failed', 'refunded')) not null default 'pending',
  "amount" numeric not null,
  "currency" varchar not null default 'NGN',
  "customer_phone" varchar,
  "customer_email" varchar,
  "payment_data" text,
  "description" text,
  "zoho_transaction_id" varchar,
  "processed_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id"),
  foreign key("user_id") references "users"("id")
);
CREATE INDEX "payment_logs_status_created_at_index" on "payment_logs"(
  "status",
  "created_at"
);
CREATE INDEX "payment_logs_payment_method_created_at_index" on "payment_logs"(
  "payment_method",
  "created_at"
);
CREATE INDEX "payment_logs_reference_id_index" on "payment_logs"(
  "reference_id"
);
CREATE INDEX "payment_logs_zoho_transaction_id_index" on "payment_logs"(
  "zoho_transaction_id"
);
CREATE INDEX "payment_logs_customer_phone_index" on "payment_logs"(
  "customer_phone"
);
CREATE UNIQUE INDEX "payment_logs_transaction_id_unique" on "payment_logs"(
  "transaction_id"
);
CREATE TABLE IF NOT EXISTS "leads"(
  "id" integer primary key autoincrement not null,
  "zoho_lead_id" varchar,
  "lead_number" varchar not null,
  "customer_name" varchar not null,
  "customer_phone" varchar not null,
  "customer_email" varchar,
  "address" text,
  "status" varchar check("status" in('new', 'contacted', 'qualified', 'proposal_sent', 'negotiation', 'won', 'lost')) not null default 'new',
  "source" varchar check("source" in('website', 'phone_call', 'referral', 'social_media', 'walk_in')) not null default 'phone_call',
  "notes" text,
  "potential_value" numeric,
  "assigned_to" integer,
  "assigned_at" datetime,
  "last_contact_at" datetime,
  "whatsapp_otp" varchar,
  "whatsapp_verified" tinyint(1) not null default '0',
  "whatsapp_verified_at" datetime,
  "interaction_history" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("assigned_to") references "users"("id")
);
CREATE INDEX "leads_status_created_at_index" on "leads"(
  "status",
  "created_at"
);
CREATE INDEX "leads_assigned_to_status_index" on "leads"(
  "assigned_to",
  "status"
);
CREATE INDEX "leads_zoho_lead_id_index" on "leads"("zoho_lead_id");
CREATE INDEX "leads_customer_phone_index" on "leads"("customer_phone");
CREATE INDEX "leads_source_index" on "leads"("source");
CREATE UNIQUE INDEX "leads_lead_number_unique" on "leads"("lead_number");
CREATE TABLE IF NOT EXISTS "delivery_logs"(
  "id" integer primary key autoincrement not null,
  "order_id" integer not null,
  "da_id" integer not null,
  "action" varchar check("action" in('assigned', 'picked_up', 'in_transit', 'arrived', 'otp_sent', 'otp_verified', 'delivered', 'failed', 'returned')) not null default 'assigned',
  "location" varchar,
  "notes" text,
  "otp_code" varchar,
  "otp_verified" tinyint(1) not null default '0',
  "otp_verified_at" datetime,
  "customer_signature" varchar,
  "delivery_photos" text,
  "delivery_rating" numeric,
  "customer_feedback" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id"),
  foreign key("da_id") references "users"("id")
);
CREATE INDEX "delivery_logs_order_id_created_at_index" on "delivery_logs"(
  "order_id",
  "created_at"
);
CREATE INDEX "delivery_logs_da_id_action_index" on "delivery_logs"(
  "da_id",
  "action"
);
CREATE INDEX "delivery_logs_action_index" on "delivery_logs"("action");
CREATE TABLE IF NOT EXISTS "otp_logs"(
  "id" integer primary key autoincrement not null,
  "otp_code" varchar not null,
  "phone_number" varchar not null,
  "type" varchar check("type" in('delivery', 'whatsapp', 'kyc', 'login', 'password_reset')) not null default 'delivery',
  "status" varchar check("status" in('sent', 'verified', 'expired', 'failed')) not null default 'sent',
  "attempts" integer not null default '0',
  "max_attempts" integer not null default '3',
  "expires_at" datetime not null,
  "verified_at" datetime,
  "ip_address" varchar,
  "user_agent" varchar,
  "user_id" integer,
  "order_id" integer,
  "lead_id" integer,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id"),
  foreign key("order_id") references "orders"("id"),
  foreign key("lead_id") references "leads"("id")
);
CREATE INDEX "otp_logs_phone_number_type_created_at_index" on "otp_logs"(
  "phone_number",
  "type",
  "created_at"
);
CREATE INDEX "otp_logs_status_created_at_index" on "otp_logs"(
  "status",
  "created_at"
);
CREATE INDEX "otp_logs_otp_code_index" on "otp_logs"("otp_code");
CREATE INDEX "otp_logs_expires_at_index" on "otp_logs"("expires_at");
CREATE TABLE IF NOT EXISTS "bonus_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "bonus_type" varchar check("bonus_type" in('delivery', 'sales', 'performance', 'referral', 'special')) not null default 'delivery',
  "amount" numeric not null,
  "currency" varchar not null default 'NGN',
  "status" varchar check("status" in('pending', 'approved', 'paid', 'cancelled')) not null default 'pending',
  "description" text not null,
  "calculation_data" text,
  "period_start" date,
  "period_end" date,
  "approved_by" integer,
  "approved_at" datetime,
  "paid_at" datetime,
  "payment_reference" varchar,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id"),
  foreign key("approved_by") references "users"("id")
);
CREATE INDEX "bonus_logs_user_id_bonus_type_created_at_index" on "bonus_logs"(
  "user_id",
  "bonus_type",
  "created_at"
);
CREATE INDEX "bonus_logs_status_created_at_index" on "bonus_logs"(
  "status",
  "created_at"
);
CREATE INDEX "bonus_logs_approved_by_index" on "bonus_logs"("approved_by");
CREATE TABLE IF NOT EXISTS "kyc_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "document_type" varchar check("document_type" in('national_id', 'passport', 'drivers_license', 'utility_bill', 'bank_statement', 'selfie')) not null default 'national_id',
  "status" varchar check("status" in('pending', 'approved', 'rejected', 'expired')) not null default 'pending',
  "document_number" varchar,
  "expiry_date" date,
  "document_data" text,
  "verification_data" text,
  "rejection_reason" text,
  "verified_by" integer,
  "verified_at" datetime,
  "ip_address" varchar,
  "user_agent" varchar,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id"),
  foreign key("verified_by") references "users"("id")
);
CREATE INDEX "kyc_logs_user_id_document_type_created_at_index" on "kyc_logs"(
  "user_id",
  "document_type",
  "created_at"
);
CREATE INDEX "kyc_logs_status_created_at_index" on "kyc_logs"(
  "status",
  "created_at"
);
CREATE INDEX "kyc_logs_verified_by_index" on "kyc_logs"("verified_by");
CREATE INDEX "kyc_logs_document_number_index" on "kyc_logs"("document_number");
CREATE TABLE IF NOT EXISTS "action_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer,
  "action" varchar not null,
  "model_type" varchar,
  "model_id" integer,
  "old_values" text,
  "new_values" text,
  "metadata" text,
  "ip_address" varchar,
  "user_agent" varchar,
  "session_id" varchar,
  "risk_level" varchar check("risk_level" in('low', 'medium', 'high', 'critical')) not null default 'low',
  "is_suspicious" tinyint(1) not null default '0',
  "risk_notes" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id")
);
CREATE INDEX "action_logs_user_id_created_at_index" on "action_logs"(
  "user_id",
  "created_at"
);
CREATE INDEX "action_logs_action_created_at_index" on "action_logs"(
  "action",
  "created_at"
);
CREATE INDEX "action_logs_model_type_model_id_index" on "action_logs"(
  "model_type",
  "model_id"
);
CREATE INDEX "action_logs_risk_level_created_at_index" on "action_logs"(
  "risk_level",
  "created_at"
);
CREATE INDEX "action_logs_is_suspicious_index" on "action_logs"(
  "is_suspicious"
);
CREATE INDEX "action_logs_ip_address_index" on "action_logs"("ip_address");
CREATE TABLE IF NOT EXISTS "pressone_logs"(
  "id" integer primary key autoincrement not null,
  "api_endpoint" varchar not null,
  "method" varchar check("method" in('GET', 'POST', 'PUT', 'DELETE', 'PATCH')) not null default 'GET',
  "status" varchar check("status" in('pending', 'success', 'failed', 'timeout')) not null default 'pending',
  "response_code" integer,
  "request_data" text,
  "response_data" text,
  "error_message" text,
  "response_time_ms" integer,
  "user_id" integer,
  "ip_address" varchar,
  "headers" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id")
);
CREATE INDEX "pressone_logs_api_endpoint_created_at_index" on "pressone_logs"(
  "api_endpoint",
  "created_at"
);
CREATE INDEX "pressone_logs_status_created_at_index" on "pressone_logs"(
  "status",
  "created_at"
);
CREATE INDEX "pressone_logs_user_id_index" on "pressone_logs"("user_id");
CREATE INDEX "pressone_logs_response_code_index" on "pressone_logs"(
  "response_code"
);
CREATE TABLE IF NOT EXISTS "unmatched_payments"(
  "id" integer primary key autoincrement not null,
  "transaction_id" varchar not null,
  "reference_id" varchar,
  "amount" numeric not null,
  "currency" varchar not null default 'NGN',
  "customer_phone" varchar,
  "customer_email" varchar,
  "customer_name" varchar,
  "payment_method" varchar check("payment_method" in('moniepoint', 'cash', 'bank_transfer', 'card')) not null default 'moniepoint',
  "status" varchar check("status" in('unmatched', 'matched', 'refunded', 'expired')) not null default 'unmatched',
  "payment_data" text,
  "notes" text,
  "matched_by" integer,
  "matched_to_order_id" integer,
  "matched_at" datetime,
  "expires_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("matched_by") references "users"("id"),
  foreign key("matched_to_order_id") references "orders"("id")
);
CREATE INDEX "unmatched_payments_status_created_at_index" on "unmatched_payments"(
  "status",
  "created_at"
);
CREATE INDEX "unmatched_payments_customer_phone_index" on "unmatched_payments"(
  "customer_phone"
);
CREATE INDEX "unmatched_payments_reference_id_index" on "unmatched_payments"(
  "reference_id"
);
CREATE INDEX "unmatched_payments_matched_by_index" on "unmatched_payments"(
  "matched_by"
);
CREATE UNIQUE INDEX "unmatched_payments_transaction_id_unique" on "unmatched_payments"(
  "transaction_id"
);
CREATE TABLE IF NOT EXISTS "personal_access_tokens"(
  "id" integer primary key autoincrement not null,
  "tokenable_type" varchar not null,
  "tokenable_id" integer not null,
  "name" varchar not null,
  "token" varchar not null,
  "abilities" text,
  "last_used_at" datetime,
  "expires_at" datetime,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "personal_access_tokens_tokenable_type_tokenable_id_index" on "personal_access_tokens"(
  "tokenable_type",
  "tokenable_id"
);
CREATE UNIQUE INDEX "personal_access_tokens_token_unique" on "personal_access_tokens"(
  "token"
);
CREATE TABLE IF NOT EXISTS "inventory_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" varchar,
  "action" varchar not null,
  "item_id" varchar,
  "item_name" varchar,
  "from_bin" varchar,
  "to_bin" varchar,
  "quantity" numeric,
  "notes" text,
  "zoho_reference" varchar,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "inventory_logs_action_created_at_index" on "inventory_logs"(
  "action",
  "created_at"
);
CREATE INDEX "inventory_logs_user_id_index" on "inventory_logs"("user_id");
CREATE INDEX "inventory_logs_item_id_index" on "inventory_logs"("item_id");
CREATE TABLE IF NOT EXISTS "bin_items"(
  "id" integer primary key autoincrement not null,
  "bin_id" integer not null,
  "item_id" varchar not null,
  "item_name" varchar not null,
  "quantity" integer not null default '0',
  "reserved_quantity" integer not null default '0',
  "cost_per_unit" numeric not null default '0',
  "batch_number" varchar,
  "expiry_date" date,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("bin_id") references "bins"("id") on delete cascade
);
CREATE UNIQUE INDEX "bin_items_bin_id_item_id_unique" on "bin_items"(
  "bin_id",
  "item_id"
);
CREATE INDEX "bin_items_item_id_quantity_index" on "bin_items"(
  "item_id",
  "quantity"
);
CREATE INDEX "bin_items_expiry_date_index" on "bin_items"("expiry_date");
CREATE TABLE IF NOT EXISTS "stock_receipts"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "stock_movements"(
  "id" integer primary key autoincrement not null,
  "product_id" integer,
  "movement_type" varchar check("movement_type" in('inbound', 'outbound', 'transfer', 'return', 'adjustment')) not null,
  "source_type" varchar,
  "source_id" integer,
  "destination_type" varchar,
  "destination_id" integer,
  "quantity" integer not null,
  "reference_type" varchar,
  "reference_id" integer,
  "performed_by" varchar not null,
  "notes" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "stock_movements_product_id_created_at_index" on "stock_movements"(
  "product_id",
  "created_at"
);
CREATE INDEX "stock_movements_movement_type_created_at_index" on "stock_movements"(
  "movement_type",
  "created_at"
);
CREATE INDEX "stock_movements_source_type_source_id_index" on "stock_movements"(
  "source_type",
  "source_id"
);
CREATE INDEX "stock_movements_destination_type_destination_id_index" on "stock_movements"(
  "destination_type",
  "destination_id"
);
CREATE INDEX "stock_movements_reference_type_reference_id_index" on "stock_movements"(
  "reference_type",
  "reference_id"
);
CREATE INDEX "stock_movements_performed_by_index" on "stock_movements"(
  "performed_by"
);
CREATE TABLE IF NOT EXISTS "products"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "sku" varchar not null,
  "description" text,
  "category" varchar,
  "unit_price" numeric not null,
  "cost_price" numeric not null,
  "available_quantity" integer not null default '0',
  "minimum_stock_level" integer not null default '0',
  "maximum_stock_level" integer not null default '1000',
  "status" varchar check("status" in('active', 'inactive')) not null default 'active',
  "created_at" datetime,
  "updated_at" datetime,
  "low_stock_threshold" integer not null default '10',
  "is_low_stock" tinyint(1) not null default '0',
  "last_stock_check" datetime,
  "price" numeric not null default '0',
  "zoho_item_id" varchar
);
CREATE INDEX "products_sku_status_index" on "products"("sku", "status");
CREATE INDEX "products_category_index" on "products"("category");
CREATE UNIQUE INDEX "products_sku_unique" on "products"("sku");
CREATE TABLE IF NOT EXISTS "warehouse_stocks"(
  "id" integer primary key autoincrement not null,
  "warehouse_id" integer not null,
  "product_id" integer not null,
  "quantity" integer not null default '0',
  "reserved_quantity" integer not null default '0',
  "last_updated" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("warehouse_id") references "warehouses"("id") on delete cascade,
  foreign key("product_id") references "products"("id") on delete cascade
);
CREATE UNIQUE INDEX "warehouse_stocks_warehouse_id_product_id_unique" on "warehouse_stocks"(
  "warehouse_id",
  "product_id"
);
CREATE INDEX "warehouse_stocks_warehouse_id_product_id_index" on "warehouse_stocks"(
  "warehouse_id",
  "product_id"
);
CREATE TABLE IF NOT EXISTS "warehouses"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "code" varchar not null,
  "address" text not null,
  "manager" varchar,
  "phone" varchar,
  "capacity" integer not null default '1000',
  "status" varchar check("status" in('active', 'inactive')) not null default 'active',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "warehouses_code_unique" on "warehouses"("code");
CREATE TABLE IF NOT EXISTS "bin_stocks"(
  "id" integer primary key autoincrement not null,
  "bin_id" integer not null,
  "product_id" integer not null,
  "quantity" numeric not null default '0',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "bin_stocks_bin_id_product_id_unique" on "bin_stocks"(
  "bin_id",
  "product_id"
);
CREATE TABLE IF NOT EXISTS "purchase_order_items"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "roles"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "display_name" varchar not null,
  "description" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "roles_name_unique" on "roles"("name");
CREATE TABLE IF NOT EXISTS "role_user"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "role_id" integer not null,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete cascade,
  foreign key("role_id") references "roles"("id") on delete cascade
);
CREATE UNIQUE INDEX "role_user_user_id_role_id_unique" on "role_user"(
  "user_id",
  "role_id"
);
CREATE TABLE IF NOT EXISTS "security_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer,
  "event_type" varchar not null,
  "ip_address" varchar not null,
  "user_agent" text,
  "request_method" varchar not null,
  "request_path" varchar not null,
  "status_code" integer not null,
  "request_data" text,
  "response_data" text,
  "session_id" varchar,
  "request_id" varchar not null,
  "duration_ms" integer,
  "error_message" text,
  "risk_level" varchar not null default 'low',
  "is_suspicious" tinyint(1) not null default '0',
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete set null
);
CREATE INDEX "security_logs_user_id_created_at_index" on "security_logs"(
  "user_id",
  "created_at"
);
CREATE INDEX "security_logs_event_type_created_at_index" on "security_logs"(
  "event_type",
  "created_at"
);
CREATE INDEX "security_logs_ip_address_created_at_index" on "security_logs"(
  "ip_address",
  "created_at"
);
CREATE INDEX "security_logs_risk_level_created_at_index" on "security_logs"(
  "risk_level",
  "created_at"
);
CREATE INDEX "security_logs_is_suspicious_created_at_index" on "security_logs"(
  "is_suspicious",
  "created_at"
);
CREATE INDEX "security_logs_request_id_index" on "security_logs"("request_id");
CREATE UNIQUE INDEX "security_logs_request_id_unique" on "security_logs"(
  "request_id"
);
CREATE TABLE IF NOT EXISTS "failed_login_attempts"(
  "id" integer primary key autoincrement not null,
  "email" varchar not null,
  "ip_address" varchar not null,
  "user_agent" text,
  "attempted_at" datetime not null,
  "is_locked" tinyint(1) not null default '0',
  "locked_until" datetime
);
CREATE INDEX "failed_login_attempts_email_ip_address_attempted_at_index" on "failed_login_attempts"(
  "email",
  "ip_address",
  "attempted_at"
);
CREATE INDEX "failed_login_attempts_ip_address_attempted_at_index" on "failed_login_attempts"(
  "ip_address",
  "attempted_at"
);
CREATE INDEX "failed_login_attempts_is_locked_locked_until_index" on "failed_login_attempts"(
  "is_locked",
  "locked_until"
);
CREATE TABLE IF NOT EXISTS "api_rate_limits"(
  "id" integer primary key autoincrement not null,
  "key" varchar not null,
  "type" varchar not null,
  "attempts" integer not null default '0',
  "reset_at" datetime not null,
  "is_blocked" tinyint(1) not null default '0',
  "blocked_until" datetime
);
CREATE INDEX "api_rate_limits_key_type_index" on "api_rate_limits"(
  "key",
  "type"
);
CREATE INDEX "api_rate_limits_is_blocked_blocked_until_index" on "api_rate_limits"(
  "is_blocked",
  "blocked_until"
);
CREATE INDEX "api_rate_limits_reset_at_index" on "api_rate_limits"("reset_at");
CREATE TABLE IF NOT EXISTS "inventory_movements"(
  "id" integer primary key autoincrement not null,
  "product_id" integer not null,
  "from_bin_id" integer not null,
  "to_bin_id" integer not null,
  "quantity" numeric not null,
  "movement_type" varchar not null,
  "reason" varchar not null,
  "status" varchar not null default('pending'),
  "notes" text,
  "created_at" datetime,
  "updated_at" datetime,
  "approval_status" varchar check("approval_status" in('pending', 'approved', 'rejected', 'auto_approved')) not null default 'pending',
  "approved_by" integer,
  "approved_at" datetime,
  "approval_notes" text,
  "approval_threshold" numeric not null default '1000',
  foreign key("approved_by") references "users"("id") on delete set null
);
CREATE INDEX "inventory_movements_approval_status_created_at_index" on "inventory_movements"(
  "approval_status",
  "created_at"
);
CREATE INDEX "inventory_movements_approved_by_approved_at_index" on "inventory_movements"(
  "approved_by",
  "approved_at"
);
CREATE TABLE IF NOT EXISTS "approval_logs"(
  "id" integer primary key autoincrement not null,
  "approvable_type" varchar not null,
  "approvable_id" integer not null,
  "user_id" integer not null,
  "action" varchar check("action" in('submitted', 'approved', 'rejected', 'cancelled', 'requested_changes')) not null,
  "comments" text,
  "metadata" text,
  "performed_at" datetime not null,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete cascade
);
CREATE INDEX "approval_logs_approvable_type_approvable_id_index" on "approval_logs"(
  "approvable_type",
  "approvable_id"
);
CREATE INDEX "approval_logs_user_id_index" on "approval_logs"("user_id");
CREATE INDEX "approval_logs_action_index" on "approval_logs"("action");
CREATE INDEX "approval_logs_performed_at_index" on "approval_logs"(
  "performed_at"
);
CREATE INDEX "products_is_low_stock_last_stock_check_index" on "products"(
  "is_low_stock",
  "last_stock_check"
);
CREATE INDEX "products_low_stock_threshold_index" on "products"(
  "low_stock_threshold"
);
CREATE TABLE IF NOT EXISTS "inventory_archive_tables"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "products_price_index" on "products"("price");
CREATE TABLE IF NOT EXISTS "comprehensive_bin_system"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "zoho_operation_logs"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "order_otps"(
  "id" integer primary key autoincrement not null,
  "order_number" varchar not null,
  "otp_code" varchar not null,
  "attempt_count" integer not null default '0',
  "resend_count" integer not null default '0',
  "expires_at" datetime not null,
  "is_verified" tinyint(1) not null default '0',
  "is_locked" tinyint(1) not null default '0',
  "locked_at" datetime,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "order_otps_order_number_otp_code_index" on "order_otps"(
  "order_number",
  "otp_code"
);
CREATE INDEX "order_otps_expires_at_index" on "order_otps"("expires_at");
CREATE UNIQUE INDEX "order_otps_order_number_unique" on "order_otps"(
  "order_number"
);
CREATE TABLE IF NOT EXISTS "inventory_audits"(
  "id" integer primary key autoincrement not null,
  "order_number" varchar not null,
  "item_id" varchar not null,
  "bin_id" varchar not null,
  "quantity_deducted" integer not null,
  "reason" varchar check("reason" in('package_dispatch', 'order_fulfillment', 'quality_control', 'return_processing')) not null,
  "user_id" integer not null,
  "zoho_adjustment_id" varchar,
  "zoho_response" text,
  "deducted_at" datetime not null,
  "ip_address" varchar,
  "user_agent" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id")
);
CREATE INDEX "inventory_audits_item_id_bin_id_index" on "inventory_audits"(
  "item_id",
  "bin_id"
);
CREATE INDEX "inventory_audits_deducted_at_index" on "inventory_audits"(
  "deducted_at"
);
CREATE INDEX "inventory_audits_order_number_index" on "inventory_audits"(
  "order_number"
);
CREATE TABLE IF NOT EXISTS "inventory_cache"(
  "id" integer primary key autoincrement not null,
  "item_id" varchar not null,
  "bin_id" varchar not null,
  "warehouse_id" varchar not null,
  "available_stock" integer not null default '0',
  "reserved_stock" integer not null default '0',
  "last_synced_at" datetime not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "inventory_cache_item_id_bin_id_unique" on "inventory_cache"(
  "item_id",
  "bin_id"
);
CREATE INDEX "inventory_cache_item_id_available_stock_index" on "inventory_cache"(
  "item_id",
  "available_stock"
);
CREATE TABLE IF NOT EXISTS "bin_locations"(
  "id" integer primary key autoincrement not null,
  "bin_id" varchar not null,
  "bin_name" varchar not null,
  "warehouse_id" varchar not null,
  "zone" varchar,
  "aisle" varchar,
  "rack" varchar,
  "shelf" varchar,
  "is_active" tinyint(1) not null default '1',
  "restrictions" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "bin_locations_warehouse_id_is_active_index" on "bin_locations"(
  "warehouse_id",
  "is_active"
);
CREATE UNIQUE INDEX "bin_locations_bin_id_unique" on "bin_locations"("bin_id");
CREATE TABLE IF NOT EXISTS "delivery_otps"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "deliveries"(
  "id" integer primary key autoincrement not null,
  "order_number" varchar not null,
  "delivery_location" varchar,
  "recipient_name" varchar,
  "delivery_notes" text,
  "confirmed_by" integer not null,
  "confirmed_at" datetime not null,
  "otp_verified" tinyint(1) not null default '0',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "deliveries_order_number_index" on "deliveries"("order_number");
CREATE TABLE IF NOT EXISTS "agent_actions_table_final"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "bin_audit_trails_table_final"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "payout_action_logs"(
  "id" integer primary key autoincrement not null,
  "payout_id" integer not null,
  "action" varchar not null,
  "performed_by" integer not null,
  "role" varchar not null,
  "note" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("payout_id") references "payouts"("id") on delete cascade,
  foreign key("performed_by") references "users"("id") on delete cascade
);
CREATE INDEX "payout_action_logs_payout_id_index" on "payout_action_logs"(
  "payout_id"
);
CREATE TABLE IF NOT EXISTS "payouts"(
  "id" integer primary key autoincrement not null,
  "order_id" integer not null,
  "amount" numeric not null,
  "status" varchar not null default('pending'),
  "created_at" datetime,
  "updated_at" datetime,
  "deleted_at" datetime,
  "approved_by" integer,
  "approved_at" datetime,
  "approval_notes" text,
  "locked_by" integer,
  "locked_at" datetime,
  "lock_reason" text,
  "lock_type" varchar check("lock_type" in('fraud', 'dispute', 'investigation', 'compliance')),
  foreign key("order_id") references orders("id") on delete cascade on update no action,
  foreign key("approved_by") references "users"("id") on delete set null,
  foreign key("locked_by") references "users"("id") on delete set null
);
CREATE INDEX "payouts_order_id_index" on "payouts"("order_id");
CREATE TABLE IF NOT EXISTS "watchlist"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "reason" text not null,
  "created_by" integer,
  "escalated_at" datetime not null,
  "is_active" tinyint(1) not null default '1',
  "resolved_at" datetime,
  "resolved_by" integer,
  "created_at" datetime,
  "updated_at" datetime,
  "deleted_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id") on delete cascade,
  foreign key("created_by") references "users"("id") on delete set null,
  foreign key("resolved_by") references "users"("id") on delete set null
);
CREATE INDEX "watchlist_delivery_agent_id_index" on "watchlist"(
  "delivery_agent_id"
);
CREATE INDEX "watchlist_is_active_escalated_at_index" on "watchlist"(
  "is_active",
  "escalated_at"
);
CREATE TABLE IF NOT EXISTS "strike_logs"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "reason" varchar not null,
  "notes" text,
  "source" varchar not null default 'payout_compliance',
  "severity" varchar check("severity" in('low', 'medium', 'high')) not null default 'medium',
  "issued_by" integer not null,
  "payout_id" integer,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id") on delete cascade,
  foreign key("issued_by") references "users"("id") on delete cascade,
  foreign key("payout_id") references "payouts"("id") on delete set null
);
CREATE INDEX "strike_logs_delivery_agent_id_index" on "strike_logs"(
  "delivery_agent_id"
);
CREATE INDEX "strike_logs_delivery_agent_id_created_at_index" on "strike_logs"(
  "delivery_agent_id",
  "created_at"
);
CREATE INDEX "strike_logs_severity_index" on "strike_logs"("severity");
CREATE TABLE IF NOT EXISTS "export_logs"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "system_logs"(
  "id" integer primary key autoincrement not null,
  "type" varchar not null,
  "message" text not null,
  "context" text,
  "level" varchar not null default 'info',
  "user_id" integer,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "system_logs_type_created_at_index" on "system_logs"(
  "type",
  "created_at"
);
CREATE INDEX "system_logs_level_created_at_index" on "system_logs"(
  "level",
  "created_at"
);
CREATE INDEX "delivery_agents_status_state_city_index" on "delivery_agents"(
  "status",
  "state",
  "city"
);
CREATE INDEX "delivery_agents_rating_successful_deliveries_index" on "delivery_agents"(
  "rating",
  "successful_deliveries"
);
CREATE INDEX "delivery_agents_last_active_at_index" on "delivery_agents"(
  "last_active_at"
);
CREATE INDEX "delivery_agents_vehicle_status_index" on "delivery_agents"(
  "vehicle_status"
);
CREATE INDEX "delivery_agents_deleted_at_index" on "delivery_agents"(
  "deleted_at"
);
CREATE INDEX "delivery_agents_strikes_count_index" on "delivery_agents"(
  "strikes_count"
);
CREATE TABLE IF NOT EXISTS "bins"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "zoho_storage_id" varchar,
  "zoho_warehouse_id" varchar,
  "assigned_to_da" varchar,
  "da_phone" varchar,
  "location" varchar,
  "status" varchar not null default('active'),
  "type" varchar not null default('delivery_agent'),
  "capacity" numeric,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  "state" varchar,
  "zoho_location_id" varchar,
  "zoho_zone_id" varchar,
  "zoho_bin_id" varchar,
  "delivery_agent_id" integer,
  "current_stock_count" integer not null default '0',
  "is_active" tinyint(1) not null default '1',
  "location_coordinates" text,
  "bin_type" varchar not null default 'delivery_agent',
  "last_inventory_update" datetime,
  "utilization_rate" numeric not null default '0',
  "deleted_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id") on delete set null
);
CREATE INDEX "bins_assigned_to_da_index" on "bins"("assigned_to_da");
CREATE INDEX "bins_state_index" on "bins"("state");
CREATE INDEX "bins_status_index" on "bins"("status");
CREATE INDEX "bins_type_index" on "bins"("type");
CREATE INDEX "bins_zoho_bin_id_index" on "bins"("zoho_bin_id");
CREATE INDEX "bins_zoho_location_id_zoho_zone_id_index" on "bins"(
  "zoho_location_id",
  "zoho_zone_id"
);
CREATE INDEX "bins_zoho_storage_id_index" on "bins"("zoho_storage_id");
CREATE UNIQUE INDEX "bins_zoho_storage_id_unique" on "bins"("zoho_storage_id");
CREATE INDEX "bins_delivery_agent_id_status_index" on "bins"(
  "delivery_agent_id",
  "status"
);
CREATE INDEX "bins_state_is_active_index" on "bins"("state", "is_active");
CREATE INDEX "bins_bin_type_index" on "bins"("bin_type");
CREATE INDEX "bins_utilization_rate_index" on "bins"("utilization_rate");
CREATE INDEX "bins_deleted_at_index" on "bins"("deleted_at");
CREATE TABLE IF NOT EXISTS "agent_activity_logs"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "activity_type" varchar check("activity_type" in('login', 'logout', 'pickup', 'delivery', 'location_update', 'status_change', 'order_acceptance', 'order_rejection')) not null,
  "description" varchar not null,
  "activity_data" text,
  "ip_address" varchar,
  "related_order_id" integer,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id")
);
CREATE INDEX "agent_activity_logs_delivery_agent_id_created_at_index" on "agent_activity_logs"(
  "delivery_agent_id",
  "created_at"
);
CREATE INDEX "agent_activity_logs_activity_type_index" on "agent_activity_logs"(
  "activity_type"
);
CREATE TABLE IF NOT EXISTS "agent_performance_metrics"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "metric_date" date not null,
  "deliveries_assigned" integer not null default '0',
  "deliveries_completed" integer not null default '0',
  "deliveries_failed" integer not null default '0',
  "success_rate" numeric not null default '0',
  "average_delivery_time" numeric,
  "total_distance_km" numeric not null default '0',
  "average_rating" numeric,
  "total_earnings" numeric not null default '0',
  "active_hours" integer not null default '0',
  "complaints_received" integer not null default '0',
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id")
);
CREATE UNIQUE INDEX "agent_performance_metrics_delivery_agent_id_metric_date_unique" on "agent_performance_metrics"(
  "delivery_agent_id",
  "metric_date"
);
CREATE INDEX "agent_performance_metrics_metric_date_index" on "agent_performance_metrics"(
  "metric_date"
);
CREATE TABLE IF NOT EXISTS "zobins"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "zoho_storage_id" varchar,
  "zoho_warehouse_id" varchar not null,
  "shampoo_count" integer not null default '0',
  "pomade_count" integer not null default '0',
  "conditioner_count" integer not null default '0',
  "last_updated" datetime not null,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id")
);
CREATE TABLE IF NOT EXISTS "im_daily_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "log_date" date not null,
  "login_time" time,
  "completed_da_review" tinyint(1) not null default '0',
  "das_reviewed_count" integer not null default '0',
  "recommendations_executed" integer not null default '0',
  "penalty_amount" numeric not null default '0',
  "bonus_amount" numeric not null default '0',
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id")
);
CREATE UNIQUE INDEX "im_daily_logs_user_id_log_date_unique" on "im_daily_logs"(
  "user_id",
  "log_date"
);
CREATE TABLE IF NOT EXISTS "system_recommendations"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "type" varchar check("type" in('restock', 'transfer', 'audit', 'return')) not null,
  "priority" varchar not null,
  "message" text not null,
  "action_data" text not null,
  "status" varchar check("status" in('pending', 'executed', 'ignored', 'expired')) not null,
  "assigned_to" integer not null,
  "executed_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id"),
  foreign key("assigned_to") references "users"("id")
);
CREATE TABLE IF NOT EXISTS "photo_audits"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "audit_date" date not null,
  "photo_url" varchar,
  "photo_uploaded_at" datetime,
  "da_claimed_shampoo" integer,
  "da_claimed_pomade" integer,
  "da_claimed_conditioner" integer,
  "im_counted_shampoo" integer,
  "im_counted_pomade" integer,
  "im_counted_conditioner" integer,
  "zoho_recorded_shampoo" integer,
  "zoho_recorded_pomade" integer,
  "zoho_recorded_conditioner" integer,
  "is_match" tinyint(1),
  "status" varchar check("status" in('pending_photo', 'pending_im_review', 'completed', 'flagged')) not null,
  "notes" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("delivery_agent_id") references "delivery_agents"("id")
);
CREATE UNIQUE INDEX "photo_audits_delivery_agent_id_audit_date_unique" on "photo_audits"(
  "delivery_agent_id",
  "audit_date"
);
CREATE TABLE IF NOT EXISTS "da_distance_matrix"(
  "id" integer primary key autoincrement not null,
  "from_da_id" integer not null,
  "to_da_id" integer not null,
  "distance_km" numeric not null,
  "travel_time_minutes" integer not null,
  "transport_cost" numeric not null,
  "route_quality" varchar not null,
  "route_waypoints" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "da_distance_matrix_from_da_id_to_da_id_unique" on "da_distance_matrix"(
  "from_da_id",
  "to_da_id"
);
CREATE INDEX "da_distance_matrix_from_da_id_distance_km_index" on "da_distance_matrix"(
  "from_da_id",
  "distance_km"
);
CREATE TABLE IF NOT EXISTS "regional_performance"(
  "id" integer primary key autoincrement not null,
  "region_code" varchar not null,
  "state" varchar not null,
  "city" varchar not null,
  "performance_date" date not null,
  "total_stock" integer not null,
  "units_sold" integer not null,
  "sell_through_rate" numeric not null,
  "days_of_inventory" integer not null,
  "velocity_score" numeric not null,
  "seasonal_factors" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "regional_performance_region_code_performance_date_unique" on "regional_performance"(
  "region_code",
  "performance_date"
);
CREATE TABLE IF NOT EXISTS "transfer_recommendations"(
  "id" integer primary key autoincrement not null,
  "from_da_id" integer not null,
  "to_da_id" integer not null,
  "recommended_quantity" integer not null,
  "priority" varchar not null,
  "potential_savings" numeric not null,
  "reasoning" text not null,
  "logistics_data" text not null,
  "status" varchar not null default 'pending',
  "recommended_at" datetime not null,
  "approved_at" datetime,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "transfer_recommendations_status_priority_index" on "transfer_recommendations"(
  "status",
  "priority"
);
CREATE TABLE IF NOT EXISTS "geographic_zones"(
  "id" integer primary key autoincrement not null,
  "zone_code" varchar not null,
  "zone_name" varchar not null,
  "states_included" text not null,
  "hub_da_id" integer,
  "avg_transport_cost_per_km" numeric not null,
  "seasonal_patterns" text not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "geographic_zones_zone_code_unique" on "geographic_zones"(
  "zone_code"
);
CREATE TABLE IF NOT EXISTS "stock_velocity_logs"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "tracking_date" date not null,
  "opening_stock" integer not null,
  "closing_stock" integer not null,
  "units_sold" integer not null,
  "units_received" integer not null,
  "daily_velocity" numeric not null,
  "stockout_days" integer not null default '0',
  "opportunity_cost" numeric not null default '0',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "stock_velocity_logs_delivery_agent_id_tracking_date_unique" on "stock_velocity_logs"(
  "delivery_agent_id",
  "tracking_date"
);
CREATE TABLE IF NOT EXISTS "permissions"(
  "id" integer primary key autoincrement not null,
  "name" varchar not null,
  "guard_name" varchar not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "permissions_name_guard_name_unique" on "permissions"(
  "name",
  "guard_name"
);
CREATE TABLE IF NOT EXISTS "demand_forecasts"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "forecast_date" date not null,
  "forecast_period" varchar not null,
  "predicted_demand" integer not null,
  "confidence_score" numeric not null,
  "model_used" varchar not null,
  "input_factors" text not null,
  "accuracy_score" numeric,
  "actual_demand" integer,
  "model_metadata" text not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE UNIQUE INDEX "demand_forecasts_delivery_agent_id_forecast_date_forecast_period_unique" on "demand_forecasts"(
  "delivery_agent_id",
  "forecast_date",
  "forecast_period"
);
CREATE INDEX "demand_forecasts_forecast_date_confidence_score_index" on "demand_forecasts"(
  "forecast_date",
  "confidence_score"
);
CREATE TABLE IF NOT EXISTS "seasonal_patterns"(
  "id" integer primary key autoincrement not null,
  "pattern_type" varchar not null,
  "pattern_name" varchar not null,
  "start_date" date not null,
  "end_date" date not null,
  "demand_multiplier" numeric not null,
  "affected_regions" varchar,
  "historical_data" text not null,
  "confidence_level" numeric not null,
  "description" text not null,
  "is_active" tinyint(1) not null default '1',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "seasonal_patterns_pattern_type_start_date_end_date_index" on "seasonal_patterns"(
  "pattern_type",
  "start_date",
  "end_date"
);
CREATE TABLE IF NOT EXISTS "event_impacts"(
  "id" integer primary key autoincrement not null,
  "event_type" varchar not null,
  "event_name" varchar not null,
  "event_date" date not null,
  "impact_duration_days" integer not null,
  "demand_impact" numeric not null,
  "affected_locations" text not null,
  "severity" varchar not null,
  "external_data" text not null,
  "impact_description" text not null,
  "confidence_level" numeric not null default '75',
  "is_active" tinyint(1) not null default '1',
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "event_impacts_event_type_event_date_index" on "event_impacts"(
  "event_type",
  "event_date"
);
CREATE INDEX "event_impacts_severity_event_date_index" on "event_impacts"(
  "severity",
  "event_date"
);
CREATE TABLE IF NOT EXISTS "prediction_accuracy"(
  "id" integer primary key autoincrement not null,
  "model_name" varchar not null,
  "prediction_type" varchar not null,
  "evaluation_date" date not null,
  "accuracy_percentage" numeric not null,
  "mean_absolute_error" numeric not null,
  "root_mean_square_error" numeric not null,
  "total_predictions" integer not null,
  "correct_predictions" integer not null,
  "performance_metrics" text not null,
  "model_parameters" text not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "prediction_accuracy_model_name_evaluation_date_index" on "prediction_accuracy"(
  "model_name",
  "evaluation_date"
);
CREATE TABLE IF NOT EXISTS "automated_decisions"(
  "id" integer primary key autoincrement not null,
  "decision_type" varchar not null,
  "delivery_agent_id" integer not null,
  "trigger_reason" text not null,
  "decision_data" text not null,
  "confidence_score" numeric not null,
  "status" varchar not null default 'pending',
  "triggered_at" datetime not null,
  "executed_at" datetime,
  "execution_result" text,
  "human_override" tinyint(1) not null default '0',
  "notes" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "automated_decisions_status_triggered_at_index" on "automated_decisions"(
  "status",
  "triggered_at"
);
CREATE INDEX "automated_decisions_delivery_agent_id_decision_type_index" on "automated_decisions"(
  "delivery_agent_id",
  "decision_type"
);
CREATE TABLE IF NOT EXISTS "risk_assessments"(
  "id" integer primary key autoincrement not null,
  "delivery_agent_id" integer not null,
  "assessment_date" date not null,
  "stockout_probability" numeric not null,
  "overstock_probability" numeric not null,
  "days_until_stockout" integer not null,
  "potential_lost_sales" numeric not null,
  "carrying_cost_risk" numeric not null,
  "risk_level" varchar not null,
  "risk_factors" text not null,
  "mitigation_suggestions" text not null,
  "overall_risk_score" numeric not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "risk_assessments_delivery_agent_id_assessment_date_index" on "risk_assessments"(
  "delivery_agent_id",
  "assessment_date"
);
CREATE INDEX "risk_assessments_risk_level_assessment_date_index" on "risk_assessments"(
  "risk_level",
  "assessment_date"
);
CREATE TABLE IF NOT EXISTS "market_intelligence"(
  "id" integer primary key autoincrement not null,
  "region_code" varchar not null,
  "intelligence_date" date not null,
  "market_temperature" numeric not null,
  "demand_drivers" text not null,
  "supply_constraints" text not null,
  "price_sensitivity" numeric not null,
  "competitor_activity" text not null,
  "external_indicators" text not null,
  "market_summary" text not null,
  "reliability_score" numeric not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "market_intelligence_region_code_intelligence_date_index" on "market_intelligence"(
  "region_code",
  "intelligence_date"
);
CREATE TABLE IF NOT EXISTS "money_out_compliance"(
  "id" integer primary key autoincrement not null,
  "order_id" integer not null,
  "delivery_agent_id" integer not null,
  "amount" numeric not null default '2500',
  "payment_verified" tinyint(1) not null default '0',
  "otp_submitted" tinyint(1) not null default '0',
  "friday_photo_approved" tinyint(1) not null default '0',
  "three_way_match" tinyint(1) not null default '0',
  "compliance_status" varchar check("compliance_status" in('ready', 'locked', 'paid')) not null default 'ready',
  "proof_of_payment_path" varchar,
  "paid_at" datetime,
  "paid_by" integer,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id") on delete cascade,
  foreign key("delivery_agent_id") references "delivery_agents"("id") on delete cascade,
  foreign key("paid_by") references "users"("id") on delete set null
);
CREATE INDEX "money_out_compliance_compliance_status_three_way_match_index" on "money_out_compliance"(
  "compliance_status",
  "three_way_match"
);
CREATE UNIQUE INDEX "money_out_compliance_order_id_unique" on "money_out_compliance"(
  "order_id"
);
CREATE TABLE IF NOT EXISTS "logistics_costs"(
  "id" integer primary key autoincrement not null,
  "transfer_type" varchar check("transfer_type" in('supplier_to_im', 'im_to_da', 'da_to_da', 'da_to_factory')) not null,
  "origin_location" varchar not null,
  "origin_phone" varchar not null,
  "destination_location" varchar not null,
  "destination_phone" varchar not null,
  "items_description" text not null,
  "quantity" integer not null,
  "transport_company" varchar not null,
  "transport_phone" varchar not null,
  "storekeeper_phone" varchar not null,
  "total_cost" numeric not null,
  "cost_per_unit" numeric not null,
  "storekeeper_fee" numeric not null,
  "transport_fare" numeric not null,
  "proof_of_payment_path" varchar,
  "approved_by" integer,
  "status" varchar check("status" in('pending', 'approved', 'paid', 'escalated')) not null default 'pending',
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("approved_by") references "users"("id") on delete set null
);
CREATE INDEX "logistics_costs_status_transfer_type_index" on "logistics_costs"(
  "status",
  "transfer_type"
);
CREATE INDEX "logistics_costs_approved_by_index" on "logistics_costs"(
  "approved_by"
);
CREATE TABLE IF NOT EXISTS "other_expenses"(
  "id" integer primary key autoincrement not null,
  "expense_id" varchar not null,
  "requested_by" integer not null,
  "department" varchar not null,
  "expense_type" varchar not null,
  "description" text not null,
  "amount" numeric not null,
  "vendor_name" varchar not null,
  "vendor_phone" varchar not null,
  "urgency_level" varchar check("urgency_level" in('normal', 'urgent')) not null default 'normal',
  "business_justification" text not null,
  "receipt_path" varchar,
  "approval_required" varchar check("approval_required" in('fc', 'gm', 'ceo')) not null default 'fc',
  "approved_by" integer,
  "approval_status" varchar check("approval_status" in('pending', 'approved', 'rejected')) not null default 'pending',
  "approval_reference" varchar,
  "paid_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("requested_by") references "users"("id") on delete cascade,
  foreign key("approved_by") references "users"("id") on delete set null
);
CREATE INDEX "other_expenses_approval_status_approval_required_index" on "other_expenses"(
  "approval_status",
  "approval_required"
);
CREATE INDEX "other_expenses_requested_by_expense_type_index" on "other_expenses"(
  "requested_by",
  "expense_type"
);
CREATE UNIQUE INDEX "other_expenses_expense_id_unique" on "other_expenses"(
  "expense_id"
);
CREATE TABLE IF NOT EXISTS "audit_logs"(
  "id" integer primary key autoincrement not null,
  "event_type" varchar not null,
  "auditable_type" varchar not null,
  "auditable_id" integer not null,
  "user_id" integer,
  "old_values" text,
  "new_values" text,
  "user_agent" varchar,
  "ip_address" varchar,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete set null
);
CREATE INDEX "audit_logs_auditable_type_auditable_id_index" on "audit_logs"(
  "auditable_type",
  "auditable_id"
);
CREATE INDEX "audit_logs_user_id_index" on "audit_logs"("user_id");
CREATE INDEX "audit_logs_event_type_index" on "audit_logs"("event_type");
CREATE INDEX "audit_logs_created_at_index" on "audit_logs"("created_at");
CREATE TABLE IF NOT EXISTS "customers"(
  "id" integer primary key autoincrement not null,
  "customer_id" varchar not null,
  "name" varchar not null,
  "phone" varchar not null,
  "email" varchar,
  "address" text,
  "city" varchar,
  "state" varchar,
  "lga" varchar,
  "customer_type" varchar check("customer_type" in('individual', 'business')) not null default 'individual',
  "status" varchar check("status" in('active', 'inactive', 'suspended')) not null default 'active',
  "zoho_contact_id" varchar,
  "lifetime_value" numeric not null default '0',
  "total_orders" integer not null default '0',
  "last_order_date" date,
  "preferences" text,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE INDEX "customers_customer_id_index" on "customers"("customer_id");
CREATE INDEX "customers_phone_index" on "customers"("phone");
CREATE INDEX "customers_email_index" on "customers"("email");
CREATE INDEX "customers_status_index" on "customers"("status");
CREATE INDEX "customers_zoho_contact_id_index" on "customers"(
  "zoho_contact_id"
);
CREATE UNIQUE INDEX "customers_customer_id_unique" on "customers"(
  "customer_id"
);
CREATE UNIQUE INDEX "customers_phone_unique" on "customers"("phone");
CREATE TABLE IF NOT EXISTS "payments"(
  "id" integer primary key autoincrement not null,
  "payment_id" varchar not null,
  "order_id" integer not null,
  "customer_id" integer not null,
  "amount" numeric not null,
  "payment_method" varchar check("payment_method" in('pos', 'transfer', 'cash', 'card', 'ussd')) not null default 'pos',
  "transaction_reference" varchar,
  "moniepoint_reference" varchar,
  "status" varchar check("status" in('pending', 'confirmed', 'failed', 'disputed')) not null default 'pending',
  "paid_at" datetime,
  "pos_terminal_id" varchar,
  "merchant_id" varchar,
  "pos_charges" numeric not null default '0',
  "net_amount" numeric,
  "moniepoint_response" text,
  "verification_code" varchar,
  "verification_expires_at" datetime,
  "is_verified" tinyint(1) not null default '0',
  "verified_by" integer,
  "verified_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id") on delete cascade,
  foreign key("customer_id") references "customers"("id") on delete cascade,
  foreign key("verified_by") references "users"("id") on delete set null
);
CREATE INDEX "payments_payment_id_index" on "payments"("payment_id");
CREATE INDEX "payments_order_id_index" on "payments"("order_id");
CREATE INDEX "payments_customer_id_index" on "payments"("customer_id");
CREATE INDEX "payments_transaction_reference_index" on "payments"(
  "transaction_reference"
);
CREATE INDEX "payments_status_index" on "payments"("status");
CREATE INDEX "payments_paid_at_index" on "payments"("paid_at");
CREATE UNIQUE INDEX "payments_payment_id_unique" on "payments"("payment_id");
CREATE TABLE IF NOT EXISTS "otp_verifications"(
  "id" integer primary key autoincrement not null,
  "order_id" integer not null,
  "payment_id" integer,
  "delivery_agent_id" integer not null,
  "otp_code" varchar not null,
  "otp_type" varchar check("otp_type" in('delivery', 'payment', 'pickup')) not null default 'delivery',
  "customer_phone" varchar not null,
  "status" varchar check("status" in('pending', 'verified', 'expired', 'failed')) not null default 'pending',
  "sent_at" datetime not null,
  "expires_at" datetime not null,
  "verified_at" datetime,
  "verified_by" integer,
  "attempts" integer not null default '0',
  "max_attempts" integer not null default '3',
  "delivery_method" varchar check("delivery_method" in('sms', 'whatsapp', 'call')) not null default 'sms',
  "sms_sent" tinyint(1) not null default '0',
  "whatsapp_sent" tinyint(1) not null default '0',
  "call_made" tinyint(1) not null default '0',
  "delivery_log" text,
  "location_lat" varchar,
  "location_lng" varchar,
  "location_address" varchar,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id") on delete cascade,
  foreign key("payment_id") references "payments"("id") on delete set null,
  foreign key("delivery_agent_id") references "delivery_agents"("id") on delete cascade,
  foreign key("verified_by") references "users"("id") on delete set null
);
CREATE INDEX "otp_verifications_order_id_index" on "otp_verifications"(
  "order_id"
);
CREATE INDEX "otp_verifications_payment_id_index" on "otp_verifications"(
  "payment_id"
);
CREATE INDEX "otp_verifications_delivery_agent_id_index" on "otp_verifications"(
  "delivery_agent_id"
);
CREATE INDEX "otp_verifications_otp_code_index" on "otp_verifications"(
  "otp_code"
);
CREATE INDEX "otp_verifications_customer_phone_index" on "otp_verifications"(
  "customer_phone"
);
CREATE INDEX "otp_verifications_status_index" on "otp_verifications"("status");
CREATE INDEX "otp_verifications_expires_at_index" on "otp_verifications"(
  "expires_at"
);
CREATE TABLE IF NOT EXISTS "escalations"(
  "id" integer primary key autoincrement not null,
  "escalation_id" varchar not null,
  "escalation_type" varchar check("escalation_type" in('logistics_cost', 'other_expense', 'compliance_issue', 'performance_issue')) not null,
  "escalatable_id" integer not null,
  "escalatable_type" varchar not null,
  "created_by" integer not null,
  "priority" varchar check("priority" in('low', 'medium', 'high', 'urgent')) not null default 'medium',
  "status" varchar check("status" in('pending', 'in_review', 'approved', 'rejected', 'resolved')) not null default 'pending',
  "title" varchar not null,
  "description" text not null,
  "business_justification" text,
  "amount_involved" numeric,
  "required_approval" varchar check("required_approval" in('fc', 'gm', 'ceo')) not null,
  "assigned_to" integer,
  "assigned_at" datetime,
  "reviewed_by" integer,
  "reviewed_at" datetime,
  "review_notes" text,
  "due_date" datetime,
  "attachments" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("created_by") references "users"("id") on delete cascade,
  foreign key("assigned_to") references "users"("id") on delete set null,
  foreign key("reviewed_by") references "users"("id") on delete set null
);
CREATE INDEX "escalations_escalation_id_index" on "escalations"(
  "escalation_id"
);
CREATE INDEX "escalations_escalatable_type_escalatable_id_index" on "escalations"(
  "escalatable_type",
  "escalatable_id"
);
CREATE INDEX "escalations_created_by_index" on "escalations"("created_by");
CREATE INDEX "escalations_status_index" on "escalations"("status");
CREATE INDEX "escalations_priority_index" on "escalations"("priority");
CREATE INDEX "escalations_assigned_to_index" on "escalations"("assigned_to");
CREATE INDEX "escalations_due_date_index" on "escalations"("due_date");
CREATE UNIQUE INDEX "escalations_escalation_id_unique" on "escalations"(
  "escalation_id"
);
CREATE TABLE IF NOT EXISTS "health_criteria_logs"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "week_start_date" date not null,
  "week_end_date" date not null,
  "payment_matching_accuracy" numeric not null default '0',
  "escalation_discipline_score" numeric not null default '0',
  "documentation_integrity_score" numeric not null default '0',
  "bonus_log_accuracy_score" numeric not null default '0',
  "overall_score" numeric not null default '0',
  "bonus_eligible" tinyint(1) not null default '0',
  "bonus_amount" numeric not null default '0',
  "total_payments_processed" integer not null default '0',
  "payment_mismatches" integer not null default '0',
  "required_escalations" integer not null default '0',
  "actual_escalations" integer not null default '0',
  "total_transactions" integer not null default '0',
  "complete_documentation" integer not null default '0',
  "total_bonus_logs" integer not null default '0',
  "accurate_bonus_logs" integer not null default '0',
  "performance_level" varchar check("performance_level" in('Poor', 'Needs Improvement', 'Satisfactory', 'Good', 'Excellent')) not null default 'Satisfactory',
  "is_final" tinyint(1) not null default '0',
  "calculated_at" datetime,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete cascade
);
CREATE INDEX "health_criteria_logs_user_id_index" on "health_criteria_logs"(
  "user_id"
);
CREATE INDEX "health_criteria_logs_week_start_date_index" on "health_criteria_logs"(
  "week_start_date"
);
CREATE INDEX "health_criteria_logs_week_end_date_index" on "health_criteria_logs"(
  "week_end_date"
);
CREATE INDEX "health_criteria_logs_overall_score_index" on "health_criteria_logs"(
  "overall_score"
);
CREATE INDEX "health_criteria_logs_bonus_eligible_index" on "health_criteria_logs"(
  "bonus_eligible"
);
CREATE INDEX "health_criteria_logs_performance_level_index" on "health_criteria_logs"(
  "performance_level"
);
CREATE UNIQUE INDEX "health_criteria_logs_user_id_week_start_date_unique" on "health_criteria_logs"(
  "user_id",
  "week_start_date"
);
CREATE TABLE IF NOT EXISTS "bonus_disbursements"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "da_inventory_counts"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "im_inventory_verifications"(
  "id" integer primary key autoincrement not null,
  "created_at" datetime,
  "updated_at" datetime
);
CREATE TABLE IF NOT EXISTS "file_uploads"(
  "id" integer primary key autoincrement not null,
  "file_id" varchar not null,
  "uploadable_id" integer not null,
  "uploadable_type" varchar not null,
  "file_name" varchar not null,
  "file_path" varchar not null,
  "file_url" varchar,
  "file_size" integer not null,
  "mime_type" varchar not null,
  "file_extension" varchar not null,
  "file_type" varchar check("file_type" in('proof_of_payment', 'receipt', 'invoice', 'inventory_photo', 'document', 'other')) not null default 'document',
  "status" varchar check("status" in('pending', 'verified', 'rejected')) not null default 'pending',
  "uploaded_by" integer not null,
  "verified_by" integer,
  "verified_at" datetime,
  "verification_notes" text,
  "is_public" tinyint(1) not null default '0',
  "hash" varchar,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("uploaded_by") references "users"("id") on delete cascade,
  foreign key("verified_by") references "users"("id") on delete set null
);
CREATE INDEX "file_uploads_file_id_index" on "file_uploads"("file_id");
CREATE INDEX "file_uploads_uploadable_type_uploadable_id_index" on "file_uploads"(
  "uploadable_type",
  "uploadable_id"
);
CREATE INDEX "file_uploads_uploaded_by_index" on "file_uploads"("uploaded_by");
CREATE INDEX "file_uploads_verified_by_index" on "file_uploads"("verified_by");
CREATE INDEX "file_uploads_file_type_index" on "file_uploads"("file_type");
CREATE INDEX "file_uploads_status_index" on "file_uploads"("status");
CREATE INDEX "file_uploads_mime_type_index" on "file_uploads"("mime_type");
CREATE UNIQUE INDEX "file_uploads_file_id_unique" on "file_uploads"("file_id");
CREATE TABLE IF NOT EXISTS "payment_mismatches"(
  "id" integer primary key autoincrement not null,
  "mismatch_id" varchar not null,
  "order_id" integer not null,
  "payment_id" integer not null,
  "entered_phone" varchar not null,
  "entered_order_id" varchar not null,
  "actual_phone" varchar not null,
  "actual_order_id" varchar not null,
  "mismatch_type" varchar check("mismatch_type" in('order_id', 'phone', 'both', 'unknown')) not null default 'unknown',
  "payment_amount" numeric not null,
  "webhook_payload" text not null,
  "investigation_required" tinyint(1) not null default '1',
  "investigation_notes" text,
  "investigated_at" datetime,
  "investigated_by" integer,
  "corrective_action" varchar check("corrective_action" in('reprocess_payment', 'contact_customer', 'manual_override')),
  "resolution_type" varchar check("resolution_type" in('corrected', 'customer_error', 'system_error')),
  "resolution_notes" text,
  "resolved_at" datetime,
  "resolved_by" integer,
  "penalty_amount" numeric not null default '10000',
  "penalty_applied" tinyint(1) not null default '0',
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("order_id") references "orders"("id") on delete cascade,
  foreign key("payment_id") references "payments"("id") on delete cascade,
  foreign key("investigated_by") references "users"("id") on delete set null,
  foreign key("resolved_by") references "users"("id") on delete set null
);
CREATE INDEX "payment_mismatches_mismatch_id_index" on "payment_mismatches"(
  "mismatch_id"
);
CREATE INDEX "payment_mismatches_order_id_index" on "payment_mismatches"(
  "order_id"
);
CREATE INDEX "payment_mismatches_payment_id_index" on "payment_mismatches"(
  "payment_id"
);
CREATE INDEX "payment_mismatches_mismatch_type_index" on "payment_mismatches"(
  "mismatch_type"
);
CREATE INDEX "payment_mismatches_investigation_required_index" on "payment_mismatches"(
  "investigation_required"
);
CREATE INDEX "payment_mismatches_resolved_at_index" on "payment_mismatches"(
  "resolved_at"
);
CREATE UNIQUE INDEX "payment_mismatches_mismatch_id_unique" on "payment_mismatches"(
  "mismatch_id"
);
CREATE TABLE IF NOT EXISTS "manual_investigations"(
  "id" integer primary key autoincrement not null,
  "investigation_id" varchar not null,
  "type" varchar check("type" in('payment_verification_failed', 'webhook_processing_failed', 'system_error', 'data_integrity_issue')) not null,
  "data" text not null,
  "status" varchar check("status" in('pending', 'in_progress', 'resolved', 'escalated')) not null default 'pending',
  "priority" varchar check("priority" in('low', 'medium', 'high', 'critical')) not null default 'medium',
  "description" text,
  "assigned_to" integer,
  "assigned_at" datetime,
  "resolution_notes" text,
  "resolved_at" datetime,
  "resolved_by" integer,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("assigned_to") references "users"("id") on delete set null,
  foreign key("resolved_by") references "users"("id") on delete set null
);
CREATE INDEX "manual_investigations_investigation_id_index" on "manual_investigations"(
  "investigation_id"
);
CREATE INDEX "manual_investigations_type_index" on "manual_investigations"(
  "type"
);
CREATE INDEX "manual_investigations_status_index" on "manual_investigations"(
  "status"
);
CREATE INDEX "manual_investigations_priority_index" on "manual_investigations"(
  "priority"
);
CREATE INDEX "manual_investigations_assigned_to_index" on "manual_investigations"(
  "assigned_to"
);
CREATE UNIQUE INDEX "manual_investigations_investigation_id_unique" on "manual_investigations"(
  "investigation_id"
);
CREATE TABLE IF NOT EXISTS "approval_workflows"(
  "id" integer primary key autoincrement not null,
  "violation_id" integer not null,
  "workflow_type" varchar not null,
  "required_approvers" text not null,
  "timeout_hours" integer not null,
  "auto_reject_on_timeout" tinyint(1) not null default '1',
  "status" varchar check("status" in('pending', 'approved', 'rejected', 'timeout_rejected')) not null default 'pending',
  "approvals_received" text,
  "rejections_received" text,
  "expires_at" datetime not null,
  "completed_at" datetime,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("violation_id") references "threshold_violations"("id") on delete cascade
);
CREATE INDEX "approval_workflows_status_expires_at_index" on "approval_workflows"(
  "status",
  "expires_at"
);
CREATE INDEX "approval_workflows_workflow_type_index" on "approval_workflows"(
  "workflow_type"
);
CREATE INDEX "approval_workflows_violation_id_index" on "approval_workflows"(
  "violation_id"
);
CREATE INDEX "approval_workflows_expires_at_index" on "approval_workflows"(
  "expires_at"
);
CREATE TABLE IF NOT EXISTS "approval_decisions"(
  "id" integer primary key autoincrement not null,
  "workflow_id" integer not null,
  "approver_id" integer not null,
  "decision" varchar check("decision" in('approve', 'reject')) not null,
  "comments" text,
  "decision_at" datetime not null,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("workflow_id") references "approval_workflows"("id") on delete cascade,
  foreign key("approver_id") references "users"("id") on delete cascade
);
CREATE INDEX "approval_decisions_workflow_id_approver_id_index" on "approval_decisions"(
  "workflow_id",
  "approver_id"
);
CREATE INDEX "approval_decisions_decision_index" on "approval_decisions"(
  "decision"
);
CREATE INDEX "approval_decisions_decision_at_index" on "approval_decisions"(
  "decision_at"
);
CREATE TABLE IF NOT EXISTS "salary_deductions"(
  "id" integer primary key autoincrement not null,
  "user_id" integer not null,
  "violation_id" integer not null,
  "amount" numeric not null,
  "reason" text not null,
  "status" varchar check("status" in('pending', 'processed', 'cancelled', 'failed')) not null default 'pending',
  "deduction_date" date not null,
  "processed_at" datetime,
  "processed_by" integer,
  "notes" text,
  "metadata" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("user_id") references "users"("id") on delete cascade,
  foreign key("violation_id") references "threshold_violations"("id") on delete cascade,
  foreign key("processed_by") references "users"("id") on delete set null
);
CREATE INDEX "salary_deductions_status_deduction_date_index" on "salary_deductions"(
  "status",
  "deduction_date"
);
CREATE INDEX "salary_deductions_user_id_index" on "salary_deductions"(
  "user_id"
);
CREATE INDEX "salary_deductions_violation_id_index" on "salary_deductions"(
  "violation_id"
);
CREATE INDEX "salary_deductions_deduction_date_index" on "salary_deductions"(
  "deduction_date"
);
CREATE INDEX "salary_deductions_processed_by_index" on "salary_deductions"(
  "processed_by"
);
CREATE TABLE IF NOT EXISTS "escalation_requests"(
  "id" integer primary key autoincrement not null,
  "threshold_violation_id" integer not null,
  "escalation_type" varchar not null,
  "amount_requested" numeric not null,
  "threshold_limit" numeric not null,
  "overage_amount" numeric not null,
  "approval_required" text not null,
  "escalation_reason" text not null,
  "business_justification" text,
  "status" varchar check("status" in('pending_approval', 'approved', 'rejected', 'expired')) not null default 'pending_approval',
  "priority" varchar check("priority" in('normal', 'medium', 'high', 'critical')) not null default 'normal',
  "expires_at" datetime not null,
  "created_by" integer,
  "final_decision_at" datetime,
  "final_outcome" varchar check("final_outcome" in('approved', 'rejected', 'expired')),
  "rejection_reason" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("threshold_violation_id") references "threshold_violations"("id") on delete cascade,
  foreign key("created_by") references "users"("id")
);
CREATE INDEX "escalation_requests_status_expires_at_index" on "escalation_requests"(
  "status",
  "expires_at"
);
CREATE INDEX "escalation_requests_priority_created_at_index" on "escalation_requests"(
  "priority",
  "created_at"
);
CREATE INDEX "escalation_requests_escalation_type_status_index" on "escalation_requests"(
  "escalation_type",
  "status"
);
CREATE TABLE IF NOT EXISTS "threshold_violations"(
  "id" integer primary key autoincrement not null,
  "cost_type" varchar not null,
  "cost_category" varchar,
  "amount" numeric not null,
  "threshold_limit" numeric not null,
  "overage_amount" numeric not null,
  "violation_details" text,
  "status" varchar check("status" in('blocked', 'approved', 'rejected', 'processed')) not null default 'blocked',
  "created_by" integer,
  "reference_type" varchar,
  "reference_id" integer,
  "approved_at" datetime,
  "rejected_at" datetime,
  "approved_amount" numeric,
  "rejection_reason" text,
  "created_at" datetime,
  "updated_at" datetime,
  foreign key("created_by") references "users"("id")
);
CREATE INDEX "threshold_violations_cost_type_created_at_index" on "threshold_violations"(
  "cost_type",
  "created_at"
);
CREATE INDEX "threshold_violations_status_created_at_index" on "threshold_violations"(
  "status",
  "created_at"
);
CREATE INDEX "threshold_violations_reference_type_reference_id_index" on "threshold_violations"(
  "reference_type",
  "reference_id"
);

INSERT INTO migrations VALUES(1,'0001_01_01_000000_create_users_table',1);
INSERT INTO migrations VALUES(2,'0001_01_01_000001_create_cache_table',1);
INSERT INTO migrations VALUES(3,'0001_01_01_000002_create_jobs_table',1);
INSERT INTO migrations VALUES(4,'2024_01_01_000003_create_purchase_orders_table',1);
INSERT INTO migrations VALUES(5,'2024_01_01_000005_create_orders_table',1);
INSERT INTO migrations VALUES(6,'2024_01_01_000006_create_delivery_agents_table',1);
INSERT INTO migrations VALUES(7,'2024_01_01_000007_create_payment_logs_table',1);
INSERT INTO migrations VALUES(8,'2024_01_01_000008_create_leads_table',1);
INSERT INTO migrations VALUES(9,'2024_01_01_000010_create_delivery_logs_table',1);
INSERT INTO migrations VALUES(10,'2024_01_01_000011_create_otp_logs_table',1);
INSERT INTO migrations VALUES(11,'2024_01_01_000012_create_bonus_logs_table',1);
INSERT INTO migrations VALUES(12,'2024_01_01_000013_create_kyc_logs_table',1);
INSERT INTO migrations VALUES(13,'2024_01_01_000014_create_action_logs_table',1);
INSERT INTO migrations VALUES(14,'2024_01_01_000015_create_pressone_logs_table',1);
INSERT INTO migrations VALUES(15,'2024_01_01_000016_create_unmatched_payments_table',1);
INSERT INTO migrations VALUES(16,'2025_06_20_204909_create_personal_access_tokens_table',1);
INSERT INTO migrations VALUES(17,'2025_06_24_211622_create_inventory_logs_table',1);
INSERT INTO migrations VALUES(18,'2025_06_25_110749_create_bins_table',1);
INSERT INTO migrations VALUES(19,'2025_06_25_151757_create_bin_items_table',1);
INSERT INTO migrations VALUES(20,'2025_06_28_214424_create_stock_receipts_table',1);
INSERT INTO migrations VALUES(21,'2025_06_30_024651_create_stock_movements_table',1);
INSERT INTO migrations VALUES(22,'2025_06_30_031305_create_bin_stocks_table',1);
INSERT INTO migrations VALUES(23,'2025_06_30_031305_create_products_table',1);
INSERT INTO migrations VALUES(24,'2025_06_30_031305_create_warehouse_stocks_table',1);
INSERT INTO migrations VALUES(25,'2025_06_30_031305_create_warehouses_table',1);
INSERT INTO migrations VALUES(26,'2025_06_30_055518_create_inventory_movements_table',1);
INSERT INTO migrations VALUES(27,'2025_06_30_161002_update_bins_table_for_returns',2);
INSERT INTO migrations VALUES(28,'2025_06_30_193802_fix_bin_stocks_table',3);
INSERT INTO migrations VALUES(29,'2025_06_30_194758_add_columns_to_inventory_movements_table',4);
INSERT INTO migrations VALUES(30,'2025_06_30_230222_create_purchase_order_items_table',5);
INSERT INTO migrations VALUES(32,'2025_07_04_213749_create_roles_table',6);
INSERT INTO migrations VALUES(33,'2025_01_01_000000_create_security_logs_table',7);
INSERT INTO migrations VALUES(34,'2025_07_05_134600_add_approval_fields_to_inventory_movements',8);
INSERT INTO migrations VALUES(35,'2025_07_05_140256_add_approval_fields_to_inventory_movements',8);
INSERT INTO migrations VALUES(36,'2025_07_05_140426_create_approval_logs_table',8);
INSERT INTO migrations VALUES(37,'2025_07_05_190631_add_low_stock_threshold_to_products',9);
INSERT INTO migrations VALUES(38,'2025_07_05_221332_create_inventory_archive_tables',10);
INSERT INTO migrations VALUES(39,'2025_07_06_054508_add_price_to_products_table',11);
INSERT INTO migrations VALUES(40,'2025_07_06_063308_create_comprehensive_bin_system',12);
INSERT INTO migrations VALUES(41,'2025_07_06_092219_add_state_to_bins_table',13);
INSERT INTO migrations VALUES(42,'2025_07_06_092252_add_state_to_bins_table',13);
INSERT INTO migrations VALUES(43,'2025_07_06_095523_add_zoho_fields_to_products_table',14);
INSERT INTO migrations VALUES(44,'2025_07_06_100150_add_state_to_bins_table',14);
INSERT INTO migrations VALUES(45,'2025_07_06_100150_add_zoho_fields_to_products_table',14);
INSERT INTO migrations VALUES(46,'2025_07_06_100315_add_state_to_bins_table',14);
INSERT INTO migrations VALUES(47,'2025_07_06_100330_add_zoho_fields_to_products_table',14);
INSERT INTO migrations VALUES(48,'2025_07_06_135817_add_zoho_location_zone_fields_to_bins_table',15);
INSERT INTO migrations VALUES(49,'2025_07_06_154907_fix_bins_table_nullable_zoho_fields',16);
INSERT INTO migrations VALUES(50,'2025_07_06_164918_fix_bins_table_nullable_zoho_fields',16);
INSERT INTO migrations VALUES(51,'2025_07_06_160655_create_zoho_operation_logs_table',17);
INSERT INTO migrations VALUES(52,'2025_07_07_084249_add_delivery_fields_to_orders_table',18);
INSERT INTO migrations VALUES(53,'2025_07_07_150445_create_order_otps_table',19);
INSERT INTO migrations VALUES(54,'2025_07_07_164002_create_inventory_audits_table',20);
INSERT INTO migrations VALUES(55,'2025_07_07_164050_create_inventory_cache_table',20);
INSERT INTO migrations VALUES(56,'2025_07_07_164136_create_bin_locations_table',20);
INSERT INTO migrations VALUES(57,'2025_07_07_204407_create_delivery_otps_table',21);
INSERT INTO migrations VALUES(58,'2025_07_07_210513_add_inventory_processing_to_orders_table',22);
INSERT INTO migrations VALUES(60,'2025_07_07_211600_create_inventory_movements_table',1);
INSERT INTO migrations VALUES(74,'2025_07_07_210524_create_deliveries_table',23);
INSERT INTO migrations VALUES(75,'2025_07_07_214943_create_agent_actions_table_final',23);
INSERT INTO migrations VALUES(76,'2025_07_07_214943_create_bin_audit_trails_table_final',23);
INSERT INTO migrations VALUES(77,'2025_07_10_185804_create_payouts_table',23);
INSERT INTO migrations VALUES(78,'2025_07_10_191551_add_approval_and_lock_fields_to_payouts_table',23);
INSERT INTO migrations VALUES(79,'2025_07_10_192158_create_payout_action_logs_table',23);
INSERT INTO migrations VALUES(80,'2025_07_10_201559_add_approval_and_lock_fields_to_payouts_table',23);
INSERT INTO migrations VALUES(81,'2025_07_11_174802_create_watchlist_table',23);
INSERT INTO migrations VALUES(82,'2025_07_11_175720_create_strike_logs_table',23);
INSERT INTO migrations VALUES(83,'2025_07_11_182052_create_export_logs_table',23);
INSERT INTO migrations VALUES(84,'2025_07_11_211641_add_payout_compliance_fields',23);
INSERT INTO migrations VALUES(85,'2025_07_11_221557_create_system_logs_table',23);
INSERT INTO migrations VALUES(86,'2025_07_12_170532_add_agent_fields_to_users_table',24);
INSERT INTO migrations VALUES(87,'2025_07_12_170542_add_performance_fields_to_deliveries_table',24);
INSERT INTO migrations VALUES(88,'2025_07_12_205215_add_missing_fields_to_users_table',25);
INSERT INTO migrations VALUES(89,'2025_07_12_205245_update_delivery_agents_table',25);
INSERT INTO migrations VALUES(90,'2025_07_12_205300_fix_bins_delivery_agent_relationship',25);
INSERT INTO migrations VALUES(91,'2025_07_12_215245_update_delivery_agents_table',26);
INSERT INTO migrations VALUES(92,'2025_07_12_215300_fix_bins_delivery_agent_relationship',26);
INSERT INTO migrations VALUES(93,'2025_07_12_212502_create_agent_activity_logs_table',27);
INSERT INTO migrations VALUES(94,'2025_07_12_212502_create_agent_performance_metrics_table',27);
INSERT INTO migrations VALUES(95,'2025_07_12_212502_create_complete_deliveries_table',27);
INSERT INTO migrations VALUES(96,'2025_07_13_100619_add_profile_fields_to_users_table',28);
INSERT INTO migrations VALUES(97,'2025_07_13_094752_create_personal_access_tokens_table',28);
INSERT INTO migrations VALUES(98,'2025_07_13_094902_create_password_reset_tokens_table',29);
INSERT INTO migrations VALUES(99,'2025_07_13_100545_add_profile_fields_to_users_table',29);
INSERT INTO migrations VALUES(100,'2024_01_01_000002_create_zobins_table',30);
INSERT INTO migrations VALUES(101,'2024_01_01_000003_create_im_daily_logs_table',30);
INSERT INTO migrations VALUES(102,'2024_01_01_000004_create_system_recommendations_table',30);
INSERT INTO migrations VALUES(103,'2024_01_01_000005_create_photo_audits_table',30);
INSERT INTO migrations VALUES(104,'2025_07_17_222422_create_missing_inventory_tables',31);
INSERT INTO migrations VALUES(105,'2025_07_18_002037_create_geographic_optimization_system',31);
INSERT INTO migrations VALUES(107,'2025_07_18_114641_create_predictive_analytics_system',32);
INSERT INTO migrations VALUES(108,'2025_07_18_170700_create_money_out_compliance_table',33);
INSERT INTO migrations VALUES(109,'2025_07_18_170800_create_logistics_costs_table',33);
INSERT INTO migrations VALUES(110,'2025_07_18_170900_create_other_expenses_table',33);
INSERT INTO migrations VALUES(111,'2025_07_18_171000_create_audit_logs_table',34);
INSERT INTO migrations VALUES(112,'2025_07_18_173700_create_customers_table',34);
INSERT INTO migrations VALUES(113,'2025_07_18_173702_create_payments_table',34);
INSERT INTO migrations VALUES(114,'2025_07_18_173704_create_otp_verifications_table',34);
INSERT INTO migrations VALUES(115,'2025_07_18_173712_create_escalations_table',34);
INSERT INTO migrations VALUES(116,'2025_07_18_173714_create_health_criteria_logs_table',34);
INSERT INTO migrations VALUES(117,'2025_07_18_173715_create_bonus_disbursements_table',34);
INSERT INTO migrations VALUES(118,'2025_07_18_173726_create_da_inventory_counts_table',34);
INSERT INTO migrations VALUES(119,'2025_07_18_173728_create_im_inventory_verifications_table',34);
INSERT INTO migrations VALUES(120,'2025_07_18_173729_create_file_uploads_table',34);
INSERT INTO migrations VALUES(121,'2025_07_18_174540_create_payment_mismatches_table',35);
INSERT INTO migrations VALUES(122,'2025_07_18_174543_create_manual_investigations_table',35);
INSERT INTO migrations VALUES(123,'2025_07_18_200000_create_threshold_violations_table',36);
INSERT INTO migrations VALUES(124,'2025_07_18_200100_create_approval_workflows_table',36);
INSERT INTO migrations VALUES(125,'2025_07_18_200200_create_approval_decisions_table',36);
INSERT INTO migrations VALUES(126,'2025_07_18_200300_create_salary_deductions_table',36);
INSERT INTO migrations VALUES(127,'2025_07_18_195716_create_escalation_requests_table',37);
INSERT INTO migrations VALUES(128,'2025_07_18_200129_recreate_threshold_violations_table_with_new_structure',38);
