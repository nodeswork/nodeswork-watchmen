
nodeswork = require 'nodeswork'


module.exports = ExecutionSchema = nodeswork.mongoose.Schema {
  task:
    type: nodeswork.mongoose.Schema.ObjectId
    ref:  'WatchStaticPageTask'
  patterns:   [ String ]
}
