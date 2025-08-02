<?php

namespace App\Livewire;

use App\Models\Sanction;
use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Component;

class SanctionsOverviewPage extends Component
{
    use LivewireAlert;

    public function render()
    {
        $sanctions = Sanction::query()
            ->with(['issuer'])
            ->orderBy('expires_at', 'desc')
            ->paginate(100);

        return view('livewire.sanctions-overview-page', compact('sanctions'));
    }
}
