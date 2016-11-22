
nodeswork = require 'nodeswork'

Session   = require './models/session'

module.exports = watchmen = new nodeswork.Nodeswork

watchmen.model Session, {
  apiExposed:
    methods:      ['get', 'create', 'update', 'delete']
    urlName:      'Session'
    path:         '/sessions/:sessionId'
    params:
      sessionId:  '@_id'
}
