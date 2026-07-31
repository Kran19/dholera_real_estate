<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.0.4",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk",
    "update_message"      => "Version 1.0.4 is live! Added Super Admin Inquiry Management, direct +91 calling, PDF report exports, tighter property cards, and 10-item infinite scroll property pagination.",
    "force_update"        => false
]);
