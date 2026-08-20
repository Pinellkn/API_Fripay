<?php

namespace App\Http\Middleware;

use App\Models\StaffUser;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class AdminRbac
{
    /**
     * Handle an incoming request - verify the staff user has the required permission.
     */
    public function handle(Request $request, Closure $next, string $permission): Response
    {
        /** @var StaffUser|null $staff */
        $staff = $request->user('sanctum');

        if (!$staff || !$staff instanceof StaffUser) {
            return response()->json([
                'type' => 'INSUFFICIENT_PERMISSIONS',
                'title' => 'Permissions insuffisantes',
                'status' => 403,
                'detail' => 'Accès réservé au personnel autorisé.',
                'request_id' => $request->header('X-Request-Id', ''),
            ], 403);
        }

        if (!$staff->hasPermission($permission)) {
            return response()->json([
                'type' => 'INSUFFICIENT_PERMISSIONS',
                'title' => 'Permissions insuffisantes',
                'status' => 403,
                'detail' => "Vous n'avez pas la permission: {$permission}",
                'request_id' => $request->header('X-Request-Id', ''),
            ], 403);
        }

        return $next($request);
    }
}
