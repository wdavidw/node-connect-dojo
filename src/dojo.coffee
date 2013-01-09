connect = require 'connect'
fs = require 'fs'
fs.exists ?= require('path').exists
{exec} = require 'child_process'

###
`dojo([options])`
-----------------

Connect middleware exposing the Dojo Toolkit.

By default, Dojo releases are downloaded and extracted 
inside the "/tmp" folder and are cached for later usages. 
You may change this folder into a permanent location by 
providing the option "repository".

Options include: 
*   method        One of "release" or "git"
*   version       Dojo version
*   repository    Caching folder, default to "/tmp"

###
module.exports = (options = {}) ->
  # Merge user options with default options
  options.method ?= 'release'
  options.version ?= '1.8.3'
  options.repository ?= '/tmp'
  # Store HTTP request in case we need to download Dojo
  loading = true
  submodules = ['dojo', 'dijit', 'dojox', 'util']
  mapping = {}
  args = []
  switch options.method
    when 'release'
      tgz = "#{options.repository}/dojo-release-#{options.version}.tar.gz"
      dir = "#{options.repository}/dojo-release-#{options.version}"
      url = "http://download.dojotoolkit.org/release-#{options.version}/dojo-release-#{options.version}.tar.gz"
      mapping = 
        dojo: "#{dir}/dojo"
        dijit: "#{dir}/dijit"
        dojox: "#{dir}/dojox"
        util: "#{dir}/util"
      fs.exists dir, (exists) ->
        return finish() if exists
        cmd = "curl #{url} -o #{tgz} && tar -xzf #{tgz} -C #{options.repository}"
        exec cmd, (err, stdout, stderr) ->
          return finish err if err
          finish err
    when 'git'
      count = 0
      _finish = ->
        return if ++count isnt 4
        finish()
      submodules.forEach (submodule) ->
        revision =  options["#{submodule}_revision"] or 'HEAD'
        dirname = "git-#{submodule}-#{revision}"
        mapping[submodule] = "#{options.repository}/#{dirname}"
        clone = (next) ->
          fs.exists '#{options.repository}/#{dirname}', (exists) ->
            # Unrequired checkout if the directory named after the revision exists
            return _finish() if exists and revision isnt 'HEAD'
            return next() if exists
            url = "https://github.com/dojo/#{submodule}.git"
            cmds = []
            cmds.push "cd #{options.repository}"
            cmds.push "git clone #{url} #{dirname}"
            cmds = cmds.join ' && '
            exec cmds, (err, stdout, stderr) ->
              next err
        checkout = (next) ->
          cmds = []
          cmds.push 'cd #{options.repository}/#{dirname}'
          cmds.push "git checkout #{revision}"
          cmds = cmds.join ' && '
          exec cmds, (err, stdout, stderr) ->
            next(err)
        clone (err) ->
          return finish err if err
          checkout (err) ->
            return finish err if err
            _finish()
    else
      throw new Error "Invalid method option \"#{options.method}\")"
  finish = (err) ->
    throw err if err
    loading = false
    for arg in args
      plugin.apply null, arg
  plugin = (req, res, next) ->
    return args.push arguments if loading
    app = /^\/(\w+)\/.*/.exec req.url
    if app and submodules.indexOf(app[1]) isnt -1
      app = app[1]
      req.url = req.url.substr app.length + 1
      # Static
      sttc = connect.static mapping[app]
      sttc req, res, ->
        req.url = "/#{app}#{req.url}"
        next()
    else
      next()
  plugin
