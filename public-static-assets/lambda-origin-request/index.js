'use strict'

function handler (event, context, callback) {
  const request = event.Records[0].cf.request
  const headers = request.headers

  // Set `default_root_object` on sub folders
  request.uri = request.uri.replace(/\/$/, '/index.html')

  // .well-known redirects
  const well_known_files = ['robots.txt', 'favicon.ico', 'security.txt', 'humans.txt']

  well_known_files.forEach(file => {
    const re = new RegExp(`^\\/${file}$`)
    request.uri = request.uri.replace(re, `/.well-known/${file}`)
  })

  // load brotli encoded version
  if (headers['accept-encoding'] && headers['accept-encoding'][0].value.indexOf('br') !== -1) {
    request.uri = request.uri + '.br'
  }

  return callback(null, request)
}

module.exports = {
  handler
}
