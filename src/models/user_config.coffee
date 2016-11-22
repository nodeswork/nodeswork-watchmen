_                    = require 'underscore'
co                   = require 'co'
nodeswork            = require 'nodeswork'


module.exports = UserConfigSchema = nodeswork.mongoose.Schema {
  user:       Number  # change to external reference later.
  sessions:   [
    name:     String
    session:
      type:   nodeswork.mongoose.Schema.ObjectId
      ref:    'Session'
  ]
}, collection: 'users.configs'
  .plugin nodeswork.ModelPlugins.Descriptive
  .plugin nodeswork.ModelPlugins.Status
  .plugin nodeswork.ModelPlugins.Tagable
  .plugin nodeswork.ModelPlugins.Timestamp


UserConfigSchema.statics.findOneOrCreate = (userId) -> co =>
  user = yield @findOne user: userId
  return user if user?

  session = yield @Models.Session.create {}

  yield @Models.UserConfig.create {
    user: userId
    sessions: [
      name: 'Default'
      session: session
    ]
  }


UserConfigSchema.methods.getSession = (sessionId) -> co =>
  session = _.find @sessions, (s) -> s.session == sessionId

  unless sessionId?
    session = _.find @sessions, (s) -> s.name == 'Default'

  unless session?
    session = yield @Models.Session.create {}
    @sessions.push_back name: 'Default', session: session
    yield @save()

  session


UserConfigSchema.methods.findWatchTasks = () -> co =>
  yield @Tasks.WatchStaticPageTask.find({user: @user}).exec()
