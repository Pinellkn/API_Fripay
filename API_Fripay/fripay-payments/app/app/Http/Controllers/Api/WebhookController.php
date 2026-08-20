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
        $signature = $request->header('X-Signature');
        $payload = $request->getContent();

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
        if (!$signature) {
            return false;
        }

        $secret = config("services.{$provider}.webhook_secret", '');

        if (empty($secret)) {
            return false;
        }

        $expected = hash_hmac('sha256', $payload, $secret);

        return hash_equals($expected, $signature);
    }

    /**
     * Process a webhook event (update transaction status).
     */
    private function processWebhook(WebhookEvent $event): void
    {
        $payload = $event->payload;
        $externalRef = $payload['transaction_id'] ?? $payload['reference'] ?? null;

        if (!$externalRef) {
            $event->update(['processing_error' => 'Missing transaction reference']);
            return;
        }

        $transaction = Transaction::where('external_reference', $externalRef)->first();

        if (!$transaction) {
            $event->update(['processing_error' => 'Transaction not found']);
            return;
        }

        $newStatus = match ($payload['status'] ?? '') {
            'success', 'completed' => 'succeeded',
            'failed', 'error' => 'failed',
            'pending' => 'pending',
            default => null,
        };

        if ($newStatus) {
            $previousStatus = $transaction->status;
            $transaction->update([
                'status' => $newStatus,
                'completed_at' => in_array($newStatus, ['succeeded', 'failed']) ? now() : $transaction->completed_at,
            ]);

            TransactionStatusHistory::create([
                'transaction_id' => $transaction->id,
                'previous_status' => $previousStatus,
                'new_status' => $newStatus,
                'source' => 'webhook',
                'note' => "Mis à jour via webhook {$event->provider}",
            ]);
        }

        $event->update(['processed' => true]);
    }
}
