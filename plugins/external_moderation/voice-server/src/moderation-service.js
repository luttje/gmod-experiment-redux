const axios = require('axios')

const moderationService = {
  init: function (url, secret) {
    this.url = url
    this.secret = secret
  },

  // TODO: For simplicity we just leave the file in place, since the voice-server and moderation-service are running on the same machine atm. Eventually, we should send it off to a different server.
  sendForModeration: function (id64, text, filePath) {
    const data = {
      steam_id: id64,
      message: text,
      voice_chat_path: filePath,
    }

    axios.post(this.url, data, {
      headers: {
        'X-Api-Secret': this.secret,
        'Accept': 'application/json',
      },
    }).catch((error) => {
      console.error('Error sending for moderation:', error)
    })
  },
}

module.exports = { moderationService }
