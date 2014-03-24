law = require 'law'
logger = require 'torch'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    run:
      extends: 'server'
      models: []
      host: "mongodb://localhost:27017/"

  # Services used by the extension
  services: law.load rel('services')
