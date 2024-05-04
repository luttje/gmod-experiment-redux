# 🎤 Experiment External Moderation - Voice Chat Recorder

This uses [the awesome `gm_8bit` module](https://github.com/Meachamp/gm_8bit) to save and transcribe voice chats. It then sends them off to the [companion web interface](../web/) for external moderation.

For a standalone example see [the `gmod-voice-chat-recorder` repository](https://github.com/luttje/gmod-voice-chat-recorder).

## 🚀 Getting Started

1. Ensure you have [Node.js](https://nodejs.org/en/) installed and also: `sudo apt-get install build-essential` on Linux.

2. Clone (or download) this repository.

3. Open a terminal (or command prompt) in this directory.

4. Run `npm ci` in this directory.

5. Set this server up to run on startup using crontab, we've prepared a bash script that will keep it running in the background:

    ```bash
    crontab -e
    ```

    Add the following line to the end of the file:

    ```bash
    @reboot /srv/experiment-redux/plugins/external_moderation/voice-server/start.sh
    ```

    Save and exit the file.

6. Install `gm_8bit` to the server:

    1. Going to the [`gm_8bit` GitHub Actions](https://github.com/Meachamp/gm_8bit/actions)

    2. Clicking the latest workflow run that has a green checkmark.

    3. Scroll all the way down to the `Artifacts` section ([see for example the February 19 workflow artifacts](https://github.com/Meachamp/gm_8bit/actions/runs/7953375251#artifacts)).

    4. Download the `gmsv_eightbit_win64.dll` file if you're on Windows, or the `gmsv_eightbit_linux64.dll` file if you're on Linux (or choose the non-64-bit version if you're not running the server on a 64-bit system).

    5. Place the downloaded file in the `garrysmod/lua/bin` directory of your Garry's Mod server.

7. Start your Garry's Mod server with the Experiment gamemode.

8. Join your server, don't forget to plug in a microphone, then start voice chatting.

9. You'll see debug output marking how many bytes were received:

    ```bash
    $ node .
    UDP socket listening at 0.0.0.0:4000
    Received: 534 bytes from 127.0.0.1:52909
    Received: 227 bytes from 127.0.0.1:52909
    Received: 277 bytes from 127.0.0.1:52909
    Received: 248 bytes from 127.0.0.1:52909
    Received: 172 bytes from 127.0.0.1:52909
    Received: 244 bytes from 127.0.0.1:52909
    ... etc ...
    ```

10. Each time a player speaks the data is saved to a file like `user_<STEAM_ID_64>_<CURRENT_TIMESTAMP>.wav` in the `recordings/untranscribed` directory.

    New files are created each time the player falls silent.

## 👄 Voice Chat Transcription

This example shows how to use [`sharpa-onnx`](https://github.com/k2-fsa/sherpa-onnx) to transcribe recorded voice chat to text. This uses a pre-trained model which works offline, even on your CPU.

For this basic example we've chosen the fastest English model we've tried, but **other models like OpenAI Whisper are also supported. [&raquo; Read more](https://github.com/luttje/gmod-voice-chat-recorder/blob/main/docs/transcribe-other-models.md)**

To get started transcribing voice chat automatically:

1. Download the pre-trained offline transducer model into this repository's directory:

    ```bash
    wget https://github.com/k2-fsa/sherpa-onnx/releases/download/asr-models/sherpa-onnx-zipformer-en-2023-06-26.tar.bz2
    tar xvf sherpa-onnx-zipformer-en-2023-06-26.tar.bz2
    ```

2. Run the server with `npm run start`

3. When a player speaks, the audio is transcribed to text. You'll find transcribed audio moved to the `recordings/transcribed` directory.

4. Transcriptions will be sent to the companion web interface for external moderation.

5. During transcription you might see output like this being repeated in the console:

    ```bash
    YYYY-MM-DD HH:MM:SS.000000 [W:onnxruntime:, graph_utils.cc:139 CanUpdateImplicitInputNameInSubgraphs]  Implicit input name <number> cannot be safely updated to <number> in one of the subgraphs.
    ```

> [!WARNING]
> Note that transcription isn't perfect and will not work well with noisy audio or non-English speakers. In my experience it only works well if you articulate clearly and speak English with a neutral accent.
> Nevertheless, seeing how this is all done on-device (offline) it's still pretty impressive!

## 📦 Troubleshooting

In order to get the library to work on `Ubuntu 24.04 LTS (x86_64)` I had to run:

```bash
ln -s libtier0_s.so libtier0.so
```

Inside my servers `/bin` directory (not the `garrysmod/bin` and not the `garrysmod/lua/bin` directory).
