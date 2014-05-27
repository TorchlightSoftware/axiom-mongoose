module.exports =
  required: ['db']
  service: ({db}, done) ->
    db.close(done)
