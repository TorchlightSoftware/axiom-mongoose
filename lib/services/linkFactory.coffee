async = require 'async'
Factory = require 'factory-worker'

# helpers for constructing chains and chain collections
Factory.createRef = (name, fields, done) ->
  Factory.create name, fields, (err, obj) ->
    done err, obj?._id

Factory.assemble = (name, fields) ->
  (cb) -> Factory.createRef name, fields, cb

Factory.assembleGroup = (name, records) ->
  records ?= [{}]
  (cb) -> async.forEach records, Factory.createRef, cb

Factory.clear = (done) ->
  clearModel = (name, next) ->
    Factory.models[name].remove {}, next

  async.forEach Object.keys(Factory.models), clearModel, done

module.exports =
  required: ['db']
  service: ({db}, done) ->

    Factory.models = db.models

    # initialize the application's sample data
    try
      @retrieve(@config.dataLocation)(Factory)
    catch e
      output = e.stack or e.message or e
      @log.warning "Could not load sample-data:\n#{output}"

    for name of Factory.patterns
      @respond "factory/#{name}", (args, next) ->
        Factory.create name, args, (err, result) ->
          obj = {}
          obj[name] = result
          next err, obj

    done null, {Factory}
