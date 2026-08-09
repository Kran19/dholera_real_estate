<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"       => "1.4.1",
    "min_required_version" => "1.0.0",
    "apk_download_url"     => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"       => "v1.4.1 is live! Includes Calls Today rotating 10-contact batch, per-card save spinner fix, and instant property search.",
    "force_update"         => false
]);
