module.exports = CredentialSchemaPlugin = (schema, opts) ->

  schema.add {
    credential:
      username:     type: String
      password:     type: String
      secret:       type: String   # the answer of security question
  }
