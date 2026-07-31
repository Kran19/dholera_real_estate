<?php
/**
 * API Response Helper & CORS Headers
 * DHOLERA REAL ESTATE
 */

// Start output buffering immediately to prevent HTML warnings or whitespace from corrupting JSON output
if (!ob_get_level()) {
    ob_start();
}

// Global Exception Handler to format fatal PHP errors as JSON
set_exception_handler(function (Throwable $e) {
    if (ob_get_length()) ob_clean();
    header("Content-Type: application/json; charset=UTF-8");
    header("Access-Control-Allow-Origin: *");
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Server Exception: " . $e->getMessage(),
        "data"    => null
    ]);
    exit();
});

// Global Shutdown Handler to catch unhandled fatal errors
register_shutdown_function(function () {
    $error = error_get_last();
    if ($error !== null && in_array($error['type'], [E_ERROR, E_PARSE, E_CORE_ERROR, E_COMPILE_ERROR])) {
        if (ob_get_length()) ob_clean();
        header("Content-Type: application/json; charset=UTF-8");
        header("Access-Control-Allow-Origin: *");
        http_response_code(500);
        echo json_encode([
            "success" => false,
            "message" => "Fatal Error: " . $error['message'] . " in " . basename($error['file']) . ":" . $error['line'],
            "data"    => null
        ]);
        exit();
    }
});

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
    header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, X-Auth-Token");
    header("X-Content-Type-Options: nosniff");
    header("X-Frame-Options: DENY");

    // Handle OPTIONS Pre-flight requests immediately
    if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
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
    if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        header("Access-Control-Allow-Origin: *");
        header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
        header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With, X-Auth-Token");
        http_response_code(200);
        exit();
    }
}
