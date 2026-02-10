<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CustomerAuthController;
use App\Http\Controllers\Api\ProductController;
use App\Http\Controllers\Api\CategoryController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Admin auth routes (for User model)
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Admin protected routes
Route::middleware('auth:api')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::post('/refresh', [AuthController::class, 'refresh']);
        Route::get('/me', [AuthController::class, 'me']);
        
        // 2FA routes for admin
        Route::post('/2fa/enable', [AuthController::class, 'enable2FA']);
        Route::post('/2fa/verify', [AuthController::class, 'verify2FA']);
        Route::post('/2fa/disable', [AuthController::class, 'disable2FA']);
    });
});

// Customer auth routes (for Customer model - mobile app users)
Route::prefix('customer')->group(function () {
    Route::post('/register', [CustomerAuthController::class, 'register']);
    Route::post('/verify-otp', [CustomerAuthController::class, 'verifyOtp']);
    Route::post('/resend-otp', [CustomerAuthController::class, 'resendOtp']);
    Route::post('/login', [CustomerAuthController::class, 'login']);
});

// Customer protected routes 
Route::middleware('auth:customer')->prefix('customer')->group(function () {
    Route::get('/me', [CustomerAuthController::class, 'me']);
    Route::post('/logout', [CustomerAuthController::class, 'logout']);
    Route::post('/refresh', [CustomerAuthController::class, 'refresh']);
});

// Public product and category routes
Route::prefix('products')->group(function () {
    Route::get('/', [ProductController::class, 'index']);
    Route::get('/featured', [ProductController::class, 'featured']);
    Route::get('/new-arrivals', [ProductController::class, 'newArrivals']);
    Route::get('/{id}', [ProductController::class, 'show']);
});

Route::prefix('categories')->group(function () {
    Route::get('/', [CategoryController::class, 'index']);
    Route::get('/{id}', [CategoryController::class, 'show']);
    Route::get('/{id}/products', [CategoryController::class, 'products']);
});
