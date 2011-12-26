/**
 * Your Copyright Here
 *
 * Appcelerator Titanium is Copyright (c) 2009-2010 by Appcelerator, Inc.
 * and licensed under the Apache Public License (version 2)
 */
#import "DeMarcelpociotTwitterModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiApp.h"
#import <Twitter/Twitter.h>

@implementation DeMarcelpociotTwitterModule

#pragma mark Internal

// this is generated for your module, please do not change it
-(id)moduleGUID
{
	return @"08450466-1372-4846-84a7-2315835a78a2";
}

// this is generated for your module, please do not change it
-(NSString*)moduleId
{
	return @"de.marcelpociot.twitter";
}

#pragma mark Lifecycle

-(void)startup
{
	// this method is called when the module is first loaded
	// you *must* call the superclass
	[super startup];
	
	NSLog(@"[INFO] %@ loaded",self);
}

-(void)shutdown:(id)sender
{
	// this method is called when the module is being unloaded
	// typically this is during shutdown. make sure you don't do too
	// much processing here or the app will be quit forceably
	
	// you *must* call the superclass
	[super shutdown:sender];
}

#pragma mark Cleanup 

-(void)dealloc
{
	// release any resources that have been retained by the module
    [accountStore dealloc];
    [successCallback dealloc];
	[super dealloc];
}

#pragma mark Internal Memory Management

-(void)didReceiveMemoryWarning:(NSNotification*)notification
{
	// optionally release any resources that can be dynamically
	// reloaded once memory is available - such as caches
	[super didReceiveMemoryWarning:notification];
}

#pragma mark Listener Notifications

-(void)_listenerAdded:(NSString *)type count:(int)count
{

}

-(void)_listenerRemoved:(NSString *)type count:(int)count
{

}

#pragma Public APIs

-(void)accounts:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);
    
    id load = [args objectForKey:@"load"];
    id cancel = [args objectForKey:@"cancel"];
    RELEASE_TO_NIL(loadCallback);
    RELEASE_TO_NIL(accessErrorCallback);
    loadCallback    = [load retain];
    accessErrorCallback = [cancel retain];
    if( accountStore == nil ){
        accountStore = [[ACAccountStore alloc] init];
    }
    ACAccountType *accountTypeTwitter =
    [accountStore
     accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [accountStore requestAccessToAccountsWithType:accountTypeTwitter withCompletionHandler:^(BOOL granted, NSError *error) {
        if(granted) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSArray* accounts = [accountStore
                                 accountsWithAccountType:accountTypeTwitter];
                
                if( loadCallback != nil )
                {
                    NSMutableDictionary* event = [[NSMutableDictionary alloc] init];
                    NSMutableArray* accountArray = [[NSMutableArray alloc] init];
                    for( ACAccount* account in accounts ){
                        NSDictionary* accountObject = [NSDictionary dictionaryWithObjectsAndKeys:
                                                       account.username,
                                                       @"username",
                                                       account.description,
                                                       @"description",
                                                       account.accountDescription,
                                                       @"accountDescription", nil];
                        [accountArray addObject:accountObject];
                    }
                    [event setValue:accountArray forKey:@"accounts"];
                    [self _fireEventToListener:@"loadAccount" withObject:event listener:loadCallback thisObject:nil];
                    [accountArray release];
                }
            });
        } else {
            if( accessErrorCallback != nil )
            {
                [self _fireEventToListener:@"accessForbidden" withObject:nil listener:accessErrorCallback thisObject:nil];
            }   
        }
    }];

}

-(void)request:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);

    NSString        *urlString      = [args objectForKey:@"url"];
    ENSURE_STRING(urlString);
    NSDictionary *params = (NSDictionary*)[args objectForKey:@"params"];
    
    //    NSString        *method         = [args objectForKey:@"method"];
    id success        = [args objectForKey:@"success"];
    id error          = [args objectForKey:@"error"];
    RELEASE_TO_NIL(requestSuccessCallback);
    RELEASE_TO_NIL(requestErrorCallback);
    requestSuccessCallback  = [success retain];
    requestErrorCallback    = [error retain];
    
    // Do a simple search, using the Twitter API
    TWRequest *request = [[TWRequest alloc] initWithURL:[NSURL URLWithString:urlString] 
                                             parameters:params requestMethod:TWRequestMethodGET];
    
    // Notice this is a block, it is the handler to process the response
    [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error)
    {
        if ([urlResponse statusCode] == 200) 
        {
            // The response from Twitter is in JSON format
            // Move the response into a dictionary and print
            NSError *error;        
            NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
            NSDictionary *event = [NSDictionary dictionaryWithObjectsAndKeys:response,@"response", nil];
            if( requestSuccessCallback != nil ){
                [self _fireEventToListener:@"requestSuccess" withObject:event listener:requestSuccessCallback thisObject:nil];
            }
        }
        else
        {
            if( requestErrorCallback != nil ){
                [self _fireEventToListener:@"requestError" withObject:[args objectForKey:@"params"] listener:requestErrorCallback thisObject:nil];
            }
        }
    }];
}


-(void)tweet:(id)args
{
    ENSURE_UI_THREAD_1_ARG(args);
    ENSURE_SINGLE_ARG(args,NSDictionary);

    NSString*   message          = [args objectForKey:@"message"];
    NSArray*    imageArray       = [args objectForKey:@"images"];
    NSArray*    urlArray         = [args objectForKey:@"urls"];
    
    id success      = [args objectForKey:@"success"];
    id cancel       = [args objectForKey:@"cancel"];
    id error        = [args objectForKey:@"error"];
    RELEASE_TO_NIL(successCallback);
    RELEASE_TO_NIL(cancelCallback);
    RELEASE_TO_NIL(errorCallback);
    successCallback = [success retain];
    cancelCallback  = [cancel retain];
    errorCallback   = [error retain];
    
    if ([TWTweetComposeViewController canSendTweet])
    {
        TWTweetComposeViewController *tweetSheet = [[TWTweetComposeViewController alloc] init];
        
        tweetSheet.completionHandler = ^(TWTweetComposeViewControllerResult res) {
            if (TWTweetComposeViewControllerResultDone) {
                if (successCallback!=nil)
                {
                    [self _fireEventToListener:@"success" withObject:nil listener:successCallback thisObject:nil];
                }
            } else if (TWTweetComposeViewControllerResultCancelled) {
                if (cancelCallback!=nil)
                {
                    [self _fireEventToListener:@"cancel" withObject:nil listener:cancelCallback thisObject:nil];
                }            }
            [[TiApp app] hideModalController:tweetSheet animated:YES];
        };

        [tweetSheet setInitialText:message];
        if( [imageArray count] > 0 ){
            for(id image in imageArray )
            {
                [tweetSheet addImage:[TiUtils toImage:image proxy:nil]];
            }
        }
        if( [urlArray count] > 0 )
        {
            for(NSString* url in urlArray )
            {
                [tweetSheet addURL:[TiUtils toURL:url proxy:nil]];
            }
        }
        [[TiApp app] showModalController:tweetSheet animated:YES];
    } else 
    {
        if (errorCallback!=nil)
        {
            [self _fireEventToListener:@"error" withObject:nil listener:errorCallback thisObject:nil];
        }
    }
}
@end
