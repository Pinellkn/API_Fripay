<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Foundation\Auth\User as Authenticatable;

class StaffUser extends Authenticatable
{
    use HasFactory;

    protected $fillable = [
        'email', 'password_hash', 'first_name', 'last_name', 'role_id', 'active',
    ];

    protected function casts(): array
    {
        return [
            'active' => 'boolean',
        ];
    }

    public function role()
    {
        return $this->belongsTo(Role::class);
    }

    public function hasPermission(string $permissionCode): bool
    {
        return $this->role->permissions()->where('code', $permissionCode)->exists();
    }
}
