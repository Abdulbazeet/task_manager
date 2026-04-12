<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\TaskController;

Route::get('/health', function () {
    return response()->json(['status' => 'OK']);
});

// Public routes (auth)
Route::prefix('auth')->group(function () {
    Route::post('/register', [AuthController::class, 'register']);
    Route::post('/login', [AuthController::class, 'login']);
});

// Protected routes (require authentication)
Route::middleware('auth:api')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);
    });

    // Tasks CRUD
    Route::prefix('tasks')->group(function () {
        Route::get('/', [TaskController::class, 'index']);           // List with filtering & pagination
        Route::post('/', [TaskController::class, 'store']);          // Create task
        Route::get('/{id}', [TaskController::class, 'show']);        // Get single task
        Route::put('/{id}', [TaskController::class, 'update']);      // Update task
        Route::delete('/{id}', [TaskController::class, 'destroy']);  // Delete task
        Route::post('/{id}/attach-file', [TaskController::class, 'attachFile']); // File upload
    });
});
