const express = require('express');
const { spawn } = require('child_process');
const { createHash } = require('crypto');
const dotenv = require('dotenv')
// const cors = require('cors');
const fs = require('fs');

const pathOfScript = process.argv[1]
const apiKey = process.env.API_SECRET

dotenv.config({ path: `${pathOfScript}/.env` })

const app = express();
const port = 3000;

// app.use(cors())
app.use(express.urlencoded({ extended: true }));

app.post('/generate-voice', (req, res) => {
    const scriptPath = './init-voice-gen.sh';
    const body = req.body.text
    const requestApiKey = req.body.api_key

    if (requestApiKey !== apiKey) {
        return res.status(401).send('Unauthorized')
    }

    const outputFileName = createHash('md5').update(body).digest('hex') + '.wav';

    // Check if the file already exists, and if so, return it instead of regenerating it
    const filePath = `/root/.local/share/mycroft/mimic3/${outputFileName}`;
    if (fs.existsSync(filePath)) {
        console.log('File already exists, returning it');
        return res.send(outputFileName);
    }

    // Run the script to generate the voice
    const childProcess = spawn(scriptPath, [outputFileName]);

    childProcess.stdout.on('data', (data) => {
        console.log(`stdout: ${data}`);
    });

    childProcess.stderr.on('data', (data) => {
        console.log(`stderr: ${data}`);
    });

    childProcess.on('close', (code) => {
        console.log(`child process exited with code ${code}`);

        res.send(outputFileName);
    });

    childProcess.stdin.write(body);
    childProcess.stdin.end();
});

app.listen(port, () => {
    console.log(`Voice generator server listening at http://localhost:${port}`);
});
