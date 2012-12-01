
fs = require 'fs'
should = require 'should'
each = require 'each'
dojo = if process.env.DOJO_COV then require '../lib-cov/dojo' else require '../lib/dojo'

describe 'Release', ->
  it 'should download specific release', (next) ->
    @timeout 0
    middleware = dojo version: '1.5.0'
    req = url: 'http://localhost'
    res = {}
    middleware req, res, (err) ->
      should.not.exist err
      each([
        '/tmp/dojo-release-1.5.0/dojo'
        '/tmp/dojo-release-1.5.0/dijit'
        '/tmp/dojo-release-1.5.0/dojox'
      ])
      .on 'item', (path, next) ->
        fs.stat path, (err, stats) ->
          should.not.exist err
          stats.isDirectory().should.be.ok
          next()
      .on 'both', next
