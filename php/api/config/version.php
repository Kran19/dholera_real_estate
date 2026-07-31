<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.0.3",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk",
    "update_message"      => "Version 1.0.3 is live! Features Super Admin Inquiry Management, direct customer calling, PDF report exports, and infinite scroll property pagination.",
    "force_update"        => false
]);
