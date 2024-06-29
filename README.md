# Experiment Redux

**An FPS RPG gamemode for Garry's Mod, built using the [Helix framework](https://github.com/nebulouscloud/helix).**

<div align="middle">

![Experiment Redux logo](./logo.png)

**🐕 It's a dog-eat-dog world out there, and these dogs have guns.**

</div>

## Installation

1. Subscribe to the required addons on the [Steam Workshop Collection](https://steamcommunity.com/sharedfiles/filedetails/?id=3215035081).

2. Install Git LFS by following the [official installation instructions](https://git-lfs.github.com/).

3. Clone this repository into your `garrysmod/gamemodes` directory and name the directory `experiment-redux`:

    ```sh
    git clone https://github.com/luttje/gmod-experiment-redux experiment-redux
    ```

4. Ensure you have the Helix based installed [following the Helix documentation](https://docs.gethelix.co/manual/getting-started/).

5. (Re-)start Garry's Mod and start a game with the `Experiment Redux` gamemode.

## About

**Experiment Redux** is a reimagining of the original *Experiment* gamemode for Garry's Mod. It combines elements of first-person shooters, role-playing games, and survival games, along with a month-long competitive cycle to create a unique gameplay experience.

&raquo; **Read more in our [🔮 Vision](docs/vision.md) document**

## 📸 Screenshots

<details>

<summary>Create a single character to play for the Epoch</summary>

![One Character](docs/screenshots/screenshot01_one_character.jpg)

</details>

<details>

<summary>Select a spawn point to start/respawn from</summary>

![Spawn Select](docs/screenshots/screenshot02_spawn_select.jpg)

</details>

<details>

<summary>Manage your inventory and equipment</summary>

![Inventory](docs/screenshots/screenshot03_inventory.jpg)

</details>

<details>

<summary>View your character's stats and nano buffs</summary>

![You](docs/screenshots/screenshot04_you.jpg)

</details>

<details>

<summary>Store items in your locker for safekeeping</summary>

![Locker](docs/screenshots/screenshot05_locker.jpg)

</details>

<details>

<summary>Buy and sell items at The Business</summary>

![The Business](docs/screenshots/screenshot06_the_business.jpg)

</details>

<details>

<summary>Protect your door with a door protector</summary>

![The Business Door Protector](docs/screenshots/screenshot07_the_business_door_protector.jpg)

![Door Protector](docs/screenshots/screenshot08_door_protector.jpg)

</details>

<details>

<summary>Upgrade your bolt generator to produce more bolts</summary>

![Bolt Generator](docs/screenshots/screenshot09_bolt_generator.jpg)

![Bolt Generator Upgrade](docs/screenshots/screenshot10_bolt_generator_upgrade.jpg)

</details>

<details>

<summary>Scavenge for items in this forsaken city</summary>

![Scavenging](docs/screenshots/screenshot11_scanvenging.jpg)

![Scavenging Loot](docs/screenshots/screenshot12_scavenging_loot.jpg)

</details>

<details>

<summary>The medic NPC will ask for your aid</summary>

![NPC Medic](docs/screenshots/screenshot13_npc_medic.jpg)

![NPC Medic Dialog](docs/screenshots/screenshot14_npc_medic_dialog.jpg)

</details>

<details>

<summary>Monsters roam a select location in the city, slay them for loot</summary>

![Monsters](docs/screenshots/screenshot15_monsters.jpg)

![Monsters](docs/screenshots/screenshot16_monsters.jpg)

</details>

<details>

<summary>Compete in a footrace against other players to improve your attributes</summary>

![NPC Footrace](docs/screenshots/screenshot17_npc_footrace.jpg)

![NPC Footrace Dialog](docs/screenshots/screenshot18_npc_footrace_dialog.jpg)

</details>

<details>

<summary>Improve your attributes at the target practice NPC</summary>

![NPC Target Practice](docs/screenshots/screenshot19_npc_target_practice.jpg)

![NPC Target Practice Dialog](docs/screenshots/screenshot20_npc_target_practice_dialog.jpg)

</details>

## Hosting a Server

For a quick overview check out the [🏗 Dev Server Guide](docs/dev-server-guide.md). This guide will walk you through setting up a dedicated server for development purposes.

You can find more information on hosting a Garry's Mod server in the [official documentation](https://wiki.facepunch.com/gmod/Downloading_a_Dedicated_Server).

## Content

**This project will maintain a minimal schema to run Experiment on Helix. It will only contain code and content that can be licensed under the MIT license.** This means we can not include content from the original Experiment schema that used third-party assets for items like the Exo Skeletons inside the repository.

Other third-party content may be included through the use of the [Steam Workshop](https://steamcommunity.com/app/4000). See [the `customizable_weaponry` plugin](plugins/customizable_weaponry) for an example of how to include third-party content.

## License

This project is licensed under the MIT license. See the [LICENSE](./LICENSE) file for details.

The original Experiment was developed by Conna Wiles around 2009. You'll find a lot of his code in this project, which you can originally find MIT licensed code in his [`kurozael/project-archive` repository](https://github.com/kurozael/project-archive)
