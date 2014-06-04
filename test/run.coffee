{join} = require 'path'
rel = (args...) -> join __dirname, '..', args...

should = require 'should'
axiom = require 'axiom'
logger = require 'torch'
logger.toggleElapsed()
_ = require 'lodash'

db = require 'mongoose'
axiomMongoose = require '..'

describe 'Mongoose Run', ->
  before (done) ->

    axiom.wireUpLoggers [{writer: 'console', level: 'warning'}]
    axiom.init {}, {root: rel 'sample'}

    # Given the run command is initiated
    axiom.request "server.run", {}, (err, {mongoose: {db}}) =>
      should.not.exist err
      @db = db

      axiom.request 'mongoose.linkFactory', {db}, (err, {@Factory}) =>
        @Factory.clear(done)

  afterEach (done) ->
    @Factory.clear(done)

  after (done) ->
    axiom.reset(done)

  it 'models should be loaded after server.run', ->
    @db.models.should.have.keys ['User']

  describe 'CRUD', ->

    it 'should respond to users/index', (done) ->

      # Given a user in the system
      @Factory.create 'user', (err, createdUser) =>
        should.not.exist err

        # When I request a user listing
        axiom.request "mongoose.resources/users/index", {}, (err, result) =>

          # Then I should get the user I created
          should.not.exist err
          should.exist result, 'expected result'

          {users} = result
          should.exist users, 'expected users'
          users.should.have.length 1
          users[0].should.eql createdUser.toJSON()

          done()

    it 'should respond to users/show', (done) ->

      # Given a user in the system
      @Factory.create 'user', (err, createdUser) =>
        should.not.exist err

        # When I request a user
        axiom.request "mongoose.resources/users/show",
          {_id: createdUser._id}, (err, result) =>

            # Then I should get the user I created
            should.not.exist err
            should.exist result, 'expected result'

            {user} = result
            should.exist user, 'expected user'
            user.should.eql createdUser.toJSON()

            done()

    it 'should respond to users/create', (done) ->

      # When I create a user
      axiom.request "mongoose.resources/users/create",
        {email: 'jon@test.com'}, (err, result) =>

          # Then I should get the user I created
          should.not.exist err
          should.exist result, 'expected result'

          {user} = result
          should.exist user, 'expected user'
          user.email.should.eql 'jon@test.com'

          done()

    it 'should respond to users/update', (done) ->

      @Factory.create 'user', (err, createdUser) =>
        should.not.exist err

        # When I create a user
        axiom.request "mongoose.resources/users/update", {
            _id: createdUser._id
            email: 'not-jon@test.com'
          }, (err, result) =>

            # Then I should get the user I created
            should.not.exist err
            should.exist result, 'expected result'

            {user} = result
            should.exist user, 'expected user'
            user.email.should.eql 'not-jon@test.com'

            done()

    it 'should respond to users/delete', (done) ->

      @Factory.create 'user', (err, createdUser) =>
        should.not.exist err

        # When I create a user
        axiom.request "mongoose.resources/users/delete", {
            _id: createdUser._id
          }, (err, result) =>

            # Then I should get the user I created
            should.not.exist err
            should.exist result, 'expected result'

            {user} = result
            should.exist user, 'expected user'
            user.should.eql createdUser.toJSON()

            done()

    it 'should respond to users/findByEmail', (done) ->

      @Factory.create 'user', (err, createdUser) =>
        should.not.exist err

        # When I create a user
        axiom.request "mongoose.resources/users/findByEmail", {
            email: createdUser.email
          }, (err, result) =>

            # Then I should get the user I created
            should.not.exist err
            should.exist result, 'expected result'

            {user} = result
            should.exist user, 'expected user'
            user.should.eql createdUser.toJSON()

            done()
