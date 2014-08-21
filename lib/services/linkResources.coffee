logger = require 'torch'
_ = require 'lodash'
law = require 'law'

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

      resources = law.create
        services:

          index:
            service: (args, done) ->
              model.find args, (err, results) ->
                results = (r.toJSON() for r in results) if results
                done err, buildObject(collection, results)

          create:
            service: (args, done) ->
              model.create args, (err, result) ->
                done err, buildObject(instance, result?.toJSON())
          show:
            required: ['_id']
            service: ({_id}, done) ->
              model.findById _id, (err, result) ->
                done err, buildObject(instance, result?.toJSON())

          update:
            required: ['_id']
            service: (args, done) ->
              {_id} = args
              args = _.omit args, '_id'

              model.findById _id, (err, result) ->
                return done(err) if err?
                result.set(args)
                result.save (err) ->
                  done err, buildObject(instance, result?.toJSON())

          delete:
            required: ['_id']
            service: ({_id}, done) ->
              model.findOneAndRemove {_id}, (err, result) ->
                done err, buildObject(instance, result?.toJSON())

      @respond "resources/#{collection}/index", resources.index
      @respond "resources/#{collection}/create", resources.create
      @respond "resources/#{collection}/show", resources.show
      @respond "resources/#{collection}/update", resources.update
      @respond "resources/#{collection}/delete", resources.delete

      # connect any static methods that have been defined on the schema
      for method of model.schema.statics
        @respond "resources/#{collection}/#{method}", model[method].bind model

    done()
