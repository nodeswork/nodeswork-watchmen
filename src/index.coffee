_                           = require 'underscore'
co                          = require 'co'
nodeswork                   = require 'nodeswork'

ExecutionSchema             = require './models/execution'
SessionSchema               = require './models/session'
UserConfigSchema            = require './models/user_config'
WatchStaticPageTaskSchema   = require './models/tasks/watch_static_page_task'


module.exports = watchmen = nodeswork.extend {
  moduleName: 'watchmen'
  dbAddress:   'mongodb://localhost/watchmen'
}

watchmen
  .model 'Session', SessionSchema, {
    apiExposed:
      methods:      ['get', 'create', 'update', 'delete']
      urlName:      'Session'
      path:         '/sessions/:sessionId'
      params:
        sessionId:  '@_id'
  }
  .model 'UserConfig', UserConfigSchema
  .model 'Execution', ExecutionSchema
  .task  'WatchStaticPageTask', WatchStaticPageTaskSchema


watchmen.server.use (ctx, next) -> co ->
  ctx.user = yield watchmen.Models.UserConfig.findOneOrCreate 123
  next()


watchmen.api.get  'WatchTask', '/watch-tasks', (ctx, next) -> co ->
  ctx.body = yield ctx.user.findWatchTasks()


watchmen.api.post 'WatchTask', '/watch-tasks', (ctx, next) -> co ->
  doc  = _.extend ctx.request.body, user: ctx.user.user

  ctx.body = yield watchmen.Tasks.WatchStaticPageTask.create _.extend doc, {
    session: (yield ctx.user.getSession doc.session).session
  }


watchmen.api.post 'WatchTask', '/watch-tasks/:taskId', (ctx, next) -> co ->
  doc  = ctx.request.body

  ctx.body = yield watchmen.Tasks.WatchStaticPageTask.findOneAndUpdate {
    user: ctx.user.user
    _id:  ctx.params.taskId
  }, _.extend(doc, user: ctx.user.user), {
    new: yes
  }


getOrCreateUserSession = (userId, sessionId) -> co ->
  if sessionId? then return sessionId

  user = yield watchmen.Models.UserConfig.findOneOrCreate userId
