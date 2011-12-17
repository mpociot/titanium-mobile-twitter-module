// This is a test harness for your module
// You should do something interesting in this harness 
// to test out the module and to provide instructions 
// to users on how to use it by example.


// open a single window
var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var module	= require('de.marcelpociot.twitter');
module.tweet({
	message: 	'Hey, this is some cool tweet!',
	url: 		'http://www.marcelpociot.de',
	image: 		'http://www.marcelpociot.de/logo.png'
});