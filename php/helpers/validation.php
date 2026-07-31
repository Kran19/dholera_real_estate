<?php
/**
 * Input Validation & Sanitization Helper
 * DHOLERA REAL ESTATE
 */

/**
 * Get Decoded JSON Request Body
 */
function getJsonInput(): array {
    $rawInput = file_get_contents("php://input");
    if (empty($rawInput)) {
        return $_POST ?? [];
    }
    $decoded = json_decode($rawInput, true);
    return is_array($decoded) ? $decoded : [];
}

/**
 * Sanitize String Input
 */
function sanitizeString(?string $input): string {
    if ($input === null) return '';
    return trim(htmlspecialchars(strip_tags($input), ENT_QUOTES, 'UTF-8'));
}

/**
 * Validate Required Fields
 */
function validateRequired(array $data, array $requiredFields): array {
    $errors = [];
    foreach ($requiredFields as $field) {
        if (!isset($data[$field]) || trim((string)$data[$field]) === '') {
            $errors[$field][] = ucfirst(str_replace('_', ' ', $field)) . " is required.";
        }
    }
    return $errors;
}
