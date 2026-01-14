-- Virtual Number Platform Database Schema
-- Created: 2026-01-14
-- This schema contains tables for managing virtual numbers, orders, and messaging

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(255),
  `avatar_url` VARCHAR(500),
  `phone_number` VARCHAR(20),
  `country` VARCHAR(100),
  `city` VARCHAR(100),
  `address` TEXT,
  `postal_code` VARCHAR(20),
  `account_type` ENUM('personal', 'business', 'developer') DEFAULT 'personal',
  `account_status` ENUM('active', 'suspended', 'banned', 'pending_verification') DEFAULT 'pending_verification',
  `email_verified_at` TIMESTAMP NULL,
  `phone_verified_at` TIMESTAMP NULL,
  `last_login_at` TIMESTAMP NULL,
  `balance` DECIMAL(15, 2) DEFAULT 0.00,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `notifications_email` BOOLEAN DEFAULT TRUE,
  `notifications_sms` BOOLEAN DEFAULT FALSE,
  `api_key` VARCHAR(255) UNIQUE,
  `api_secret` VARCHAR(255),
  `two_factor_enabled` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_username` (`username`),
  INDEX `idx_email` (`email`),
  INDEX `idx_account_status` (`account_status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PROVIDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `providers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `display_name` VARCHAR(255) NOT NULL,
  `description` TEXT,
  `logo_url` VARCHAR(500),
  `website_url` VARCHAR(500),
  `country` VARCHAR(100) NOT NULL,
  `supported_countries` JSON,
  `api_endpoint` VARCHAR(500),
  `api_key` VARCHAR(500),
  `api_secret` VARCHAR(500),
  `is_active` BOOLEAN DEFAULT TRUE,
  `provider_type` ENUM('sms', 'voice', 'both') DEFAULT 'both',
  `verification_method` ENUM('instant', 'manual', 'automatic') DEFAULT 'automatic',
  `rate_per_number` DECIMAL(10, 2) NOT NULL,
  `monthly_fee` DECIMAL(10, 2) DEFAULT 0.00,
  `retention_days` INT DEFAULT 30,
  `connection_status` ENUM('connected', 'disconnected', 'error') DEFAULT 'disconnected',
  `last_checked_at` TIMESTAMP NULL,
  `failure_count` INT DEFAULT 0,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_name` (`name`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_country` (`country`),
  INDEX `idx_connection_status` (`connection_status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VIRTUAL NUMBERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `numbers` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `provider_id` BIGINT UNSIGNED NOT NULL,
  `phone_number` VARCHAR(20) NOT NULL,
  `country_code` VARCHAR(5) NOT NULL,
  `area_code` VARCHAR(10),
  `service_type` ENUM('sms', 'voice', 'both') DEFAULT 'both',
  `number_type` ENUM('local', 'toll_free', 'mobile') DEFAULT 'local',
  `is_active` BOOLEAN DEFAULT TRUE,
  `verification_status` ENUM('pending', 'verified', 'failed', 'expired') DEFAULT 'pending',
  `purchase_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `activation_date` TIMESTAMP NULL,
  `expiration_date` TIMESTAMP NULL,
  `renewal_date` TIMESTAMP NULL,
  `renewal_cost` DECIMAL(10, 2),
  `auto_renewal` BOOLEAN DEFAULT TRUE,
  `forwarding_number` VARCHAR(20),
  `forwarding_enabled` BOOLEAN DEFAULT FALSE,
  `call_recording_enabled` BOOLEAN DEFAULT FALSE,
  `call_recording_url` VARCHAR(500),
  `usage_count` INT DEFAULT 0,
  `message_count` INT DEFAULT 0,
  `last_used_at` TIMESTAMP NULL,
  `provider_reference_id` VARCHAR(255),
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_numbers_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_numbers_provider_id` (`provider_id`) REFERENCES `providers` (`id`) ON DELETE RESTRICT,
  UNIQUE KEY `uq_phone_number_provider` (`phone_number`, `provider_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_provider_id` (`provider_id`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_verification_status` (`verification_status`),
  INDEX `idx_expiration_date` (`expiration_date`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `number_id` BIGINT UNSIGNED,
  `provider_id` BIGINT UNSIGNED NOT NULL,
  `order_type` ENUM('purchase', 'renewal', 'upgrade', 'downgrade') DEFAULT 'purchase',
  `quantity` INT DEFAULT 1,
  `unit_price` DECIMAL(10, 2) NOT NULL,
  `total_amount` DECIMAL(15, 2) NOT NULL,
  `discount_amount` DECIMAL(15, 2) DEFAULT 0.00,
  `tax_amount` DECIMAL(15, 2) DEFAULT 0.00,
  `final_amount` DECIMAL(15, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `payment_method` ENUM('credit_card', 'paypal', 'bank_transfer', 'crypto', 'wallet') NOT NULL,
  `payment_reference_id` VARCHAR(255),
  `transaction_id` VARCHAR(255),
  `order_status` ENUM('pending', 'processing', 'completed', 'failed', 'cancelled', 'refunded') DEFAULT 'pending',
  `payment_status` ENUM('unpaid', 'paid', 'partially_refunded', 'fully_refunded') DEFAULT 'unpaid',
  `coupon_code` VARCHAR(100),
  `billing_cycle` ENUM('monthly', 'quarterly', 'yearly', 'one_time') DEFAULT 'one_time',
  `next_billing_date` TIMESTAMP NULL,
  `activation_date` TIMESTAMP NULL,
  `completion_date` TIMESTAMP NULL,
  `cancellation_date` TIMESTAMP NULL,
  `cancellation_reason` TEXT,
  `refund_amount` DECIMAL(15, 2) DEFAULT 0.00,
  `refund_date` TIMESTAMP NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_orders_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_orders_number_id` (`number_id`) REFERENCES `numbers` (`id`) ON DELETE SET NULL,
  FOREIGN KEY `fk_orders_provider_id` (`provider_id`) REFERENCES `providers` (`id`) ON DELETE RESTRICT,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_provider_id` (`provider_id`),
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_order_status` (`order_status`),
  INDEX `idx_payment_status` (`payment_status`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_completion_date` (`completion_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- MESSAGES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `number_id` BIGINT UNSIGNED NOT NULL,
  `provider_id` BIGINT UNSIGNED NOT NULL,
  `message_type` ENUM('inbound', 'outbound') DEFAULT 'inbound',
  `sender_number` VARCHAR(20) NOT NULL,
  `recipient_number` VARCHAR(20) NOT NULL,
  `message_content` LONGTEXT NOT NULL,
  `message_length` INT,
  `part_count` INT DEFAULT 1,
  `status` ENUM('received', 'sent', 'failed', 'pending', 'delivered') DEFAULT 'received',
  `delivery_status` ENUM('pending', 'delivered', 'failed', 'read') DEFAULT 'pending',
  `error_code` VARCHAR(50),
  `error_message` TEXT,
  `provider_message_id` VARCHAR(255),
  `reply_to_message_id` BIGINT UNSIGNED,
  `is_read` BOOLEAN DEFAULT FALSE,
  `read_at` TIMESTAMP NULL,
  `cost` DECIMAL(10, 2),
  `webhook_url` VARCHAR(500),
  `webhook_status` ENUM('pending', 'sent', 'failed') DEFAULT 'pending',
  `webhook_response` TEXT,
  `retry_count` INT DEFAULT 0,
  `last_retry_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_messages_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_messages_number_id` (`number_id`) REFERENCES `numbers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_messages_provider_id` (`provider_id`) REFERENCES `providers` (`id`) ON DELETE RESTRICT,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_provider_id` (`provider_id`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_sender_number` (`sender_number`),
  INDEX `idx_recipient_number` (`recipient_number`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_user_number_created` (`user_id`, `number_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- CALL LOGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `call_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `number_id` BIGINT UNSIGNED NOT NULL,
  `provider_id` BIGINT UNSIGNED NOT NULL,
  `caller_number` VARCHAR(20) NOT NULL,
  `recipient_number` VARCHAR(20) NOT NULL,
  `call_type` ENUM('incoming', 'outgoing', 'missed') DEFAULT 'incoming',
  `call_status` ENUM('connected', 'no_answer', 'busy', 'failed', 'completed') DEFAULT 'completed',
  `duration_seconds` INT DEFAULT 0,
  `start_time` TIMESTAMP NOT NULL,
  `end_time` TIMESTAMP NULL,
  `recording_url` VARCHAR(500),
  `recording_duration` INT,
  `provider_call_id` VARCHAR(255),
  `country_code` VARCHAR(5),
  `cost` DECIMAL(10, 2),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_call_logs_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_call_logs_number_id` (`number_id`) REFERENCES `numbers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_call_logs_provider_id` (`provider_id`) REFERENCES `providers` (`id`) ON DELETE RESTRICT,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_call_type` (`call_type`),
  INDEX `idx_start_time` (`start_time`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- TRANSACTIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `order_id` BIGINT UNSIGNED,
  `transaction_type` ENUM('credit', 'debit', 'refund', 'adjustment') DEFAULT 'debit',
  `amount` DECIMAL(15, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `balance_before` DECIMAL(15, 2),
  `balance_after` DECIMAL(15, 2),
  `description` VARCHAR(500),
  `reference_id` VARCHAR(255),
  `payment_method` VARCHAR(100),
  `status` ENUM('completed', 'pending', 'failed') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_transactions_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY `fk_transactions_order_id` (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_order_id` (`order_id`),
  INDEX `idx_transaction_type` (`transaction_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- AUDIT LOGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED,
  `action` VARCHAR(255) NOT NULL,
  `entity_type` VARCHAR(100),
  `entity_id` BIGINT UNSIGNED,
  `old_values` JSON,
  `new_values` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` TEXT,
  `status` VARCHAR(50),
  `error_message` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_audit_logs_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_entity_type` (`entity_type`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- VERIFICATION CODES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `verification_codes` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `code` VARCHAR(10) NOT NULL,
  `code_type` ENUM('email', 'sms', '2fa') DEFAULT 'email',
  `target` VARCHAR(255) NOT NULL,
  `is_used` BOOLEAN DEFAULT FALSE,
  `used_at` TIMESTAMP NULL,
  `expires_at` TIMESTAMP NOT NULL,
  `attempts` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_verification_codes_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_code_type` (`code_type`),
  INDEX `idx_is_used` (`is_used`),
  INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- COUPONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `coupons` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(100) NOT NULL UNIQUE,
  `discount_type` ENUM('percentage', 'fixed_amount') DEFAULT 'percentage',
  `discount_value` DECIMAL(10, 2) NOT NULL,
  `max_discount_amount` DECIMAL(15, 2),
  `min_order_amount` DECIMAL(15, 2),
  `usage_limit` INT,
  `usage_count` INT DEFAULT 0,
  `per_user_limit` INT DEFAULT 1,
  `is_active` BOOLEAN DEFAULT TRUE,
  `start_date` TIMESTAMP,
  `end_date` TIMESTAMP,
  `applicable_to` ENUM('all', 'providers', 'services') DEFAULT 'all',
  `applicable_providers` JSON,
  `created_by` BIGINT UNSIGNED,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_code` (`code`),
  INDEX `idx_is_active` (`is_active`),
  INDEX `idx_start_date` (`start_date`),
  INDEX `idx_end_date` (`end_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- WEBHOOK LOGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `webhook_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `event_type` VARCHAR(100) NOT NULL,
  `webhook_url` VARCHAR(500) NOT NULL,
  `payload` JSON,
  `response_code` INT,
  `response_body` TEXT,
  `attempt_count` INT DEFAULT 1,
  `last_attempt_at` TIMESTAMP,
  `status` ENUM('pending', 'delivered', 'failed') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_webhook_logs_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_event_type` (`event_type`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- USER NOTIFICATIONS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `user_notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED NOT NULL,
  `notification_type` VARCHAR(100) NOT NULL,
  `title` VARCHAR(255) NOT NULL,
  `message` TEXT NOT NULL,
  `data` JSON,
  `is_read` BOOLEAN DEFAULT FALSE,
  `read_at` TIMESTAMP NULL,
  `action_url` VARCHAR(500),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_user_notifications_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_notification_type` (`notification_type`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- SETTINGS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `settings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `user_id` BIGINT UNSIGNED,
  `setting_key` VARCHAR(255) NOT NULL,
  `setting_value` LONGTEXT,
  `setting_type` VARCHAR(50),
  `is_global` BOOLEAN DEFAULT FALSE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY `fk_settings_user_id` (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `uq_setting_key` (`setting_key`, `user_id`, `is_global`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_is_global` (`is_global`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- INDICES FOR PERFORMANCE
-- =====================================================

-- Additional compound indices for common queries
CREATE INDEX IF NOT EXISTS `idx_numbers_user_active` ON `numbers` (`user_id`, `is_active`);
CREATE INDEX IF NOT EXISTS `idx_messages_user_read` ON `messages` (`user_id`, `is_read`, `created_at`);
CREATE INDEX IF NOT EXISTS `idx_orders_user_status` ON `orders` (`user_id`, `order_status`, `created_at`);
CREATE INDEX IF NOT EXISTS `idx_call_logs_user_time` ON `call_logs` (`user_id`, `start_time`);

-- =====================================================
-- END OF SCHEMA
-- =====================================================
