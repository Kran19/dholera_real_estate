<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"       => "1.5.3",
    "min_required_version" => "1.0.0",
    "apk_download_url"     => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"       => "v1.5.3 is live! Dynamic Pachi NA Order & Zoning Cert image layout engine.",
    "force_update"         => false
]);
