{join} = require 'path'
rel = (args...) -> join __dirname, '..', args...

should = require 'should'
axiom = require 'axiom'
_ = require 'lodash'

axiomMongoose = require '..'

describe 'Mongoose Test', ->
  before (done) ->

    axiom.wireUpLoggers [{writer: 'console', level: 'warning'}]
    axiom.init {timeout: 1200}, {root: rel 'sample'}

    # When the run step is initiated
    axiom.respond 'server.test/run', (@args, @next) =>
      done()

    # Given the server test command is initiated
    axiom.request "server.test", {}, (err) =>
      should.not.exist err

  afterEach (done) ->
    axiom.reset(done)

  it 'should create a user', (done) ->
    axiom.request 'mongoose.factory/user', {}, (err, result) ->
      should.not.exist err
      {user} = result
      should.exist user, 'expected user'
      done()
