<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Transaction;
use App\Models\TransactionStatusHistory;
use App\Models\WebhookEvent;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class WebhookController extends Controller
{
    /**
     * POST /api/v1/webhooks/aggregator/{provider}
     */
    public function handleAggregator(Request $request, string $provider): JsonResponse
    {
        // Verify HMAC signature
        $signature = $request->header('X-Signature');
        $payload = $request->getContent();

        // Log the webhook event
        $webhookEvent = WebhookEvent::create([
            'provider' => $provider,
            'signature_valid' => $this->verifySignature($signature, $payload, $provider),
            'payload' => $request->all(),
            'processed' => false,
        ]);

        if (!$webhookEvent->signature_valid) {
            return response()->json([
                'type' => 'INVALID_SIGNATURE',
                'title' => 'Signature invalide',
                'status' => 401,
                'detail' => 'La signature du webhook est invalide.',
                'request_id' => $request->header('X-Request-Id', ''),
            ], 401);
        }

        // Process the webhook payload asynchronously
        $this->processWebhook($webhookEvent);

        return response()->json(['status' => 'ok'], 200);
    }

    /**
     * POST /api/v1/webhooks/pispi
     */
    public function handlePispi(Request $request): JsonResponse
    {
        return $this->handleAggregator($request, 'pispi');
    }

    /**
     * Verify signature using HMAC.
     */
    private function verifySignature(?string $signature, string $payload, string $provider): bool
    {
  
