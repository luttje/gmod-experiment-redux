TacRP.News = {
    --[[]
    {
        Title = "New Article",
        Type = "Update",
        Date = "2023-03-16", -- yyyy-mm-dd
        Major = true, -- if unread, brings up page on startup
        Summary = nil, -- text shown in the side tab
        Hyperlink = nil, -- if set, loads the specified webpage instead of Contents.
        Contents = "", -- main text, uses HTML
    },
    ]]
    {
        Title = "New Newsletter System!",
        Type = "Announcement",
        Date = "2023-03-17",
        Author = "8Z",
        Major = true,
        Summary = nil,
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>Thank you for using Tactical RP, and welcome to our new newsletter!<br>
<span style="font-size:80%;"><i>If you forgot you had TacRP installed, we're sorry for distrubing your gmod session, please don't unsubscribe</i></span></p>

<p>You can now catch up with updates, dev blogs, and more, all from the comfort of your own video game! A few posts (like this one) are embedded within the addon and will always be available, while others will be fetched remotely so you can get the hottest news without updating the addon.</p>

<p>Major updates and releases will be displayed on startup, while minor posts will bring up a reminder in the chat box. If you want to be only notified for major updates, toggle the checkbox above.</p>

<p>Despite the cold reception TacRP got at launch, some of you stuck with us (or at least tolerated its presence in the weapons tab), and we cannot thank you enough for your support. That's why we here at <b>Garry's Mod Tactical Realism Industries™</b><i style="font-size:50%;">(trademark pending)</i> are cooking up more good stuff for you to enjoy, including an <i>expansion pack full of new weapons</i>.</p>

<p>In the meantime, we hope you enjoy Tactical RP, and remember:<br>
<i>No matter what Arctic might say, the RP in TacRP stands for Remix Pack, not Role Play!</i>
<br><span style="font-size:50%;opacity:0.25;">It is seriously kind of stupid to put roleplay in your weapon pack name. Is there even a DarkRP server out there that uses these guns? Don't they all just use M9K? Why do we even make new weapon packs if a decade-old weapon base with no c_hands is enough for them? Is humanity truly doomed? sussy imposter amogus??? skull emoji</span></p>

<p>Yours,<br>
<b>8Z, the gmod hyperealist</b></p>
</body>]]
    },
    {
        Title = "Interops Update",
        Type = "Announcement",
        Date = "2023-05-14",
        Author = "8Z",
        Major = true,
        Summary = "Major update and expansion! It's here!!!",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>It's here!<br></p>

<p>Alongside the release of thirty-one new weapons in the Interops pack, a long list of changes have also dropped. They've been sneakily updated (sorry) but I've finally bothered to write the patch notes for them now.</p>

<p>Without being too verbose, here is a shortlist of all the changes up until this point.</p>

<h3>Armor Penetration</h3>
<p>Combat can get really awkward with HL2 armor absorbing 80% of all damage. Now, TacRP braves the unknown to become the second addon to ever challenge this status quo! (The first being, of course, my own Danger Zone Entities. #humblebrag)<br>
Every weapon has an Armor Piercing and Armor Shredding value. The former dictates how much damage is blocked by armor and the latter determines how much damage armor takes.
All weapons have naturally been balanced to use these numbers, so you can expect a tactical experience even with armor.</p>
<p>Of course, TacRP is fully compatible with Danger Zone Entities' armor, and will use the weapons' AP value for them.</p>

<h3>TTT Support</h3>
<p>It's a match made in heaven! TacRP will now natively support TTT, and using it is as easy as installing and opening the game. In addition to compatibility, a new set of stats have been made for the mode in particular so that the weapons' balance is similar to vanilla TTT.<br>
Several guns are added as buyable equipment, like the launchers, anti-materiel snipers, and the riot shield.<br>
There's also two buyable equipment, an attachment bench (if you restrict customization), and an ammo box.</p>

<h3>Rebalance... Again</h3>
<p>I just can't help it. The default "Tactical" balance mode has been rewritten to be less slow (considering reduced movement speed in most roleplay modes), and higher-tiered weapons are less overpowered, albeit still stronger on average.<br>
With the addition of new weapons to round out the set, some category changes have also been made.</p>

<h3>Hints</h3>
<p>You can do so many things with these guns it's hard to keep track. Now, you don't have to!<br>
Hints will show up reminding you what contextually relevant buttons you can press. It'll also nag you to bind your grenade input.</p>

<h3>Stats Menu Rework</h3>
<p>The stats menu finally has a scroll bar to scroll through all those numbers. They also now show the change in difference as a percentage.</p>

<h3>Held Grenades</h3>
<p>Relevant to TTT, you can now pull out grenades as weapons. Unfortunately I was not able to get custom viewmodels for them, so bear with the CSS placeholders for a bit.<br>
Also, if you have Danger Zone Entities, you can quickthrow and switch to Bump Mines.</p>
<br>
<p>Anyways, I hope all of you have as much fun with the Interops weapons as speedonerd and I had making them. It's a pleasure seeing these old models come to life again.<br>
Be sure to check out the Interops workshop page as well as Danger Zone Entities.</p>

<p>Yours,<br>
<b>8Z, the gmod hyperealist</b></p>
</body>]],
    },
    {
        Title = "Update 8",
        Type = "Patch Notes",
        Date = "2023-05-15",
        Author = "8Z",
        Major = false,
        Summary = "Post release fixes because it keeps happening.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>No update survives first contact. As is tradition, things immediately break when I push updates. Even if the version number is my lucky number.</p>
<p>In addition to some fixes, I've also added a few small but cool things, like the ability to pick up DNA from dropped magazines in TTT, and gas effects.</p>
<ul>
<li><b>Added:</b> Overlay, motion blur and color modification when affected by gas directly (but not lingering damage).
<li><b>Added:</b> (TTT) Dropped magazines (including grenade spoons) contain DNA of the dropper and no longer fade.
<li><b>Added:</b> (TTT) Customization Bench allows you to freely customize (equivalent to free atts).
<li><b>Added:</b> (TTT) Picking up a grenade will make the player select it as a quicknade if the current selection isn't valid.
<li><b>Balance:</b> Sticky sounds (Breaching Charges, C4) and quickthrow sounds are less loud.
<li><b>Balance:</b> (TTT) Breaching Charges have a bigger blast radius, slightly lower damage and much quieter beeps.
<li><b>Balance:</b> Gas grenades no longer do damage when exploding.
<li><b>Balance:</b> Flashbang blast and effect radius now 728 (previously 512 and 1024).
<li><b>Changed:</b> (TTT) Random attachments will try to avoid duplicates and respect InvAtt.
<li><b>Fixed:</b> Various issues with the Medkit.
<li><b>Fixed:</b> Bodygroup related errors.
<li><b>Fixed:</b> Quicknade and grenade weapons do not respect ttt_no_nade_throw_during_prep.
<li><b>Fixed:</b> Gas grenade doesn't cause sway and coughing when below health threshold.
<li><b>Fixed:</b> Attachments do not sync properly if weapon is out of PVS initially (such as spawning in TTT).
</ul>
<p>I'm sure I've missed some more, so send any issues or suggestions my way!</p>
<p>Yours,<br>
<b>8Z, the gmod hyperealist</b></p>]],
    },
    {
        Title = "Update 9",
        Type = "Patch Notes",
        Date = "2023-05-16",
        Author = "8Z",
        Major = false,
        Summary = "The biggest changes tend to slip under the hood.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>A humble update. Aside from a lot of internal changes, some systems have been reworked and a new ammo attachment for pistols is added.</p>

<h3>Jamming Rework</h3>
<p>Arctic added jamming for fun and neither of us really knew what to do with it. We didn't want to just slap it on all guns just because, but there also seemed to not be any good reason to put it anywhere.
In lieu of a better idea, I've elected to give the surplus attachments some dubious upside that at the very least may be interesting.</p>

<p>Furthermore, the chance to jam is now based on ammo type, with attachments adding a "Jam Factor" instead of modifying percentage chances directly. This should help prevent pistols, shotguns and snipers from jamming too infrequently compared to automatic high fire rate guns.</p>


<h3>Free Aim Rework</h3>
<p>Free Aim was one of those features that nobody liked - admittedly, not even myself. But I couldn't not give it another chance.</p>
<ul>
<li>All weapons now have their own Free Aim Angle, typically between 2-9 degrees. Generally speaking, pistols, SMGs and stockless weapons have little free aim.
<li>Overall free aim value is much lower. Most rifles will have 4-5 degrees, and only cumbersome weapons like snipers and machine guns will have high values.
<li>Free aim point of aim moves across the screen slower.
</ul>

<h3>Mr. Worldwide</h3>
<p>Ported over the localization system used in ARC9. As of now, there are no other languages, so if you are interested in contributing your language, please contact me or make a pull request!<br>
An additional benefit is that a lot of the attachments now use consistent wording due to switching to phrases.</p>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Free Aim rework.
<li><b>Major Change:</b> Jamming rework.
<li><b>Added:</b> Surplus Ammo and Surplus Bolt gained unique behavior. They still jam though.
<li><b>Added:</b> Steel Core Rounds for pistols, basically the oppposite of Hollowpoints.
<li><b>Added:</b> Localization system. Currently only Chinese Simplified is available.
<li><b>Rebalance:</b> (Arcade) Most pistols are no longer lethal on headshot without Hollowpoints/Skullsplitter.
<li><b>Rebalance:</b> Dual MTX has reduced spread and fires in runaway burst.
<li><b>Rebalance:</b> Riot Shield can now be penetrated with sufficient Material Penetration (around 30).
<li><b>Rebalance:</b> TMJ now gives flat penetration increase of 8" (generally lower than before).
<li><b>Rebalance:</b> AS-50 and Hecate II got more penetration.
<li><b>Rebalance:</b> Auto-Burst trigger no longer has downsides (it's now easy to get optimal ROF with improved buffering).
<li><b>Rebalance:</b> Sniper rifles have lower hip spread penalty (to compensate for free aim).
<li><b>Rebalance:</b> Juice up UMP45 with less recoil kick and spread.
<li><b>Rebalance:</b> Burst trigger on semi-auto guns increase RPM further and no longer increase recoil spread. Burst is now runaway and semi mode is removed.
<li><b>Rebalance:</b> Competition/Weighted trigger no longer change recoil kick.
<li><b>Changed:</b> Adjusted thresholds and criteria for some ratings.
<li><b>Changed:</b> Click buffering for burst fire now works during the whole burst and not just after the last shot.
<li><b>Changed:</b> Renamed Penetration to Material Penetration, and Armor Piercing to Armor Penetration.
<li><b>Changed:</b> Some descriptions for stats and ratings.
<li><b>Fixed:</b> When both Free Aim and Sway are on, point of aim shakes intensely while recovering from recoil.
<li><b>Fixed:</b> Safety desync causing gun able to shoot while apparently in safety.
</ul>]],
    },
    {
        Title = "Update 10",
        Type = "Patch Notes",
        Date = "2023-06-14",
        Author = "8Z",
        Major = false,
        Summary = "Minor performance and PVE Balance.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> PvE balance mode.
<li><b>Changed:</b> ConVars are now cached, which should increase performance.
<li><b>Changed:</b> Hold type while aiming.
<li><b>Changed:</b> Lasers now draw only a dot and not the beam. They are also more consistent.
</ul>]],
    },
    {
        Title = "Update 11",
        Type = "Patch Notes",
        Date = "2023-06-27",
        Author = "8Z",
        Major = false,
        Summary = "New customization menu, and more suppressors!",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>The customization menu is getting a little cramped with all the tactical customization going on. The new UI should be way more concise, hiding all the options behind a click but still allowing you to see all your current choices at a glance.</p>

<p>If you're not a fan, the legacy menu option can be toggled back with the checkbox in the bottom left.</p>

<p>Besides that, there's also 2 more suppressor options to make the Muzzle slot a little less lonely. Also, they're suppressors and not silencers now.</p>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Customization menu rework.
<li><b>Added:</b> Support for DynaMetR's Customizable HL2 HUD. Secondary ammo will display the type and amount of the currently selected quicknade, and ammo pickup will also display correctly.
<li><b>Added:</b> Compact Suppressor. Reduces spread, lower penalty compared to the Silencer (now Tactical Suppressor).
<li><b>Added:</b> Weighted Suppressor. Increases range and reduces recoil, but worsens ADS and sprint time.
<li><b>Added:</b> Akimbo variants for some attachments.
<li><b>Added:</b> Icons for PS90 and HK94 (thanks speedonerd).
<li><b>Rebalance:</b> Tactical Suppressor also reduces recoil spread penalty (5%).
<li><b>Rebalance:</b> Akimbo trigger has weaker RPM penalty (10%).
<li><b>Rebalance:</b> Reduced recoil spread on several assault rifles.
<li><b>Rebalance:</b> Reduced recoil on the RPG-7 drastically.
<li><b>Changed:</b> Adjusted shooting volume on some weapons for consistency. Pistol caliber weapons have ~110dB, carbines ~120dB, and the rest are ~130dB.
<li><b>Changed:</b> Stat differences are now rounded to the whole percent (due to rounding errors in the values, the extra precision is meaningless).
<li><b>Fixed:</b> Adjusted suppressor positions on some guns.
<li><b>Fixed:</b> Akimbo pistols use last shot animation correctly.
<li><b>Fixed:</b> Pre-emptively fix an upcoming issue in the June 2023 update related to loading server files in Singleplayer.
</ul>]],
    },
    {
        Title = "Update 12",
        Type = "Patch Notes",
        Date = "2023-07-18",
        Author = "8Z",
        Major = false,
        Summary = "AR Expansion, and recoil system overhaul.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">

<p>The AR Expansion Pack is out now! Get 5 new guns by clicking this (not a rickroll): <input type='submit' value='Open Workshop Page' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3006376475\")")' /></p>

<p>This update introduces changes to how recoil and spread works. Before, most "Recoil" stats were actually affecting spread, and Recoil Kick was the only actual recoil stat. These stats are now renamed to Bloom, and their behavior has changed as well.</p>

<p>Under the new system, instead of your gun magically becoming less accurate as you shoot, the recoil becomes stronger instead. If you wish to revert to old behavior, untick "Bloom Modifies Recoil" in the Mechanics setting page.</p>

<p>Recoil Stability is a new stat that makes recoil go more straight up. Previously, recoil could go anywhere within a 180 degree half circle - this is equivalent to 0% stability now. Certain guns, especially high recoil rifles, have increased stability to make their recoil manageable.</p>

<p>The intent of the overall change is to improve the viability of high recoil weapons and to make medium to long range combat more viable on non-sniper rifles.</p>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Alternate Recoil Mode.
<li><b>Major Change:</b> Recoil Stability stat.
<li><b>Added:</b> All weapons gain a 0.01 moving spread penalty.
<li><b>Added:</b> You can now bind +tacrp_melee to any button to quick melee. E+LMB will still work.
<li><b>Added:</b> ConVar to allow firing while sprinting, in case you're a boomer shooter enthuasist.
<li><b>Rebalance:</b> Fold Stock and Adjust Stock reduce ADS and sprint time by 0.08/0.04 seconds instead of a percentage, and recoil is reduced.
<li><b>Changed:</b> Some "Recoil" stats are now named Bloom. Their functionality remains identical.
<li><b>Fixed:</b> Certain lower resolutions unable to display attachments properly.
</ul>]],
    },
    {
        Title = "Update 13",
        Type = "Patch Notes",
        Date = "2023-07-24",
        Author = "8Z",
        Major = false,
        Summary = "Small compatability additions and balance tweaks.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">

<p>The Special Delivery expansion is out - get 21 extra special weapons for TacRP today!: <input type='submit' value='Open Workshop Page' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3007840813\")")' /></p>

<p>This is a small update with mostly minor changes.</p>

<h3>Changelist</h3>
<ul>
<li><b>Added:</b> Breach Charges will attract VJ L4D Common Infected like a pipe bomb. Why? Why not?
<li><b>Added:</b> Expansion addons can now add shell ejections (used by Special Delivery for the Super X3)
<li><b>Rebalance:</b> Buffed DSA-58.
<li><b>Rebalance:</b> Some adjustments to akimbo attachments.
<li><b>Rebalance:</b> Buffed burst trigger fire rate.
<li><b>Changed:</b> When using Sliding Ability's slide, you aren't considered sprinting and can fire your gun.
<li><b>Fixed:</b> Auto-Burst doesn't work with non-runaway bursts.
</ul>]],
    },
    {
        Title = "Update 14",
        Type = "Patch Notes",
        Date = "2023-07-25",
        Author = "8Z",
        Major = false,
        Summary = "Melee update.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">

<p>Even if you run out of bullets, you'll never run out of bullets. Brute Force, a melee weapon expansion for TacRP, is out now!: <input type='submit' value='Open Workshop Page' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3009874388\")")' /></p>

<p>Accompanying Brute Force is a list of updates to melee weapons, as well as a new perk.</p>

<h3>Changelist</h3>
<ul>
<li><b>Added:</b> Melee Special attachment Scout. Gain a double jump and bat balls into others to slow them.
<li><b>Added:</b> Melee bashes and delays have a small delay before the hit connects. (0.25s for bash, 0.15s for knives)
<li><b>Rebalance:</b> Charge special use same meter as other mobility specials and charge the same rate.
<li><b>Rebalance:</b> Melee weapons now have varied throwing damage, velocity, and mobility recharge time.
<li><b>Rebalance:</b> Ninja can backhop regardless of whether the smoke bomb is ready.
<li><b>Rebalance:</b> Knife throw headshot detection is slightly more generous.
<li><b>Rebalance:</b> Knife throw does double damage on stunned/slowed targets, and no longer on mid-air targets.
<li><b>Rebalance:</b> Slow total duration increased from 2s to 3s, fade start time unchanged.
</ul>]],
    },
    {
        Title = "Update 15",
        Type = "Patch Notes",
        Date = "2023-08-06",
        Author = "8Z",
        Major = false,
        Summary = "",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>With so many updates on the list, I'm starting to run out of quirky hooks to put in front of patch notes. Ah well, nobody reads this anyways.</p>

<h3>A Twenty-Three Millimeter Shotgun</h3>
<p>The old model was the first re-rigged weapon for TacRP and had quite a few flaws. It's been replaced with the model from FA:S2, complete with actual sounds, visible shells during reloading and cycling, and a slight buff.</p>

<p>In addition, the Zvezda flash shell has a new variant which only loads the top shell as a flashbang, for more practical applications.</p>

<h3>Stat Menu Expansion</h3>
<p>Number lovers rejoice, for there's been a heap of changes to the stat menu. The whole thing has been reorganized and spacers are added to group stats into (mostly) sensible categories. Furthermore, a couple of missing stats have now been added.</p>

<h3>Smooth like Tactical Butter</h3>
<p>Previously, leaving sprint was an awkward action that prevented you from doing what you want: aiming down sights. Not anymore! You can start aiming as soon as you let go of sprint; however, this will be slower than normal and you still cannot fire for the Sprint to Fire duration.</p>

<p>Shotguns can now also immediately cancel reloading to fire, making them more useful in a pinch.</p>

<h3>Grenade View Models</h3>
<p>Speedonerd very kindly rigged the grenades to CSS viewmodels so you don't have to pretend you're using our grenades anymore.</p>

<hr>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Stat menu expansion.
<li><b>Major Change:</b> New KS-23 Model and sounds (from FA:S 2). New KS-23 attachment: Top-loaded Zvezda shells.
<li><b>Added:</b> Muzzle Light feature: brief flash of projected light when firing, like L4D2. Only visible on self, can be disabled.
<li><b>Added:</b> You can now aim the weapon while exiting sprint state, albeit at a slower speed.
<li><b>Added:</b> Shotgun reloading can be instantly cancelled (configurable, default on).
<li><b>Added:</b> Akimbo pistols now use the correct worldmodel attachments and drop magazines from both hands.
<li><b>Added:</b> Better effects system to allow for double ejects and muzzles on certain expansion guns.
<li><b>Added:</b> Client config "Aiming Stops Sprinting" (default on).
<li><b>Added:</b> "Lower Weapon While Airborne" config (default off), because bhopping is not tactical.
<li><b>Added:</b> You can now reset all client configs in the menu with a button.
<li><b>Added:</b> Grenade viewmodels rigged to CS:S animations by speedonerd.
<li><b>Added:</b> Holding overhand throw for pulled out grenades increases throw velocity by up to 50% over 0.25s.
<li><b>Added:</b> RPM Burst and Semi multipliers.
<li><b>Added:</b> Flashbangs will now stun human type NPCs.
<li><b>Rebalance:</b> Triggers now affect Recoil Stability.
<li><b>Rebalance:</b> Burst trigger has increased RPM for burst fire mode only.
<li><b>Rebalance:</b> Scope glint is slightly more visible and starts being visible closer.
<li><b>Rebalance:</b> Frag grenades, C4s and Breach Charges do more damage.
<li><b>Rebalance:</b> Buffed AMD-65, FB Beryl 96, HK94 and PS90.
<li><b>Rebalance:</b> Mag Extender slows reload by 3-5% (weapon type dependent).
<li><b>Rebalance:</b> Adjusted burst fire weapons to accomdate for RPM Burst multipliers.
<li><b>Changed:</b> When "Allow Reload While Sprinting" is disabled, sprinting cancels reload (unless ammo is already replenished).
<li><b>Changed:</b> Shuffled around some options in Mechanics menu.
<li><b>Changed:</b> Adjusted thermite effects and removed initial explosion. Thermite now ignites non-players.
<li><b>Changed:</b> Adjusted some rating rules.
<li><b>Fixed:</b> Error when trying to pick up weapon in DarkRP caused by incorrect hook usage.
<li><b>Fixed:</b> Should fix situation where removed smokes still block targetid.
<li><b>Fixed:</b> Firing buffer does not trigger when weapon is locked in animation (shotgun reload finishing).
<li><b>Fixed:</b> Weapon withs >100% AP deal more damage than normal and restores armor.
</ul>]],
    },
    {
        Title = "Update 16",
        Type = "Patch Notes",
        Date = "2023-12-02",
        Author = "8Z",
        Major = true,
        Summary = "A flurry of new features: Trivia, Recoil patterns, Bipods, Breath holding.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>What is Tactical may never die. Is that how the saying goes?
<br>Here's an update that's been cooking for a while. We've got a bit of everything: cool new features that enhance gameplay, visual reworks to some old models, performance update, it's all here.</p>

<h2>Shots 1-5: Clearly Missed</h2>
<p>Not enough skill issue in your Garry's Mod weapon addon? Now, instead of complaining about random recoil spread, you're gonna have to complain about something else, cause it's no longer random.</p>

<p>Similar to CS:GO (I guess it's now CS2)'s implementation, weapon recoil will follow a consistent pattern, typically going upwards until reaching a "suppression threshold", after which recoil becomes mostly horizontal.</p>

<p>Best used with "Bloom Modifies Recoil". Guns that have low RPM (<100), are burst fire, or shoot entities do not use patterns.</p>

<h2>I'll take "Useless Firearm Knowledge" for 500, Alex</h2>
<p>Want to know more about all the guns we have? No? Damn, cause we wasted a lot of hours putting in trivia and credits for</p>

<p><i>Every. Single. Gun.</i> There's like over a hundred. Yeah.</p>

<p>There's also now a credits page, so you know who to thank for the pretty models in all of our packs!</p>

<p>For additional realism, some guns have their names changed. The exception is the TGS-12, which we're almost certain Gooseman made up and is just a Bekas decked with aftermarket parts.</p>

<h2>Pod means legs, Bi means two</h2>
<p>The previous iteration of bipod was like pretending to use a bipod. It was not very fun. So I went ahead and implemented a proper bipod system.</p>

<p>Now, you can deploy bipod on any surface by aiming down sights when the prompt shows up. While deployed, you can enjoy significantly reduced bloom gain and recoil kick, zero sway and free aim, and reduced hip spread (based on peeking bonus).</p>

<p>AS50, MG4, Hecate and SA58 come with a bipod in the base pack. They are now innate and no longer take up your Accessory slot (the Bipod attachment is deprecated). Plus, the bipod will unfold while deployed and fold up when it's not. Neat!</p>

<h2>Steady, Steady...</h2>
<p>Sway is kinda annoying when you want to snipe. Now, you can hold your breath to stop swaying for a little bit, like most modern games.</p>

<p>The amount of breath meter drained is dependent on Scoped Sway. Iron sights and low magnification optics are easier to hold still with. Careful not to hold too long, as running low or out will increase sway significantly!</p>

<h2>Facelifts</h2>
<p>The Glock 17 model has been swapped out for the cooler one by Twinke Masta.
<br>The Hecate II now has its original scope and bipod models, and the animations have been improved a little.</p>

<hr>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Trivia and Credits tab.
<li><b>Major Change:</b> Bipod.
<li><b>Major Change:</b> Hold Breath.
<li><b>Major Change:</b> Recoil Patterns.
<li><b>Added:</b> Glock 17 model replaced.
<li><b>Added:</b> Hecate II model touch up - added scope and bipod from original model.
<li><b>Added:</b> Bulk attachment files. This should speed up loading noticeably.
<li><b>Changed:</b> Spread gauge is no longer FOV dependent. Outer (thin) circle is ~17MOA per tick and inner (thick) circle is ~83MOA per tick.
<li><b>Changed:</b> Phrasing changes for Speed, Bloom and Duration stats.
<li><b>Changed:</b> MAC-10 firing sounds.
<li><b>Changed:</b> Adjusted some weapon names and descriptions.
<li><b>Changed:</b> Magnum Pistols are now its own category.
<li><b>Changed:</b> Newsletter now appears when a TacRP weapon is drawn, instead of on load.
<li><b>Rebalance:</b> Significantly increased bloom recovery and reduced maximum bloom on most guns.
<li><b>Rebalance:</b> Significantly reduced range on all weapons.
<li><b>Rebalance:</b> Snipers now use Magnum Ammo (357) instead of Sniper Ammo (SniperPenetratedRound).
<li><b>Rebalance:</b> Surplus attachments now reduce recoil.
<li><b>Rebalance:</b> Mag Extenders slows down reload slightly.
<li><b>Rebalance:</b> Buffs to Beryl and M1A.
<li><b>Rebalance:</b> Sphinx 2000 is now a 3-round burst Machine Pistol (again).
<li><b>Rebalance:</b> Increased P90 recoil.
<li><b>Fixed:</b> Some worldmodels not having a folded stock bodygroup.
<li><b>Fixed:</b> Firemode resetting when detaching attachment.
<li><b>Fixed:</b> Minor alignment issues with optics.
<li><b>Fixed:</b> Some TTT2 related issues.
<li><b>Fixed:</b> Runaway Burst interactions with "Lower Weapon While Sprinting" off.
</ul>]],
    },
    {
        Title = "U16 Expansions",
        Type = "Patch Notes",
        Date = "2023-12-02",
        Author = "8Z",
        Major = true,
        Summary = "New expansion, new weapons, and many model touchups among the expanded TacRP family.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>As TacRP grows richer in features, the expansion addons also receive additions and touchups. Previously only documented in the steam page, the patch notes for them are now being added to the newsletter for ease of access.</p>

<hr>

<h2>Iron Curtain <i>(New!)</i></h2>
<p><input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3102297293\")")' /></p>
The Soviet/AK themed expansion starring 9 weapons, including well-known AK variants, weapons descended from the Kalashnikov design and the SVD (which isn't actually an AK, sorry for the false advertising).
<ul>
<li>AEK-971
<li>AK-12
<li>AK-74
<li>AK-74U
<li>AN-94
<li>Galil ARM (LMG configuration)
<li>Galil Sniper (a.k.a. The Galatz)
<li>RK-95
<li>SVD (we're really playing it loose with this one)
</ul>

<h2>InterOps</h2>
<input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=2975992869\")")' />
<ul>
<li>Model fixes to MX4/CX4, Remington 870 SPMM, and M14 SOPMOD.
<li>Reworked SCAR-H model with fixes and new animations.
<li>Replaced Desert Eagle textures.
</ul>

<h2>Special Delivery</h2>
<input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3007840813\")")' />
<ul>
<li><b>New weapons:</b> M1A1 Thompson, M1 Carbine, T/C G2 Contender.
<li>Replaced model for PP-19 Bizon.
<li>G3SG1 changed to G3A3, replaced model and reworked stats.
<li>Groza is now integrally suppressed, and has a different set of animations.
<li>Groza and FAMAS now have a rail mount for scopes.
<li>Added unique firing sound for De Lisle Carbine.
<li>Animation touch-ups across the board. Some animations will look significantly less jank now.
</ul>

<h2>ArmaLite Revolution</h2>
<input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3006376475\")")' />
<ul>
<li><b>New weapon:</b> AR-15 Compact.
</ul>

<h2>Brute Force</h2>
<input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3009874388\")")' />
<ul>
<li><b>New weapons:</b> The shovel and frying pan, for all you slapstick comedy fans.
</ul>

]],
    },
    {
        Title = "Update 16 Hotfix",
        Type = "Patch Notes",
        Date = "2023-12-05",
        Author = "8Z",
        Major = false,
        Summary = "i broke autosave sry",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<h3>Changelist</h3>
<ul>
<li><b>Fixed:</b> Autosave desyncing in singleplayer, causing attachments to not show up.
<li><b>Fixed:</b> Autosave not checking for slot validity or take from attachment inventory.
<li><b>Fixed:</b> AUG procedural irons issue.
<li><b>Fixed:</b> Exiting sprint disables shooting even if "Lower Weapon While Sprinting" is off.
<li><b>Changed:</b> Quick melee can now be held down to fire immediately or continue meleeing.
</ul>]],
    },
    {
        Title = "Update 17",
        Type = "Patch Notes",
        Date = "2023-12-24",
        Author = "speedonerd",
        Major = true,
        Summary = "A holly jolly update",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>This is speedonerd speaking! I'm one of the other people working on this mess, mainly in the asset department (models, sounds, animations).
<p>We've got quite the update here, one that brought on more things than we initially anticipated adding, including a bunch of new configuration options and a total melee system rework.

<h2>They have guns...lots of guns...</h2>
<p>NPC support now has a new dropdown menu, sorted by weapon type so you can easily find whatever weapon you're looking for. Within each category you can specify a certain weapon or have NPCs pick a random weapon from each quality tier.
<p>And for those who enjoy chaos, we've included an option for NPCs to spawn with <i>any</i> weapon randomly. Enjoy a random rebel with no sense of self-preservation facerocketing you!

<h2>drop me avp plz</h2>
<p>There's now a dedicated button in the customization menu to drop your current weapon, with dropped weapons able to be picked up with your 'use' key. 
<p>This synergizes with weapon slot restrictions, allowing you to swap weapons with any gun you find lying around with the press of a button.

<h2>It's like wading through molasses.</h2>
<p>In case you don't like how a certain balancing scheme punishes movement, there are now convars for each of the movement penalties that let you turn them off individually. 
<p>They can all be found under Movement in the Mechanics tab.

<h2>What happened to my freakin' car?!</h2>
<p>Fighting against vehicles with TacRP will now be a lot more interesting thanks to some hackery and workarounds to make infantry-to-vehicle combat functional.
<p>TacRP now works with LVS' armor penetration system, allowing gunfire, launched grenades and rockets to pierce vehicle armor. 
<p>Combine Hunter Choppers, infamous for their hardcoded immunity to everything but airboat gun damage, can now take damage from direct hits with rockets.

<h2>Now this...is a knife.</h2>
<p>TacRP's melee system has been very superficial for a while now with little statistical difference between weapons (which is especially prominent if you have Brute Force installed) and were more goofy than they were actually viable. 
<p>As such, we've remade the melee system with a host of new features, including actual weapon stats and a new attachment slot: Boost, which acts as a perk slot with various passive benefits from simple stat boosts to unique effects like regaining health. 
<p>The base pack's knives and every weapon from Brute Force have been updated to use this new system.

<h2>You kids today don't know how to circlestrafe!</h2>
<p>Do you yearn for the good old days, when shooters were fun because they didn't have depth or good game balance? I did for a brief period, and it compelled me to quickly integrate a new balance mode that removed ironsights and tightened up weapon spread. 
<p>It didn't really pan out how I had hoped—TacRP is built around so many modern mechanics and systems that it's hard to make it "old school" without stripping away nearly all of them. 
<p>Regardless, what I ended up with before abandoning it is still accessible via the console for preservation's sake, if you're interested.

<hr>

<h3>Changelist</h3>
<ul>
<li><b>Major Change:</b> Melee attributes & boost perks.
<li><b>Major Change:</b> NPC weapon dropdown with random roll option.
<li><b>Major Change:</b> Weapon dropping and swapping. TacRP weapons will now require pressing +USE to pick up - this can be disabled.
<li><b>Added:</b> New icons for Deadeye and Grenadier.
<li><b>Added:</b> Unfinished Old School balance mode. Enter "tacrp_balance 4" in console to access.
<li><b>Added:</b> CVars for toggling specific movement penalties.
<li><b>Added:</b> Restored concealment accessory. Hides weapon when holstered.
<li><b>Added:</b> Bipod hint will now draw with backup HUD.
<li><b>Added:</b> 40mm grenade casing eject effect.
<li><b>Added:</b> Dual MTX tactical attachment slot, attached to the right gun.
<li><b>Changed:</b> Gunfire can now penetrate LVS vehicles.
<li><b>Changed:</b> RPG rockets can now penetrate LVS vehicles and damage Combine Helicopter NPCs on a direct hit.
<li><b>Changed:</b> RPG-7 & M320 moved to separate launchers weapon category.
<li><b>Changed:</b> Added "Special Weapon" category for unorthodox weapons that don't fit any other category (currently only used by expansion weapons).
<li><b>Changed:</b> New trigger category for 4-position FCG weapons (weapons with auto, burst & semi modes). Blocks the Forced Reset and Burst triggers.
<li><b>Rebalance:</b> RPG rockets do more direct impact damage.
<li><b>Rebalance:</b> Deadeye grants increased zoom distance (again).
<li><b>Fixed:</b> Customization slot icon flash behavior causing errors.
<li><b>Fixed:</b> Corner cam display being the incorrect aspect ratio.
<li><b>Fixed:</b> Multiplayer attachment bodygroup networking issue.
<li><b>Fixed:</b> Multiplayer hold breath meter jitteryness.
<li><b>Fixed:</b> Multiplayer autosave playing deploy animation twice.
</ul>

<hr>

<p>For those wanting to follow TacRP, as well as anything else I or 8Z are working on, we now have our own Discord server! Join GMod Hyperrealism today!
<p><input type='submit' value='Join Server' onclick='console.log("RUNLUA:gui.OpenURL(\"https://discord.gg/w4n4FZmDtF\")")' /></p>

]],
    },
    {
        Title = "U17 Expansions",
        Type = "Patch Notes",
        Date = "2023-12-24",
        Author = "speedonerd",
        Major = false,
        Summary = "Touchups to existing packs.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<h3>Changelist</h3>
<ul>
<li><b>Added:</b> (ArmaLite Revolution) M16A1 refurbished bolt.
<li><b>Added:</b> (Special Delivery) Double Defense ejected shells sound.
<li><b>Fixed:</b> (Brute Force) M9 Bayonet misaligned worldmodel.
<li><b>Rebalance:</b> (Brute Force) All weapons have been updated to make use of the new melee stat system.
<li><b>Changed:</b> (InterOps) Replaced Five-Seven model and firing sounds.
<li><b>Changed:</b> (InterOps) Colt SMG restricted to using Colt 3x20 scope only.
<li><b>Changed:</b> (InterOps) China Lake revamp - Touched up animations, now ejects spent casings.
<li><b>Changed:</b> (InterOps) Automag animation touch-ups.
<li><b>Changed:</b> (Special Delivery) Gyrojet revamp - New firing sound, new animations, now in the "Special Weapon" category along with the Fat Mac.
<li><b>Changed:</b> (Special Delivery) WA2000 animation improvements.
<li><b>Changed:</b> (Special Delivery) Dual Berettas, USPs, 1911s & Deagles tactical attachment slot.
</ul>]],
    },
    {
        Title = "Update 17 Hotfix",
        Type = "Patch Notes",
        Date = "2023-12-31",
        Author = "8Z",
        Major = false,
        Summary = "Quick fix for NPC issue.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<h3>Changelist</h3>
<ul>
<li><b>Fixed:</b> Error when spawning NPC with default weapon.
</ul>]],
    },
    {
        Title = "Update 18",
        Type = "Patch Notes",
        Date = "2024-01-07",
        Author = "speedonerd",
        Major = false,
        Summary = "Small additions.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>Small update with a few fixes to compliment the new expansion.

<h3>Changelist</h3>
<ul>
<li><b>Added:</b> News button in customization page.
<li><b>Added:</b> Bind for HL2 flashlight when a tactical attachment is fitted (ALT + F).
<li><b>Added:</b> Random any weapon option for NPCs.
<li><b>Changed:</b> (TTT) Snipers now use 357 ammo instead of Deagle ammo.
<li><b>Changed:</b> (TTT) New TTT2 sprint functionality.
<li><b>Fixed:</b> (TTT) Quicknade convar errors in TTT2.
<li><b>Fixed:</b> (TTT) General TTT2 networking improvements and fixes.
</ul>]],
    },
    {
        Title = "Heavy Duty Release",
        Type = "Expansion Release",
        Date = "2024-01-07",
        Author = "speedonerd",
        Major = true,
        Summary = "New expansion and a new weapon for InterOps",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>Yet another new expansion. Originally intended to release in time for Christmas, we missed the mark a bit but hope you'll enjoy it all the same. We've also pushed some extra goodies to existing expansions.

<h2>Heavy Duty <i>(New!)</i></h2>
<p><input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3134547969\")")' /></p>
The heavy weaponry expansion, sporting 10 new weapons including autoshotties, guided rockets and an 80's cinema icon.
<ul>
<li>AMT Hardballer
<li>Dual Hardballers
<li>CheyTac M200 Intervention
<li>Franchi SPAS-12
<li>HK XM25 CDTE
<li>Holland & Holland Double Rifle
<li>Mk 153 SMAW
<li>Pancor Jackhammer
<li>SSK Industries .950 JDJ "Fat Mac"
<li>Taurus Raging Judge
</ul>

<h2>InterOps</h2>
<p><input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=2975992869\")")' /></p>
<ul>
<li><b>New weapon:</b> SIG SG 550-2 SP. A semi auto-only, non-sniper SIG in the Sporter Carbines category.
</ul>

<h2>ArmaLite Revolution</h2>
<input type='submit' value='Open Workshop' onclick='console.log("RUNLUA:gui.OpenURL(\"https://steamcommunity.com/sharedfiles/filedetails/?id=3006376475\")")' />
<ul>
<li><b>New weapon:</b> KAC SR-25 EMR. A high-power, low-capacity AR-based marksman rifle.
</ul>

<hr>

<h3>Changelist</h3>
<ul>
<li><b>Changed:</b> (InterOps) Updated XM8 LMG model. Added bipod and now has correct barrel length.
<li><b>Changed:</b> (InterOps) SG 550-1 burst mode changed to automatic, redone stats.
<li><b>Changed:</b> (Brute Force) Replaced crowbar and pipe wrench models with new ones from CSO2.
<li><b>Changed:</b> (Iron Curtain) SVD stat tweaks.
</ul>

<hr>

<p>Have a tactical 2024, gamers!]],
    },
        {
        Title = "Update 19",
        Type = "Patch Notes",
        Date = "2024-04-01",
        Author = "speedonerd",
        Major = true,
        Summary = "Not (quite) an April Fools update.",
        Contents = [[<body style="font-family:'Myriad Pro';color:white;font-size:125%;">
<p>Hey all! It's been a while since our last Workshop release and things over on the dev front have started to slow, owing to some real-life obligations from both me and 8Z. That's not to say we don't have anything new to share, as we've cooked up a few things in the past 2 months that we'll be dropping with this update.

<h2>What is this, "balance," you speak of?</h2>
<p>TacRP's various gameplay and balance settings have been, frankly, a total mess for a while. As we continued adding new tweakable options the menus started getting very cluttered, and as we continued adding new weapons we found that having to create 4 whole sets of stats for every single one became insanely arduous.
<p>A balance revamp was well overdue so we've gone and done just that. Instead of the Arcade-Tactical-TTT-PvE modes we had before that mainly changed TTK speeds and speed penalties, we've reduced this to three new balance modes: Tiered, Untiered and TTT.
<p>The main difference now is the utilization of the weapon tier system, with Tiered separating weapons into four tiers with higher tiers having better stats, and Untiered eliminating these tiers and making all weapons similar in stats. TTT mode still exists to cater to the specific gameplay flow of the mode.
<p>Instead of balance schemes controlling speed and handling penalties, things like melee and sighted slowdowns are togglable options independent of the balancing scheme, and damage can now be fine tuned per weapontype to increase or decrease TTK. Sliders for various other things like ADS speed, reload speed and recoil kick have also been added.
<p>These sliders and certain options that directly affect balance are under the Balance tab while mechanics that exist independent of balance scheme are under the Mechanics tab.

<h2>Dwarves don't use ironsights.</h2>
<p>Old School mode has been reworked into Old School Scopes; a balance mechanic independent of any one scheme. Like before, it disables ironsights and tightens hipfire, but spread will now be increased with an optic fitted. The higher an optic's magnification, the higher your spread penalty. 

<h2>More options, more fun!</h2>
<p>Some new minor gameplay options have been added for extra spice. 
<p>'Dump ammo in magazines' does exactly what it says on the tin: any ammo left in your magazine when you reload will be dropped onto the ground. It is not lost, however, as dropped magazines can be picked up by the player to recover the lost ammo. (This mechanic was not inspired by any particular <i>democratic game</i> and was entirely of our own invention)
<p>'Lower weapon while not aiming' forces weapons to always be lowered unless you're aiming them, similar to DarkRP.

<h2>Animator? I barely know her!</h2>
<p>Normally I wouldn't write something for an animation overhaul but this one is a special case. The K98 Sporter from InterOps has always been controversial as it's an iconic old-world bolt action that's been bastardized to use a box mag. The real reason for this was TacInt had no suitable animation set for a weapon like a Mauser rifle and we had to settle for what we had.
<p>That was until recently when a friend of ours approached us with new animations for the rifle; the Hunting Rifle animations from Cry of Fear. As such, the K98 has been revamped with these new animations and no longer has that fugly Sako mag protruding out from it. Thanks Lazarus!
<p>Oh yeah, the Double Defense from Special Delivery received new animations too, so that's neat.

<hr>

<h3>Changelog</h3>
<ul>
<li><b>Added:</b> (Base) HK45 Compact in Elite tier.
<li><b>Added:</b> (Base) New balance scheme overhaul.
<li><b>Changed:</b> (Base) RPG-7 projectiles have slightly shorter safety fuse.
<li><b>Changed:</b> (InterOps) New Kar 98k animations from Cry of Fear. (Thanks Lazarus!)
<li><b>Changed:</b> (InterOps) Rescaled FNC model.
<li><b>Changed:</b> (InterOps) Revised Honey Badger model and sounds.
<li><b>Changed:</b> (InterOps) New STAR-15 sounds. (Thanks rzenith!)
<li><b>Changed:</b> (Special Delivery) New Double Defense animations.
<li><b>Changed:</b> (Brute Force) New baseball bat animations. (Thanks Lazarus!)
<li><b>Fixed:</b> (Heavy Metal) Fixed laser beam origin on Hardballer.
<li><b>Fixed:</b> Some other stuff probably not worth documenting.
]],
    },
}
TacRP.NewsRead = TacRP.NewsRead or {}
TacRP.NewsFirstLoad = false
TacRP.NewsLoaded = nil
TacRP.NewsResult = "Uninitialized"
TacRP.NewsPopup = nil

function TacRP.SaveReadData()
    local tbl = {}
    for k, v in pairs(TacRP.NewsRead) do
        table.insert(tbl, k)
    end
    file.Write(TacRP.PresetPath .. "tacrp_news.txt", util.TableToJSON(tbl, false))
end

local date_pattern = "(%d+)-(%d+)-(%d+)"
function TacRP.LoadReadData()
    local tbl = util.JSONToTable(file.Read(TacRP.PresetPath .. "tacrp_news.txt", "DATA") or "") or {}
    TacRP.NewsRead = {}

    if #tbl == 0 then
        TacRP.NewsFirstLoad = true
    end

    for _, i in ipairs(tbl) do
        TacRP.NewsRead[i] = true
    end
end

function TacRP.RemoveNewsPanel()
    if TacRP.NewsPanel then
        TacRP.NewsPanel:Close()
        TacRP.NewsPanel = nil
    end
end

local function loadlocalandsort()
    TacRP.NewsLoaded = TacRP.NewsLoaded or {}

    for k, v in pairs(TacRP.News) do
        v.Key = k
        table.insert(TacRP.NewsLoaded, v)
    end

    table.sort(TacRP.NewsLoaded, function(a, b)
        local a_y, a_m, a_d = string.match(a.Date, date_pattern)
        local b_y, b_m, b_d = string.match(b.Date, date_pattern)
        if !a_y or !a_m or !a_d then return true end
        if !b_y or !b_y or !b_y then return false end
        if (a_y > b_y) or (a_y == b_y and a_m > b_m) or (a_y == b_y and a_m == b_m and a_d > b_d) then
            return true
        end
        return false
    end)
end

function TacRP.FetchNews(callback)
    if TacRP.NewsLoaded then
        if callback then
            callback()
        end
        return
    end
    TacRP.NewsResult = "Fetching news..."
    http.Fetch("https://theonly8z.github.io/tactical_realist/article_list", function(body, length, headers, code)
        local _, body_start = string.find(body, "<html lang=\"en\">", nil, true)
        local body_end = string.find(body, "</html>", nil, true)
        if body_start and body_end then
            local json = string.sub(body, body_start + 1, body_end - 1)
            local loaded = (util.JSONToTable(json) or {}).news
            if not loaded then
                loadlocalandsort()
                if callback then
                    callback()
                end
                TacRP.NewsResult = "Fetch failed: " .. #TacRP.News .. " local (cannot parse)"
                return
            end
            TacRP.NewsLoaded = {}
            for i, v in pairs(loaded or {}) do
                v.Key = v.Link
                table.insert(TacRP.NewsLoaded, v)
            end
            loadlocalandsort()

            TacRP.NewsResult = "Fetch OK: " .. #loaded .. " remote, " .. #TacRP.News .. " local"

            if callback then
                callback()
            end
        else
            loadlocalandsort()
            if callback then
                callback()
            end
            TacRP.NewsResult = "Fetch failed: " .. #TacRP.News .. " local (cannot parse)"
        end
    end, function(message)
        loadlocalandsort()
        TacRP.NewsResult = "Fetch failed: " .. #TacRP.News .. " local (" .. message .. ")"
        if callback then
            callback()
        end
    end)
end
local fetchnews = TacRP.FetchNews

local html_head = [[<head>
<style>
@font-face {
    font-family: "Myriad Pro";
    src: url("asset://garrysmod/resource/fonts/myriad pro regular.ttf");
}
</style>
</head>]]

local html_failed = [[<body style="font-family:'Myriad Pro';text-align:center;color:white;font-size:200%;">
<p>Failed to load this page.</p>
<p>Link: {URL}</p>
<p>Error: {ERROR}</p>
]]

TacRP.NewsPanel = TacRP.NewsPanel or nil
function TacRP.CreateNewsPanel(open)
    TacRP.RemoveNewsPanel()

    if TacRP.NewsFirstLoad then
        TacRP.SaveReadData()
        TacRP.NewsFirstLoad = false
    end

    local is_workshop = nil
    local last_update = nil
    steamworks.FileInfo(2588031232, function(result)
        last_update = os.date("%Y-%m-%d %H:%M", result.updated)
        is_workshop = steamworks.ShouldMountAddon(2588031232)
    end)

    local w_news, h_news = TacRP.SS(384), TacRP.SS(256)

    local h_bottom = TacRP.SS(8)
    local h_title = TacRP.SS(24)
    local w_list = TacRP.SS(96)
    local h_entry = TacRP.SS(18)

    TacRP.NewsPanel = vgui.Create("DFrame")
    TacRP.NewsPanel:SetTitle("")
    TacRP.NewsPanel:SetSize(w_news, h_news)
    TacRP.NewsPanel:ShowCloseButton(false)
    TacRP.NewsPanel:MakePopup()
    TacRP.NewsPanel:Center()
    TacRP.NewsPanel:SetDeleteOnClose(true)
    TacRP.NewsPanel:SetDraggable(false)
    function TacRP.NewsPanel.Paint(self, w, h)
    end

    local close = vgui.Create("DButton", TacRP.NewsPanel)
    close:SetSize(TacRP.SS(8), TacRP.SS(8))
    close:SetPos(w_news - TacRP.SS(10), 0)
    close:SetText("")
    function close.Paint(self, w, h)
        local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self:IsHovered() and !self:IsDown(), self:IsDown())
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
        draw.SimpleText("X", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function close.DoClick()
        TacRP.RemoveNewsPanel()
    end

    local cvarbox = vgui.Create("DCheckBox", TacRP.NewsPanel)
    cvarbox:SetSize(TacRP.SS(8), TacRP.SS(8))
    cvarbox:SetPos(TacRP.SS(2), 0)
    cvarbox:SetText("")
    cvarbox:SetConVar("tacrp_news_majoronly")
    function cvarbox.Paint(self, w, h)
        local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self:IsHovered(), self:GetChecked())
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
        if self:GetChecked() then
            draw.SimpleText("O", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    end
    local cvarback = vgui.Create("DPanel", TacRP.NewsPanel)
    cvarback:SetPos(TacRP.SS(11), 0)
    cvarback:SetSize(TacRP.SS(110), TacRP.SS(8))
    function cvarback.Paint(self, w, h)
        surface.SetDrawColor(0, 0, 0, 100)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h)

        draw.SimpleText("Only notify on major news/updates", "TacRP_Myriad_Pro_8", w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local y_title = TacRP.SS(2)
    local title = vgui.Create("DPanel", TacRP.NewsPanel)
    title:SetSize(w_news, h_title)
    title:Dock(TOP)
    function title.Paint(self, w, h)
        local c_bg = TacRP.GetPanelColor("bg2")
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, y_title, w, h - y_title)
        TacRP.DrawCorneredBox(0, y_title, w, h - y_title)
        draw.SimpleText("Tactical RP Newsletter", "TacRP_Myriad_Pro_20", w / 2, TacRP.SS(2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end

    local bottom = vgui.Create("DPanel", TacRP.NewsPanel)
    bottom:SetSize(w_news, h_bottom)
    bottom:Dock(BOTTOM)
    function bottom.Paint(self, w, h)
        local c_bg = TacRP.GetPanelColor("bg2")
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h)

        local text
        if is_workshop == true then
            text = "Update " .. tostring(TacRP.Version) .. " | " .. "Workshop: " .. last_update
        elseif is_workshop == false then
            text = "Update " .. tostring(TacRP.Version) .. " | " .. "Workshop: Not Mounted"
        end

        if text then
            draw.SimpleText(text, "TacRP_Myriad_Pro_6", TacRP.SS(4), h / 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        local branch = tostring(BRANCH)
        if branch == "unknown" then branch = "main" end

        draw.SimpleText("GMod Branch: " .. branch, "TacRP_Myriad_Pro_6", w - TacRP.SS(4), h / 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)

        draw.SimpleText(TacRP.NewsResult, "TacRP_Myriad_Pro_6", w  / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    local newspanel = vgui.Create("DScrollPanel", TacRP.NewsPanel)
    newspanel:SetSize(w_list, h_news - h_title)
    newspanel:DockMargin(0, TacRP.SS(2), 0, TacRP.SS(2))
    newspanel:Dock(LEFT)
    function newspanel.Paint(self, w, h)
        local c_bg = TacRP.GetPanelColor("bg")
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
    end
    local sbar = newspanel:GetVBar()
    function sbar:Paint(w, h)
    end
    function sbar.btnUp:Paint(w, h)
        local c_bg, c_txt = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("text", self:IsHovered())
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("↑", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function sbar.btnDown:Paint(w, h)
        local c_bg, c_txt = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("text", self:IsHovered())        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        draw.SimpleText("↓", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
    function sbar.btnGrip:Paint(w, h)
        local c_bg, c_cnr = TacRP.GetPanelColor("bg2", self:IsHovered()), TacRP.GetPanelColor("corner", self:IsHovered())        surface.SetDrawColor(c_bg)
        TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)
    end

    local newslist = vgui.Create("DIconLayout", newspanel)
    newslist:Dock(FILL)
    newslist:SetLayoutDir(TOP)
    newslist:SetSpaceY(TacRP.SS(2))

    local buttons = {}
    function TacRP.NewsPanel.PopulateNews(self2)
        newslist:Clear()
        for i, v in ipairs(TacRP.NewsLoaded) do
            local data = v
            local btn = newslist:Add("DButton")
            if data.Summary then
                btn.TextLines = TacRP.MultiLineText(data.Summary, w_list - TacRP.SS(4), "TacRP_Myriad_Pro_6")
                btn:SetSize(w_list, h_entry + #btn.TextLines * TacRP.SS(6.5))
            else
                btn:SetSize(w_list, h_entry)
            end
            btn:SetText("")
            btn.Index = i
            function btn.DoClick(self)
                TacRP.NewsPanel.Page:SetPageIndex(i)
            end
            function btn.Paint(self3, w, h)
                local down = btn.Index == TacRP.NewsPanel.Index
                local c_bg, c_cnr, c_txt = TacRP.GetPanelColors(self3:IsHovered() and !down, down)
                surface.SetDrawColor(c_bg)
                surface.DrawRect(0, 0, w, h)
                TacRP.DrawCorneredBox(0, 0, w, h, c_cnr)

                if !TacRP.NewsRead[data.Key] then
                    local c_glow = TacRP.GetPanelColor("text_glow", self3:IsHovered() and !down, down)
                    draw.SimpleText(data.Title, "TacRP_Myriad_Pro_8_Glow", TacRP.SS(2), TacRP.SS(2), c_glow, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                end
                draw.SimpleText(data.Title, "TacRP_Myriad_Pro_8", TacRP.SS(2), TacRP.SS(2), c_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                draw.SimpleText(data.Date or "Unknown Date", "TacRP_Myriad_Pro_6", w - TacRP.SS(2) - 12, TacRP.SS(9.5), c_txt, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP)
                draw.SimpleText((data.Type or "Article") .. ((data.Link or data.Hyperlink) and " (Web)" or ""), "TacRP_Myriad_Pro_6", TacRP.SS(2), TacRP.SS(9.5), c_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)

                if btn.TextLines then
                    for j, text in ipairs(btn.TextLines) do
                        draw.SimpleText(text, "TacRP_Myriad_Pro_6", TacRP.SS(2), TacRP.SS(16) + (j - 1) * TacRP.SS(6.5), c_txt, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
                    end
                end
            end
            buttons[i] = btn
        end
        newslist:SizeToChildren(false, true)
    end
    TacRP.NewsPanel:PopulateNews()

    local page = vgui.Create("DPanel", TacRP.NewsPanel)
    TacRP.NewsPanel.Page = page
    page:Dock(FILL)
    page:DockMargin(TacRP.SS(2), TacRP.SS(2), 0, TacRP.SS(2))
    page:InvalidateParent(true)

    function page:SetPageIndex(i)

        self:Clear()
        TacRP.NewsPanel.Index = i
        local data = TacRP.NewsLoaded[TacRP.NewsPanel.Index or -1]
        local ind = data.Key

        if !TacRP.NewsRead[ind] then
            timer.Remove("tacrp_news")
            timer.Create("tacrp_news", 0.5, 1, function()
                if TacRP.NewsPanel and TacRP.NewsPanel.Index == i then
                    TacRP.NewsRead[ind] = true
                    TacRP.SaveReadData()
                end
            end)
        end

        local pagelink = data.Hyperlink or data.Link
        if pagelink then
            self:SetSize(w_news - w_list - TacRP.SS(2), h_news - h_title - h_bottom - TacRP.SS(16))

            local topbar = vgui.Create("DPanel", self)
            topbar:Dock(TOP)
            topbar:SetTall(TacRP.SS(8))
            function topbar.Paint(self2, w, h)
            end

            local homebutton = vgui.Create("DButton", topbar)
            homebutton:SetText("")
            homebutton:Dock(LEFT)
            homebutton:SetSize(TacRP.SS(16), TacRP.SS(8))
            homebutton:DockMargin(TacRP.SS(2), 0, TacRP.SS(2), 0)
            homebutton:SetMouseInputEnabled(true)
            function homebutton.Paint(self2, w, h)
                local hover = self2:IsHovered()
                local c_bg, c_txt = TacRP.GetPanelColor("bg", hover), TacRP.GetPanelColor("text", hover)
                surface.SetDrawColor(c_bg)
                surface.DrawRect(0, 0, w, h)
                TacRP.DrawCorneredBox(0, 0, w, h, TacRP.GetPanelColor("corner", hover))
                draw.SimpleText("HOME", "TacRP_HD44780A00_5x8_4", w / 2, h / 2, c_txt, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            end
            function homebutton.DoClick(self2)
                homebutton.Page:OpenURL(pagelink)
            end

            local linkbutton = vgui.Create("DButton", topbar)
            if BRANCH == "unknown" then
                linkbutton:SetText("")
                linkbutton:Dock(FILL)
                linkbutton:SetMouseInputEnabled(true)
                linkbutton.Hyperlink = pagelink
                function linkbutton.Paint(self2, w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawRect(0, 0, w, h)
                    TacRP.DrawCorneredBox(0, 0, w, h, Color(0, 0, 0, 255))
                    local c = Color(50, 50, 255)
                    if self2:IsHovered() then
                        c = Color(100, 100, 255)
                    end
                    draw.SimpleText(self2.Hyperlink, "TacRP_Myriad_Pro_6", w / 2, h / 2, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    DisableClipping(true)
                    draw.SimpleText("Embedded browers do not work on your branch of GMod.", "TacRP_Myriad_Pro_8", w / 2, h + TacRP.SS(96), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Click here to open the tab in the overlay.", "TacRP_Myriad_Pro_8", w / 2, h + TacRP.SS(106), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DisableClipping(false)
                end
                function linkbutton.DoClick(self2)
                    gui.OpenURL(self2.Hyperlink)
                end
            else
                linkbutton:SetText("")
                linkbutton:Dock(FILL)
                linkbutton:SetMouseInputEnabled(true)
                linkbutton.Hyperlink = pagelink
                function linkbutton.Paint(self2, w, h)
                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.DrawRect(0, 0, w, h)
                    TacRP.DrawCorneredBox(0, 0, w, h, Color(0, 0, 0, 255))
                    local c = Color(50, 50, 255)
                    if self2:IsHovered() then
                        c = Color(100, 100, 255)
                    end
                    draw.SimpleText(self2.Hyperlink, "TacRP_Myriad_Pro_6", w / 2, h / 2, c, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                    DisableClipping(true)
                    draw.SimpleText("If the page does not load, click the link at the top to open externally.", "TacRP_Myriad_Pro_8", w / 2, h + TacRP.SS(96), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    DisableClipping(false)
                end
                function linkbutton.DoClick(self2)
                    gui.OpenURL(self2.Hyperlink)
                end
            end


            if BRANCH != "unknown" then
                local html = vgui.Create("DHTML", self)
                html:Dock(FILL)
                html:OpenURL(pagelink)
                function html.OnBeginLoadingDocument(self2, url)
                    linkbutton.Hyperlink = url
                end
                homebutton.Page = html
            else
                local html = vgui.Create("DButton", self)
                html:SetText("")
                html:Dock(FILL)
                linkbutton.Hyperlink = pagelink
                function html.Paint(self2) end
                function html.DoClick(self2)
                    gui.OpenURL(linkbutton.Hyperlink)
                end
            end
        else
            local c_txt = TacRP.GetPanelColor("text")

            local page_title = vgui.Create("DLabel", self)
            page_title:SetFont("TacRP_Myriad_Pro_20")
            page_title:SetTextColor(c_txt)
            page_title:SetText(data.Title)
            page_title:SizeToContents()
            page_title:DockMargin(TacRP.SS(4), TacRP.SS(2), 0, 0)
            page_title:Dock(TOP)

            local page_subtitle = vgui.Create("DPanel", self)
            page_subtitle:DockMargin(TacRP.SS(4), 0, TacRP.SS(4), TacRP.SS(2))
            page_subtitle:Dock(TOP)
            page_subtitle:SetTall(TacRP.SS(14))
            page_subtitle.Paint = function(self2, w, h)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.DrawLine(0, h - 1, w, h - 1)
            end

            local page_type = vgui.Create("DLabel", page_subtitle)
            page_type:SetFont("TacRP_Myriad_Pro_12")
            page_type:SetTextColor(c_txt)
            page_type:SetText((data.Type or "Article") .. (data.Author and (" • " .. data.Author) or ""))
            page_type:SizeToContents()
            page_type:Dock(LEFT)

            local page_date = vgui.Create("DLabel", page_subtitle)
            page_date:SetFont("TacRP_Myriad_Pro_12")
            page_date:SetTextColor(c_txt)
            page_date:SetText(data.Date or "Unknown Date")
            page_date:SizeToContents()
            page_date:Dock(RIGHT)

            local html = vgui.Create("DHTML", self)
            html:Dock(FILL)
            local url = data.ContentSource --or data.Link
            if url then
                http.Fetch(url, function(body, length, headers, code)
                    local article_start = string.find(body, "<section[^>]+>", nil, true)
                    local _, article_end = string.find(body, "</section>", nil, true)
                    if article_start and article_end then
                        body = string.sub(body, article_start, article_end)
                        html:SetHTML(html_head .. "\n" .. body)
                    else
                        html:SetHTML(body)
                    end
                end, function(message)
                    local body = html_failed
                    body = string.Replace(body, "{URL}", url)
                    body = string.Replace(body, "{ERROR}", message)
                    html:SetHTML(html_head .. "\n" .. body)
                end)
            else
                html:SetHTML(html_head .. "\n" .. data.Contents)
                html:SetAllowLua(true)
            end
        end

        self:InvalidateLayout(true)

        self:SizeToChildren(false, true)
    end

    function page:Paint(w, h)
        if !TacRP.NewsLoaded then return end
        local data = TacRP.NewsLoaded[TacRP.NewsPanel.Index or -1]
        if data and data.Hyperlink then return end

        local c_bg = TacRP.GetPanelColor("bg2")
        surface.SetDrawColor(c_bg)
        surface.DrawRect(0, 0, w, h)
        TacRP.DrawCorneredBox(0, 0, w, h)
    end

    local chosen = buttons[isnumber(open) and open or 1]
    if chosen then
        chosen:DoClick()
    end
end

concommand.Add("tacrp_news", function()
    fetchnews(function()
        local ind, major
        for i, v in ipairs(TacRP.NewsLoaded) do
            if !TacRP.NewsRead[v.Key] and (!ind or !major) then
                ind = i
                major = v.Major
            end
            if TacRP.NewsFirstLoad then -- if no read articles exist, mark all as read!
                TacRP.NewsRead[v.Key] = true
            elseif major then break end
        end

        TacRP.CreateNewsPanel(ind)
    end)
end)

concommand.Add("tacrp_news_reset", function()
    file.Delete(TacRP.PresetPath .. "tacrp_news.txt")
    TacRP.NewsRead = {}
    TacRP.NewsLoaded = nil
    TacRP.NewsFirstLoad = true
    TacRP.NewsPopup = nil
    TacRP.NewsResult = "Uninitialized"
end)

local function notifynews()
    TacRP.LoadReadData()

    fetchnews(function()
        local ind, major

        for i, v in ipairs(TacRP.NewsLoaded) do
            if !TacRP.NewsRead[v.Key] and (!ind or !major) then
                ind = i
                major = v.Major
            end
            if TacRP.NewsFirstLoad then -- if no read articles exist, mark all as read!
                TacRP.NewsRead[v.Key] = true
            elseif major then break end
            -- if major then break end
        end

        if ind then
            if major and !TacRP.ConVars["news_majoronly"]:GetBool() then
                TacRP.CreateNewsPanel(ind)
            -- elseif major or !TacRP.ConVars["news_majoronly"]:GetBool() then
            --     chat.AddText(color_white, "------------- Tactical RP -------------")
            --     chat.AddText(color_white, "New " .. string.lower(TacRP.NewsLoaded[ind].Type or "article") .. " released!")
            --     chat.AddText(color_white, "Use command 'tacrp_news' or type '/tacrp_news' to view it and suppress this message.")
            --     chat.AddText(color_white, "---------------------------------------")
            end
        end
    end)
end
concommand.Add("tacrp_news_check", notifynews)

-- hook.Add("InitPostEntity", "tacrp_news", function()
--     timer.Simple(5, function()
--         if !TacRP.ConVars["checknews"]:GetBool() then return end
--         notifynews()
--     end)
-- end)

hook.Add("OnPlayerChat", "tacrp_news", function(ply, txt)
    if ply == LocalPlayer() and string.lower(txt) == "/tacrp_news" then
        LocalPlayer():ConCommand("tacrp_news")
        return true
    end
end)