path = require 'path'
fs = require 'fs'

should = require 'should'
axiom = require 'axiom'
request = require 'request'
logger = require 'torch'
_ = require 'lodash'
mockery = require 'mockery'

retriever = require '../node_modules/axiom/lib/retriever'

server = require '..'
{port} = server.config.run

projectDir = path.join(__dirname, '..', 'sample')


describe 'run', ->
  beforeEach ->
    mockery.enable
      warnOnReplace: false
      warnOnUnregistered: false
    mockery.registerMock(
      path.join(projectDir, 'node_modules', 'axiom-base'),
      require('axiom-base')
    )
    mockery.registerMock(
      'axiom-base',
      require('axiom-base')
    )
    retriever.projectRoot = projectDir
    retriever.projectRoot.should.eql projectDir
    retriever.rel().should.eql projectDir
    axiom.init {}, retriever
    axiom.load 'server', server

  afterEach ->
    mockery.disable()

  it 'should start the server', (done) ->

    # when the end of the 'start' lifecycle is reached
    axiom.respond "server.run/connect", (args, fin) ->
      fin()

      # then the server should respond to requests
      request {
        url: "http://localhost:#{port}"
        json: true
      }, (err, res, body) ->
        should.not.exist err
        should.exist body
        body.should.eql {greeting: 'hello, world'}
        done()

    # given the run command is initiated
    axiom.request "server.run", {}, (err, result) ->
      should.not.exist err
