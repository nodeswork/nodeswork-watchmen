_                       = require 'underscore'
co                      = require 'co'
nodeswork               = require 'nodeswork'
winston                 = require 'winston'


CredentialSchemaPlugin  = require '../credential_plugin'


module.exports = WatchStaticPageTaskSchema = nodeswork.Models.Task.schema.extend {

  user:
    type:         Number
    required:     yes

  session:
    type:         nodeswork.mongoose.Schema.ObjectId
    ref:          'Session'
    required:     yes

  headers:        nodeswork.mongoose.Schema.Types.Mixed

  url:
    type:         String
    required:     yes

  authProcess:
    needLogin:
      type:       Boolean
      default:    false
    identifyUrl:  String

  matchPatterns:  [
    name:         String
    patternType:
      type:       String
      enum:       ['ATTRIBUTE']
    regex:        String
  ]
}
  .plugin CredentialSchemaPlugin


WatchStaticPageTaskSchema.methods.execute = (nw) -> co =>
  yield @populate('session').execPopulate()

  logout = yield @session.request {
    url: 'http://www.departementfeminin.com/en/deconnexion.php'
    headers: @headers
    gzip:   true
  }

  console.log 'logout'

  if @authProcess.needLogin

    loginFormDetection = yield @isUserLogin()

    if loginFormDetection?
      winston.info 'Login form detected.'
      yield @login loginFormDetection
      winston.info 'User logined.'

  loginFormDetection = yield @isUserLogin()

  console.log 'again', loginFormDetection



WatchStaticPageTaskSchema.methods.isUserLogin = () -> co =>
  console.log 'identifyUrl', @authProcess.identifyUrl
  identifyWindow = yield @session.request {
    url:      @authProcess.identifyUrl
    headers:  @headers
    gzip:     true
    jsdom:    true
  }

  detections = @detectLoginForm @authProcess.identifyUrl, identifyWindow

  loginFormDetection = _.find detections, (x) -> x.itemType == 'LOGIN_FORM'


WatchStaticPageTaskSchema.methods.login = (loginDetection) -> co =>
  form = _.extend {}, loginDetection.form.defaultFields, (
    _.chain loginDetection.form.inputFields
      .map (f) => [
        f.name
        switch f.mappedType
          when 'username' then @credential.username
          when 'password' then @credential.password
      ]
      .object()
      .value()
  )

  try
    res = yield @session.request {
      url:     loginDetection.form.action
      method:  'POST'
      form:    form
      headers: @headers
      gzip:    true
      followRedirect: true
    }

    console.log 'res', res
  catch
    winston.info 'Login successfully.'


WatchStaticPageTaskSchema.methods.detectLoginForm = (sourceUrl, window) ->
  $           = window.$
  detections  = []
  forms       = window.$('form')

  for form in forms
    unless (action = $(form).attr('action'))
      continue
    unless (method = $(form).attr('method')) == 'post'
      continue

    $inputs = $(form).find(':input')

    detection = {
      sourceUrl:        sourceUrl
      form:
        action:         action
        method:         method
        defaultFields:  {}
        inputFields:    []
    }

    _.each $inputs, (input) ->
      switch input.type
        when 'hidden'
          detection.form.defaultFields[input.name] = $(input).val() ? ''
        when 'submit'
          detection.form.submit = $(input).text().trim()
        else
          detection.form.inputFields.push {
            name: input.name, inputType: input.type
          }

    fieldsCounter = _.countBy detection.form.inputFields, (field) ->
      field.mappedType = switch
        when field.inputType == 'password' then 'password'
        when field.inputType == 'email' then 'username'
        when field.name == 'username' then 'username'
        else 'others'

    if fieldsCounter.username == 1 and fieldsCounter.password == 1
      detection.itemType      = 'LOGIN_FORM'
      detection.autofillable  = !fieldsCounter.others

    if detection.itemType? then detections.push detection

  detections
