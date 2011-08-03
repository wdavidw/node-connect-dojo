
dojo = require('connect-dojo');

module.exports =
    'Test git # HEAD': (next) ->
        middleware = dojo { method: 'git' }
        req = { url: 'http://localhost' }
        res = {}
        middleware req, res, next
    'Test git # revision': (next) ->
        middleware = dojo
            method: 'git',
            dojo_revision: '852b5161559f3eda16dc'
            dijit_revision: '37b5298bb8b4f24134d5'
            dojox_revision: '145d3bec095382c2f4ac'
            util_revision: 'f9cbb550e2959024df57'
        req = { url: 'http://localhost' }
        res = {}
        middleware req, res, next
