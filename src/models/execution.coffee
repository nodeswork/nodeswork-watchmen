
nodeswork = require 'nodeswork'


module.exports = ExecutionSchema = nodeswork.mongoose.Schema {

  task:
    type:             nodeswork.mongoose.Schema.ObjectId
    ref:              'WatchStaticPageTask'

  detections:         [
    sourceUrl:        String
    itemType:
      type:           String
      enum:           ['LOGIN_FORM', 'SIGNUP_FORM']
    autofillable:     Boolean
    form:
      action:         String
      method:         String
      defaultFields:  nodeswork.mongoose.Schema.Types.Mixed
      inputFields:    [
        name:         String
        inputType:    String
        mappedType:   String
      ]
      submit:         String
  ]
}
