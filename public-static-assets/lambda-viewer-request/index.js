'use strict'

function handler (event, context, callback) {
  const request = event.Records[0].cf.request

  // Set `default_root_object` on sub folders
  request.uri = request.uri.replace(/\/$/, '\/index.html')

  return callback(null, request)
}

module.exports = {
  handler
}
