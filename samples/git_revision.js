
  var express = require('express');
  var dojo = require('connect-dojo');
  var app = express.createServer();
  app.configure( function(){
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(express.cookieParser());
    app.use(dojo({
      method: 'git',
      repository: __dirname + '/git_revision',
      dojo_revision: '852b5161559f3eda16dc',
      dijit_revision: '37b5298bb8b4f24134d5',
      dojox_revision: '145d3bec095382c2f4ac',
      util_revision: 'f9cbb550e2959024df57'
    }));
    app.use(app.router);
    app.use(express.static(__dirname + '/public'));
    app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
  } );
  app.listen(7000);
  console.log('http://localhost:3000/dojo/dojo.js');
