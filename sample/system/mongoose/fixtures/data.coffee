module.exports = (Factory) ->
  {User} = Factory.models

  Factory.define 'user', User, {
    email: 'foo@bar.com'
  }
