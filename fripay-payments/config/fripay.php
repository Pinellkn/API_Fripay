<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Connecteurs de paiement mobile money
    |--------------------------------------------------------------------------
    |
    | Chaque réseau GSM (MTN, Moov, Celtiis) dispose d'une API native. Chaque
    | intégration implémente App\Contracts\TransferConnector et est déclarée
    | ici, soit par opérateur (code), soit par fournisseur de corridor
    | (rail / aggregator_provider).
    |
    | 'connectors' => [
    |     // 'MTN'     => \App\Services\Connectors\MtnMomoConnector::class,
    |     // 'MOOV'    => \App\Services\Connectors\MoovMoneyConnector::class,
    |     // 'CELTIIS' => \App\Services\Connectors\CeltiisConnector::class,
    | ],
    |
    | Tant qu'aucun connecteur n'est enregistré, les transferts acceptés
    | restent en file d'attente (outbox) et sont exécutés dès qu'un
    | connecteur devient disponible.
    |
    */
    'connectors' => [
        // API native MTN (produit Disbursements). Sans clés MTN_MOMO_*,
        // isConfigured() vaut false : les transferts MTN restent en file.
        'MTN' => \App\Services\Connectors\MtnMomoConnector::class,
    ],

    /*
    |--------------------------------------------------------------------------
    | File d'attente des transferts différés (outbox)
    |--------------------------------------------------------------------------
    |
    | Quand le connecteur du réseau est injoignable (réseau, timeout, HTTP
    | 5xx) ou non encore intégré, le transfert est accepté en statut 'pending'
    | et mis en file d'attente locale. La commande `transfers:process-pending`
    | (ou le flush opportuniste déclenché par GET /transfers/...) le traite
    | dès que la connexion revient.
    |
    */
    /*
    |--------------------------------------------------------------------------
    | Connecteur MTN MoMo (API native, produit Disbursements)
    |--------------------------------------------------------------------------
    |
    | Clés : https://momodeveloper.mtn.com (créer un API User + API Key)
    |
    */
    'mtn_momo' => [
        'api_user'           => env('MTN_MOMO_API_USER'),
        'api_key'            => env('MTN_MOMO_API_KEY'),
        'subscription_key'   => env('MTN_MOMO_SUBSCRIPTION_KEY'),
        'target_environment' => env('MTN_MOMO_TARGET_ENVIRONMENT', 'sandbox'),
        'base_url'           => env('MTN_MOMO_BASE_URL', 'https://sandbox.momodeveloper.mtn.com'),
        'callback_url'       => env('MTN_MOMO_CALLBACK_URL'),
    ],

    'outbox' => [
        'enabled' => (bool) env('FRIPAY_OUTBOX_ENABLED', true),

        // Nombre maximal de tentatives avant échec définitif de la transaction.
        'max_attempts' => (int) env('FRIPAY_OUTBOX_MAX_ATTEMPTS', 10),

        // Backoff exponentiel : base (s) * 2^(tentative-1), plafonné à backoff_max.
        'backoff_base_seconds' => (int) env('FRIPAY_OUTBOX_BACKOFF_BASE', 60),
        'backoff_max_seconds'  => (int) env('FRIPAY_OUTBOX_BACKOFF_MAX', 86400),

        // Délai avant de re-tester un transfert dont le connecteur n'est pas
        // encore disponible (aucune tentative consommée dans ce cas).
        'no_connector_retry_seconds' => (int) env('FRIPAY_OUTBOX_NO_CONNECTOR_RETRY', 3600),

        // Nombre d'items traités par exécution (commande ou flush opportuniste).
        'batch_size' => (int) env('FRIPAY_OUTBOX_BATCH_SIZE', 10),
    ],

];
