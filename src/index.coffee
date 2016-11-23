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
  .task  'WatchStaticPageTask', WatchStaticPageTaskSchema, {
    apiExposed:
      methods:      ['get', 'create', 'find', 'update', 'delete']
      urlName:      'WatchTask'
      path:         '/watch-tasks/:taskId'
      params:
        taskId:     '@_id'
      superDoc:     (ctx) -> user: ctx.user.user
      middlewares:
        create:     [
          (ctx, next) -> co ->
            session = yield ctx.user.getSession ctx.request.body.session
            ctx.request.body.session = session.session
            next()
        ]
  }


watchmen.server.use (ctx, next) -> co ->
  ctx.user = yield watchmen.Models.UserConfig.findOneOrCreate 123
  next()


getOrCreateUserSession = (userId, sessionId) -> co ->
  if sessionId? then return sessionId

  user = yield watchmen.Models.UserConfig.findOneOrCreate userId
