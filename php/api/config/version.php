<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"       => "1.4.0",
    "min_required_version" => "1.0.0",
    "apk_download_url"     => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"       => "v1.4.0 is live! New: Calls Today — daily 10-contact rotating follow-up list. Also: property search now works instantly as you type.",
    "force_update"         => false
]);
