
nodeswork            = require 'nodeswork'

Execution            = require './models/execution'
Session              = require './models/session'
UserConfig           = require './models/user_config'
WatchStaticPageTask  = require './models/tasks/watch_static_page_task'


module.exports = watchmen = new nodeswork.Nodeswork

watchmen
  .model Session, {
    apiExposed:
      methods:      ['get', 'create', 'update', 'delete']
      urlName:      'Session'
      path:         '/sessions/:sessionId'
      params:
        sessionId:  '@_id'
  }
  .model UserConfig, {}
  .model Execution, {}
  .task WatchStaticPageTask
