<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return view('welcome');
});

// QR Code Widget
Route::get('/qr', function () {
    return view('qr.index');
});
