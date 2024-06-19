<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\Pivot;

class CharacterMetric extends Pivot
{
    protected $guarded = [];

    public function character()
    {
        return $this->belongsTo(Character::class);
    }

    public function metric()
    {
        return $this->belongsTo(Metric::class);
    }
}
