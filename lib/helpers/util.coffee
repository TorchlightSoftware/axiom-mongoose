_ = require 'lodash'

module.exports =

  getType: (obj) ->
    ptype = Object.prototype.toString.call(obj).slice 8, -1
    if ptype is 'Object'
      return obj.constructor.name.toString()
    else
      return ptype

  walk: (data, fn, path=[]) ->
    dataType = @getType(data)
    switch dataType
      when 'Array'
        @walk(d, fn, path.concat(i)) for d, i in data
      when 'Object'
        result = {}
        for k, v of data
          result[k] = @walk(v, fn, path.concat(k))
        result
      else
        fn(data, path)

  convertObjectID: (data) ->
    if @getType(data) is 'ObjectID'
      return data.toString()
    else
      return data

_.bindAll module.exports, ['convertObjectID', 'walk']
