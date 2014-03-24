{join} = require 'path'
fs = require 'fs'
read = (file) -> fs.readFileSync file, 'utf8'
async = require 'async'
logger = require 'torch'

module.exports =
  service: (args, done) ->

    @db = require 'mongoose'

    loadModel = (name) =>
      schema = @util.retrieve "models/#{name}"
      # convert objectIDs to strings
      schema.path('_id').get (_id) -> _id.toString()

      @db.model name, schema

    if @config.debug
      @db.set 'debug', @config.debug

    connectionString = @config.host + (@app.appName or '__axiom_test')
    @db.connect connectionString
    @db.connection.on 'error', @axiom.log.error

    for model in @config.models
      loadModel model

    @db.wipe = (cb) =>
      async.parallel (m.remove.bind m, null for _, m of @db.models), cb

    @axiom.log.info "Connected to mongo at: #{connectionString}."
    done()
