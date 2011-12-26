var window = Ti.UI.createWindow({
	backgroundColor:'white'
});
var label = Ti.UI.createLabel();
window.add(label);
window.open();

var module	= require('de.marcelpociot.twitter');
var tweetButton	= Ti.UI.createButton({
	title: 'tweet',
	top: 10,
	left: 10,
	height: 50
});
window.add(tweetButton);
tweetButton.addEventListener('click',function(e){
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
});
var accountsButton	= Ti.UI.createButton({
	title: 'accounts',
	top: 70,
	left: 10,
	height: 50
});
window.add(accountsButton);
accountsButton.addEventListener('click',function(e){
	module.accounts({
		load: function(e){
			for( var i =0; i<e.accounts.length; i++ ){
				var account = e.accounts[i];
				alert(account.username);
				alert(account.description)
			}
		},
		error: function(e){
			alert("access not granted");
		}
	});
});
