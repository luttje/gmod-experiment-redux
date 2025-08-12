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

    // Commented because in production we don't log all data since there's privacy-sensitive data in there
    // logMessage('Webhook data: '.json_encode($data, JSON_PRETTY_PRINT));

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
            $customData = $data['meta']['custom_data'] ?? [];

            // Extract tracking ID and other custom data
            $trackingId = $customData['tracking_id'] ?? '';
            $steamid64 = $customData['steamid64'] ?? '';
            $playerName = $customData['player_name'] ?? '';
            $packageKey = $customData['package_key'] ?? '';
            $packageType = $customData['package_type'] ?? 'package';

            if (empty($trackingId)) {
                logMessage('Missing tracking_id in custom data');
                http_response_code(400);
                echo json_encode(['error' => 'Missing tracking_id in custom data']);
                exit;
            }

            // Determine payment status based on order status
            $paymentStatus = 'pending';
            if ($orderStatus === 'paid') {
                $paymentStatus = 'completed';
                logMessage('Order is already paid, setting status to completed');
            }

            // Check if payment record exists using tracking ID
            $checkStmt = $pdo->prepare('SELECT payment_id FROM exp_premium WHERE tracking_id = ?');
            $checkStmt->execute([$trackingId]);

            if ($checkStmt->rowCount() > 0) {
                logMessage("Payment record found for tracking ID $trackingId, updating with LemonSqueezy order ID and status");

                // Update existing record with LemonSqueezy order ID and status
                $updateStmt = $pdo->prepare('
                    UPDATE exp_premium
                    SET status = ?, updated_at = ?, lemonsqueezy_order_id = ?
                    WHERE tracking_id = ?
                ');
                $updateStmt->execute([$paymentStatus, time(), $orderId, $trackingId]);

                logMessage("Updated payment record for tracking ID $trackingId with order ID $orderId and status: $paymentStatus");
            } else {
                logMessage("No payment record found for tracking ID $trackingId - this shouldn't happen in normal flow");

                // This shouldn't happen in normal flow, but we can create a record as fallback
                if (! empty($steamid64) && ! empty($packageKey)) {
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

                    $stmt = $pdo->prepare('
                        INSERT INTO exp_premium (
                            tracking_id, steamid64, player_name, cart_items,
                            total_price, currency, payment_url, status,
                            created_at, updated_at, lemonsqueezy_order_id
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                    ');

                    $stmt->execute([
                        $trackingId,
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

                    logMessage("Created fallback payment record for tracking ID $trackingId with order ID $orderId");
                } else {
                    logMessage('Cannot create fallback record - missing steamid64 or packageKey');
                }
            }
            break;

        case 'order_refunded':
            logMessage('Processing order_refunded event');

            $order = $data['data'];
            $orderId = $order['id'];

            // Update payment status to refunded using LemonSqueezy order ID
            $stmt = $pdo->prepare("
                UPDATE exp_premium
                SET status = 'refunded', updated_at = ?
                WHERE lemonsqueezy_order_id = ?
            ");

            $stmt->execute([time(), $orderId]);

            if ($stmt->rowCount() > 0) {
                logMessage("Updated payment status to refunded for order $orderId");
            } else {
                logMessage("No payment record found for LemonSqueezy order ID $orderId");
            }
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
