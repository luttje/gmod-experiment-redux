<?php

namespace Tests\Feature\Api;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Foundation\Testing\WithFaker;
use Tests\TestCase;

class MetricsTest extends TestCase
{
    /**
     * A basic feature test example.
     */
    public function test_example(): void
    {
        $response = $this->postJson(route('submit-metrics'), [
            'epoch' => [
                'name' => 'Epoch 1',
                'started_at' => '2024-01-01',
                'ends_at' => '2024-01-31',
            ],
            'players' => [
                ['name' => 'Player 1', 'steam_id' => '90071996842377318'],
                ['name' => 'Player 2', 'steam_id' => '90071996842377319'],
            ],
            'characters' => [
                ['name' => 'Character 1', 'player_id' => 1],
                ['name' => 'Character 2', 'player_id' => 2],
            ],
            'character_metrics' => [
                ['character_id' => 1, 'metric_id' => 1, 'value' => 100],
                ['character_id' => 1, 'metric_id' => 2, 'value' => 50],
                ['character_id' => 2, 'metric_id' => 1, 'value' => 200],
                ['character_id' => 2, 'metric_id' => 2, 'value' => 100],
            ],
            'alliances' => [
                ['name' => 'Alliance 1'],
                ['name' => 'Alliance 2'],
            ],
            'metrics' => [
                ['name' => 'Metric 1', 'description' => 'Metric 1 description'],
                ['name' => 'Metric 2', 'description' => 'Metric 2 description'],
            ],
        ])->dump();

        $response->assertStatus(200);

        $response->assertJson([
            'message' => 'Metrics submitted successfully',
        ]);

        // assert that the epoch, players, characters, alliances and metrics were created
        $this->assertDatabaseHas('epochs', ['name' => 'Epoch 1']);
        $this->assertDatabaseHas('players', ['name' => 'Player 1']);
        $this->assertDatabaseHas('players', ['name' => 'Player 2']);

        $this->assertDatabaseHas('characters', ['name' => 'Character 1']);
        $this->assertDatabaseHas('characters', ['name' => 'Character 2']);

        $this->assertDatabaseHas('alliances', ['name' => 'Alliance 1']);
        $this->assertDatabaseHas('alliances', ['name' => 'Alliance 2']);

        $this->assertDatabaseHas('metrics', ['name' => 'Metric 1']);
        $this->assertDatabaseHas('metrics', ['name' => 'Metric 2']);

        // assert that the character metrics were created
        $this->assertDatabaseHas('character_metric', ['character_id' => 1, 'metric_id' => 1, 'value' => 100]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 1, 'metric_id' => 2, 'value' => 50]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 2, 'metric_id' => 1, 'value' => 200]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 2, 'metric_id' => 2, 'value' => 100]);
    }
}
