var dojo = require('connect-dojo');

module.exports = {
	'Test download': function(next){
		dojo({version: '1.5.0'});
	}
}