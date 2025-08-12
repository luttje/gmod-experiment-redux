<?php

/**
 * LemonSqueezy Webhook Handler for Premium Shop
 * Place this file at billing.experiment.games/webhook.php
 */

require_once 'shared.incl.php';

header('Content-Type: application/json');

try {
    // Load environment variables
    $env = loadEnv();

    // Database connection
    $lemonsqueezy_secret = $env['LEMONSQUEEZY_WEBHOOK_SECRET'] ?? '';

    if (empty($lemonsqueezy_secret)) {
        throw new Exception('Missing LEMONSQUEEZY_WEBHOOK_SECRET environment variable');
    }

    // Get webhook payload
    $payload = file_get_contents('php://input');
    $headers = getallheaders();
    $signature = $headers['X-Signature'] ?? '';

    logMessage("Webhook received - Signature: $signature");

    // Verify signature
    if (! verifyWebhookSignature($payload, $signature, $lemonsqueezy_secret)) {
        logMessage('Invalid webhook signature');
        http_response_code(401);
        echo json_encode(['error' => 'Invalid signature']);
        exit;
    }

    // Parse webhook data
    $data = json_decode($payload, true);
    if (! $data) {
        throw new Exception('Invalid JSON payload');
    }

    logMessage('Webhook data: '.json_encode($data, JSON_PRETTY_PRINT));

    // Connect to database
    $pdo = createDatabaseConnection($env);

    // Handle different webhook events
    $eventName = $data['meta']['event_name'] ?? '';

    switch ($eventName) {
        case 'order_created':
            logMessage('Processing order_created event');

            $order = $data['data'];
            $orderId = $order['id'];
            $orderStatus = $order['attributes']['status'] ?? '';
            $orderStatusFormatted = $order['attributes']['status_formatted'] ?? '';

            logMessage("Order status: $orderStatus, formatted: $orderStatusFormatted");

            // Extract custom data from the order
            $customData = json_decode($order['attributes']['first_order_item']['product_options']['custom_data'] ?? '{}', true);

            // Extract custom data
            $steamid64 = $customData['steamid64'] ?? '';
            $playerName = $customData['player_name'] ?? '';
            $packageKey = $customData['package_key'] ?? '';
            $packageType = $customData['package_type'] ?? 'package';

            if (empty($steamid64) || empty($packageKey)) {
                logMessage("Missing required custom data: steamid64=$steamid64, packageKey=$packageKey");
                http_response_code(400);
                echo json_encode(['error' => 'Missing required custom data']);
                exit;
            }

            $cartItems = json_encode([
                [
                    'type' => $packageType,
                    'key' => $packageKey,
                    'quantity' => 1,
                ],
            ]);

            $totalPrice = $order['attributes']['total'] / 100; // Convert from cents
            $currency = strtoupper($order['attributes']['currency']);
            $currentTime = time();

            // Determine initial status based on order status
            $paymentStatus = 'pending';
            if ($orderStatus === 'paid') {
                $paymentStatus = 'completed';
                logMessage('Order is already paid, setting status to completed');
            }

            // Check if payment record already exists
            $checkStmt = $pdo->prepare('SELECT payment_id FROM exp_premium WHERE lemonsqueezy_order_id = ?');
            $checkStmt->execute([$orderId]);

            if ($checkStmt->rowCount() > 0) {
                logMessage("Payment record already exists for order $orderId, updating status if needed");

                // Update existing record
                $updateStmt = $pdo->prepare('
                    UPDATE exp_premium
                    SET status = ?, updated_at = ?
                    WHERE lemonsqueezy_order_id = ?
                ');
                $updateStmt->execute([$paymentStatus, $currentTime, $orderId]);
            } else {
                // Create new payment record
                $stmt = $pdo->prepare('
                    INSERT INTO exp_premium (
                        session_id, steamid64, player_name, cart_items,
                        total_price, currency, payment_url, status,
                        created_at, updated_at, lemonsqueezy_order_id
                    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ');

                $stmt->execute([
                    $orderId, // Use order ID as session ID
                    $steamid64,
                    $playerName,
                    $cartItems,
                    $totalPrice,
                    $currency,
                    '', // No payment URL for LemonSqueezy
                    $paymentStatus,
                    $currentTime,
                    $currentTime,
                    $orderId,
                ]);

                logMessage("Created payment record for order $orderId with status: $paymentStatus");
            }
            break;

        case 'order_refunded':
            logMessage('Processing order_refunded event');

            $order = $data['data'];
            $orderId = $order['id'];

            // Update payment status to refunded
            $stmt = $pdo->prepare("
                UPDATE exp_premium
                SET status = 'refunded', updated_at = ?
                WHERE lemonsqueezy_order_id = ?
            ");

            $stmt->execute([time(), $orderId]);

            logMessage("Updated payment status to refunded for order $orderId");
            break;

        default:
            logMessage("Unhandled webhook event: $eventName");
            break;
    }

    // Respond with success
    http_response_code(200);
    echo json_encode(['status' => 'success']);

} catch (Exception $e) {
    logMessage('Error: '.$e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
