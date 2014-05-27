{join} = require 'path'
fs = require 'fs'
read = (file) -> fs.readFileSync file, 'utf8'
async = require 'async'
logger = require 'torch'

module.exports =
  service: (args, done) ->

    mongoose = require 'mongoose'

    if @config.debug
      mongoose.set 'debug', @config.debug

    # connect to database
    db = mongoose.createConnection @config.host
    db.on 'error', @axiom.log.error
    @axiom.log.info "Connected to mongo at: #{@config.host}."

    # load models
    modelDir = @retriever.rel 'models'
    fs.readdir modelDir, (err, files) =>
      if err
        @axiom.log.warning "Mongoose Extension could not read model directory:\n#{err.message}"
        return done()

      names = for fname in files
        [parts..., ext] = fname.split('.')
        name = parts.join '.'

        schema = @retriever.retrieve 'models', name

        # convert objectIDs to strings
        schema.path('_id').get (_id) -> _id.toString()

        db.model name, schema
        name #return

      @axiom.log.info "Loaded models:", names

      done null, {db}
