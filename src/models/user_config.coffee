nodeswork = require 'nodeswork'


UserConfigSchema = nodeswork.mongoose.Schema {
  user:       Number  # change to external reference later.
  sessions:   [
    name:     String
    session:
      type:   nodeswork.mongoose.Schema.ObjectId
      ref:    'Session'
  ]
}, collection: 'users.configs'


module.exports = UserConfig = nodeswork.mongoose.model(
  'UserConfig', UserConfigSchema
)
