<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"      => "1.0.7",
    "min_required_version"=> "1.0.0",
    "apk_download_url"    => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"      => "Version 1.0.7 is live! Features manual update checker, profile version display, rootNavigator dialog fix, and fast 18MB APK downloads.",
    "force_update"        => false
]);
