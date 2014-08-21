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
    db.on 'error', @log.error
    @log.info "Connected to mongo at: #{@config.host}."

    # load models
    modelDir = @rel(@config.modelDir)
    fs.readdir modelDir, (err, files) =>
      if err
        @log.warning "Mongoose Extension could not read model directory:\n#{err.message}"
        return done()

      names = []
      for fname in files

        # don't process hidden files
        unless fname.substring(0, 1) is '.'
          [parts..., ext] = fname.split('.')
          name = parts.join '.'

          schemaBuilder = @retrieve @config.modelDir, name
          schema = schemaBuilder(mongoose.Schema)

          # convert objectIDs to strings
          schema.path('_id').get (_id) -> _id.toString()

          try
            db.model name, schema
          catch e
            msg = "Failed loading model '#{name}'.\n"
            err = new Error msg + e.message
            err.stack = msg + e.stack
            throw err

          names.push name

      @log.info "Loaded models:", names

      done null, {db}
