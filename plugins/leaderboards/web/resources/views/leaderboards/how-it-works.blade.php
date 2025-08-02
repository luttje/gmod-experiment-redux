<x-layouts.app>
    <x-slot name="title">
        How it works
    </x-slot>
    <x-slot name="subtitle">
        This page explains how the leaderboards work, what Epochs are, and how metrics are calculated.
    </x-slot>

    <section class="rounded flex flex-col gap-8">
        <div class="text-center py-8 bg-gradient-to-r from-amber-500/80 to-amber-200/80 rounded-xl shadow-lg">
            <h1 class="text-slate-700 text-4xl md:text-5xl m-0 font-extrabold drop-shadow-lg">🏆 Heroes of the Epoch</h1>
            <p class="text-slate-700/70 text-lg font-bold mt-3 mb-0">Leaderboards to track your defiance against the Nemesis AI</p>
        </div>

        <div class="bg-black bg-opacity-20 rounded-lg p-6 border-l-4 border-amber-500 backdrop-blur-sm">
            <h2 class="text-amber-500 text-xl mb-4 mt-0">🎯 What Are Epochs?</h2>
            <p class="mb-4">An <span class="bg-gradient-to-r from-amber-500 to-amber-400 text-cyan-950 px-2 py-1 rounded font-bold">Epoch</span> is Experiment's version of a competitive season, lasting 20-30 days. Unlike traditional games with short matches, our "match" spans an entire month, giving you time to develop strategies, build alliances, and climb the rankings.</p>
            <p>At the end of each Epoch, leaderboards reset and top performers receive exclusive rewards including medals, cosmetic items, and eternal glory in the rebellion's archives.</p>
        </div>

        <div class="bg-black bg-opacity-20 rounded-lg p-6 border-l-4 border-amber-500 backdrop-blur-sm">
            <h2 class="text-amber-500 text-xl mb-4 mt-0">📊 Tracked Metrics</h2>
            <p class="mb-5">Your heroic actions are tracked across multiple leaderboards. Excel in any category to earn rewards:</p>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4 my-5">
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">⚡ Bolts Generated</h3>
                    <p class="text-sm">Power the rebellion's efforts</p>
                </div>
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">🛡️ Successfully Defended</h3>
                    <p class="text-sm">Protect fellow players</p>
                </div>
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">💚 Healing Done</h3>
                    <p class="text-sm">Support your allies</p>
                </div>
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">❤️ Healing Received</h3>
                    <p class="text-sm">Community cooperation</p>
                </div>
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">💰 Bolts Spent</h3>
                    <p class="text-sm">Strategic resource usage</p>
                </div>
                <div class="bg-cyan-900 bg-opacity-60 p-4 rounded-lg text-center border border-cyan-700">
                    <h3 class="text-cyan-400 text-lg mb-2 mt-0">🏆 Overall Ranking</h3>
                    <p class="text-sm">Combined weighted score</p>
                </div>
            </div>

            <p>The <span class="bg-gradient-to-r from-amber-500 to-amber-400 text-cyan-950 px-2 py-1 rounded font-bold">Overall Leaderboard</span> combines all metrics with a weighted scoring system, but you can win exclusive rewards by leading in any individual category.</p>
        </div>

        <div class="bg-black bg-opacity-20 rounded-lg p-6 border-l-4 border-amber-500 backdrop-blur-sm">
            <h2 class="text-amber-500 text-xl mb-4 mt-0">⚔️ The AI's Influence</h2>
            <p class="mb-5">The nemesis AI actively works against leaderboard climbers, making the game progressively harder for top performers. This creates dynamic opportunities for new players and those who join late in an Epoch.</p>

            <div class="bg-amber-500/50 border-2 border-amber-400 rounded-lg p-5 my-5">
                <h3 class="text-amber-400 mt-0 mb-3">🚨 Beware the AI's Temptations</h3>
                <p class="mb-0">The AI will offer seemingly attractive deals that harm your leaderboard standing. It might promise huge bolt rewards for actions that damage the community - like eliminating fellow players. Stay true to the rebellion's values!</p>
            </div>

            <p><strong>Late joiners have real advantages:</strong> While leaders face increasing AI pressure, newcomers can rise quickly by maintaining consistent positive actions and avoiding the AI's traps.</p>
        </div>

        <div class="bg-black bg-opacity-20 rounded-lg p-6 border-l-4 border-amber-500 backdrop-blur-sm">
            <h2 class="text-amber-500 text-xl mb-4 mt-0">🔄 Epoch Resets & Rewards</h2>
            <p class="mb-4">When an Epoch ends:</p>
            <ul class="space-y-2 mb-4">
                <li class="flex items-start"><span class="text-2xl mr-3">🎖️</span> Top performers receive medals and exclusive cosmetic items</li>
                <li class="flex items-start"><span class="text-2xl mr-3">🌍</span> The game world resets for a fresh start</li>
                <li class="flex items-start"><span class="text-2xl mr-3">📖</span> The story progresses with new characters and mechanics</li>
                <li class="flex items-start"><span class="text-2xl mr-3">⏱️</span> A 1-2 week off-season allows for the development of new content</li>
            </ul>
            <p>During off-season, you can still play but leaderboards are paused, giving everyone an equal fresh start for the next Epoch.</p>
        </div>

        <div class="bg-black bg-opacity-20 rounded-lg p-6 border-l-4 border-amber-500 backdrop-blur-sm">
            <h2 class="text-amber-500 text-xl mb-4 mt-0">💡 Strategy Tips</h2>
            <ul class="space-y-3 list-disc pl-5">
                <li><strong>Focus on positive actions:</strong> All tracked metrics reward community-beneficial behavior</li>
                <li><strong>Resist AI corruption:</strong> Short-term gains often lead to long-term leaderboard losses</li>
                <li><strong>Play consistently:</strong> Regular engagement often beats sporadic intense sessions</li>
                <li><strong>Join anytime:</strong> Late starters can leverage the AI's focus on current leaders</li>
                <li><strong>Diversify your impact:</strong> Excel in multiple metrics for better overall ranking</li>
            </ul>
        </div>
    </section>
</x-layouts.app>
