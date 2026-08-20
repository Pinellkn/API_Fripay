<?php

use App\Http\Controllers\Api\TransferController;
use App\Http\Controllers\Api\WebhookController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| FriPay Payments Service API Routes
| Prefix: /api/v1
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // --- Webhooks (pas de JWT, signature HMAC) ---
    Route::post('/webhooks/aggregator/{provider}', [WebhookController::class, 'handleAggregator']);
    Route::post('/webhooks/pispi', [WebhookController::class, 'handlePispi']);

    // --- Routes protégées ---
    Route::middleware('auth:sanctum')->group(function () {

        // Simulation de frais
        Route::post('/transfers/quote', [TransferController::class, 'quote']);

        // Initiation (avec idempotence)
        Route::post('/transfers', [TransferController::class, 'initiate'])
            ->middleware('idempotent');

        // Suivi
        Route::get('/transfers/{transaction_id}', [TransferController::class, 'show']);
        Route::get('/transfers', [TransferController::class, 'index']);
        Route::post('/transfers/{transaction_id}/cancel', [TransferController::class, 'cancel']);
    });
});

// Health check
Route::get('/up', function () {
    return response()->json(['status' => 'ok', 'service' => 'FriPay Payments', 'version' => 'v1']);
});
