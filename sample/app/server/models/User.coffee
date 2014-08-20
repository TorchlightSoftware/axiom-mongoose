db = require 'mongoose'
{Schema} = db

User = new Schema
  email: String

User.statics.findByEmail = ({email}, done) ->
  @findOne {email}, (err, user) ->
    done err, {user: user.toJSON()}

module.exports = User
