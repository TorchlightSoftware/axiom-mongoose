logger = require 'torch'
_ = require 'lodash'

buildObject = (key, value) ->
  obj = {}
  obj[key] = value
  return obj

module.exports =
  required: ['db']
  service: ({db}, done) ->

    for name, model of db.models
      instance = name.toLowerCase()
      collection = model.collection.name

      @axiom.respond "resources/#{collection}/index", (args, done) ->
        model.find args, (err, results) ->
          results = (r.toJSON() for r in results) if results
          done err, buildObject(collection, results)

      @axiom.respond "resources/#{collection}/create", (args, done) ->
        model.create args, (err, result) ->
          done err, buildObject(instance, result?.toJSON())

      # required: ['_id']
      @axiom.respond "resources/#{collection}/show", ({_id}, done) ->
        model.findById _id, (err, result) ->
          done err, buildObject(instance, result?.toJSON())

      # required: ['_id']
      @axiom.respond "resources/#{collection}/update", (args, done) ->
        {_id} = args
        args = _.omit args, '_id'

        model.findOneAndUpdate {_id}, args, (err, result) ->
          done err, buildObject(instance, result?.toJSON())

      # required: ['_id']
      @axiom.respond "resources/#{collection}/delete", (args, done) ->
        {_id} = args
        args = _.omit args, '_id'

        model.findOneAndRemove {_id}, (err, result) ->
          done err, buildObject(instance, result?.toJSON())

      # connect any static methods that have been defined on the schema
      for method of model.schema.statics
        @axiom.respond "resources/#{collection}/#{method}", model[method].bind model

    done()
