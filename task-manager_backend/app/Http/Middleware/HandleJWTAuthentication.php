<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Tymon\JWTAuth\Exceptions\JWTException;
use Tymon\JWTAuth\Exceptions\TokenExpiredException;
use Tymon\JWTAuth\Facades\JWTAuth;

class HandleJWTAuthentication
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        try {
            JWTAuth::parseToken()->authenticate();
        } catch (TokenExpiredException $e) {
            return response()->json([
                'message' => 'Token has expired',
                'errors' => ['token' => 'Your session has expired. Please login again.'],
            ], 401);
        } catch (JWTException | \Exception $e) {
            return response()->json([
                'message' => 'Unauthorized access',
                'errors' => ['auth' => 'Invalid or missing authorization token.'],
            ], 401);
        }

        return $next($request);
    }
}
