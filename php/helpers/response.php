<?php
/**
 * API Response Helper & CORS Headers
 * DHOLERA REAL ESTATE
 */

/**
 * Send Standard JSON Response
 */
function sendJsonResponse(
    bool $success,
    string $message,
    mixed $data = null,
    int $statusCode = 200,
    ?array $pagination = null,
    ?array $errors = null
): void {
    // Prevent any prior output corruption
    if (ob_get_length()) ob_clean();

    // Set Security & CORS Headers
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
    header("X-Content-Type-Options: nosniff");
    header("X-Frame-Options: DENY");

    // Handle OPTIONS Pre-flight requests immediately
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(200);
        exit();
    }

    http_response_code($statusCode);

    $response = [
        "success" => $success,
        "message" => $message,
        "data"    => $data
    ];

    if ($pagination !== null) {
        $response["pagination"] = $pagination;
    }

    if ($errors !== null) {
        $response["errors"] = $errors;
    }

    echo json_encode($response, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
    exit();
}

/**
 * Handle Pre-flight OPTIONS HTTP requests globally
 */
function handleCorsPreflight(): void {
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
        http_response_code(200);
        exit();
    }
}
