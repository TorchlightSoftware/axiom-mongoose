module.exports = (Schema) ->
  User = new Schema
    email: String

  User.statics.findByEmail = ({email}, done) ->
    @findOne {email}, (err, user) ->
      done err, {user: user.toJSON()}

  return User
