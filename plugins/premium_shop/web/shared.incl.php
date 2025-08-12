<?php

function loadEnv($filePath = null)
{
    if ($filePath === null) {
        $filePath = __DIR__.'/../.env';
    }

    if (! file_exists($filePath)) {
        throw new Exception('.env file not found at: '.$filePath);
    }

    $lines = file($filePath, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    $env = [];

    foreach ($lines as $line) {
        $line = trim($line);

        // Skip comments and empty lines
        if (empty($line) || strpos($line, '#') === 0) {
            continue;
        }

        // Parse key=value pairs
        if (strpos($line, '=') !== false) {
            [$name, $value] = explode('=', $line, 2);
            $name = trim($name);
            $value = trim($value, '"\''); // Remove quotes
            $env[$name] = $value;
        }
    }

    return $env;
}

function createDatabaseConnection($env)
{
    $host = $env['DB_HOST'] ?? 'localhost';
    $dbname = $env['DB_NAME'] ?? '';
    $username = $env['DB_USER'] ?? '';
    $password = $env['DB_PASSWORD'] ?? '';

    if (empty($dbname) || empty($username)) {
        throw new Exception('Missing required database environment variables');
    }

    try {
        $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password, [
            PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        ]);

        return $pdo;
    } catch (PDOException $e) {
        throw new Exception('Database connection failed: '.$e->getMessage());
    }
}

function logMessage($message, $logFile = null)
{
    if ($logFile === null) {
        $logFile = __DIR__.'/../webhook.log';
    }

    $timestamp = date('Y-m-d H:i:s');
    $logEntry = "[$timestamp] $message\n";
    file_put_contents($logFile, $logEntry, FILE_APPEND | LOCK_EX);

    // Also output to console if running from CLI or in test mode
    if (php_sapi_name() === 'cli' || (isset($_GET) && isset($_GET['debug']))) {
        echo $logEntry;
    }
}

function verifyWebhookSignature($payload, $signature, $secret)
{
    $expectedSignature = hash_hmac('sha256', $payload, $secret);

    return hash_equals($signature, $expectedSignature);
}

function isTestMode($env)
{
    return isset($env['TEST_ENABLED']) &&
           (strtolower($env['TEST_ENABLED']) === 'true' || $env['TEST_ENABLED'] === '1');
}
