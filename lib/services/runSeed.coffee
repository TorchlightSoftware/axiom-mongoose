module.exports =
  required: ['Factory']
  service: ({Factory}, done) ->

    try
      seed = @retrieve @config.seedLocation
    catch e
      output = e.stack or e.message or e
      @log.warning "Could not load seed:\n#{output}"

    if seed?
      seed Factory, ->
        done()
    else
      done()
