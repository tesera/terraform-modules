const middy = require('middy')
const {
  doNotWaitForEmptyEventLoop,
  urlEncodeBodyParser,
  jsonBodyParser,
  cors,
  httpErrorHandler,
  httpEventNormalizer,
  httpHeaderNormalizer,
  httpContentNegotiation,
  validator
} = require('middy/middlewares')
const jsonapi = require('middy-jsonapi')
const httpSecurityHeaders = require('./http-security-headers')
//const authorization = require('@company/authorization')

const ajvOptions = {
  format: 'full'
}

const meta = require('./package.json')
const response = {
  jsonapi: { version: '1.0' },
  meta: {
    version: `v${meta.version}`, // Include from package.json
    copyright: meta.copyright, // Include from package.json
    authors: meta.authors, // Include from package.json
    now: new Date().toISOString() // request timestamp in ISO format ("2015-06-11T22:27:42.668Z")
  }
}

module.exports = (app, { inputSchema, outputSchema }) =>
  middy(app)
    .use(doNotWaitForEmptyEventLoop())
    .use(httpEventNormalizer())
    .use(httpHeaderNormalizer())
    .use(urlEncodeBodyParser())
    .use(jsonBodyParser())

    .use(httpSecurityHeaders())
    .use(cors())
    .use(jsonapi({ response }))
    .use(
      httpContentNegotiation({
        availableLanguages: ['en-CA', 'fr-CA'],
        availableMediaTypes: ['application/vnd.api+json']
      })
    )

    //.use(authorization({accessRole}))
    //.use(cache)
    .use(validator({ inputSchema, outputSchema, ajvOptions }))
    //.use(ssm or secret manager or vault)
    .use(httpErrorHandler())
