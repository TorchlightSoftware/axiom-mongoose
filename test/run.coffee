path = require 'path'
fs = require 'fs'

should = require 'should'
axiom = require 'axiom'
logger = require 'torch'
_ = require 'lodash'

axiomMongoose = require '..'

describe 'run', ->
  before ->

    axiom.init() #{loggers: [{writer: 'console', level: 'debug'}]}
    axiom.load 'mongoose', axiomMongoose

  it 'should start the server', (done) ->

    # when the end of the 'start' lifecycle is reached
    axiom.load 'test', {
      config:
        run:
          extends: 'server'
      services:
        'run/connect': (args, fin) ->

          # then the context should include a working 'db' object
          should.exist @db
          fin()
          done()
    }

    # given the run command is initiated
    axiom.request "server.run", {foo: 1}, (err, result) ->
      should.not.exist err
