<?php

/**
 * Test script for LemonSqueezy webhook
 * Usage:
 * - http://localhost/test.php?paid - Test completed order
 * - http://localhost/test.php?pending - Test pending order
 * - http://localhost/test.php?refunded - Test refunded order
 * - http://localhost/test.php?custom&steamid=76561198000000000&package=supporter_role - Custom test
 */

require_once 'shared.incl.php';

try {
    // Load environment
    $env = loadEnv();

    // Check if testing is enabled
    if (! isTestMode($env)) {
        http_response_code(403);
        exit('Testing is not enabled. Set TEST_ENABLED=true in .env file.');
    }

    // Generate test data based on query parameters
    $testData = generateTestData();

    if (! $testData) {
        http_response_code(400);
        exit('Invalid test parameters. Use ?paid, ?pending, ?refunded, or ?custom with steamid and package parameters.');
    }

    // Log the test
    logMessage('=== WEBHOOK TEST START ===');
    logMessage('Test type: '.$testData['type']);
    logMessage('Test data: '.json_encode($testData['payload'], JSON_PRETTY_PRINT));

    // Call the webhook
    $result = callWebhook($testData['payload'], $env);

    // Display results
    header('Content-Type: text/html; charset=utf-8');
    ?>
    <!DOCTYPE html>
    <html>
    <head>
        <title>LemonSqueezy Webhook Test</title>
        <style>
            body { font-family: monospace; margin: 20px; background: #f5f5f5; }
            .container { max-width: 800px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
            .success { color: #22c55e; }
            .error { color: #ef4444; }
            .info { color: #3b82f6; }
            pre { background: #f8f9fa; padding: 15px; border-radius: 4px; overflow-x: auto; }
            .section { margin: 20px 0; padding: 15px; border-left: 4px solid #e5e7eb; }
            h2 { color: #374151; margin-top: 0; }
            .test-links { margin: 20px 0; }
            .test-links a { display: inline-block; margin: 5px; padding: 8px 16px; background: #3b82f6; color: white; text-decoration: none; border-radius: 4px; }
            .test-links a:hover { background: #2563eb; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>LemonSqueezy Webhook Test</h1>

            <div class="test-links">
                <strong>Quick Tests:</strong><br>
                <a href="?paid&debug">Test Paid Order</a>
                <a href="?pending&debug">Test Pending Order</a>
                <a href="?refunded&debug">Test Refunded Order</a>
                <a href="?custom&steamid=76561198123456789&package=supporter_role&debug">Test Custom Order</a>
            </div>

            <div class="section">
                <h2>Test Configuration</h2>
                <strong>Type:</strong> <?= htmlspecialchars($testData['type']) ?><br>
                <strong>Order ID:</strong> <?= htmlspecialchars($testData['payload']['data']['id']) ?><br>
                <strong>Status:</strong> <?= htmlspecialchars($testData['payload']['data']['attributes']['status'] ?? 'N/A') ?><br>
                <strong>SteamID:</strong> <?= htmlspecialchars($testData['steamid']) ?><br>
                <strong>Package:</strong> <?= htmlspecialchars($testData['package']) ?>
            </div>

            <div class="section">
                <h2>Webhook Response</h2>
                <?php if ($result['success']) { ?>
                    <span class="success">✓ Webhook executed successfully</span><br>
                    <strong>HTTP Status:</strong> <?= $result['http_code'] ?><br>
                    <strong>Response:</strong> <?= htmlspecialchars($result['response']) ?>
                <?php } else { ?>
                    <span class="error">✗ Webhook failed</span><br>
                    <strong>Error:</strong> <?= htmlspecialchars($result['error']) ?>
                <?php } ?>
            </div>

            <div class="section">
                <h2>Payload Sent</h2>
                <pre><?= htmlspecialchars(json_encode($testData['payload'], JSON_PRETTY_PRINT)) ?></pre>
            </div>

            <?php if (isset($_GET['debug'])) { ?>
            <div class="section">
                <h2>Debug Information</h2>
                <strong>Webhook URL:</strong> <?= htmlspecialchars($result['webhook_url']) ?><br>
                <strong>Signature:</strong> <?= htmlspecialchars($result['signature']) ?><br>
                <strong>Request Headers:</strong>
                <pre><?= htmlspecialchars(print_r($result['headers'], true)) ?></pre>
            </div>
            <?php } ?>

            <div class="section">
                <h2>Database Check</h2>
                <?php
                try {
                    $pdo = createDatabaseConnection($env);
                    $stmt = $pdo->prepare('SELECT * FROM exp_premium WHERE lemonsqueezy_order_id = ? ORDER BY created_at DESC LIMIT 1');
                    $stmt->execute([$testData['payload']['data']['id']]);
                    $dbRecord = $stmt->fetch();

                    if ($dbRecord) {
                        ?>
                    <span class="success">✓ Database record found</span>
                    <pre><?= htmlspecialchars(print_r($dbRecord, true)) ?></pre>
                <?php } else { ?>
                    <span class="error">✗ No database record found for this order</span>
                <?php }
                } catch (Exception $e) {
                    echo '<span class="error">✗ Database error: '.htmlspecialchars($e->getMessage()).'</span>';
                }
    ?>
            </div>
        </div>
    </body>
    </html>
    <?php

    logMessage('=== WEBHOOK TEST END ===');

} catch (Exception $e) {
    logMessage('Test error: '.$e->getMessage());
    http_response_code(500);
    exit('Test error: '.$e->getMessage());
}

function generateTestData()
{
    $baseOrderId = 'test_'.time().'_'.rand(1000, 9999);
    $baseSteamId = $_GET['steamid'] ?? '76561198123456789';
    $basePackage = $_GET['package'] ?? 'supporter_role';
    $playerName = 'TestPlayer_'.rand(100, 999);

    if (isset($_GET['paid'])) {
        return [
            'type' => 'paid_order',
            'steamid' => $baseSteamId,
            'package' => $basePackage,
            'payload' => createOrderPayload($baseOrderId, 'paid', $baseSteamId, $basePackage, $playerName),
        ];
    } elseif (isset($_GET['pending'])) {
        return [
            'type' => 'pending_order',
            'steamid' => $baseSteamId,
            'package' => $basePackage,
            'payload' => createOrderPayload($baseOrderId, 'pending', $baseSteamId, $basePackage, $playerName),
        ];
    } elseif (isset($_GET['refunded'])) {
        return [
            'type' => 'refunded_order',
            'steamid' => $baseSteamId,
            'package' => $basePackage,
            'payload' => createRefundPayload($baseOrderId),
        ];
    } elseif (isset($_GET['custom'])) {
        $status = $_GET['status'] ?? 'paid';

        return [
            'type' => 'custom_order',
            'steamid' => $baseSteamId,
            'package' => $basePackage,
            'payload' => createOrderPayload($baseOrderId, $status, $baseSteamId, $basePackage, $playerName),
        ];
    }

    return null;
}

function createOrderPayload($orderId, $status, $steamId, $packageKey, $playerName)
{
    $packagePrices = [
        'supporter_role' => 499,
        'sprites_colored' => 99,
        'sprites_graffiti_don' => 119,
        'sprites_graffiti_stencil' => 149,
    ];

    $price = $packagePrices[$packageKey] ?? 499;

    return [
        'meta' => [
            'event_name' => 'order_created',
            'test_mode' => true,
        ],
        'data' => [
            'type' => 'orders',
            'id' => $orderId,
            'attributes' => [
                'store_id' => 12345,
                'customer_id' => 67890,
                'identifier' => $orderId,
                'order_number' => rand(1000000, 9999999),
                'user_name' => $playerName,
                'user_email' => 'test@example.com',
                'currency' => 'EUR',
                'currency_rate' => '1.00000000',
                'subtotal' => $price,
                'discount_total' => 0,
                'tax' => 0,
                'total' => $price,
                'subtotal_usd' => $price,
                'discount_total_usd' => 0,
                'tax_usd' => 0,
                'total_usd' => $price,
                'tax_name' => null,
                'tax_rate' => '0.0000',
                'status' => $status,
                'status_formatted' => ucfirst($status),
                'refunded' => false,
                'refunded_at' => null,
                'subtotal_formatted' => '€'.number_format($price / 100, 2),
                'discount_total_formatted' => '€0.00',
                'tax_formatted' => '€0.00',
                'total_formatted' => '€'.number_format($price / 100, 2),
                'first_order_item' => [
                    'id' => rand(100000, 999999),
                    'order_id' => $orderId,
                    'product_id' => rand(10000, 99999),
                    'variant_id' => rand(10000, 99999),
                    'product_name' => ucfirst(str_replace('_', ' ', $packageKey)),
                    'variant_name' => 'Default',
                    'price' => $price,
                    'quantity' => 1,
                    'created_at' => date('Y-m-d\TH:i:s.000000\Z'),
                    'updated_at' => date('Y-m-d\TH:i:s.000000\Z'),
                    'test_mode' => true,
                    'product_options' => [
                        'custom_data' => json_encode([
                            'steamid64' => $steamId,
                            'player_name' => $playerName,
                            'package_key' => $packageKey,
                            'package_type' => 'package',
                            'server_name' => 'Test Server',
                        ]),
                    ],
                ],
                'urls' => [
                    'receipt' => 'https://test-store.lemonsqueezy.com/checkout/receipt/'.$orderId,
                ],
                'created_at' => date('Y-m-d\TH:i:s.000000\Z'),
                'updated_at' => date('Y-m-d\TH:i:s.000000\Z'),
                'test_mode' => true,
            ],
        ],
    ];
}

function createRefundPayload($orderId)
{
    return [
        'meta' => [
            'event_name' => 'order_refunded',
            'test_mode' => true,
        ],
        'data' => [
            'type' => 'orders',
            'id' => $orderId,
            'attributes' => [
                'refunded' => true,
                'refunded_at' => date('Y-m-d\TH:i:s.000000\Z'),
                'status' => 'refunded',
                'status_formatted' => 'Refunded',
                'updated_at' => date('Y-m-d\TH:i:s.000000\Z'),
            ],
        ],
    ];
}

function callWebhook($payload, $env)
{
    $webhookUrl = 'http://localhost'.dirname($_SERVER['REQUEST_URI']).'/webhook.php';
    $secret = $env['LEMONSQUEEZY_WEBHOOK_SECRET'] ?? 'test_secret';
    $payloadJson = json_encode($payload);
    $signature = hash_hmac('sha256', $payloadJson, $secret);

    $headers = [
        'Content-Type: application/json',
        'X-Signature: '.$signature,
        'User-Agent: LemonSqueezy-Test/1.0',
    ];

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $webhookUrl,
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $payloadJson,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => 30,
        CURLOPT_FOLLOWLOCATION => true,
        CURLOPT_SSL_VERIFYPEER => false, // For localhost testing
    ]);

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    $error = curl_error($ch);
    curl_close($ch);

    return [
        'success' => empty($error) && $httpCode >= 200 && $httpCode < 300,
        'http_code' => $httpCode,
        'response' => $response,
        'error' => $error,
        'webhook_url' => $webhookUrl,
        'signature' => $signature,
        'headers' => $headers,
    ];
}
?>
