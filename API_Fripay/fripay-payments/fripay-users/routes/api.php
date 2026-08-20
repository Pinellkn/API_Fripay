<?php

use App\Http\Controllers\Api\Admin\CorridorController;
use App\Http\Controllers\Api\Admin\DashboardController;
use App\Http\Controllers\Api\Admin\StaffController;
use App\Http\Controllers\Api\Admin\TransactionController as AdminTransactionController;
use App\Http\Controllers\Api\Admin\UserController as AdminUserController;
use App\Http\Controllers\Api\Admin\AuthController as AdminAuthController;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ContactController;
use App\Http\Controllers\Api\LinkedAccountController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\TransferController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\WebhookController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| FriPay API Routes
|--------------------------------------------------------------------------
|
| Base path: /api/v1
| Conformes à la spécification technique FriPay
|
*/

// =========================================================================
// Routes publiques (SANS authentification)
// =========================================================================
Route::prefix('v1')->group(function () {

    // --- Authentification ---
    Route::post('/auth/register', [AuthController::class, 'register']);
    Route::post('/auth/verify-otp', [AuthController::class, 'verifyOtp']);
    Route::post('/auth/login', [AuthController::class, 'login']);
    Route::post('/auth/refresh-token', [AuthController::class, 'refreshToken']);

    // --- Webhooks (signature HMAC, pas de JWT) ---
    Route::post('/webhooks/aggregator/{provider}', [WebhookController::class, 'handleAggregator']);
    Route::post('/webhooks/pispi', [WebhookController::class, 'handlePispi']);

    // --- Admin Auth (back-office) ---
    Route::post('/admin/auth/login', [AdminAuthController::class, 'login']);

    // =========================================================================
    // Routes protégées (authentification Sanctum)
    // =========================================================================
    Route::middleware('auth:sanctum')->group(function () {

        // --- Session ---
        Route::post('/auth/logout', [AuthController::class, 'logout']);

        // --- Profil utilisateur ---
        Route::get('/users/me', [UserController::class, 'show']);
        Route::put('/users/me', [UserController::class, 'update']);
        Route::post('/users/me/pin', [UserController::class, 'setPin']);

        // --- Comptes mobile money liés ---
        Route::get('/users/me/accounts', [LinkedAccountController::class, 'index']);
        Route::post('/users/me/accounts', [LinkedAccountController::class, 'store'])
            ->middleware('idempotent');
        Route::delete('/users/me/accounts/{account_id}', [LinkedAccountController::class, 'destroy']);

        // --- Contacts favoris ---
        Route::get('/users/me/contacts', [ContactController::class, 'index']);
        Route::post('/users/me/contacts', [ContactController::class, 'store']);
        Route::delete('/users/me/contacts/{contact_id}', [ContactController::class, 'destroy']);

        // --- Transferts ---
        Route::post('/transfers/quote', [TransferController::class, 'quote']);
        Route::post('/transfers', [TransferController::class, 'initiate'])
            ->middleware('idempotent');
        Route::get('/transfers/{transaction_id}', [TransferController::class, 'show']);
        Route::get('/transfers', [TransferController::class, 'index']);
        Route::post('/transfers/{transaction_id}/cancel', [TransferController::class, 'cancel']);

        // --- Notifications ---
        Route::get('/notifications', [NotificationController::class, 'index']);
        Route::put('/notifications/{notification_id}/read', [NotificationController::class, 'markAsRead']);

        // =========================================================================
        // Routes Admin (Back-office) — RBAC vérifié par AdminRbac middleware
        // =========================================================================
        Route::prefix('admin')->middleware('admin:')->group(function () {

            // --- Utilisateurs ---
            Route::get('/users', [AdminUserController::class, 'index'])
                ->middleware('admin:users.read');
            Route::get('/users/{user_id}', [AdminUserController::class, 'show'])
                ->middleware('admin:users.read');
            Route::put('/users/{user_id}/status', [AdminUserController::class, 'updateStatus'])
                ->middleware('admin:users.block');

            // --- Transactions ---
            Route::get('/transactions', [AdminTransactionController::class, 'index'])
                ->middleware('admin:transactions.read');
            Route::get('/transactions/{transaction_id}', [AdminTransactionController::class, 'show'])
                ->middleware('admin:transactions.read');
            Route::post('/transactions/{transaction_id}/retry', [AdminTransactionController::class, 'retry'])
                ->middleware('admin:transactions.retry');

            // --- Corridors ---
            Route::get('/corridors', [CorridorController::class, 'index'])
                ->middleware('admin:corridors.read');
            Route::post('/corridors', [CorridorController::class, 'store'])
                ->middleware('admin:corridors.write');
            Route::put('/corridors/{corridor_id}', [CorridorController::class, 'update'])
                ->middleware('admin:corridors.write');

            // --- Dashboard ---
            Route::get('/dashboard/kpis', [DashboardController::class, 'kpis'])
                ->middleware('admin:dashboard.read');

            // --- Staff ---
            Route::get('/staff', [StaffController::class, 'index'])
                ->middleware('admin:staff.read');
            Route::post('/staff', [StaffController::class, 'store'])
                ->middleware('admin:staff.write');
            Route::put('/staff/{id}/role', [StaffController::class, 'updateRole'])
                ->middleware('admin:staff.write');
        });
    });
});

// Health check
Route::get('/up', function () {
    return response()->json(['status' => 'ok', 'service' => 'FriPay API', 'version' => 'v1']);
});
