<?php

use Illuminate\Foundation\Application;
use Illuminate\Http\Request;

define('LARAVEL_START', microtime(true));

// Determine if the application is in maintenance mode...
if (file_exists($maintenance = __DIR__.'/../storage/framework/maintenance.php')) {
    require $maintenance;
}

// Register the Composer autoloader...
require __DIR__.'/../vendor/autoload.php';

// Bootstrap Laravel and handle the request...
/** @var Application $app */
$app = require_once __DIR__.'/../bootstrap/app.php';

# PINDAHKAN MODIFIKASI VERCEL KE SINI (Setelah Laravel ter-bootstrap)
if (env('APP_ENV') === 'production' || env('VERCEL') === '1') {
    config(['app.manifest' => '/tmp/manifest']);
    config(['view.compiled' => '/tmp/views']);
    config(['cache.stores.file.path' => '/tmp/cache']);
    config(['session.files' => '/tmp/sessions']);
}

$app->handleRequest(Request::capture());