logger = require 'torch'

module.exports = (Factory, done) ->
  Factory.create 'user', (err, user) ->
    done err
