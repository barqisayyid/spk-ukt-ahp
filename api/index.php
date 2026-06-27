<?php

// Paksa path agar Laravel tidak kebingungan dengan routing di Vercel
$_SERVER['SCRIPT_FILENAME'] = dirname(__DIR__) . '/public/index.php';
$_SERVER['SCRIPT_NAME'] = '/index.php';

require dirname(__DIR__) . '/public/index.php';