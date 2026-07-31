<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../helpers/response.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.0.0",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/app-release.apk",
    "update_message"      => "A new version of Dholera Real Estate is available with performance improvements and new features!",
    "force_update"        => false
]);
