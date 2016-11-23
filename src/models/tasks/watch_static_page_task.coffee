_          = require 'underscore'
co         = require 'co'
nodeswork  = require 'nodeswork'


module.exports = WatchStaticPageTaskSchema = nodeswork.Models.Task.schema.extend {
  user:
    type:         Number
    required:     yes
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

  # console.log $('body').text().replace("\n", "").replace(" ", "")

  # console.log $("[role='main']").text()
  main = $("[role='main']")
  center = main.find('#centerCol')
  console.log 'title', center.find("h1").text().trim()
  console.log 'brand', center.find("#brand").text().trim()
  console.log 'price', center.find("#price").text().trim().replace(/[ \n]+?/g, '')

  console.log 'all', main.text().replace(/[ \n]+?/g, ' ')

  # 1. load session
  # 2. request url
  # 3. pattern match
