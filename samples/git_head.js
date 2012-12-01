
  var express = require('express');
  var dojo = require('connect-dojo');
  var app = express.createServer();
  app.configure( function(){
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(dojo({
      method: 'git',
      repository: __dirname + '/git_head'
    }));
    app.use(app.router);
    app.use(express.static(__dirname + '/public'));
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
  } );
  app.listen(7000);
  console.log('http://localhost:3000/dojo/dojo.js');
