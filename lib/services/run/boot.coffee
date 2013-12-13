{join} = require 'path'
fs = require 'fs'

logger = require 'torch'
http = require 'http'
https = require 'https'

read = (file) -> fs.readFileSync file, 'utf8'

module.exports =
  service: (args, done) ->

    finished = (err) =>
      @axiom.log.info "Started server on port #{@config.port}."
      done(err)

    {app} = @config
    done ?= ->

    if @config.ssl

      # read cert files
      ca = config.app.ssl.ca || []
      options =
        key: read config.app.ssl.key
        cert: read config.app.ssl.cert
        ca: ca.map read

      # create server with ssl
      server = https.createServer(options, app).listen @config.port, finished

      #http server to redirect to https
      if @config.ssl.redirectFrom?
        redirect = (req, res) ->
          redirectTarget = "https://#{req.headers.host}#{req.url}"
          res.writeHead 301, {
            "Location": redirectTarget
          }
          res.end()
        redirectServer = http.createServer(redirect).listen config.app.ssl.redirectFrom
      @config.server = server

    else
      @config.server = http.createServer(app).listen @config.port, finished
