<?php

/**
 * Circuit Breaker
 *
 * Protège les microservices en aval en arrêtant de leur envoyer
 * du trafic lorsqu'ils sont détectés comme défaillants.
 *
 * États :
 * - CLOSED  : fonctionnement normal
 * - OPEN    : le circuit est ouvert, les requêtes sont rejetées immédiatement
 * - HALF_OPEN : période de test, on laisse passer une requête pour vérifier
 */
class CircuitBreaker
{
    private string $storagePath;
    private int $failureThreshold;
    private int $successThreshold;
    private int $openTimeoutSeconds;

    public function __construct(array $config)
    {
        $this->storagePath       = rtrim($config['storage_path'], '/\\');
        $this->failureThreshold  = $config['failure_threshold'];
        $this->successThreshold  = $config['success_threshold'];
        $this->openTimeoutSeconds = $config['open_timeout_seconds'];
    }

    /**
     * Vérifie si le circuit pour un service donné est fermé (autorise la requête).
     */
    public function isAvailable(string $serviceKey): bool
    {
        $state = $this->loadState($serviceKey);

        switch ($state['state']) {
            case 'closed':
                return true;

            case 'open':
                // Vérifier si le temps d'attente est écoulé → passage en half-open
                if (time() - $state['opened_at'] >= $this->openTimeoutSeconds) {
                    $state['state']    = 'half_open';
                    $state['successes'] = 0;
                    $this->saveState($serviceKey, $state);
                    return true;
                }
                return false;

            case 'half_open':
                // En half-open, on ne laisse passer qu'une requête à la fois
                // (ici on permet 1 requête ; si elle réussit, on ferme)
                return true;

            default:
                return true;
        }
    }

    /**
     * Enregistre un succès pour un service.
     */
    public function recordSuccess(string $serviceKey): void
    {
        $state = $this->loadState($serviceKey);

        switch ($state['state']) {
            case 'half_open':
                $state['successes']++;
                if ($state['successes'] >= $this->successThreshold) {
                    $state['state']     = 'closed';
                    $state['failures']   = 0;
                    $state['successes']  = 0;
                    $state['opened_at']  = null;
                }
                break;

            case 'closed':
                // Réinitialiser le compteur d'échecs après un succès
                $state['failures'] = 0;
                break;

            default:
                break;
        }

        $this->saveState($serviceKey, $state);
    }

    /**
     * Enregistre un échec pour un service.
     */
    public function recordFailure(string $serviceKey): void
    {
        $state = $this->loadState($serviceKey);

        $state['failures']++;

        if ($state['state'] === 'half_open') {
            // En half-open, un seul échec rouvre le circuit
            $state['state']    = 'open';
            $state['opened_at'] = time();
            $state['successes'] = 0;
        } elseif ($state['state'] === 'closed' && $state['failures'] >= $this->failureThreshold) {
            $state['state']    = 'open';
            $state['opened_at'] = time();
            $state['successes'] = 0;
        }

        $this->saveState($serviceKey, $state);
    }

    /**
     * Récupère l'état actuel du circuit (pour monitoring / debug).
     */
    public function getState(string $serviceKey): array
    {
        $state = $this->loadState($serviceKey);

        return [
            'service'       => $serviceKey,
            'state'         => $state['state'],
            'failures'      => $state['failures'],
            'remaining_retry' => $state['state'] === 'open'
                ? max(0, $this->openTimeoutSeconds - (time() - $state['opened_at']))
                : 0,
        ];
    }

    // ------------------------------------------------------------------ //
    //  Stockage fichier
    // ------------------------------------------------------------------ //

    private function loadState(string $key): array
    {
        $path = $this->getFilePath($key);

        if (!file_exists($path)) {
            return [
                'state'     => 'closed',
                'failures'  => 0,
                'successes' => 0,
                'opened_at' => null,
            ];
        }

        $data = @file_get_contents($path);
        if ($data === false) {
            return [
                'state'     => 'closed',
                'failures'  => 0,
                'successes' => 0,
                'opened_at' => null,
            ];
        }

        $state = json_decode($data, true);
        if (!is_array($state)) {
            return [
                'state'     => 'closed',
                'failures'  => 0,
                'successes' => 0,
                'opened_at' => null,
            ];
        }

        return $state;
    }

    private function saveState(string $key, array $state): void
    {
        $path = $this->getFilePath($key);
        @file_put_contents($path, json_encode($state), LOCK_EX);
    }

    private function getFilePath(string $key): string
    {
        $safeKey = preg_replace('/[^a-zA-Z0-9_.-]/', '_', $key);
        return $this->storagePath . '/' . $safeKey . '.json';
    }
}
