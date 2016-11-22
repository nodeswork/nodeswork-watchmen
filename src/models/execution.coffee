
nodeswork = require 'nodeswork'


ExecutionSchema = nodeswork.mongoose.Schema {
  task:
    type: nodeswork.mongoose.Schema.ObjectId
    ref:  'WatchStaticPageTask'
  patterns:   [ String ]
}


module.exports = Execution = nodeswork.mongoose.model(
  'Execution', ExecutionSchema
)
