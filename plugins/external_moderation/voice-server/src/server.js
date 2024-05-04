const { processAndSavePackets } = require('./packet-processor')
const { transcribe } = require('./transcribe')
const { moderationService } = require('./moderation-service')
const dotenv = require('dotenv')
const dgram = require('dgram')
const fs = require('fs')

const shouldTranscribe = true
const modelArgIndex = process.argv.indexOf('--model')
let model = 'en'

if (modelArgIndex !== -1) {
  model = process.argv[modelArgIndex + 1]
}

const outputDirectoryNotTranscribed = 'recordings/untranscribed/'
const outputDirectoryTranscribed = 'recordings/transcribed/'
const pathOfScript = process.argv[1]

dotenv.config({ path: `${pathOfScript}/../web/.env` })

moderationService.init(process.env.APP_URL + '/api/submit-voice-chat-log', process.env.API_SECRET)

const server = dgram.createSocket('udp4')

server.on('error', (err) => {
  console.error(`Server error:\n${err.stack}`)
  server.close()
})

server.on('message', (msg, remoteInfo) => {
  try {
    processAndSavePackets(msg, outputDirectoryNotTranscribed, function (id64, wavFileName) {
      if (shouldTranscribe) {
        const notTranscribedFilePath = `${outputDirectoryNotTranscribed}/${wavFileName}`

        transcribe(notTranscribedFilePath, model).then((text) => {
          const transcribedFilePath = `${pathOfScript}/${outputDirectoryTranscribed}${wavFileName}`
          fs.renameSync(notTranscribedFilePath, transcribedFilePath)

          moderationService.sendForModeration(id64, text.trim(), transcribedFilePath)
        })
      }
    })
  } catch (error) {
    console.error(`Error processing packet from ${remoteInfo.address}:${remoteInfo.port}:`, error)
  }
})

server.on('listening', () => {
  const { address, port } = server.address()

  console.log(`UDP socket listening at ${address}:${port}`)
})

const PORT = process.env.PORT || 4000
server.bind(PORT)
