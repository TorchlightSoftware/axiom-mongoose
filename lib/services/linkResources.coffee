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
      do (name, model) =>
        instance = name.toLowerCase()
        collection = model.collection.name

        resources = law.create
          services:

            find:
              optional: ['conditions', 'fields', 'options']
              service: ({conditions, fields, options}, done) ->
                conditions or= {}
                model.find conditions, fields, options, (err, results) ->
                  results = (r.toJSON() for r in results) if results
                  done err, buildObject(collection, results)

            create:
              required: ['document']
              service: ({document}, done) ->
                model.create document, (err, result) ->
                  done err, buildObject(instance, result?.toJSON())

            findone:
              required: ['conditions']
              optional: ['fields', 'options']
              service: ({conditions, fields, options}, done) ->
                model.findOne conditions, fields, options, (err, result) ->
                  # return 404 if not found?
                  done err, buildObject(instance, result?.toJSON())

            update:
              required: ['conditions', 'update']
              optional: ['options']
              service: ({conditions, update, options}, done) ->
                model.findOne conditions, update, options, (err, result) ->
                  return done(err) if err?

                  result.set(update)
                  result.save (err) ->
                    done err, buildObject(instance, result?.toJSON())

            remove:
              required: ['conditions']
              service: ({conditions}, done) ->
                model.findOneAndRemove conditions, (err, result) ->
                  done err, buildObject(instance, result?.toJSON())

        @respond "resources/#{collection}/find", resources.find
        @respond "resources/#{collection}/create", resources.create
        @respond "resources/#{collection}/findone", resources.findone
        @respond "resources/#{collection}/update", resources.update
        @respond "resources/#{collection}/remove", resources.remove

        # connect any static methods that have been defined on the schema
        for method of model.schema.statics
          @respond "resources/#{collection}/#{method}", model[method].bind model

    done()
