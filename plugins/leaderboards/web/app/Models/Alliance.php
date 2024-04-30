<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Alliance extends Model
{
    use HasFactory;

    protected $guarded = [];

    /**
     * Relationships
     */

    public function characters()
    {
        return $this->belongsToMany(Character::class)
            ->using(AllianceCharacter::class)
            ->withPivot('rank');
    }
}
