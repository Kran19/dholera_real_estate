<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.2.1",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"      => "Version 1.2.1 is live! Fixed SQL query in property PDF brochure generator for 1-click WhatsApp brochure sharing.",
    "force_update"        => false
]);
