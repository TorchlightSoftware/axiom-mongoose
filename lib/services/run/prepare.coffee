logger = require 'torch'
connect = require 'connect'
law = require 'law'
lawAdapter = require 'law-connect'
fs = require 'fs'

module.exports =
  required: []
  service: (args, done) ->

    app = connect()
    app.use (req, res, next) ->
      res.setHeader "Access-Control-Allow-Origin", "*"
      next()
    app.use connect.compress()
    app.use connect.responseTime()
    app.use connect.favicon()
    app.use connect.query()
    app.use connect.cookieParser()
    app.use connect.static @config.paths.public

    # TODO: break out into separate service, call via @axiom.request
    app.use connect.bodyParser()

    load = (prop) =>
      filepath = @config.law[prop]
      return @util.retrieve(filepath)

    app.use lawAdapter {
      services: law.create {
        services: law.load @util.rel(@config.law.services)
        jargon: try load('jargon')
        policy: try load('policy')
      }
      routeDefs: try load('routeDefs')
      options: @config.law.adapterOptions
    }

    @config.app = app
    done()
