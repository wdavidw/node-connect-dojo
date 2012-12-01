Connect middleware exposing the Dojo Toolkit
============================================

This Connect middleware transparently download and display Dojo files.

In its simplest form, it takes no argument and the latest stable release is used. Here is a quick example:

```javascript
var express = require('express');
var dojo = require('connect-dojo');
var app = express.createServer();
app.configure(
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(dojo());
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
);
app.listen(3000);
```

Options
-------

-   *method*, support 'release' (default) and 'git'
-   *repository*, Default parent directory where source codes are downloaded
-   *version*, Dojo version, currently `'1.7.1'`, apply only to the 'download' method

Using a released version of Dojo
--------------------------------

Source code is downloaded from the official Dojo website and all the versions 
present on the website are available. For example to download the version '1.5.0', setup 
the middleware as:

```javascript
dojo({ version: '1.7.1' })
```

Using the git HEAD
------------------

If the option 'method' is set to 'git' and the revision option of a dojo project 
is not defined, the middleware will checkout the HEAD revision. Each Dojo project 
will be store inside a directory defined by the option 'repository' and named as "git-#{project}-HEAD"

Using a specific git revision
-----------------------------

If the option 'method' is set to 'git' and one of 'dojo_revision', 'dijit_revision', 
'dojox_revision' or 'util_revision' is defined, then the middleware to checkout 
the revision in a specific directory inside the one defined by the option 'repository' 
and named as "git-${project}-#{revision}".

General note
------------

To prevent multiple application from conflicting, a new directory is created 
for each released version and git revision. This can lead to a large number of directories 
as new revisions are setup over time. By default, source code is stored inside the 
connect-dojo module and it is recommended to define your own directory through 
the 'repository' option.

Testing
-------

Running the tests can take a long time because of the size of dojo. Using 
expresso, run the following command by adjusting the '-t' (timeout) argument:

```bash
expresso -s -t 10000 test
```
