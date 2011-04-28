var express = require('express'),
	path = require('path'),
	exec = require('child_process').exec;

module.exports = function(config){
	if(!config.version){ throw new Error('Require the Dojo version'); }
	var destination = config.destination || __dirname+'/releases';
	var destinationTgz = destination+'/dojo-release-'+config.version+'.tar.gz';
	var destinationRelease = destination+'/dojo-release-'+config.version;
	var loading, args = [];
	if(!path.existsSync(destinationRelease)){
		loading = true;
		var url = 'http://download.dojotoolkit.org/release-'+config.version+'/dojo-release-'+config.version+'.tar.gz';
		var cmd = 'curl '+url+' -o '+destinationTgz+' && tar -xzf '+destinationTgz+' -C '+destination;
		exec(cmd, function(err, stdout, stderr){
			if(err){ throw err };
			loading = false;
			args.forEach(function(arg){
				plugin.apply(null,arg);
			});
		});
	}
	var plugin = function(req,res,next){
		if(loading){
			args.push(arguments);
			return;
		}
		var app = /^\/(\w+)\/.*/.exec(req.url);
		if(app && ['dojo','dijit','dojox','util'].indexOf(app[1]) !== -1){
			var app = app[1];
			req.url = req.url.substr(app.length+1);
			// Less
			express.compiler({ src: destinationRelease+'/'+app, enable: ['less'] })(req,res,function(err){
				if(err){ console.log(err); }
				// Static
				express.static(destinationRelease+'/'+app)(req,res,function(){
					req.url = '/'+app+req.url;
					next();
				});
			});
		}else{
			next();
		}
	};
	return plugin;
};