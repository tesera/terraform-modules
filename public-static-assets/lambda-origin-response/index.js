'use strict'

const headers = {
  'any': {
    'Server': '',
    'X-Content-Type-Options': 'nosniff',
    'Referrer-Policy': 'no-referrer',
    'Strict-Transport-Security': 'max-age=31536000; includeSubdomains; preload'
    //"Expect-CT":""
  },
  'html': {
    // Content-Security-Policy-Report-Only: https://{report-uri}.report-uri.com/r/d/csp/reportOnly
    // Content-Security-Policy:             https://{report-uri}.report-uri.com/r/d/csp/enforce
    'Content-Security-Policy-Report-Only': 'default-src \'none\';' +
      ' img-src \'self\';' +
      ' script-src \'self\';' +
      ' style-src \'self\';' +
      ' connect-src \'self\';' +
      ' form-action \'none\';' +
      ' base-uri \'none\';' +
      ' frame-ancestors \'none\';' +
      ' block-all-mixed-content;' +
      ' upgrade-insecure-requests;' +
      ' report-uri https://{report-uri}.report-uri.com/r/d/csp/reportOnly',
    // https://github.com/WICG/feature-policy/blob/master/features.md
    'Feature-Policy': '' +
      ' camera \'none\'' +
      ' fullscreen \'self\'' +
      ' gyroscope \'none\'' +
      ' geolocation \'none\'' +
      ' magnetometer \'none\'' +
      ' microphone \'none\'' +
      ' midi \'none\'' +
      ' payment \'none\'' +
      ' speaker \'none\'' +
      ' sync-xhr \'self\'',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    //'X-UA-Compatible': 'ie=edge',
    //'Content-Encoding':'gzip'
  }
}

// Reformat headers object for CF
function makeHeaders (headers) {
  const formattedHeaders = {}
  Object.keys(headers).forEach((key) => {
    formattedHeaders[key.toLowerCase()] = [{
      key: key,
      value: headers[key]
    }]
  })
  return formattedHeaders
}

function getHeaders (mime) {
  return makeHeaders(headers[mime])
}

function handler (event, context, callback) {
  const request = event.Records[0].cf.request
  const response = event.Records[0].cf.response

  console.log(JSON.stringify(request),JSON.stringify(response))

  let responseHeaders = getHeaders('any')

  // Catch 304 w/o Content-Type from S3
  if (!response.headers['content-type'] && request.uri === '/') {
    response.headers['content-type'] = [{
      key: 'Content-Type',
      value: 'text/html; charset=utf-8'
    }]
  }

  if (response.headers['content-type'] && response.headers['content-type'][0].value.indexOf('text/html') !== -1) {
    Object.assign(responseHeaders, getHeaders('html'))
  }

  // Compression
  //if (response.headers['content-type'] && response.headers['content-type'][0].value.indexOf('text/html') !== -1) {
  //  Object.assign(responseHeaders, getHeaders('html'))
  //}

  Object.assign(response.headers, responseHeaders)

  return callback(null, response)
}

module.exports = {
  handler
}
