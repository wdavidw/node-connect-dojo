connect = require('connect')
path = require('path')
exec = require('child_process').exec

module.exports = (options) ->
    # Merge user options with default options
    options ?= {}
    options.method ?= 'release'
    options.version ?= '1.6.1rc1'
    options.repository ?= '/tmp'
    # Store HTTP request in case we need to download Dojo
    loading = true
    submodules = ['dojo', 'dijit', 'dojox', 'util']
    mapping = {}
    args = []
    switch options.method
        when 'release'
            dir = options.repository + '/dojo-release-' + options.version
            mapping = 
                dojo: dir + '/dojo'
                dijit: dir + '/dijit'
                dojox: dir + '/dojox'
                util: dir + '/util'
            path.exists dir, (exists) ->
                return finish() if exists
                url = 'http://download.dojotoolkit.org/release-' + options.version + '/dojo-release-' + options.version + '.tar.gz'
                tgz = options.repository + '/dojo-release-' + options.version + '.tar.gz'
                cmd = 'curl ' + url + ' -o ' + tgz + ' && tar -xzf ' + tgz + ' -C ' + options.repository
                exec cmd, (err, stdout, stderr) ->
                    finish(err)
        when 'git'
            count = 0
            _finish = ->
                return if ++count isnt 4
                finish()
            submodules.forEach (submodule) ->
                revision =  options[ submodule + '_revision' ] or 'HEAD'
                dirname = 'git-' + submodule + '-' + revision
                clone = (next) ->
                    path.exists options.repository + '/' + dirname, (exists) ->
                        return next() if exists
                        url = 'https://github.com/dojo/' + submodule + '.git'
                        cmds = []
                        cmds.push 'cd ' + options.repository
                        cmds.push 'git clone ' + url + ' ' + dirname
                        cmds = cmds.join ' && '
                        console.log cmds
                        exec cmds, (err, stdout, stderr) ->
                            next(err)
                checkout = (next) ->
                    cmds = []
                    cmds.push 'cd ' + options.repository + '/' + dirname
                    cmds.push 'git checkout ' + revision
                    cmds = cmds.join ' && '
                    console.log cmds
                    exec cmds, (err, stdout, stderr) ->
                        next(err)
                clone (err) ->
                    return finish err if err
                    checkout (err) ->
                        return finish err if err
                        mapping[submodule] = options.repository + '/' + dirname
                        _finish()
        else
            throw new Error 'Invalid method option "' + options.method + '" (expects "download")'
    finish = (err) ->
        throw err if err
        loading = false
        for arg in args
            plugin.apply null, arg
    plugin = (req, res, next) ->
        return args.push arguments if loading
        app = /^\/(\w+)\/.*/.exec req.url
        if app and submodules.indexOf( app[1] ) isnt -1
            app = app[1];
            req.url = req.url.substr app.length + 1
            # Less
            connect.compiler({ src: mapping[app], enable: ['less'] })(req, res, (err) ->
                console.log err if err
                # Static
                static = connect.static mapping[app] 
                static req, res, ->
                    req.url = '/' + app + req.url
                    next()
            )
        else
            next()
    plugin
