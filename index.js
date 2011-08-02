var connect = require('connect'),
	path = require('path'),
	exec = require('child_process').exec;

module.exports = function(options){
	// Merge user options with default options
	if(!options){ options = {}; }
	options.method = options.method || 'download';
	options.version = options.version || '1.6.1rc1';
	options.repo_dir = options.repo_dir || __dirname+'/releases';
	options.dojo_dir = options.repo_dir+'/dojo-release-'+options.version;
	// Store HTTP request in case we need to download Dojo
	var loading, args = [];
	switch(options.method){
		case 'download':
			if(!path.existsSync(options.dojo_dir)){
				loading = true;
				var url = 'http://download.dojotoolkit.org/release-'+options.version+'/dojo-release-'+options.version+'.tar.gz';
				var destinationTgz = options.repo_dir+'/dojo-release-'+options.version+'.tar.gz';
				var cmd = 'curl '+url+' -o '+destinationTgz+' && tar -xzf '+destinationTgz+' -C '+options.repo_dir;
				exec(cmd, function(err, stdout, stderr){
					if(err){ throw err };
					loading = false;
					args.forEach(function(arg){
						plugin.apply(null,arg);
					});
				});
			}
		break;
		default:
			throw new Error('Invalid method option "'+options.method+'" (expects "download")');
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
			connect.compiler({ src: options.dojo_dir+'/'+app, enable: ['less'] })(req,res,function(err){
				if(err){ console.log(err); }
				// Static
				connect.static(options.dojo_dir+'/'+app)(req,res,function(){
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