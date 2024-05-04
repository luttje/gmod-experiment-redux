const { pipeline } = require('stream')
const util = require('util')
const fs = require('fs')
const { createOfflineRecognizer } = require('./sherpa')
const { Readable } = require('stream')
const { Reader: WavReader } = require('wav')

async function transcribe(wavFileName, model) {
  const recognizer = createOfflineRecognizer(model)
  const stream = recognizer.createStream()
  const reader = new WavReader()
  const readable = new Readable().wrap(reader)
  const buffer = []

  reader.on('format', ({ audioFormat, bitDepth, channels, sampleRate }) => {
    if (sampleRate !== recognizer.config.featConfig.sampleRate) {
      throw new Error(`Only support sampleRate ${recognizer.config.featConfig.sampleRate}. Given ${sampleRate}`)
    }

    if (audioFormat !== 1) {
      throw new Error(`Only support PCM format. Given ${audioFormat}`)
    }

    if (channels !== 1) {
      throw new Error(`Only a single channel. Given ${channels}`)
    }

    if (bitDepth !== 16) {
      throw new Error(`Only support 16-bit samples. Given ${bitDepth}`)
    }
  })

  readable.on('readable', () => {
    let chunk
    while ((chunk = readable.read()) !== null) {
      const int16Samples = new Int16Array(
        chunk.buffer, chunk.byteOffset,
        chunk.length / Int16Array.BYTES_PER_ELEMENT)

      const floatSamples = new Float32Array(int16Samples.length)

      for (let i = 0; i < floatSamples.length; i++) {
        floatSamples[i] = int16Samples[i] / 32768.0
      }

      buffer.push(floatSamples)
    }
  })

  let fsStream

  try {
    fsStream = fs.createReadStream(wavFileName, { highWaterMark: 4096, autoClose: true })
    await util.promisify(pipeline)(
      fsStream,
      reader
    )

    // Tail padding
    const floatSamples = new Float32Array(recognizer.config.featConfig.sampleRate * 0.5)
    buffer.push(floatSamples)
    const flattened = Float32Array.from(buffer.reduce((a, b) => [...a, ...b], []))

    stream.acceptWaveform(recognizer.config.featConfig.sampleRate, flattened)
    recognizer.decode(stream)

    const text = recognizer.getResult(stream).text
    return text
  } catch (error) {
    throw error
  } finally {
    stream.free()
    readable.destroy()
    recognizer.free()

    if (fsStream) {
      fsStream.close()
    }
  }
}

module.exports = {
  transcribe
}
