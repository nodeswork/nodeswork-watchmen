
co         = require 'co'
nodeswork  = require 'nodeswork'


WatchStaticPageTaskSchema = nodeswork.Models.Task.schema.extend {
  user:           Number
  session:
    type:         nodeswork.mongoose.Schema.ObjectId
    ref:          'Session'
    required:     yes
  url:            String
  matchPatterns:  String
}


WatchStaticPageTaskSchema.methods.execute = (nw) ->
  # 1. load session
  # 2. request url
  # 3. pattern match


module.exports = WatchStaticPageTask = nodeswork.mongoose.model(
  'WatchStaticPageTask', WatchStaticPageTaskSchema
)
