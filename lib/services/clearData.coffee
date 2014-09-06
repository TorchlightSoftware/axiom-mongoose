module.exports =
  service: (args, done) ->
    @request 'factory/clear', args, done
