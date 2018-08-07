// Source: https://github.com/serverless/examples/blob/master/aws-node-auth0-custom-authorizers-api/handler.js
const jwt = require('jsonwebtoken')

// Set in `enviroment` of serverless.yml
const CLIENT_ID = process.env.CLIENT_ID
const CLIENT_SECRET = process.env.CLIENT_SECRET

const generatePolicy = (principalId, effect, resource) => {
  const authResponse = {}
  authResponse.principalId = principalId
  if (effect && resource) {
    const policyDocument = {}
    policyDocument.Version = '2012-10-17'
    policyDocument.Statement = []
    const statementOne = {}
    statementOne.Action = 'execute-api:Invoke'
    statementOne.Effect = effect
    statementOne.Resource = resource
    policyDocument.Statement[0] = statementOne
    authResponse.policyDocument = policyDocument
  }
  return authResponse
}

const handler = (event, context, callback) => {
  if (!event.authorizationToken) {
    return callback(new Error('Unauthorized'))
  }

  const tokenParts = event.authorizationToken.split(' ')
  const tokenValue = tokenParts[1]

  if (!(tokenParts[0].toLowerCase() === 'bearer' && tokenValue)) {
    // no auth token!
    return callback(new Error('Unauthorized'))
  }
  const options = {
    audience: CLIENT_ID
  }
  // decode base64 secret. ref: http://bit.ly/2hA6CrO
  const secret = Buffer.from(CLIENT_SECRET, 'base64')
  try {
    jwt.verify(tokenValue, secret, options, (verifyError, decoded) => {
      if (verifyError) {
        console.log('verifyError', verifyError)
        // 401 Unauthorized
        console.log(`Token invalid. ${verifyError}`)
        return callback(new Error('Unauthorized'))
      }
      // is custom authorizer function
      console.log('valid from customAuthorizer', decoded)
      return callback(
        null,
        generatePolicy(decoded.sub, 'Allow', event.methodArn)
      )
    })
  } catch (err) {
    console.log('catch error. Invalid token', err)
    return callback(new Error('Unauthorized'))
  }
}

module.exports = { handler }
