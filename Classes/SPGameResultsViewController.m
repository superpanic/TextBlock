//
//  SPGameResultsViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPGameResultsViewController.h"
#import "SPListView.h"
#import "SPCommon.h"
#import "SPHiscoreListViewController.h"
#import "SPListViewCell.h"

#import "AppDelegate_Pad.h"
#import "AppDelegate_Phone.h"

#import "FBConnect.h"
#import "Facebook.h"

#import "SimpleAudioEngine.h"

// Your Facebook APP Id must be set before running this example
// See http://www.facebook.com/developers/createapp.php
// Also, your application must bind to the fb[app_id]:// URL
// scheme (substitue [app_id] for your real Facebook app id).
static NSString* kAppId = @"148738048478096";

@implementation SPGameResultsViewController

@synthesize listView;
@synthesize hiscoreListViewController;
@synthesize gameScreenRect;
@synthesize playerWords;
@synthesize playerScores;
@synthesize playerName;
@synthesize playerScore;
@synthesize continueButton;
@synthesize gameCenterButton;
@synthesize facebookButton;

@synthesize gameOverMusic;

@synthesize facebook;

- (void)dealloc {
	
	// remove all observers
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[listView release];
	[hiscoreListViewController release];
	[buttonFont release];
	[continueButton release];
	[gameCenterButton release];
	[facebookButton release];
	[playerWords release];
	[playerScores release];
	[playerName release];
	[facebook release];
	[permissions release];
	
	[gameOverMusic release];
	
	//[SimpleAudioEngine end];
	 
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (id) init {
	if( (self = [super init]) ) {
		// create a rect for whole screen
		gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

		// keyboard is not visible 
		keyboardVisible = NO;	

		// create the list view
		SPListView *temp_listView = [[SPListView alloc] 
					     initWithFrame:gameScreenRect 
					     cellHeight:(CGRectGetHeight(gameScreenRect) * 0.2)];
		
		[self setListView:temp_listView];
		[temp_listView release];
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView {
	[super loadView];
	
	
	// AUDIO
	// get pointer to the singleton sound engine
	if(!audioEngine) audioEngine = [SimpleAudioEngine sharedEngine];
	
	gameOverMusic = [[NSString stringWithString:RSRC(@"m_gameover.caf")] retain];
	NSLog(@"gameover: %@", gameOverMusic);
	[audioEngine preloadBackgroundMusic:gameOverMusic];
	
	// AUDIO END
	
	
	
	
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];
	
	// add the list view to the view controllers main view
	[[self view] addSubview:listView];
	
	// button settings
	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width, gameScreenRect.size.height * 0.15);
	float padding = buttonSize.height / 25.0f;
	
	// obtain the facebook object from the app delegate
	Facebook *tempFacebook = [[(AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] facebook] retain];
	[self setFacebook:tempFacebook];
	[tempFacebook release];
	
	permissions =  [[NSArray arrayWithObjects:@"read_stream", @"offline_access",nil] retain];
	
	// ### create the continue button
	
	// button font
	buttonFont = [[UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.65f] retain];

	NSString *continueString;
	continueString = NSLocalizedString(@"RESULTS_CONTINUE", @"Button text: continue to the hiscore list screen.");
	
	// create and retain continue button
	continueButton = [[self 
			   createButtonWithTitle:continueString 
			   action:@selector(buttonContinueAction:) 
			   frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)] 
			  retain];
		 
	// set continue button position
	[continueButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) - buttonSize.height * 0.5f)];
	
	[continueButton setHidden:YES];
	
 	[[self view] addSubview:continueButton];
	
	NSString *facebookString;
	facebookString = NSLocalizedString(@"RESULTS_FACEBOOK", @"Button text: post score to facebook.");
	
	// create and retain facebook button
	facebookButton = [[self 
			   createButtonWithTitle:facebookString 
			   action:@selector(buttonFacebookAction:) 
			   frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)] 
			  retain];
	
	// position facebook button
	[facebookButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) - buttonSize.height * 0.5f - buttonSize.height)];

	[facebookButton setHidden:YES];

 	[[self view] addSubview:facebookButton];

}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
}



- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
	[[self view] setAlpha:0.0f];
	[audioEngine playBackgroundMusic:gameOverMusic loop:YES];
}

- (void) viewDidAppear:(BOOL) animated {
	[super viewDidAppear:animated];
	// fade in main view
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5f];
	[[self view] setAlpha:1.0f];
	[UIView commitAnimations];	
}



- (UIButton *) createButtonWithTitle:(NSString *)t action:(SEL)a frame:(CGRect)f {
	// will auto-release!
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];

	// button settings
	[b setFrame:f];
	[ [b titleLabel] setFont:buttonFont ];
	[b setTitle:t forState:UIControlStateNormal];
	[b setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[b setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[b setBackgroundColor:[SPCommon SPGetBlue]];
		
	// new game button, targets and actions
	[b addTarget:self action:a forControlEvents:UIControlEventTouchUpInside];
	[b addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[b addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[b addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
		
	return b;
}

- (void) showPlayerScore:(int)s words:(NSMutableArray *)words scores:(NSArray *)scores {
	playerScore = MAX(0, s);
	// this is a property - has to be retained in memory (released in dealloc)
	playerWords = [[NSArray arrayWithArray:words] retain];
	playerScores = [[NSArray arrayWithArray:scores] retain];
	
	NSString *scoreString;
	scoreString = NSLocalizedString(@"RESULTS_SCORE", @"Title text for player score.");

	NSString *playerNameString;
	playerNameString = NSLocalizedString(@"RESULTS_PLAYER_NAME", @"Title text for player name.");

	NSString *longestWordString;
	longestWordString = NSLocalizedString(@"RESULTS_LONGEST_WORD", @"Title text for longest word.");
	
	NSString *bestWord = @"-";
	int index = [SPCommon getHighestScoreIndexFrom:playerScores];
	if(index >= 0 && index < [playerWords count]) {
		bestWord = [playerWords objectAtIndex:index];
	}
	
	[listView addCellWithTitle:scoreString info:[NSString stringWithFormat:@"%i", playerScore] textAlignment:UITextAlignmentCenter];
	// create a cell with input add self as observer for the keyboard 
	[listView addInputCellWithTitle:playerNameString info:[SPCommon readLastUsedName] textAlignment:UITextAlignmentCenter observer:self];
	[listView addCellWithTitle:longestWordString info:bestWord textAlignment:UITextAlignmentCenter];	
}

- (void) keyboardDidShow: (NSNotification *)notif {
	NSLog(@"### keyboardDidShow");
	
	// return if keyboard is already visible
	if(keyboardVisible) return;
		
	// Keyboard is now visible
	keyboardVisible = YES;	
}

- (void) keyboardDidHide: (NSNotification *)notif {
	NSLog(@"### keyboardDidHide");
	
	// return if keyboard already hidden
	if(!keyboardVisible) return;
	
	// this is an object property, has to be retained!
	playerName = [[listView activeInputContent] retain];
	
	// save player name, score and words
	[SPCommon savePlayerScore:playerScore name:playerName words:playerWords wordScores:playerScores];
	NSLog(@"playerWords: %@", [playerWords description]);
	NSLog(@"playerScores: %@", [playerScores description]);
	
	// Keyboard is now visible
	keyboardVisible = NO;
	
	// show buttons
	[continueButton setHidden:NO];
	[facebookButton setHidden:NO];

	// remove all observers for self
	[[NSNotificationCenter defaultCenter] removeObserver:self];

}



- (void)buttonTouchUp:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void)buttonTouchDown:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetOffWhite]];
}

- (void)buttonTouchUpOutside:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void)buttonContinueAction:(id)sender {	
	// fade out view animation
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f];
		if([SPCommon readLastRanking]<kHiscoreDBMax) {
			[UIView setAnimationDidStopSelector:@selector(continueToHiscoreList)];
		} else {
			[UIView setAnimationDidStopSelector:@selector(continueToMainMenu)];	
		}
		[[self view] setAlpha:0.0f];
	[UIView commitAnimations];
}

- (void)continueToHiscoreList {
	// create the hiscore list view controller
	SPHiscoreListViewController *temp_hiscoreListViewController = [[SPHiscoreListViewController alloc] init];
	[self setHiscoreListViewController:temp_hiscoreListViewController];
	[temp_hiscoreListViewController release];
	// push the hiscore list view controller
	[[self navigationController] pushViewController:hiscoreListViewController animated:NO];	
}

- (void)continueToMainMenu {		
	//UIViewController *vc = [[[self navigationController] viewControllers] objectAtIndex:0];
	//NSLog(@"Root controller! %@", [vc description]);
	[[self navigationController] popToRootViewControllerAnimated:NO];
}


- (void)buttonFacebookAction:(id)sender {
	NSLog(@"Post to Facebook!");
	
	NSLog(@"accessToken: %@", [facebook accessToken]);
	NSLog(@"facebook isSessionValid: %@", ([facebook isSessionValid] ? @"YES" : @"NO"));
	
	if([facebook isSessionValid]) {
		[self publishToStream];
	} else {
		[facebook authorize:kAppId permissions:permissions delegate:self];
	}

}



/**
 * Open an inline dialog that allows the logged in user to publish a story to his or
 * her wall.
 */
- (void)publishToStream {
	SBJSON *jsonWriter = [[SBJSON alloc] init];

	

	NSString *playerScoreString = [NSString stringWithFormat:@"I got %i points in TextBlock!", playerScore];
	
	
	NSString *facebookDescriptionString;
	facebookDescriptionString = NSLocalizedString(@"FACEBOOK_DESCRIPTION", @"Game description, posted to facebook wall.");
		
	/*
	NSString *facebookCaptionString;
	facebookCaptionString = NSLocalizedString(@"FACEBOOK_CAPTION", @"Caption for facebook wall post.");
	
	NSString *bestWordString;
	
	if(playerWords) {
		bestWordString = [NSString stringWithFormat:@"%@ %@", facebookCaptionString, [SPCommon getLongestWordFromArray:playerWords] ];
	} else {
		bestWordString = @"";
	}
	*/
	
	NSString *bestWordString = @"";
	int index = [SPCommon getHighestScoreIndexFrom:playerScores];
	if(index >= 0 && index < [playerWords count]) {
		bestWordString = [playerWords objectAtIndex:index];
	}	
	
	NSDictionary* attachmentDict = [NSDictionary dictionaryWithObjectsAndKeys:
				    playerScoreString, @"name",
				    bestWordString, @"caption",
				    facebookDescriptionString, @"description",
				    @"http://www.superpanic.com/", @"href", nil];
	
	NSString *attachmentStr = [jsonWriter stringWithObject:attachmentDict];   

	NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
				       kAppId, @"api_key",
				       @"", @"message",
				       attachmentStr, @"attachment",
				       nil];
		
	[facebook dialog:@"stream.publish"
		andParams:params
	      andDelegate:self];
	
	[jsonWriter release];
}




- (void)buttonGameCenterAction:(id)sender {
	NSLog(@"Post to Game Center!");
	// [[self navigationController] pushViewController:gameCenterViewController animated:NO];
}




- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
	return NO;
}





///////////////////////////////////////////////////////////////////////////////////////////////////
// FBLogin

/**
 * Called when the user has logged in successfully.
 */
- (void)fbDidLogin {
	NSLog(@"logged in to facebook");
	NSLog(@"accessToken: %@", [facebook accessToken]);
	NSLog(@"facebook isSessionValid: %@", ([facebook isSessionValid] ? @"YES" : @"NO"));

	[self publishToStream];
	//[self.label setText:@"logged in"];
}

/**
 * Called when the user canceled the authorization dialog.
 */
-(void)fbDidNotLogin:(BOOL)cancelled {
	NSLog(@"did not login");
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	NSLog(@"logged out!");
	// [self.label setText:@"Please log in"];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBRequestDelegate

/**
 * Called when the Facebook API request has returned a response. This callback
 * gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
	NSLog(@"Facebook received response");
}

/**
 * Called when a request returns and its response has been parsed into an object.
 * The resulting object may be a dictionary, an array, a string, or a number, depending
 * on the format of the API response.
 * If you need access to the raw response, use
 * (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response.
 */
- (void)request:(FBRequest *)request didLoad:(id)result {
	NSLog(@"Facebook received response with parsed object");
	/*
	if ([result isKindOfClass:[NSArray class]]) {
		result = [result objectAtIndex:0];
	}
	if ([result objectForKey:@"owner"]) {
		[self.label setText:@"Photo upload Success"];
	} else {
		[self.label setText:[result objectForKey:@"name"]];
	}
	 */
}

/**
 * Called when an error prevents the Facebook API request from completing successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
	NSLog(@"Facebook failed with error");
	NSLog(@"Error: %@", error);
	// [self.label setText:[error localizedDescription]];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
// FBDialogDelegate

/**
 * Called when a UIServer Dialog successfully return.
 */
- (void)dialogDidComplete:(FBDialog *)dialog {
	NSLog(@"Facebook dialog did complete");
	
	NSLog(@"facebook isSessionValid: %@", ([facebook isSessionValid] ? @"YES" : @"NO"));

	// [self.label setText:@"publish successfully"];
}



@end




