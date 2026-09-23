<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"       => "1.5.5",
    "min_required_version" => "1.0.0",
    "apk_download_url"     => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"       => "v1.5.5 is live! Enhanced multi-field search and full property listings display.",
    "force_update"         => false
]);
