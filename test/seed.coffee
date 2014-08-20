{join} = require 'path'
rel = (args...) -> join __dirname, '..', args...

should = require 'should'
axiom = require 'axiom'
logger = require 'torch'
_ = require 'lodash'

axiomMongoose = require '..'

describe 'Mongoose Seed', ->
  before (done) ->

    axiom.wireUpLoggers [{writer: 'console', level: 'warning'}]
    axiom.init {timeout: 1200}, {root: rel 'sample'}

    # Given the seed command is initiated
    axiom.request "db.seed", {}, (err, {mongoose: {@db}}) =>
      should.not.exist err
      done()

  afterEach (done) ->
    axiom.reset(done)

  it 'models should be loaded after db.seed', ->
    @db.models.should.have.keys ['User']

  it 'a user should exist', (done) ->

    # get our own model for data verification
    db = require 'mongoose'
    db.connect axiomMongoose.config.host
    db.model 'User', require '../sample/app/server/models/User'

    {User} = db.models

    User.findOne {}, (err, user) ->
      should.not.exist err
      should.exist user, 'expected user'
      user.email.should.eql 'foo@bar.com'
      done()
