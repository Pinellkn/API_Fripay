<?php

/**
 * FriPay API Gateway
 * Point d'entrée unique qui route les requêtes vers les microservices
 */

header('Content-Type: application/json; charset=utf-8');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization, Idempotency-Key, X-Request-Id, Accept-Language, X-Signature');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(204);
    exit;
}

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH);

function getServiceUrl(string $path): ?string {
    if (str_starts_with($path, '/api/v1/admin')) {
        return 'http://127.0.0.1:8002' . $path;
    }
    if (str_starts_with($path, '/api/v1/transfers') || 
        str_starts_with($path, '/api/v1/webhooks')) {
        return 'http://127.0.0.1:8001' . $path;
    }
    if (str_starts_with($path, '/api/v1')) {
        return 'http://127.0.0.1:8000' . $path;
    }
    return null;
}

$targetUrl = getServiceUrl($path);

if (!$targetUrl) {
    http_response_code(404);
    echo json_encode([
        'type' => 'NOT_FOUND', 'title' => 'Route non trouvée',
        'status' => 404, 'detail' => "Aucune route pour : $path",
    ]);
    exit;
}

// Forward headers correctly (array_map to format "Key: Value")
$headers = getallheaders();
$curlHeaders = [];
if (is_array($headers)) {
    foreach ($headers as $key => $value) {
        $curlHeaders[] = "$key: $value";
    }
}

$ch = curl_init($targetUrl);
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_CUSTOMREQUEST => $_SERVER['REQUEST_METHOD'],
    CURLOPT_HTTPHEADER => $curlHeaders,
    CURLOPT_POSTFIELDS => file_get_contents('php://input'),
    CURLOPT_TIMEOUT => 30,
    CURLOPT_FOLLOWLOCATION => true,
]);

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

http_response_code($httpCode);
echo $response ?: json_encode([
    'type' => 'GATEWAY_ERROR', 'title' => 'Service indisponible',
    'status' => 502, 'detail' => 'Le service cible est injoignable.',
]);
