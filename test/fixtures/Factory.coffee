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

module.exports = (models) ->

  Factory.models = models
  {User} = models

  Factory.define 'user', User, {
    email: 'foo@bar.com'
  }

  return Factory
