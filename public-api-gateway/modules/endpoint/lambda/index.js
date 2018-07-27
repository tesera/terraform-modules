const app = async (event, context) => {

  return {
    statusCode: 200,
    body: {data: {success: true}}
  }
}

const inputSchema = {type: 'object'}
const outputSchema = {type: 'object'}

const handler = require('./middleware')(app, {
  inputSchema,
  outputSchema
})

module.exports = {handler}
