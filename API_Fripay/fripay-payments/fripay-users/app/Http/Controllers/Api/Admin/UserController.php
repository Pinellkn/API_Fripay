<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\AuditLog;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * GET /api/v1/admin/users
     */
    public function index(Request $request): JsonResponse
    {
        $query = User::query();

        if ($request->has('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('phone_number', 'like', "%{$search}%")
                  ->orWhere('first_name', 'like', "%{$search}%")
                  ->orWhere('last_name', 'like', "%{$search}%");
            });
        }

        if ($request->has('status')) {
            $query->where('status', $request->status);
        }

        $perPage = min((int) $request->get('size', 20), 100);
        $users = $query->orderBy('created_at', 'desc')->paginate($perPage);

        return $this->paginatedResponse($users);
    }

    /**
     * GET /api/v1/admin/users/{user_id}
     */
    public function show(string $userId): JsonResponse
    {
        $user = User::with(['linkedAccounts', 'contacts'])->findOrFail($userId);
        return response()->json(['data' => new UserResource($user)]);
    }

    /**
     * PUT /api/v1/admin/users/{user_id}/status
     */
    public function updateStatus(Request $request, string $userId): JsonResponse
    {
        $data = $request->validate([
            'status' => 'required|string|in:active,blocked,suspended',
            'reason' => 'required|string|max:500',
        ]);

        $user = User::findOrFail($userId);
        $user->update(['status' => $data['status']]);

        AuditLog::create([
            'actor_type' => 'staff',
            'actor_id' => (string) $request->user()->id,
            'action' => 'user.status_changed',
            'entity_type' => 'user',
            'entity_id' => $userId,
            'payload' => [
                'previous_status' => $user->getOriginal('status'),
                'new_status' => $data['status'],
                'reason' => $data['reason'],
            ],
            'ip_address' => $request->ip(),
        ]);

        return response()->json(['data' => new UserResource($user->fresh())]);
    }
}
