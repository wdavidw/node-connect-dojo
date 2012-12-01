
fs = require 'fs'
each = require 'each'
should = require 'should'
dojo = if process.env.DOJO_COV then require '../lib-cov/dojo' else require '../lib/dojo'

describe 'Git', ->
  it 'should download dojo HEAD', (next) ->
    @timeout 0
    middleware = dojo method: 'git'
    req = url: 'http://localhost'
    res = {}
    middleware req, res, (err) ->
      should.not.exist err
      each([
        '/tmp/git-dojo-HEAD'
        '/tmp/git-dijit-HEAD'
        '/tmp/git-dojox-HEAD'
        '/tmp/git-util-HEAD'
      ])
      .on 'item', (path, next) ->
        fs.stat path, (err, stats) ->
          should.not.exist err
          stats.isDirectory().should.be.ok
          next()
      .on 'both', next
  it 'should download specified revisions', (next) ->
    @timeout 0
    middleware = dojo
      method: 'git',
      dojo_revision: '852b5161559f3eda16dc'
      dijit_revision: '37b5298bb8b4f24134d5'
      dojox_revision: '145d3bec095382c2f4ac'
      util_revision: 'f9cbb550e2959024df57'
    req = { url: 'http://localhost' }
    res = {}
    middleware req, res, (err) ->
      should.not.exist err
      each([
        '/tmp/git-dojo-852b5161559f3eda16dc'
        '/tmp/git-dijit-37b5298bb8b4f24134d5'
        '/tmp/git-dojox-145d3bec095382c2f4ac'
        '/tmp/git-util-f9cbb550e2959024df57'
      ])
      .on 'item', (path, next) ->
        fs.stat path, (err, stats) ->
          should.not.exist err
          stats.isDirectory().should.be.ok
          next()
      .on 'both', next
