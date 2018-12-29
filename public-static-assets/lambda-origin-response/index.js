'use strict'

function handler (event, context, callback) {
  const response = event.Records[0].cf.response

  return callback(null, response)
}

module.exports = {
  handler
}
