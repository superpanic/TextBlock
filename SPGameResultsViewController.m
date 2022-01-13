//
//  SPGameResultsViewController.m
//  TypeAttack
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPGameResultsViewController.h"
#import "SPListView.h"
#import "SPCommon.h"
#import "SPHiscoreListViewController.h"

@implementation SPGameResultsViewController

@synthesize listView;
@synthesize hiscoreListViewController;
@synthesize gameScreenRect;
@synthesize playerWords;
@synthesize playerName;
@synthesize playerScore;
@synthesize continueButton;
@synthesize gameCenterButton;
@synthesize facebookButton;

- (void)dealloc {
	[listView release];
	[hiscoreListViewController release];
	[buttonFont release];
	[continueButton release];
	[gameCenterButton release];
	[facebookButton release];
	[playerWords release];
	[playerName release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (id) init {
	if(self = [super init]) {
		// create a rect for whole screen
		gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

		// keyboard is not visible 
		keyboardVisible = NO;	

		// create the list view
		SPListView *temp_listView = [[SPListView alloc] 
					     initWithFrame:gameScreenRect 
					     cellHeight:(CGRectGetHeight(gameScreenRect) * 0.2)
					     ];
		[self setListView:temp_listView];
		[temp_listView release];
	}
	return self;
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView {
	[super loadView];
	
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];
	
	// add the list view to the view controllers main view
	[[self view] addSubview:listView];
	
	// button settings
	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width, gameScreenRect.size.height * 0.15);
	float padding = buttonSize.height / 25.0f;
	

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

- (void) showPlayerScore:(int)s words:(NSMutableArray *)w {
	playerScore = MAX(0, s);
	// this is a property - has to be retained in memory
	playerWords = [[NSArray arrayWithArray:w] retain];
	
	NSString *scoreString;
	scoreString = NSLocalizedString(@"RESULTS_SCORE", @"Title text for player score.");

	NSString *playerNameString;
	playerNameString = NSLocalizedString(@"RESULTS_PLAYER_NAME", @"Title text for player name.");

	NSString *longestWordString;
	longestWordString = NSLocalizedString(@"RESULTS_LONGEST_WORD", @"Title text for longest word.");
		
	[listView addCellWithTitle:scoreString info:[NSString stringWithFormat:@"%i", playerScore] textAlignment:UITextAlignmentCenter];
	// create a cell with input add self as observer for the keyboard 
	[listView addInputCellWithTitle:playerNameString info:[SPCommon readLastUsedName] textAlignment:UITextAlignmentCenter observer:self];
	[listView addCellWithTitle:longestWordString info:[SPCommon getLongestWordFromArray:playerWords] textAlignment:UITextAlignmentCenter];	
}

- (void) keyboardDidShow: (NSNotification *)notif {
	NSLog(@"### keyboardDidShow");
	// return if keyboard is already visible
	if(keyboardVisible) return;
	
	// Get the size of the keyboard.
	//NSDictionary* userInfo = [notif userInfo];
	//NSValue* aValue = [userInfo objectForKey:UIKeyboardBoundsUserInfoKey];
	//CGSize keyboardSize = [aValue CGRectValue].size;
	// print the keyboard size vars
	//NSLog(@"keyboard height: %f", keyboardSize.height);
	//NSLog(@"keyboard width: %f", keyboardSize.width);
	
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
	[SPCommon savePlayerScore:playerScore name:playerName words:playerWords];
	// Keyboard is now visible
	keyboardVisible = NO;	
	// show buttons
	[continueButton setHidden:NO];
	[facebookButton setHidden:NO];
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
	// create the hiscore list view controller
	SPHiscoreListViewController *temp_hiscoreListViewController = [[SPHiscoreListViewController alloc] init];
	[self setHiscoreListViewController:temp_hiscoreListViewController];
	[temp_hiscoreListViewController release];
	// push the hiscore list view controller
	[[self navigationController] pushViewController:hiscoreListViewController animated:NO];
}


- (void)buttonFacebookAction:(id)sender {
	NSLog(@"Post to Facebook!");
	// [[self navigationController] pushViewController:facebookViewController animated:NO];
}

- (void)buttonGameCenterAction:(id)sender {
	NSLog(@"Post to Game Center!");
	// [[self navigationController] pushViewController:gameCenterViewController animated:NO];
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
	return NO;
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


@end




