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
  httpSecurityHeaders,
  ssm,
  // validator
} = require('middy/middlewares')

// const ajvOptions = {
//   format: 'full'
// }

module.exports = (app, { env }) =>
  middy(app)
    .use(doNotWaitForEmptyEventLoop())
    .use(httpEventNormalizer())
    .use(httpHeaderNormalizer())
    .use(urlEncodeBodyParser())
    .use(jsonBodyParser())

    .use(httpSecurityHeaders())
    .use(cors())
    .use(
      httpContentNegotiation({
        availableLanguages: ['en-CA', 'fr-CA']
      })
    )
    //.use(validator({ inputSchema, outputSchema, ajvOptions }))
    .use(env({
      cache: true,
      names: ssm,
      setToContext: true
    }))
    .use(httpErrorHandler())
