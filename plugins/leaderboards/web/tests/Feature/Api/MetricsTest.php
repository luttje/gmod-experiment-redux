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
                ['steam_name' => 'Player 1', 'steam_id' => '90071996842377318'],
                ['steam_name' => 'Player 2', 'steam_id' => '90071996842377319'],
            ],
            'characters' => [
                ['id' => 101, 'name' => 'Character 1', 'steam_id' => '90071996842377318'],
                ['id' => 102, 'name' => 'Character 2', 'steam_id' => '90071996842377319'],
            ],
            'character_metrics' => [
                ['id' => 1, 'character_id' => 101, 'metric_id' => 1, 'value' => 100],
                ['id' => 2, 'character_id' => 101, 'metric_id' => 2, 'value' => 50],
                ['id' => 3, 'character_id' => 102, 'metric_id' => 1, 'value' => 200],
                ['id' => 4, 'character_id' => 102, 'metric_id' => 2, 'value' => 100],
                ['id' => 5, 'character_id' => 101, 'metric_id' => 2, 'value' => 10],
                ['id' => 6, 'character_id' => 102, 'metric_id' => 2, 'value' => 20],
            ],
            'alliances' => [
                ['id' => 1001, 'name' => 'Alliance 1'],
                ['id' => 1010, 'name' => 'Alliance 2'],
            ],
            'metrics' => [
                ['id' => 1, 'name' => 'Metric 1', 'description' => 'Metric 1 description'],
                ['id' => 2, 'name' => 'Metric 2', 'description' => 'Metric 2 description'],
                ['id' => 3, 'name' => 'Metric Empty', 'description' => 'Metric without any scores'],
            ],
        ], [
            'X-Api-Secret' => config('app.api_secret'),
            'Content-Type' => 'application/json',
        ]);

        $response->assertStatus(200);

        $response->assertJson([
            'message' => 'Metrics submitted successfully',
        ]);

        // assert that the epoch, players, characters, alliances and metrics were created
        $this->assertDatabaseHas('epochs', ['name' => 'Epoch 1']);
        $this->assertDatabaseHas('players', ['steam_name' => 'Player 1']);
        $this->assertDatabaseHas('players', ['steam_name' => 'Player 2']);

        $this->assertDatabaseHas('characters', ['name' => 'Character 1']);
        $this->assertDatabaseHas('characters', ['name' => 'Character 2']);

        $this->assertDatabaseHas('alliances', ['name' => 'Alliance 1']);
        $this->assertDatabaseHas('alliances', ['name' => 'Alliance 2']);

        $this->assertDatabaseHas('metrics', ['name' => 'Metric 1']);
        $this->assertDatabaseHas('metrics', ['name' => 'Metric 2']);

        // assert that the character metrics were created
        $this->assertDatabaseHas('character_metric', ['character_id' => 101, 'metric_id' => 1, 'value' => 100]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 101, 'metric_id' => 2, 'value' => 50]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 101, 'metric_id' => 2, 'value' => 10]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 102, 'metric_id' => 1, 'value' => 200]);
        $this->assertDatabaseHas('character_metric', ['character_id' => 102, 'metric_id' => 2, 'value' => 100]);
    }
}
