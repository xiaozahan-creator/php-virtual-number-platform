-- MySQL Schema for PHP Virtual Number Platform
-- Created: 2026-01-14 12:23:55 UTC
-- Description: Complete database schema for virtual number platform

-- =====================================================
-- USERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `username` VARCHAR(255) NOT NULL UNIQUE,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `password_hash` VARCHAR(255) NOT NULL,
  `full_name` VARCHAR(255),
  `phone_number` VARCHAR(20),
  `profile_picture_url` VARCHAR(500),
  `bio` TEXT,
  `country` VARCHAR(100),
  `city` VARCHAR(100),
  `address` TEXT,
  `postal_code` VARCHAR(20),
  `account_type` ENUM('personal', 'business') DEFAULT 'personal',
  `status` ENUM('active', 'inactive', 'suspended', 'deleted') DEFAULT 'active',
  `email_verified` BOOLEAN DEFAULT FALSE,
  `phone_verified` BOOLEAN DEFAULT FALSE,
  `two_factor_enabled` BOOLEAN DEFAULT FALSE,
  `last_login_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `deleted_at` TIMESTAMP NULL,
  INDEX `idx_email` (`email`),
  INDEX `idx_username` (`username`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- PROVIDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `providers` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(255) NOT NULL UNIQUE,
  `slug` VARCHAR(255) NOT NULL UNIQUE,
  `description` TEXT,
  `logo_url` VARCHAR(500),
  `website` VARCHAR(500),
  `api_key` VARCHAR(500),
  `api_secret` VARCHAR(500),
  `api_endpoint` VARCHAR(500),
  `country` VARCHAR(100),
  `supported_services` JSON,
  `status` ENUM('active', 'inactive', 'testing', 'deprecated') DEFAULT 'active',
  `rating` DECIMAL(3, 2) DEFAULT 0.00,
  `total_ratings` INT DEFAULT 0,
  `success_rate` DECIMAL(5, 2) DEFAULT 100.00,
  `total_transactions` INT UNSIGNED DEFAULT 0,
  `response_time_ms` INT DEFAULT 0,
  `uptime_percentage` DECIMAL(5, 2) DEFAULT 100.00,
  `support_email` VARCHAR(255),
  `support_phone` VARCHAR(20),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY `idx_slug` (`slug`),
  INDEX `idx_status` (`status`),
  INDEX `idx_country` (`country`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- NUMBERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `numbers` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `provider_id` INT UNSIGNED NOT NULL,
  `number` VARCHAR(20) NOT NULL UNIQUE,
  `country_code` VARCHAR(5) NOT NULL,
  `country_name` VARCHAR(100),
  `service_type` VARCHAR(100),
  `number_type` ENUM('mobile', 'landline', 'toll-free', 'virtual') DEFAULT 'virtual',
  `is_available` BOOLEAN DEFAULT TRUE,
  `owner_user_id` INT UNSIGNED,
  `rental_start_date` TIMESTAMP NULL,
  `rental_end_date` TIMESTAMP NULL,
  `auto_renewal` BOOLEAN DEFAULT TRUE,
  `monthly_cost` DECIMAL(10, 2),
  `yearly_cost` DECIMAL(10, 2),
  `price` DECIMAL(10, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `status` ENUM('available', 'rented', 'reserved', 'inactive', 'expired') DEFAULT 'available',
  `rating` DECIMAL(3, 2) DEFAULT 0.00,
  `features` JSON,
  `description` TEXT,
  `sms_enabled` BOOLEAN DEFAULT TRUE,
  `call_enabled` BOOLEAN DEFAULT TRUE,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_number` (`number`),
  INDEX `idx_country_code` (`country_code`),
  INDEX `idx_is_available` (`is_available`),
  INDEX `idx_owner_user_id` (`owner_user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_provider_id` (`provider_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ORDERS TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `order_number` VARCHAR(255) NOT NULL UNIQUE,
  `user_id` INT UNSIGNED NOT NULL,
  `number_id` INT UNSIGNED NOT NULL,
  `provider_id` INT UNSIGNED NOT NULL,
  `order_type` ENUM('rental', 'purchase', 'renewal', 'upgrade', 'downgrade') DEFAULT 'rental',
  `duration_days` INT,
  `duration_type` ENUM('days', 'months', 'years', 'lifetime') DEFAULT 'months',
  `quantity` INT DEFAULT 1,
  `unit_price` DECIMAL(10, 2) NOT NULL,
  `discount_amount` DECIMAL(10, 2) DEFAULT 0.00,
  `tax_amount` DECIMAL(10, 2) DEFAULT 0.00,
  `total_amount` DECIMAL(10, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `payment_method` ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'crypto', 'bank_transfer', 'wallet') DEFAULT 'credit_card',
  `payment_status` ENUM('pending', 'processing', 'completed', 'failed', 'refunded', 'cancelled') DEFAULT 'pending',
  `transaction_id` VARCHAR(255),
  `status` ENUM('pending', 'confirmed', 'active', 'completed', 'cancelled', 'expired') DEFAULT 'pending',
  `rental_start_date` TIMESTAMP NULL,
  `rental_end_date` TIMESTAMP NULL,
  `auto_renew` BOOLEAN DEFAULT TRUE,
  `notes` TEXT,
  `ip_address` VARCHAR(45),
  `user_agent` VARCHAR(500),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `completed_at` TIMESTAMP NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`number_id`) REFERENCES `numbers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  UNIQUE KEY `idx_order_number` (`order_number`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_provider_id` (`provider_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_payment_status` (`payment_status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- MESSAGES TABLE
-- =====================================================
CREATE TABLE IF NOT EXISTS `messages` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `number_id` INT UNSIGNED NOT NULL,
  `provider_id` INT UNSIGNED NOT NULL,
  `order_id` INT UNSIGNED,
  `user_id` INT UNSIGNED NOT NULL,
  `sender_number` VARCHAR(20),
  `recipient_number` VARCHAR(20) NOT NULL,
  `message_type` ENUM('sms', 'mms', 'call', 'whatsapp', 'telegram', 'email') DEFAULT 'sms',
  `message_content` LONGTEXT,
  `message_subject` VARCHAR(255),
  `attachments` JSON,
  `status` ENUM('received', 'sent', 'pending', 'failed', 'read', 'delivered') DEFAULT 'received',
  `direction` ENUM('inbound', 'outbound') DEFAULT 'inbound',
  `message_length` INT,
  `character_count` INT,
  `is_read` BOOLEAN DEFAULT FALSE,
  `read_at` TIMESTAMP NULL,
  `response_required` BOOLEAN DEFAULT FALSE,
  `is_spam` BOOLEAN DEFAULT FALSE,
  `is_archived` BOOLEAN DEFAULT FALSE,
  `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
  `tags` JSON,
  `external_message_id` VARCHAR(255),
  `error_code` VARCHAR(50),
  `error_message` VARCHAR(500),
  `retry_count` INT DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`number_id`) REFERENCES `numbers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`provider_id`) REFERENCES `providers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_direction` (`direction`),
  INDEX `idx_message_type` (`message_type`),
  INDEX `idx_recipient_number` (`recipient_number`),
  INDEX `idx_sender_number` (`sender_number`),
  INDEX `idx_is_read` (`is_read`),
  INDEX `idx_created_at` (`created_at`),
  INDEX `idx_order_id` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =====================================================
-- ADDITIONAL SUPPORTING TABLES
-- =====================================================

-- Wallet/Balance Table
CREATE TABLE IF NOT EXISTS `wallet_balance` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL UNIQUE,
  `balance` DECIMAL(15, 2) DEFAULT 0.00,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `total_deposited` DECIMAL(15, 2) DEFAULT 0.00,
  `total_spent` DECIMAL(15, 2) DEFAULT 0.00,
  `last_transaction_at` TIMESTAMP NULL,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Payment Transactions Table
CREATE TABLE IF NOT EXISTS `payment_transactions` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `order_id` INT UNSIGNED,
  `transaction_type` ENUM('deposit', 'withdrawal', 'payment', 'refund', 'transfer') DEFAULT 'payment',
  `amount` DECIMAL(15, 2) NOT NULL,
  `currency` VARCHAR(3) DEFAULT 'USD',
  `payment_method` ENUM('credit_card', 'debit_card', 'paypal', 'stripe', 'crypto', 'bank_transfer', 'wallet') DEFAULT 'credit_card',
  `status` ENUM('pending', 'processing', 'completed', 'failed', 'refunded') DEFAULT 'pending',
  `gateway_transaction_id` VARCHAR(255),
  `reference_number` VARCHAR(255),
  `description` TEXT,
  `ip_address` VARCHAR(45),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Reviews and Ratings Table
CREATE TABLE IF NOT EXISTS `reviews` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED NOT NULL,
  `number_id` INT UNSIGNED NOT NULL,
  `order_id` INT UNSIGNED,
  `rating` INT CHECK (rating >= 1 AND rating <= 5),
  `title` VARCHAR(255),
  `comment` TEXT,
  `helpful_count` INT DEFAULT 0,
  `unhelpful_count` INT DEFAULT 0,
  `is_verified_purchase` BOOLEAN DEFAULT FALSE,
  `status` ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`number_id`) REFERENCES `numbers` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  INDEX `idx_number_id` (`number_id`),
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_rating` (`rating`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Support Tickets Table
CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `ticket_number` VARCHAR(255) NOT NULL UNIQUE,
  `user_id` INT UNSIGNED NOT NULL,
  `order_id` INT UNSIGNED,
  `subject` VARCHAR(500) NOT NULL,
  `description` LONGTEXT NOT NULL,
  `priority` ENUM('low', 'normal', 'high', 'urgent') DEFAULT 'normal',
  `category` VARCHAR(100),
  `status` ENUM('open', 'in_progress', 'waiting_customer', 'resolved', 'closed') DEFAULT 'open',
  `assigned_to_user_id` INT UNSIGNED,
  `resolution_notes` LONGTEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `resolved_at` TIMESTAMP NULL,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE SET NULL,
  FOREIGN KEY (`assigned_to_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_status` (`status`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Activity Log Table
CREATE TABLE IF NOT EXISTS `activity_logs` (
  `id` INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT UNSIGNED,
  `action` VARCHAR(255) NOT NULL,
  `entity_type` VARCHAR(100),
  `entity_id` INT UNSIGNED,
  `changes` JSON,
  `ip_address` VARCHAR(45),
  `user_agent` VARCHAR(500),
  `status` ENUM('success', 'failure', 'warning') DEFAULT 'success',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  INDEX `idx_user_id` (`user_id`),
  INDEX `idx_action` (`action`),
  INDEX `idx_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
