var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var module	= require('de.marcelpociot.twitter');
module.tweet({
	message: 	'Hey, this is some cool tweet!',
	urls: 		['http://www.marcelpociot.de'],
	images:		['http://www.marcelpociot.de/logo.png'],
	succes:		function(){
		alert("Tweet successfully sent");
	},
	cancel:		function(){
		alert("User canceled tweet");
	},
	error:		function(){
		alert("Unable to send tweet");
	}
});