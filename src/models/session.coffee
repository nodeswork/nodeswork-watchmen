# Export session model.

_            = require 'underscore'
nodeswork    = require 'nodeswork'
jsdom        = require 'jsdom'
request      = require 'request-promise'
toughCookie  = require 'tough-cookie'

module.exports = SessionSchema = nodeswork.mongoose.Schema {
  jar:      type: String, default: null
}, collection: 'sessions', discriminatorKey: 'sessionType'
  .plugin nodeswork.ModelPlugins.Descriptive
  .plugin nodeswork.ModelPlugins.Status
  .plugin nodeswork.ModelPlugins.Tagable
  .plugin nodeswork.ModelPlugins.Timestamp


SessionSchema.virtual 'requestCookieJar'
  .get -> @_requestCookieJar ?=
    unless @jar? then request.jar()
    else
      jar = request.jar()
      jar._jar = toughCookie.CookieJar.fromJSON JSON.parse @jar
      jar


SessionSchema.virtual 'cookieJar'
  .get -> @requestCookieJar._jar


SessionSchema.pre 'save', (next) ->
  jsonString = JSON.stringify @cookieJar.toJSON()
  @jar       = jsonString unless @jar == jsonString
  next()


# Send request through with current jar.
SessionSchema.methods.request = (opts) ->
  response = yield request _.extend opts, jar: @requestCookieJar
  yield @save()
  if opts.jsdom
    yield new Promise (resolve, reject) ->
      jsdom.env response, [
        "http://code.jquery.com/jquery.js"
      ], (err, window) ->
        if err? then reject err else resolve window
  else
    response


SessionSchema.methods.setCookieJarJSON = (json) ->
  @jar = JSON.stringify json
  @requestCookieJar._jar = toughCookie.CookieJar.fromJSON json
  yield @save()


SessionSchema.methods.getCookieJarJSON = ->
  @cookieJar.toJSON()
