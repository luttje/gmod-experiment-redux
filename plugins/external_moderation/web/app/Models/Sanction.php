<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Sanction extends Model
{
    use HasFactory;

    protected $fillable = [
        'steam_name',
        'steam_id',
        'character_name',
        'character_id',
        'ip_address',
        'type',
        'reason',
        'expires_at',
        'issued_by',
    ];

    protected $casts = [
        'expires_at' => 'datetime',
    ];

    /**
     *
     * Relationships
     *
     */

    public function issuer()
    {
        return $this->belongsTo(User::class, 'issued_by');
    }
}
