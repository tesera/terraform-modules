const test = require('tape');
const edge = require('./index.js');

function getEvent(contentType) {
    return {
        Records: [
            {
                cf: {
                    response: {
                        headers: {
                            "content-type": [
                                {
                                    key: "Content-Type",
                                    value: contentType
                                }
                            ]
                        }
                    }
                }
            }
        ]
    };
}

test('formats headers', function (t) {
    const headers = {
        "Header-One": "value-one",
        "Header-Two": "value-two"
    };

    const expectedHeaders = {
        "header-one": [
            {
                "key": "Header-One",
                "value": "value-one"
            },
        ],
        "header-two": [
            {
                "key": "Header-Two",
                "value": "value-two"
            }
        ]
    };

    const cfHeaders = edge.makeHeaders(headers);

    t.deepEqual(cfHeaders, expectedHeaders)
    t.end();
});

test('returns application/json headers', function (t) {
    const event = getEvent('application/json');

    const expectedResponse = {
        headers: {
            'content-type': [
                {
                    key: 'Content-Type',
                    value: 'application/json'
                }
            ],
            "server": [ 
                { 
                    key: "Server", 
                    value: "" 
                } 
            ],
            "x-content-type-options": [ 
                { 
                    key: "X-Content-Type-Options", 
                    value: "nosniff" 
                } 
            ],
            "referrer-policy": [ 
                { 
                    key: "Referrer-Policy", 
                    value: "no-referrer" 
                } 
            ],
            "strict-transport-security": [ 
                {
                    key: "Strict-Transport-Security",
                    value: "max-age=31536000; includeSubdomains; preload" 
                } 
            ]
        }
    };

    edge.handler(event, {}, function (err, response) {
        t.deepEqual(response, expectedResponse)
        t.end();
    });

});

test('returns text/html headers', function (t) {
    const event = getEvent('text/html');

    const expectedResponse = {
        headers: {
            'content-type': [
                {
                    key: 'Content-Type',
                    value: 'text/html'
                }
            ],
            "server": [ 
                { 
                    key: "Server", 
                    value: "" 
                } 
            ],
            "x-content-type-options": [ 
                { 
                    key: "X-Content-Type-Options", 
                    value: "nosniff" 
                } 
            ],
            "referrer-policy": [ 
                { 
                    key: "Referrer-Policy", 
                    value: "no-referrer" 
                } 
            ],
            "strict-transport-security": [ 
                {
                    key: "Strict-Transport-Security",
                    value: "max-age=31536000; includeSubdomains; preload" 
                } 
            ],
            'content-security-policy':[ 
                { 
                    key: 'Content-Security-Policy',
                    value: "default-src 'none'; img-src 'self'; script-src 'self'; style-src 'self'; connect-src 'self'; base-uri 'none'; frame-ancestors 'none'; block-all-mixed-content; upgrade-insecure-requests; report-uri https://tesera.report-uri.com/r/d/csp/reportOnly"
                } 
            ],
            'x-frame-options': [ 
                { 
                    key: 'X-Frame-Options', 
                    value: 'DENY' 
                } 
            ],
            'x-xss-protection': [ 
                { 
                    key: 'X-XSS-Protection', 
                    value: '1; mode=block' 
                } 
            ],
            'x-ua-compatible': [ 
                { 
                    key: 'X-UA-Compatible', 
                    value: 'ie=edge' 
                } 
            ]
        }
    };

    edge.handler(event, {}, function (err, response) {
        t.deepEqual(response, expectedResponse)
        t.end();
    });

});
