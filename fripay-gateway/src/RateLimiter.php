<?php

/**
 * Rate Limiter — Token Bucket Algorithm
 *
 * Limite le nombre de requêtes par client (IP) en utilisant
 * un seau qui se remplit à un rythme constant.
 *
 * Stockage : fichier (1 fichier par IP). Adapté pour un déploiement
 * monoprocess PHP natif.
 */
class RateLimiter
{
    private string $storagePath;
    private int $bucketSize;
    private int $refillRate;

    public function __construct(array $config)
    {
        $this->storagePath = rtrim($config['storage_path'], '/\\');
        $this->bucketSize  = $config['bucket_size'];
        $this->refillRate  = $config['refill_rate'];
    }

    /**
     * Vérifie si une requête est autorisée.
     * 
     * @return array [ 'allowed' => bool, 'remaining' => int, 'retry_after' => int (seconds) ]
     */
    public function allow(string $clientKey): array
    {
        $state = $this->loadState($clientKey);
        $now   = microtime(true);

        // Reconstituer les tokens écoulés depuis la dernière requête
        $elapsed       = $now - $state['last_request_at'];
        $newTokens     = $state['tokens'] + ($elapsed * $this->refillRate);
        $state['tokens'] = min($this->bucketSize, $newTokens);
        $state['last_request_at'] = $now;

        if ($state['tokens'] >= 1) {
            $state['tokens'] -= 1;
            $allowed       = true;
            $remaining     = (int) floor($state['tokens']);
            $retryAfter    = 0;
        } else {
            $allowed    = false;
            $remaining  = 0;
            // Temps nécessaire pour récupérer au moins 1 token
            $retryAfter = (int) ceil((1 - $state['tokens']) / $this->refillRate);
        }

        $this->saveState($clientKey, $state);

        return [
            'allowed'      => $allowed,
            'remaining'    => $remaining,
            'retry_after'  => $retryAfter,
            'limit'        => $this->bucketSize,
        ];
    }

    /**
     * Charge l'état du seau depuis le fichier.
     */
    private function loadState(string $key): array
    {
        $path = $this->getFilePath($key);

        if (!file_exists($path)) {
            return [
                'tokens'          => $this->bucketSize,
                'last_request_at' => microtime(true),
            ];
        }

        $data = @file_get_contents($path);
        if ($data === false) {
            return [
                'tokens'          => $this->bucketSize,
                'last_request_at' => microtime(true),
            ];
        }

        $state = json_decode($data, true);
        if (!is_array($state)) {
            return [
                'tokens'          => $this->bucketSize,
                'last_request_at' => microtime(true),
            ];
        }

        return $state;
    }

    /**
     * Sauvegarde l'état du seau.
     */
    private function saveState(string $key, array $state): void
    {
        $path = $this->getFilePath($key);
        @file_put_contents($path, json_encode($state), LOCK_EX);
    }

    /**
     * Nettoyage : supprime les fichiers des clients inactifs depuis plus de 1 heure.
     */
    public function cleanExpired(): void
    {
        $files = glob($this->storagePath . '/*.json');
        $now   = time();

        foreach ($files as $file) {
            if ($now - filemtime($file) > 3600) {
                @unlink($file);
            }
        }
    }

    private function getFilePath(string $key): string
    {
        $safeKey = preg_replace('/[^a-zA-Z0-9_.-]/', '_', $key);
        return $this->storagePath . '/' . $safeKey . '.json';
    }
}
