law = require 'law'
logger = require 'torch'
{join} = require 'path'

rel = (args...) -> join __dirname, args...

module.exports =
  config:
    run:
      base: 'runtime'
      stages:
        start: ['prepare', 'boot', 'connect']
        stop: ['disconnect', 'shutdown', 'release']

      port: 4000
      ssl: false
      paths:
        public: rel '..', 'public'

      allowAll: true
      options: [
        'compress'
        'responseTime'
        'favicon'
        'staticCache'
        'query'
        'cookieParser'
      ]

      static: ['app/public']

      # 'law' and 'law-connect' config
      law:
        # All paths are default subpaths (relative to 'projRoot').
        # The value of 'services' is the relative subpath to services
        # _exposed_ by the extension, via a Connect server, not _used_
        # by the extension.
        services: 'app/server/services'
        policy: 'app/load/policy'
        jargon: 'app/load/jargon'
        routeDefs: 'app/load/routes'
        adapterOptions:
          includeDetails: false
          includeStack: false

  # Services used by the extension
  services: law.load rel('services')
