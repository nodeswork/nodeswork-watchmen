_          = require 'underscore'
co         = require 'co'
nodeswork  = require 'nodeswork'


module.exports = WatchStaticPageTaskSchema = nodeswork.Models.Task.schema.extend {
  user:           Number
  session:
    type:         nodeswork.mongoose.Schema.ObjectId
    ref:          'Session'
    required:     yes
  url:
    type:         String
    required:     yes
  matchPatterns:  [
    name:         String
    patternType:
      type:       String
      enum:       ['ATTRIBUTE']
    regex:        String
  ]
}


WatchStaticPageTaskSchema.methods.execute = (nw) -> co =>
  yield @populate('session').execPopulate()

  response = yield @session.jsdom {
    url: @url
    scripts: [ "http://code.jquery.com/jquery.js" ]
  }

  $ = response.$

  $('script').remove()
  $('style').remove()

  console.log $('body').text()

  # 1. load session
  # 2. request url
  # 3. pattern match
