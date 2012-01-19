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
		success:	function(){
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

var requestButton	= Ti.UI.createButton({
	title: 'request',
	top: 130,
	left: 10,
	height: 50
});
window.add(requestButton);
requestButton.addEventListener('click',function(e){
	// This currently only allows UNSIGNED requests!
	module.request({
		params: {
			screen_name: 	'marcelpociot',
			count:			'10'
		},
		url: "http://api.twitter.com/1/statuses/user_timeline.json",
		method: 'get',
		success: function(e){
			alert(e.response);
		},
		error: function(e){
			alert(e);
		}
	});
});

var timelineButton	= Ti.UI.createButton({
	title: 'timeline',
	top: 190,
	left: 10,
	height: 50
});
window.add(timelineButton);
timelineButton.addEventListener('click',function(e){
	// gets the last 2 entries from the users timeline
	module.timeline('marcelpociot','2',function(e){
		// success function
		var response = e.response;
		for( var i=0;i < response.length; i++ ){
			var tweet = response[i];
			// access the tweet
			alert(tweet.text);
		}
	},function(e){
		// error function
	});
});
