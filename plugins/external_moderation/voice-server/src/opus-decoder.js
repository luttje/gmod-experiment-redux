const { OpusEncoder } = require('@discordjs/opus')

// Utility function to get a new Opus encoder instance
const getEncoder = () => new OpusEncoder(24000, 1)

// Decodes Opus frames and handles lost frames
const decodeOpusFrames = (buf, encoderState, id64) => {
  let readPos = 0
  const frames = []

  while (readPos < buf.length - 4) {
    const len = buf.readUInt16LE(readPos)
    readPos += 2

    const seq = buf.readUInt16LE(readPos)
    readPos += 2

    if (!encoderState.seq || seq < encoderState.seq) {
      encoderState.encoder = getEncoder()
      encoderState.seq = seq
    } else if (encoderState.seq !== seq) {
      let lostFrames = seq - encoderState.seq

      for (let i = 0; i < lostFrames; i++) {
        frames.push(encoderState.encoder.decodePacketloss())
      }

      encoderState.seq = seq
    }

    encoderState.seq++

    if (len <= 0 || seq < 0 || readPos + len > buf.length) {
      console.error(`Invalid packet LEN: ${len}, SEQ: ${seq}`)

      return
    }

    const data = buf.slice(readPos, readPos + len)
    readPos += len

    const decodedFrame = encoderState.encoder.decode(data)
    frames.push(decodedFrame)
  }

  const decompressedData = Buffer.concat(frames)
  encoderState.stream.push(decompressedData)
}

module.exports = {
  getEncoder,
  decodeOpusFrames
}
