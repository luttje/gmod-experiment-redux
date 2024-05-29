const express = require('express');
const { spawn } = require('child_process');
const { createHash } = require('crypto');
const fs = require('fs');

const apiKey = process.env.API_SECRET

const app = express();
let port = 3000;

if (process.env.APP_URL) {
    const portMatch = process.env.APP_URL.match(/:(\d+)/);

    if (portMatch) {
        port = portMatch[1];
    }
}

app.use(express.urlencoded({ extended: true }));

// curl -X POST -d "text=Hello%20world%21%0A&api_key=secret" http://localhost:3000/generate-voice
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
        return res.send(outputFileName);
    }

    // Run the script to generate the voice
    const childProcess = spawn(scriptPath, [outputFileName]);

    childProcess.on('close', (code) => {
        res.send(outputFileName);
    });

    childProcess.stdin.write(body);
    childProcess.stdin.end();
});

app.listen(port, () => {
    console.log(`Voice generator server listening at http://localhost:${port}`);
});
