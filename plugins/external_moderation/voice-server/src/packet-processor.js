const { decodeOpusFrames } = require('./opus-decoder')
const { OpusEncoder } = require('@discordjs/opus')
const { Writer: WavWriter } = require('wav')
const fs = require('fs')

const encoders = {}
const OP_CODES = {
  OP_CODEC_OPUSPLC: 6,
  OP_SAMPLERATE: 11,
  OP_SILENCE: 0
}

// Generates a unique WAV filename based on user ID
const getUniqueFilename = (id64, ext = 'wav') => `user_${id64}_${Date.now()}.${ext}`

module.exports = {
  getUniqueFilename
}

// Processes incoming packets and saves them to a WAV file
const processAndSavePackets = (buffer, outputDirectory, callback) => {
  let readPosition = 0
  const id64 = buffer.readBigInt64LE(readPosition)
  readPosition += 8

  if (!encoders[id64]) {
    const wavFileName = getUniqueFilename(id64)
    const wavFilePath = outputDirectory + '/' + wavFileName
    const wavFileStream = fs.createWriteStream(wavFilePath)
    const wavWriter = new WavWriter({ sampleRate: 24000, channels: 1, bitDepth: 16 })

    wavWriter.pipe(wavFileStream)

    encoders[id64] = {
      encoder: new OpusEncoder(24000, 1),
      stream: wavWriter,
      fileName: wavFileName,
      fileStream: wavFileStream,
    }
  }

  encoders[id64].time = Date.now() / 1000

  const maxRead = buffer.length - 4

  while (readPosition < maxRead - 1) {
    const opCode = buffer.readUInt8(readPosition)

    readPosition++

    switch (opCode) {
      case OP_CODES.OP_SAMPLERATE:
        const sampleRate = buffer.readUInt16LE(readPosition)

        readPosition += 2

        break
      case OP_CODES.OP_SILENCE:
        const samples = buffer.readUInt16LE(readPosition)
        const encoder = encoders[id64]

        readPosition += 2

        encoder.stream.push(Buffer.alloc(samples * 2))

        // Close the current file after we've processed all the packets
        encoder.stream.end()
        encoder.fileStream.close()
        encoders[id64] = null

        if (callback) {
          callback(id64.toString(), encoder.fileName)
        }

        break
      case OP_CODES.OP_CODEC_OPUSPLC:
        const dataLen = buffer.readUInt16LE(readPosition)

        readPosition += 2

        decodeOpusFrames(buffer.slice(readPosition, readPosition + dataLen), encoders[id64], id64)

        readPosition += dataLen

        break
      default:
        console.error(`Unhandled opcode ${opCode}`)
        fs.writeFileSync(getUniqueFilename(id64, 'bin'), buffer)
        break
    }
  }
}

module.exports = {
  processAndSavePackets
}
