    //
//  GameMenuViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPPauseViewController.h"
#import "SPCommon.h"
#import "SPGameViewController.h"


#pragma mark -
#pragma mark implementation

@implementation SPPauseViewController

#pragma mark -
#pragma mark synthesize object properties

// values
@synthesize gameScreenRect;

// objects
@synthesize buttonGroupView;
@synthesize buttonContinueGame;
@synthesize buttonMenu;

//@synthesize gameViewController;


#pragma mark -
#pragma mark memory warnings and dealloc

- (void)dealloc {
	[buttonGroupView release];
	[buttonContinueGame release];
	[buttonMenu release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


- (void) viewDidUnload {
	NSLog(@"\n\n	viewDidUnload %@\n\n", [self title]);
	[super viewDidUnload];
	
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	// ONLY VIEWS

}



// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
		
	[super loadView];

	// create a rect for whole screen
	gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
	
	// create the main view
	UIView *temp_view = [[UIView alloc] initWithFrame:gameScreenRect];
	// set main view background
	[self setView:temp_view];
	[temp_view release];
	
	/*
	// create the main view controller (preload here, it takes too long too load when user press the button)
	SPGameViewController *temp_gameViewController = [[SPGameViewController alloc] init];
	[self setGameViewController:temp_gameViewController];
	[temp_gameViewController release];
	
	// set the title for the game view controller
	[gameViewController setTitle:@"The Game View Controller"];
	 */
	
	// set background color
	// [[self view] setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];	

}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
		
	// load view after unload due to memory warning
	[super viewDidLoad];

	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width * 0.9, gameScreenRect.size.height * 0.15);
	float padding = 1.0f;
	
	// create a view for all the buttons (this makes it easier to group them when rotating)
	UIView *temp_buttonGroupView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height * 2.0f + padding * 2.0f )];
	[self setButtonGroupView:temp_buttonGroupView];
	[temp_buttonGroupView release];
	
	// position the button group in center of screen
	[buttonGroupView setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f)];
	
	// button font
	UIFont *buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.5f];
	
	
	// ### new game button
	UIButton *temp_buttonNewGame = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[self setButtonContinueGame:temp_buttonNewGame];
	[temp_buttonNewGame release];	
	
	// new game button settings
	[buttonContinueGame setFrame:CGRectMake(0.0f, 0.0f, buttonSize.width - padding, buttonSize.height - padding)];
	[ [buttonContinueGame titleLabel] setFont:buttonFont];
	
	NSString *continueString;
	continueString = NSLocalizedString(@"PAUSE_CONTINUE", @"Button: return to game screen and continue.");
	
	[buttonContinueGame setTitle:continueString forState:UIControlStateNormal];
	[buttonContinueGame setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[buttonContinueGame setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[buttonContinueGame setBackgroundColor:[SPCommon SPGetBlue]];
	[ [buttonContinueGame layer] setCornerRadius:buttonSize.height * 0.1f ];

	// new game button position
	// [buttonNewGame setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f - buttonSize.height * 0.5)];
	[buttonContinueGame setCenter:CGPointMake( buttonGroupView.frame.size.width * 0.5f, buttonGroupView.frame.size.height * 0.5f - buttonSize.height * 0.5 ) ];

	// new game button, targets and actions
	[buttonContinueGame addTarget:self action:@selector(buttonContinueGameAction:) forControlEvents:UIControlEventTouchUpInside];
	[buttonContinueGame addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[buttonContinueGame addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[buttonContinueGame addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];

	[buttonContinueGame setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)];	
	
	// add button to view
	[buttonGroupView addSubview:buttonContinueGame];


	// ### settings button
	// create new game button
	UIButton *temp_buttonSettings = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
	[self setButtonMenu:temp_buttonSettings];
	[temp_buttonSettings release];	
	
	// settings button settings
	[buttonMenu setFrame:CGRectMake(0.0f, 0.0f, buttonSize.width - padding, buttonSize.height - padding)];
	[ [buttonMenu titleLabel] setFont:buttonFont];
	
	NSString *menuString;
	menuString = NSLocalizedString(@"PAUSE_MENU", @"Button: quit game and return to main menu.");

	[buttonMenu setTitle:menuString forState:UIControlStateNormal];
	[buttonMenu setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[buttonMenu setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[buttonMenu setBackgroundColor:[SPCommon SPGetBlue]];
	[ [buttonMenu layer] setCornerRadius:buttonSize.height * 0.1f];
	
	// settings button position
	// [buttonSettings setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, gameScreenRect.size.height * 0.5f + buttonSize.height * 0.5)];
	[buttonMenu setCenter:CGPointMake( buttonGroupView.frame.size.width * 0.5f, buttonGroupView.frame.size.height * 0.5f + buttonSize.height * 0.5 ) ];
	
	// new game button, targets and actions
	[buttonMenu addTarget:self action:@selector(buttonMenuAction:) forControlEvents:UIControlEventTouchUpInside];
	[buttonMenu addTarget:self action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[buttonMenu addTarget:self action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[buttonMenu addTarget:self action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
	
	[buttonMenu setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin)];	
	
	// add button to view
	[buttonGroupView addSubview:buttonMenu];

	[buttonGroupView setAutoresizingMask:(UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin )];	
	[[self view] addSubview:buttonGroupView];
	
}

- (void)buttonTouchUp:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void)buttonTouchDown:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetOffWhite]];
}

- (void)buttonTouchUpOutside:(id)sender {
	NSLog(@"button state: %@", [buttonContinueGame state]);
	[sender setBackgroundColor:[SPCommon SPGetBlue]];
}

- (void)buttonContinueGameAction:(id)sender {
	[self dismissModalViewControllerAnimated:NO];
}

- (void)buttonMenuAction:(id)sender {
	[self quitGame];
}

- (void)quitGame {
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_quitGame object:nil];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return NO;
}


@end
