
dojo = require('connect-dojo');

module.exports =
    'Test release # version': (next) ->
        middleware = dojo { version: '1.5.0' }
        req = { url: 'http://localhost' }
        res = {}
        middleware req, res, next
