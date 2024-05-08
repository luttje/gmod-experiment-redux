# Experiment Redux

**An FPS RPG gamemode for Garry's Mod, built using the [Helix framework](https://github.com/nebulouscloud/helix).**

<div align="middle">

![Experiment Redux logo](./logo.png)

**🐕 It's a dog-eat-dog world out there, and these dogs have guns.**

</div>

## Installation

1. Clone this repository into your `garrysmod/gamemodes` directory and name the directory `experiment-redux`:

    ```sh
    git clone https://github.com/luttje/gmod-experiment-redux experiment-redux
    ```

2. Ensure you have the Helix based installed [following the Helix documentation](https://docs.gethelix.co/manual/getting-started/).

3. (Re-)start Garry's Mod and start a game with the `Experiment Redux` gamemode.

## About

**Experiment Redux** is a reimagining of the original *Experiment* gamemode for Garry's Mod. It combines elements of first-person shooters, role-playing games, and survival games, along with a month-long competitive cycle to create a unique gameplay experience.

&raquo; **Read more in our [🔮 Vision](docs/vision.md) document**

## Hosting a Server

For a quick overview check out the [🏗 Dev Server Guide](docs/dev-server-guide.md). This guide will walk you through setting up a dedicated server for development purposes.

You can find more information on hosting a Garry's Mod server in the [official documentation](https://wiki.facepunch.com/gmod/Downloading_a_Dedicated_Server).

## Content

**This project will maintain a minimal schema to run Experiment on Helix. It will only contain code and content that can be licensed under the MIT license.** This means we can not include content from the original Experiment schema that used third-party assets for items like the Exo Skeletons inside the repository.

Other third-party content may be included through the use of the [Steam Workshop](https://steamcommunity.com/app/4000). See [the `customizable_weaponry` plugin](plugins/customizable_weaponry) for an example of how to include third-party content.

## License

This project is licensed under the MIT license. See the [LICENSE](./LICENSE) file for details.

The original Experiment was developed by Conna Wiles around 2009. You'll find a lot of his code in this project, which you can originally find MIT licensed code in his [`kurozael/project-archive` repository](https://github.com/kurozael/project-archive)
