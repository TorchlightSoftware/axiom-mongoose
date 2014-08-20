law = require 'law'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    host: 'mongodb://localhost:27017/default'
    modelDir: 'app/server/models'
    dataLocation: 'fixtures/data'
    seedLocation: 'fixtures/seed'

  extends:
    loadDb: ['server.run/load', 'server.test/load', 'db.seed/load']
    linkResources: ['server.run/link', 'server.test/link']
    linkFactory: ['db.seed/link', 'server.test/link']
    runSeed: ['db.seed/run']

    unloadDb: ['server.run/unload', 'server.test/unload', 'db.seed/unload']

  # Services used by the extension
  services: law.load rel 'services'
