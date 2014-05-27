law = require 'law'
logger = require 'torch'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    host: 'mongodb://localhost:27017/default'

  attachments:
    boot: ['server.run/load', 'server.test/load']
    link: ['server.run/link', 'server.test/link']

  # Services used by the extension
  services: law.load rel 'services'
