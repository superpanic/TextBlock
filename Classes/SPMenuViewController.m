    //
//  SPMenuViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPMenuViewController.h"
#import "SPCommon.h"
#import "SPSettingsViewController.h"
#import "SPTutorialViewController.h"
#import "SPGameViewController.h"

#import "SPHiscoreListView.h"

#import "SPFlyingBlocks.h"

#import "SimpleAudioEngine.h"


#pragma mark -
#pragma mark implementation

@implementation SPMenuViewController

#pragma mark -
#pragma mark synthesize object properties

// values
@synthesize gameScreenRect;

// objects
@synthesize buttonGroupView;
@synthesize buttonNewGame;
@synthesize buttonSettings;

@synthesize buttonClearHiscore;
@synthesize alertClearHiscore;

@synthesize labelTitleA;
@synthesize labelTitleB;
@synthesize labelDeveloperA;
@synthesize labelDeveloperB;
@synthesize labelURL;
@synthesize titleFont;
@synthesize urlFont;

// @synthesize gameViewController;
@synthesize gameSettingsViewController;
@synthesize tutorialViewController;

@synthesize hiscoreListView;

@synthesize flyingBlocks;

@synthesize isResumingSavedGame;


// macro for getting ReSouRCe file path
#define RSRC(x) [[NSBundle mainBundle] pathForResource:x ofType:nil]


#pragma mark -
#pragma mark memory warnings and dealloc

- (void)dealloc {
//	[gameViewController release];
	[gameSettingsViewController release];
	[tutorialViewController release];
	
	[hiscoreListView release];
	[alertClearHiscore release];
	
	[flyingBlocks release];
	
	[buttonGroupView release];
	[buttonNewGame release];
	[buttonSettings release];
	[buttonClearHiscore release];
	[labelTitleA release];
	[labelTitleB release];
	[labelDeveloperA release];
	[labelDeveloperB release];
	[labelURL release];
	[titleFont release];
	[urlFont release];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	//[SimpleAudioEngine end];
	[titleMusic release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];

}


- (void) viewDidUnload {
	NSLog(@"\n\n	viewDidUnload %@\n\n", [self title]);
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	// ONLY VIEWS
	
	// Release any cached data, images, etc that aren't in use.
	if(flyingBlocks){
		[flyingBlocks stop];
		[flyingBlocks release];
		flyingBlocks = nil;
	}
	
	if(hiscoreListView) {
		[hiscoreListView release];
		hiscoreListView = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {

	// if resuming a saved game - do not load this view!
	if([self tryResumeGame]) {
		[self setIsResumingSavedGame:YES];
		return;
	} else {		
		[self setIsResumingSavedGame:NO];
	}
	
	[super loadView];
	
	NSLog(@"loadView");
	
	
	NSLog(@"running some tests");
	[self runTests];

	
	[self prepareAudio];
	
	// clear local hiscores
	//NSLog(@"Clear all local hiscores!");
	//[SPCommon clearAllHiscores];
	
	 
	// create a rect for whole screen
	gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
	
	
	// no need to create a main view, the main view is already set up by the ViewController
	
	// create the main view
	//UIView *temp_view = [[UIView alloc] initWithFrame:gameScreenRect];
	// set main view background
	//[self setView:temp_view];
	//[temp_view release];
	// set background color
	
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];
	
	/*
	// reset the game
	if(gameViewController) {
		[gameViewController release];
		gameViewController = nil;
	}
	*/

	if(!flyingBlocks) {
		[self createFlyingBlocks];
	}
	
	
	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width, gameScreenRect.size.height * 0.15);
	padding = buttonSize.height / 25.0f;
	
	// create a view for all the buttons (this makes it easier to group them when rotating)
	UIView *temp_buttonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height * 2.0f + padding * 2.0f )];
	[self setButtonGroupView:temp_buttonGroupView];
	[temp_buttonGroupView release];
	
	// position the button group in center of screen
	[buttonGroupView setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f)];
	
	// button font
	UIFont *buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.65f];
	
	
	// ### new game button
	UIButton *temp_buttonNewGame = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[self setButtonNewGame:temp_buttonNewGame];
	[temp_buttonNewGame release];	
	
	// new game button settings
	[buttonNewGame setFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)];
	[ [buttonNewGame titleLabel] setFont:buttonFont];
	[ [buttonNewGame titleLabel] setAdjustsFontSizeToFitWidth:YES];
	
	NSString *newGameString;
	newGameString = NSLocalizedString(@"MENU_NEW_GAME", @"Button text: start a new game.");
	[buttonNewGame setTitle:newGameString forState:UIControlStateNormal];
	
	[buttonNewGame setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[buttonNewGame setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[buttonNewGame setBackgroundColor:[SPCommon SPGetBlue]];
	
	// new game button position
	// [buttonNewGame setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f - buttonSize.height * 0.5)];
	[buttonNewGame setCenter:CGPointMake( buttonGroupView.frame.size.width * 0.5f, buttonGroupView.frame.size.height * 0.5f - buttonSize.height * 0.5 ) ];

	// new game button, targets and actions
	[buttonNewGame addTarget:self action:@selector(buttonNewGameAction:) forControlEvents:UIControlEventTouchUpInside];
	[buttonNewGame addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[buttonNewGame addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[buttonNewGame addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];

	[buttonNewGame setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)];	
	
	// add button to view
	[buttonGroupView addSubview:buttonNewGame];


	// ### settings button
	// create new game button
	UIButton *temp_buttonSettings = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[self setButtonSettings:temp_buttonSettings];
	[temp_buttonSettings release];	
	
	// settings button settings
	[buttonSettings setFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)];
	[ [buttonSettings titleLabel] setFont:buttonFont];
	[ [buttonSettings titleLabel] setAdjustsFontSizeToFitWidth:YES];
	
	NSString *settingsString;
	NSString *currentLang = [SPCommon readLanguageSettings];
	if( [currentLang compare:@"swe"] == NSOrderedSame ) {
		settingsString = NSLocalizedString(@"LANGUAGE_SWEDISH", @"Button text: set game dictionary language to swedish");
	} else {
		settingsString = NSLocalizedString(@"LANGUAGE_ENGLISH", @"Button text: set game dictionary language to english");
	}
	
	[buttonSettings setTitle:settingsString forState:UIControlStateNormal];
	
	[buttonSettings setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[buttonSettings setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[buttonSettings setBackgroundColor:[SPCommon SPGetBlue]];
	
	// [ [buttonSettings layer] setCornerRadius:buttonSize.height * 0.1f];
	
	// settings button position
	// [buttonSettings setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f + buttonSize.height * 0.5)];
	[buttonSettings setCenter:CGPointMake( buttonGroupView.frame.size.width * 0.5f, buttonGroupView.frame.size.height * 0.5f + buttonSize.height * 0.5 ) ];
	
	// new game button, targets and actions
	[buttonSettings addTarget:self action:@selector(buttonSettingsAction:) forControlEvents:UIControlEventTouchUpInside];
	[buttonSettings addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[buttonSettings addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[buttonSettings addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
	
	[buttonSettings setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)];	
	
	// add button to view
	[buttonGroupView addSubview:buttonSettings];

	
	
	// title font
	titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.70f];

	
	float titleSpace = [@" " sizeWithFont:titleFont].width;
	
	// ### create the title label line A
	UILabel *temp_labelTitleA = [ [UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [@"TEXT" sizeWithFont:titleFont].width, [titleFont capHeight] + padding ) ];
	[self setLabelTitleA:temp_labelTitleA];
	[temp_labelTitleA release];
	
	[labelTitleA setCenter:CGPointMake( gameScreenRect.size.width / 2.0f, [buttonGroupView frame].origin.y / 2.0f - [titleFont capHeight] * 0.6f )];
	
	[labelTitleA setFont:titleFont];
	[labelTitleA setTextAlignment:UITextAlignmentCenter];
	[labelTitleA setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];	
	[labelTitleA setText:@"TEXT"];
	[labelTitleA setBackgroundColor:[UIColor clearColor]];
	[labelTitleA setTextColor:[SPCommon SPGetOffWhite]];
	
	[[self view] addSubview:labelTitleA];
	
	
	
	
	// ### create the title label line B
	UILabel *temp_labelTitleB = [ [UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [@"BLOCK" sizeWithFont:titleFont].width, [titleFont capHeight] + padding ) ];
	[self setLabelTitleB:temp_labelTitleB];
	[temp_labelTitleB release];

	[labelTitleB setCenter:CGPointMake( gameScreenRect.size.width / 2.0f, [buttonGroupView frame].origin.y / 2.0f + [titleFont capHeight] * 0.6f )];
	
	[labelTitleB setFont:titleFont];
	[labelTitleB setTextAlignment:UITextAlignmentCenter];
	[labelTitleB setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
	[labelTitleB setText:@"BLOCK"];
	[labelTitleB setBackgroundColor:[UIColor clearColor]];
	[labelTitleB setTextColor:[SPCommon SPGetOffWhite]];
	
	[[self view] addSubview:labelTitleB];
	
	
	// labelTitleCenterOffset = (CGRectGetWidth( [labelTitleA frame] ) / 2.0f + titleSpace / 2.0 + CGRectGetWidth( [labelTitleB frame] ) / 2.0f) / 2.0f;
	
	float labelTitleLandscapeWidth = CGRectGetWidth([labelTitleA frame]) + CGRectGetWidth([labelTitleB frame]) + titleSpace;
	float labelTitleEdgePadding = (gameScreenRect.size.height - labelTitleLandscapeWidth) / 2.0f;
	
	labelTitleAPortraitPos = CGPointMake( gameScreenRect.size.width / 2.0f, [buttonGroupView frame].origin.y / 2.0f - [titleFont capHeight] * 0.6f );
	labelTitleBPortraitPos = CGPointMake( gameScreenRect.size.width / 2.0f, [buttonGroupView frame].origin.y / 2.0f + [titleFont capHeight] * 0.6f );
	labelTitleALandscapePos = CGPointMake( labelTitleEdgePadding + CGRectGetWidth([labelTitleA frame]) / 2.0f, ((CGRectGetWidth(gameScreenRect) - CGRectGetHeight([buttonGroupView frame])) / 2.0f) / 2.0f );
	labelTitleBLandscapePos = CGPointMake( gameScreenRect.size.height - labelTitleEdgePadding - CGRectGetWidth([labelTitleB frame]) / 2.0f , ((CGRectGetWidth(gameScreenRect) - CGRectGetHeight([buttonGroupView frame])) / 2.0f) / 2.0f );

	
	
	buttonGroupViewBottomPos = [buttonGroupView frame].origin.y + [buttonGroupView frame].size.height;

	// ### create the developer label line A
	UILabel *temp_labelDeveloperA = [ [UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [@"© SUPER" sizeWithFont:titleFont].width, [titleFont capHeight] + padding ) ];
	
	[self setLabelDeveloperA:temp_labelDeveloperA];
	[temp_labelDeveloperA release];
	
	[labelDeveloperA setCenter:CGPointMake( gameScreenRect.size.width / 2.0f, buttonGroupViewBottomPos + (gameScreenRect.size.height - buttonGroupViewBottomPos) / 2.0f - [titleFont capHeight] * 0.6f )];

	[labelDeveloperA setFont:titleFont];
	[labelDeveloperA setTextAlignment:UITextAlignmentCenter];
	[labelDeveloperA setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];	
	[labelDeveloperA setText:@"© SUPER"];
	[labelDeveloperA setBackgroundColor:[UIColor clearColor]];
	[labelDeveloperA setTextColor:[SPCommon SPGetOffWhite]];
	
	[[self view] addSubview:labelDeveloperA];

	
	
	
	// ### create the developer label line B
	UILabel *temp_labelDeveloperB = [ [UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [@"PANIC" sizeWithFont:titleFont].width, [titleFont capHeight] + padding ) ];
	
	[self setLabelDeveloperB:temp_labelDeveloperB];
	[temp_labelDeveloperB release];
	
	[labelDeveloperB setCenter:CGPointMake( gameScreenRect.size.width / 2.0f, buttonGroupViewBottomPos + (gameScreenRect.size.height - buttonGroupViewBottomPos) / 2.0f + [titleFont capHeight] * 0.6f )];
	
	[labelDeveloperB setFont:titleFont];
	[labelDeveloperB setTextAlignment:UITextAlignmentCenter];
	[labelDeveloperB setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];	
	[labelDeveloperB setText:@"PANIC"];
	[labelDeveloperB setBackgroundColor:[UIColor clearColor]];
	[labelDeveloperB setTextColor:[SPCommon SPGetOffWhite]];
	
	[[self view] addSubview:labelDeveloperB];
	
	float labelDeveloperLandscapeWidth = CGRectGetWidth([labelDeveloperA frame]) + CGRectGetWidth([labelDeveloperB frame]) + titleSpace;
	float labelDeveloperEdgePadding = (CGRectGetHeight(gameScreenRect) - labelDeveloperLandscapeWidth) / 2.0f;
	
	labelDeveloperAPortraitPos = CGPointMake( gameScreenRect.size.width / 2.0f, buttonGroupViewBottomPos + (gameScreenRect.size.height - buttonGroupViewBottomPos) / 2.0f - [titleFont capHeight] * 0.6f );
	labelDeveloperBPortraitPos = CGPointMake( gameScreenRect.size.width / 2.0f, buttonGroupViewBottomPos + (gameScreenRect.size.height - buttonGroupViewBottomPos) / 2.0f + [titleFont capHeight] * 0.6f );
	labelDeveloperALandscapePos = CGPointMake( labelDeveloperEdgePadding + CGRectGetWidth( [labelDeveloperA frame] ) / 2.0f, CGRectGetWidth(gameScreenRect) - ( CGRectGetWidth(gameScreenRect) - CGRectGetHeight([buttonGroupView frame]) ) / 4.0f);
	labelDeveloperBLandscapePos = CGPointMake( gameScreenRect.size.height - labelDeveloperEdgePadding - CGRectGetWidth([labelDeveloperB frame]) / 2.0f, CGRectGetWidth(gameScreenRect) - ( CGRectGetWidth(gameScreenRect) - CGRectGetHeight([buttonGroupView frame]) ) / 4.0f);
		
	
	// url font
	urlFont = [UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.20f];
	
	// ### create the URL label
	UILabel *temp_labelURL = [ [UILabel alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, [buttonGroupView frame].size.width, [urlFont leading] + padding ) ];
	[self setLabelURL:temp_labelURL];
	[temp_labelURL release];
	
	[labelURL setCenter:CGPointMake( gameScreenRect.size.width / 2.0f, [labelDeveloperB center].y + [titleFont capHeight] + padding )];
	
	[labelURL setFont:urlFont];
	[labelURL setTextAlignment:UITextAlignmentCenter];
	[labelURL setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];	
	[labelURL setText:@"www.superpanic.com v1.1"];
	[labelURL setBackgroundColor:[UIColor clearColor]];
	[labelURL setTextColor:[SPCommon SPGetOffWhite]];
	
	[[self view] addSubview:labelURL];
	

	// ### add button group to main view
	[buttonGroupView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin )];	
	[[self view] addSubview:buttonGroupView];
	

	
	// ### clear hiscore button	
//	UIFont *clearHiscoreFont = [UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.40f];
	
	// create clear hiscore button
	UIButton *temp_buttonClearHiscore = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[self setButtonClearHiscore:temp_buttonClearHiscore];
	[temp_buttonClearHiscore release];
	
	// clear hiscore button settings
	[buttonClearHiscore setFrame:CGRectMake(0.0f, 0.0f, gameScreenRect.size.width, buttonSize.height)];
	[ [buttonClearHiscore titleLabel] setFont:buttonFont ];
	
	
	
	NSString *clearHiscoreString;
	clearHiscoreString = NSLocalizedString(@"CLEAR_HISCORE", @"Button text: Clear hiscore.");	
	
	[buttonClearHiscore setTitle:clearHiscoreString forState:UIControlStateNormal];
	
	[buttonClearHiscore setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[buttonClearHiscore setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[buttonClearHiscore setBackgroundColor:[SPCommon SPGetBlue]];
	
	//[buttonClearHiscore setCenter:CGPointMake(gameScreenRect.size.width - [buttonClearHiscore frame].size.width * 0.5, gameScreenRect.size.height - [buttonClearHiscore frame].size.height * 0.5)];		
	[buttonClearHiscore setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height - [buttonClearHiscore frame].size.height * 0.5)];		
	
	// new game button, targets and actions
	[buttonClearHiscore addTarget:self action:@selector(buttonClearHiscoreAction:) forControlEvents:UIControlEventTouchUpInside];
	[buttonClearHiscore addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[buttonClearHiscore addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[buttonClearHiscore addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];	
	
	// add button to view
	[[self view] addSubview:buttonClearHiscore];
	
	[buttonClearHiscore setHidden:YES];
	[buttonClearHiscore setAlpha:0.0f];
	
	
	
	// create hiscore list
	if(!hiscoreListView){
		[self createHiscoreListView];
	}
	
	
	
	// localized hiscore alert copy
	NSString *clearHiscoresTitleString = NSLocalizedString(@"CLEAR_HISCORES_TITLE", @"Erase hiscores?");
	NSString *clearHiscoresInfoString = NSLocalizedString(@"CLEAR_HISCORES_INFO", @"Do you want to erase all your saved hiscores?");
	NSString *replyNoButtonString = NSLocalizedString(@"NO", @"No");
	NSString *replyYesButtonString = NSLocalizedString(@"YES", @"Yes");
	
	// create a warning alert for clearing hiscores
	UIAlertView *temp_alertClearHiscore = [[UIAlertView alloc] initWithTitle:clearHiscoresTitleString message:clearHiscoresInfoString delegate:self cancelButtonTitle:replyNoButtonString otherButtonTitles:replyYesButtonString, nil];
	[self setAlertClearHiscore:temp_alertClearHiscore];
	[temp_alertClearHiscore release];
	
	//[hiscoreListView setAlpha:0.0f];
	//[hiscoreListView setHidden:YES];

}

- (void) prepareAudio {
	//[SimpleAudioEngine end];
	if(!audioEngine) { 
		audioEngine = [SimpleAudioEngine sharedEngine];
		titleMusic = [[NSString stringWithString:RSRC(@"m_title.caf")] retain];
		NSLog(@"titleMusic: %@", titleMusic);
		[audioEngine preloadBackgroundMusic:titleMusic];
	}
}

- (void) createFlyingBlocks {
	// create and start the flying blocks
	SPFlyingBlocks *tempFlyingBlocks = [[SPFlyingBlocks alloc] initWithFrame:gameScreenRect];
	[self setFlyingBlocks:tempFlyingBlocks];
	[tempFlyingBlocks release];
	[flyingBlocks start];
	[[self view] addSubview:flyingBlocks];
	[[self view] sendSubviewToBack:flyingBlocks];
}

- (void) createHiscoreListView {
	// create the hiscore list view
	if(!hiscoreListView) {
		//SPHiscoreListView *temp_hiscoreListView = [[SPHiscoreListView alloc] initWithFrame:CGRectMake(0.0f, [buttonGroupView frame].origin.y + [buttonGroupView frame].size.height - padding * 2.0f, gameScreenRect.size.width, gameScreenRect.size.height - ([buttonGroupView frame].origin.y + [buttonGroupView frame].size.height) + padding * 2.0f)];
		NSLog(@"Creating hiscoreListView!");
		SPHiscoreListView *temp_hiscoreListView = [[SPHiscoreListView alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, gameScreenRect.size.width, gameScreenRect.size.height - [buttonClearHiscore frame].size.height)];
		[self setHiscoreListView:temp_hiscoreListView];
		[temp_hiscoreListView release];
		// [[self view] addSubview:hiscoreListView];
		[[self view] insertSubview:hiscoreListView belowSubview:buttonClearHiscore];
	}	
	
	[hiscoreListView setHidden:YES];
	[hiscoreListView setAlpha:0.0f];
	
	// register observer
	NSLog(@"Regestering observers!");
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeHiscoreWithDelay) name:NOTIF_hiscoreListScrollComplete object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fadeHiscore) name:NOTIF_hiscoreListTouched object:nil];

	// setting timer
	[self restartHiscore];
	
}

- (void) showHiscore {
	if(!hiscoreListView) return;
	if([hiscoreListView isEmpty]) return;
	[hiscoreListView setAlpha:0.0f];
	[hiscoreListView setHidden:NO];
	[buttonClearHiscore setAlpha:0.0f];
	[buttonClearHiscore setHidden:NO];
	// start focus animation
	[UIView beginAnimations:@"showHiscore" context:NULL]; 
	{
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(runHiscore)];
		[UIView setAnimationDuration:0.5f];
		[hiscoreListView setAlpha:1.0f];
		[buttonClearHiscore setAlpha:1.0f];
	} 
	[UIView commitAnimations];
}

- (void) runHiscore {
	[hiscoreListView startScroll];
}

- (void) fadeHiscoreWithDelay {	
	// start focus animation
	[UIView beginAnimations:@"showHiscore" context:NULL]; 
	{
		[UIView setAnimationDelay:2.0f];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(restartHiscore)];
		[UIView setAnimationDuration:0.5f];
		[hiscoreListView setAlpha:0.0f];
		[buttonClearHiscore setAlpha:0.0f];
	} 
	[UIView commitAnimations];
}

- (void) fadeHiscore {	
	// start focus animation
	[UIView beginAnimations:@"showHiscore" context:NULL]; 
	{
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(restartHiscore)];
		[UIView setAnimationDuration:0.5f];
		[hiscoreListView setAlpha:0.0f];
		[buttonClearHiscore setAlpha:0.0f];
	} 
	[UIView commitAnimations];
}


- (void) restartHiscore {

	[hiscoreListView setHidden:YES];
	[buttonClearHiscore setHidden:YES];
	
	// setting timer
	NSTimer *hiscoreTimer = [NSTimer scheduledTimerWithTimeInterval:8.0f target:self selector:@selector( showHiscore ) userInfo:nil repeats:NO];
#pragma unused(hiscoreTimer)
	
}




- (void) runTests {
	
	NSLog(@"running tests:");
	
	NSLog(@"Current locale is: %@", [[NSLocale currentLocale] localeIdentifier]);
	NSLog(@"Current Language : %@", [[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode]);
	NSLog(@"Current Country  : %@", [[NSLocale currentLocale] objectForKey: NSLocaleCountryCode]);
	
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	// load view after unload due to memory warning
	[super viewDidLoad];
	
	NSLog(@"viewDidLoad");
	
	/*
	 NSArray *keys = [NSArray arrayWithObjects:@"score", @"name", @"longword", nil];
	 NSArray *objects = [NSArray arrayWithObjects:[NSNumber numberWithInt:2010], @"superpanic", @"coffee", nil];
	 NSDictionary *playerScores = [NSDictionary dictionaryWithObjects:objects forKeys:keys];

	 [SPCommon saveNewHiscore:playerScores];
	 [SPCommon readHiscores];
	 */
	
}

- (void)viewWillAppear:(BOOL)animated {

	NSLog(@"View Controller: %@ will appear", [self title]);
	
	// if loading saved game, do not continue showing this view
	if([self isResumingSavedGame]) return;

	[super viewWillAppear:animated];
		
	/*
	// create and reset the main game view
	if(gameViewController) {
		NSLog(@"R E S E T   G A M E");
		NSLog(@"Setting game view controller to nil.");
		[gameViewController release];
		gameViewController = nil;
	}
	*/
	
	// language might have changed, change button title accordingly
	NSString *settingsString;
	NSString *currentLang = [SPCommon readLanguageSettings];
	if( [currentLang compare:@"swe"] == NSOrderedSame ) {
		settingsString = NSLocalizedString(@"LANGUAGE_SWEDISH", @"Button text: set game dictionary language to swedish");
	} else {
		settingsString = NSLocalizedString(@"LANGUAGE_ENGLISH", @"Button text: set game dictionary language to english");
	}
	[buttonSettings setTitle:settingsString forState:UIControlStateNormal];	
	
	if(!flyingBlocks) [self createFlyingBlocks];
	if(!hiscoreListView) [self createHiscoreListView];

	// hide main view (fade in later)
	[[self view] setAlpha:0.0f];
	
	if(!audioEngine) {
		[self prepareAudio];
	}
	
	[audioEngine playBackgroundMusic:titleMusic];
	
}

- (void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// fade in main view
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[[self view] setAlpha:1.0f];
	[UIView commitAnimations];	
}


- (void) buttonTouchUp:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void) buttonTouchDown:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetOffWhite]];
}

- (void) buttonTouchUpOutside:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void) buttonClearHiscoreAction:(id)sender {
	//NSLog(@"Clear all local hiscores!");
	// display an alert
	[alertClearHiscore show];
}

- (void) buttonNewGameAction:(id)sender {
	NSLog(@"New game!");

	if(hiscoreListView) {
		if(![hiscoreListView isHidden]) return;
		[hiscoreListView release];
		hiscoreListView = nil;
	}
	
	[audioEngine fadeOutAndStopBackgroundMusic];
	
	// fade out view animation
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f];
		// call [self newGame] to start the game
		[UIView setAnimationDidStopSelector:@selector(newGame)];
		[[self view] setAlpha:0.0f];
	[UIView commitAnimations];
}

- (BOOL) tryResumeGame {
	
	if(![SPCommon shouldResumeActiveGame]) return NO;
	
/*
	if(gameViewController) {
		[gameViewController release];
		gameViewController = nil;
	}
*/
	
	// create the main view controller (preload here, it takes too long too load when user tap the screen)
	SPGameViewController *temp_gameViewController = [[SPGameViewController alloc] init];
//	[self setGameViewController:temp_gameViewController];
	
	[temp_gameViewController setTitle:@"The Game View Controller"];
	
	// start new game
	[[self navigationController] pushViewController:temp_gameViewController animated:NO];

	[temp_gameViewController release];

	return YES;
}

- (void) newGame {
		
	if(flyingBlocks) {
		[flyingBlocks stop];
		[flyingBlocks release];
		flyingBlocks = nil;
	}

	if(tutorialViewController) {
		[tutorialViewController release];
		tutorialViewController = nil;
	}
	
	
	if(hiscoreListView) {
		[hiscoreListView release];
		hiscoreListView = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];


	if([SPCommon isTutorialActive]) {
		// run tutorial
		SPTutorialViewController *temp_tutorialViewController = [[SPTutorialViewController alloc] init];
		[self setTutorialViewController:temp_tutorialViewController];
		[temp_tutorialViewController release];
		[tutorialViewController setTitle:@"The Tutorial View Controller"];
		[[self navigationController] pushViewController:tutorialViewController animated:NO];
	} else {
		// run game
		SPGameViewController *temp_gameViewController = [[SPGameViewController alloc] init];
		//[self setGameViewController:temp_gameViewController];
		[temp_gameViewController setTitle:@"The Game View Controller"];
		// start new game
		[[self navigationController] pushViewController:temp_gameViewController animated:NO];		
		[temp_gameViewController release];
	}
}

- (void) killMenuItems {

/*
	if(gameViewController) {
		[gameViewController release];
		gameViewController = nil;
	}
*/
	
	if(flyingBlocks) {
		[flyingBlocks stop];
		[flyingBlocks release];
		flyingBlocks = nil;
	}
	
	if(tutorialViewController) {
		[tutorialViewController release];
		tutorialViewController = nil;
	}
	
	if(hiscoreListView) {
		[hiscoreListView release];
		hiscoreListView = nil;
	}
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
}

- (void) buttonSettingsAction:(id)sender {
	NSLog(@"Settings!");

	if(hiscoreListView) {
		if(![hiscoreListView isHidden]) return;
	}
	
	if(!gameSettingsViewController) {
		// create the settings view controller
		SPSettingsViewController *temp_gameSettingsViewController = [[SPSettingsViewController alloc] init];
		[self setGameSettingsViewController:temp_gameSettingsViewController];
		[temp_gameSettingsViewController release];
		// set the title for the game view controller
		[gameSettingsViewController setTitle:@"The Settings View Controller"];
		[gameSettingsViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	}
	[[self navigationController] presentModalViewController:gameSettingsViewController animated:YES];
	// [self presentModalViewController:gameSettingsViewController animated:YES];
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if( buttonIndex == [alertView cancelButtonIndex] ) {
		[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		NSLog(@"Cancel, don't clear hiscores");
		return;
	}	
	if( buttonIndex == [alertView firstOtherButtonIndex] ) {
		[alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
		NSLog(@"Yes, clear hiscores");
		[SPCommon clearAllHiscores];
		//[self fadeHiscore];
		[hiscoreListView reload];
		return;	
	}
}

- (void)didPresentAlertView:(UIAlertView *)alertView {
	
}

- (void)willPresentAlertView:(UIAlertView *)alertView {

}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {

}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {

}

- (void)alertViewCancel:(UIAlertView *)alertView {

}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Overriden to allow any orientation.
	return NO;
	
	switch (interfaceOrientation) {
		case UIInterfaceOrientationPortrait:
			[labelTitleA setCenter:labelTitleAPortraitPos];
			[labelTitleB setCenter:labelTitleBPortraitPos];
			[labelDeveloperA setCenter:labelDeveloperAPortraitPos];
			[labelDeveloperB setCenter:labelDeveloperBPortraitPos];
			break;
		case UIInterfaceOrientationPortraitUpsideDown:
			[labelTitleA setCenter:labelTitleAPortraitPos];
			[labelTitleB setCenter:labelTitleBPortraitPos];
			[labelDeveloperA setCenter:labelDeveloperAPortraitPos];
			[labelDeveloperB setCenter:labelDeveloperBPortraitPos];
			break;
		case UIInterfaceOrientationLandscapeRight:
			[labelTitleA setCenter:labelTitleALandscapePos];
			[labelTitleB setCenter:labelTitleBLandscapePos];
			[labelDeveloperA setCenter:labelDeveloperALandscapePos];
			[labelDeveloperB setCenter:labelDeveloperBLandscapePos];
			break;
		case UIInterfaceOrientationLandscapeLeft:
			[labelTitleA setCenter:labelTitleALandscapePos];
			[labelTitleB setCenter:labelTitleBLandscapePos];
			[labelDeveloperA setCenter:labelDeveloperALandscapePos];
			[labelDeveloperB setCenter:labelDeveloperBLandscapePos];
			break;
	}
	
	return YES;
}


@end



