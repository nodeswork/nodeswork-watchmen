# Export session model.

_            = require 'underscore'
nodeswork    = require 'nodeswork'
jsdom        = require 'jsdom'
request      = require 'request-promise'
toughCookie  = require 'tough-cookie'

SessionSchema = nodeswork.mongoose.Schema {
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
  response


SessionSchema.methods.setCookieJarJSON = (json) ->
  @jar = JSON.stringify json
  @requestCookieJar._jar = toughCookie.CookieJar.fromJSON json
  yield @save()


SessionSchema.methods.getCookieJarJSON = ->
  @cookieJar.toJSON()


SessionSchema.methods.jsdom = (params...) ->
  window = yield new Promise (resolve, reject) ->
    config = _.find params, (x) ->
      _.isObject(x) and not _.isArray(x) and not _.isFunction x
    params.push config = {} unless config?
    _.extend config, {
      done: (err, window) -> if err? then reject err else resolve window
      cookieJar: @cookieJar
    }
    jsdom.env.apply jsdom.env, params
  yield @save()
  window


module.exports = Session = nodeswork.mongoose.model 'Session', SessionSchema
