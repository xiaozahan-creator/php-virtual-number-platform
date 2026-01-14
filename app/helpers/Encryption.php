<?php

namespace App\Helpers;

/**
 * Encryption Helper Class
 * 
 * Provides encryption and decryption utilities for protecting sensitive data
 * such as API keys, authentication tokens, and other confidential information
 * using OpenSSL functions.
 * 
 * @package App\Helpers
 * @author Development Team
 * @version 1.0.0
 */
class Encryption
{
    /**
     * Encryption algorithm to use
     */
    private const CIPHER = 'AES-256-CBC';

    /**
     * Hash algorithm for key derivation
     */
    private const HASH_ALGO = 'sha256';

    /**
     * Encryption key
     * 
     * @var string
     */
    private string $key;

    /**
     * Constructor
     * 
     * Initializes the encryption key from environment variable or config
     * 
     * @throws \Exception If encryption key is not set
     */
    public function __construct()
    {
        $this->key = env('APP_ENCRYPTION_KEY') ?? config('app.encryption_key') ?? null;

        if (empty($this->key)) {
            throw new \Exception('Encryption key (APP_ENCRYPTION_KEY) is not configured.');
        }

        // Ensure the key is the correct length for AES-256
        $this->key = hash(self::HASH_ALGO, $this->key, true);
    }

    /**
     * Encrypt data
     * 
     * Encrypts sensitive data using AES-256-CBC algorithm with a random IV
     * 
     * @param string|array $data Data to encrypt
     * @return string Base64 encoded encrypted string (format: base64_iv.base64_encrypted)
     * @throws \Exception If encryption fails
     */
    public function encrypt($data): string
    {
        try {
            // Convert array to JSON if necessary
            $plaintext = is_array($data) ? json_encode($data) : (string)$data;

            // Generate a random Initialization Vector (IV)
            $ivLength = openssl_cipher_iv_length(self::CIPHER);
            $iv = openssl_random_pseudo_bytes($ivLength);

            // Encrypt the data
            $encrypted = openssl_encrypt(
                $plaintext,
                self::CIPHER,
                $this->key,
                0, // options (0 = raw data, not base64)
                $iv
            );

            if ($encrypted === false) {
                throw new \Exception('OpenSSL encryption failed: ' . openssl_error_string());
            }

            // Combine IV and encrypted data, then base64 encode for safe storage/transmission
            $payload = base64_encode($iv . $encrypted);

            return $payload;
        } catch (\Exception $e) {
            throw new \Exception('Encryption error: ' . $e->getMessage());
        }
    }

    /**
     * Decrypt data
     * 
     * Decrypts previously encrypted data using the same key and algorithm
     * 
     * @param string $encrypted Base64 encoded encrypted string (format: base64_iv.base64_encrypted)
     * @param bool $returnArray Whether to return array (if JSON was encrypted) or string
     * @return string|array Decrypted data
     * @throws \Exception If decryption fails
     */
    public function decrypt(string $encrypted, bool $returnArray = false)
    {
        try {
            // Decode the base64 payload
            $payload = base64_decode($encrypted, true);

            if ($payload === false) {
                throw new \Exception('Invalid base64 encoding in encrypted data.');
            }

            // Extract IV and encrypted data
            $ivLength = openssl_cipher_iv_length(self::CIPHER);
            $iv = substr($payload, 0, $ivLength);
            $encryptedData = substr($payload, $ivLength);

            // Decrypt the data
            $decrypted = openssl_decrypt(
                $encryptedData,
                self::CIPHER,
                $this->key,
                0, // options (0 = raw data, not base64)
                $iv
            );

            if ($decrypted === false) {
                throw new \Exception('OpenSSL decryption failed: ' . openssl_error_string());
            }

            // Try to decode as JSON if requested
            if ($returnArray) {
                $decoded = json_decode($decrypted, true);
                if (json_last_error() === JSON_ERROR_NONE) {
                    return $decoded;
                }
            }

            return $decrypted;
        } catch (\Exception $e) {
            throw new \Exception('Decryption error: ' . $e->getMessage());
        }
    }

    /**
     * Hash data using SHA-256
     * 
     * Creates a one-way hash of sensitive data for verification purposes
     * 
     * @param string $data Data to hash
     * @return string Hexadecimal hash string
     */
    public function hash(string $data): string
    {
        return hash(self::HASH_ALGO, $data);
    }

    /**
     * Verify hashed data
     * 
     * Securely compares data against a hash using timing-safe comparison
     * 
     * @param string $data Original data
     * @param string $hash Hash to compare against
     * @return bool True if data matches hash
     */
    public function verifyHash(string $data, string $hash): bool
    {
        return hash_equals($this->hash($data), $hash);
    }

    /**
     * Generate a secure random token
     * 
     * Useful for generating API keys, session tokens, and other random values
     * 
     * @param int $length Length of the token in bytes
     * @return string Base64 encoded random token
     */
    public static function generateToken(int $length = 32): string
    {
        return base64_encode(openssl_random_pseudo_bytes($length));
    }

    /**
     * Generate a secure random key
     * 
     * Creates a random key suitable for encryption
     * 
     * @param int $length Length of the key in bytes
     * @return string Hexadecimal encoded random key
     */
    public static function generateKey(int $length = 32): string
    {
        return bin2hex(openssl_random_pseudo_bytes($length));
    }

    /**
     * Get cipher information
     * 
     * Returns information about the cipher being used
     * 
     * @return array Cipher metadata
     */
    public static function getCipherInfo(): array
    {
        return [
            'cipher' => self::CIPHER,
            'key_length' => openssl_cipher_iv_length(self::CIPHER) === 16 ? 256 : 128,
            'iv_length' => openssl_cipher_iv_length(self::CIPHER),
            'hash_algo' => self::HASH_ALGO,
        ];
    }

    /**
     * Safely encrypt sensitive array data
     * 
     * Useful for encrypting multiple related values at once
     * 
     * @param array $data Associative array of data to encrypt
     * @return array Encrypted array with same keys
     * @throws \Exception If encryption fails
     */
    public function encryptArray(array $data): array
    {
        $encrypted = [];

        foreach ($data as $key => $value) {
            if ($value !== null && $value !== '') {
                $encrypted[$key] = $this->encrypt($value);
            } else {
                $encrypted[$key] = $value;
            }
        }

        return $encrypted;
    }

    /**
     * Safely decrypt sensitive array data
     * 
     * Decrypts all values in an array
     * 
     * @param array $data Associative array of encrypted data
     * @return array Decrypted array with same keys
     * @throws \Exception If decryption fails
     */
    public function decryptArray(array $data): array
    {
        $decrypted = [];

        foreach ($data as $key => $value) {
            if ($value !== null && $value !== '') {
                $decrypted[$key] = $this->decrypt($value);
            } else {
                $decrypted[$key] = $value;
            }
        }

        return $decrypted;
    }
}
