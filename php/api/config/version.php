<?php
/**
 * App Version & In-App Update Config Endpoint
 * DHOLERA REAL ESTATE
 * GET /api/config/version.php
 */

require_once __DIR__ . '/../../bootstrap.php';

handleCorsPreflight();

sendJsonResponse(true, "App version configuration retrieved.", [
    "latest_version"       => "1.4.6",
    "min_required_version" => "1.0.0",
    "apk_download_url"     => "https://emperorsmartsolutions.com/dholerarealestate/php/download_apk.php",
    "update_message"       => "v1.4.6 is live! Landing Price and Reference/Agent details are now strictly restricted to Super Admin only and hidden from all regular users, sub-admins, and public brochures.",
    "force_update"         => false
]);
