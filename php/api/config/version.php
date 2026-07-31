<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.0.2",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk",
    "update_message"      => "Version 1.0.2 is live! Features smooth animated login transitions, pulsing loading indicators, and enhanced 2-column property card layouts.",
    "force_update"        => false
]);
