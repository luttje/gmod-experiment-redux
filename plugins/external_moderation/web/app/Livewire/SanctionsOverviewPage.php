<?php

namespace App\Livewire;

use Jantinnerezo\LivewireAlert\LivewireAlert;
use Livewire\Component;
use App\Models\Sanction;

class SanctionsOverviewPage extends Component
{
    use LivewireAlert;

    public function render()
    {
        $sanctions = Sanction::query()
            ->with(['issuer'])
            ->orderBy('created_at', 'desc')
            ->paginate(100);

        return view('livewire.sanctions-overview-page', compact('sanctions'));
    }

    public function revoke(Sanction $sanction)
    {
        // Just remove it for now
        $sanction->delete();

        $this->alert('success', 'Sanction has been revoked.');
    }
}
