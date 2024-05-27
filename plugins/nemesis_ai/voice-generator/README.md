# 🤖 Experiment AI Voice Generator

We build upon the [mimic-3 tts docker image](https://mycroft-ai.gitbook.io/docs/mycroft-technologies/mimic-tts/mimic-3#docker-image) to provide a simple API that will generate speech from a given text.

## 🚀 Getting Started

1. Ensure you have [Docker](https://www.docker.com/) installed.

2. Clone (or download) this repository.

3. Open a terminal (or command prompt) in this directory.

4. Build the docker image in this directory.

    ```bash
    docker build -t voice-generator .
    ```

### Locally

1. Start the docker container

    ```bash
    MSYS_NO_PATHCONV=1 docker run -p 3000:3000 -i --rm -v "$(pwd)/volume:/root/.local/share/mycroft/mimic3" voice-generator
    ```

    The `MSYS_NO_PATHCONV=1` prefix is only required for Windows users using Git Bash.

### Production

1. Set this server up to run on startup using crontab, we've prepared a bash script that will keep it running in the background:

    ```bash
    crontab -e
    ```

    Add the following line to the end of the file:

    ```bash
    @reboot /srv/experiment-redux/plugins/nemesis_ai/voice-generator/start.sh
    ```

    Save and exit the file.

2. Ensure the Garry's Mod server is run with the `-allowlocalhttp` command line argument.

3. Restart the server.
