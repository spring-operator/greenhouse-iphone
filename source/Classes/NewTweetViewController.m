    //
//  NewTweetViewController.m
//  Greenhouse
//
//  Created by Roy Clarkson on 7/23/10.
//  Copyright 2010 VMware. All rights reserved.
//

#import "NewTweetViewController.h"
#import "OAuthManager.h"
#import "TwitterController.h"

#define MAX_TWEET_SIZE 140


@interface NewTweetViewController()

@property (nonatomic, retain) LocationManager *locationManager;
@property (nonatomic, retain) TwitterController *twitterController;

- (void)setCount:(NSUInteger)newCount;
- (void)postTweet;

@end


@implementation NewTweetViewController

@synthesize locationManager;
@synthesize twitterController;
@synthesize tweetUrl;
@synthesize tweetText;
@synthesize barButtonCancel;
@synthesize barButtonSend;
@synthesize textViewTweet;
@synthesize barButtonGeotag;
@synthesize switchGeotag;
@synthesize barButtonCount;

- (void)setCount:(NSUInteger)textLength
{
	NSInteger remainingChars = MAX_TWEET_SIZE - textLength;
	NSString *s = [[NSString alloc] initWithFormat:@"%i", remainingChars];
	barButtonCount.title = s;
	[s release];
	
	if (remainingChars < 0)
	{
		barButtonSend.enabled = NO;
	}
	else 
	{
		barButtonSend.enabled = YES;
	}	
}

- (IBAction)actionCancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
}

- (IBAction)actionGeotag:(id)sender
{
	[[UserSettings sharedInstance] setIncludeLocationInTweet:switchGeotag.on];	
}

- (IBAction)actionSend:(id)sender
{
	if ([[UserSettings sharedInstance] includeLocationInTweet])
	{
		self.locationManager = [[LocationManager alloc] init];
		locationManager.delegate = self;
		[locationManager startUpdatingLocation];
	}
	else 
	{
		self.twitterController = [[TwitterController alloc] init];
		twitterController.delegate = self;
		[twitterController postUpdate:textViewTweet.text withURL:tweetUrl];
	}
}


#pragma mark -
#pragma mark LocationManagerDelegate methods

- (void)locationManager:(LocationManager *)manager didUpdateLocation:(CLLocation *)newLocation
{
	[manager release];
	
	self.twitterController = [[TwitterController alloc] init];
	twitterController.delegate = self;
	[twitterController postUpdate:textViewTweet.text withURL:tweetUrl location:newLocation];
}

- (void)locationManager:(LocationManager *)manager didFailWithError:(NSError *)error
{
	[manager release];
}


#pragma mark -
#pragma mark TwitterControllerDelegate methods

- (void)postUpdate:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data
{
	self.twitterController = nil;
	
	[self dismissModalViewControllerAnimated:YES];
}

- (void)postUpdate:(OAServiceTicket *)ticket didFailWithError:(NSError *)error
{
	self.twitterController = nil;
}


#pragma mark -
#pragma mark UITextViewDelegate methods

- (void)textViewDidChange:(UITextView *)textView
{
	[self setCount:[textView.text length]];
}


#pragma mark -
#pragma mark UIViewController methods

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.switchGeotag.on = [[UserSettings sharedInstance] includeLocationInTweet];
}
				   
- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	textViewTweet.text = tweetText;
	[self setCount:[tweetText length]];
	
	// displays the keyboard
	[textViewTweet becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:YES];	
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	
	self.locationManager = nil;
	self.tweetUrl = nil;
	self.tweetText = nil;
	self.barButtonCancel = nil;
	self.barButtonSend = nil;
	self.textViewTweet = nil;
	self.barButtonGeotag = nil;
	self.switchGeotag = nil;
	self.barButtonCount = nil;
}


#pragma mark -
#pragma mark NSObject methods

- (void)dealloc 
{
	[locationManager release];
	[twitterController release];
	[tweetUrl release];
	[tweetText release];
	[barButtonCancel release];
	[barButtonSend release];
	[textViewTweet release];
	[barButtonGeotag release];
	[switchGeotag release];
	[barButtonCount release];
	
    [super dealloc];
}


@end
