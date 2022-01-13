    //
//  SPHiscoreListViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPHiscoreListViewController.h"
#import "SPListView.h"
#import "SPCommon.h"
#import "SimpleAudioEngine.h"


@implementation SPHiscoreListViewController

@synthesize listView;
@synthesize continueButton;
@synthesize buttonFont;


- (void)dealloc {
	[listView release];
	[continueButton release];
	[buttonFont release];
	//[SimpleAudioEngine end];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
	
	// AUDIO
	if(!audioEngine) audioEngine = [SimpleAudioEngine sharedEngine];
		
	// if not defined - create a rect for whole screen
	gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
	
	// button settings
	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width, gameScreenRect.size.height * 0.15);
	float padding = buttonSize.height / 25.0f;	
	
	// create the list view
	SPListView *temp_listView = [[SPListView alloc] 
				     initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(gameScreenRect), CGRectGetHeight(gameScreenRect) - buttonSize.height ) 
				     cellHeight:(CGRectGetHeight(gameScreenRect) * 0.2)
				     ];
	[self setListView:temp_listView];
	[temp_listView release];
	
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];
	
	// read saved hiscores from iphone
	NSArray *hiscoreArray = [SPCommon readHiscores];
	
	NSString *bestWordString;
	bestWordString = NSLocalizedString(@"HISCORE_BEST_WORD", @"Title text for best word info.");

	//NSString *lettersString;
	//lettersString = NSLocalizedString(@"HISCORE_LETTERS", @"Title text for number of letters info.");
	
	// loop through all hiscores and create a list view cell
	int counter = 0;
	int maxHiscoreCells = kHiscoreDBMax;
	for(NSDictionary *aDict in hiscoreArray) {
		if(counter >= maxHiscoreCells) continue;
		NSString *playerRankAndNameString = [NSString stringWithFormat:@"#%i - %@", counter+1, [aDict objectForKey:@"name"]];
		NSString *hiscoreString = [NSString stringWithFormat:@"%i", [[aDict objectForKey:@"score"] intValue] ];
		int letterCount = [[aDict objectForKey:@"bestWordScore"] intValue];
		if(letterCount <= 1) letterCount = 0;
		NSString *numberOfLettersInBestWordString = [NSString stringWithFormat:@"%@: %i", bestWordString, letterCount];
		[listView addCellWithTitle:playerRankAndNameString info:hiscoreString smallInfo:[aDict objectForKey:@"longword"] smallTitle:numberOfLettersInBestWordString];
		counter++;
	}

	// add list view to main view
	[[self view] addSubview:listView];
	
	//***
	
	// button font
	buttonFont = [[UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.65f] retain];
	
	NSString *continueString;
	continueString = NSLocalizedString(@"HISCORE_CONTINUE", @"Button: continue to main menu.");
	
	// create and retain continue button
	continueButton = [[self 
			   createButtonWithTitle:continueString 
			   action:@selector(buttonContinueAction:) 
			   frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)] 
			  retain];
	
	// set continue button position
	[continueButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) - buttonSize.height * 0.5f)];
	
 	[[self view] addSubview:continueButton];
	
	int ranking = [SPCommon readLastRanking];
	if(ranking < maxHiscoreCells) {
		// tell listView to focus on current score cell (scroll down and put it on top of screen)
		[listView focusOnCell:ranking];
		[listView blinkCell:ranking];
	} else {
		[listView autoScrollToTopFromCell:nil finished:nil context:[NSNumber numberWithInt:maxHiscoreCells-1]];
	}
	
}


- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
	[[self view] setAlpha:0.0f];
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
	/*
	 // create the hiscore list view controller
	 SPHiscoreListViewController *temp_hiscoreListViewController = [[SPHiscoreListViewController alloc] init];
	 [self setHiscoreListViewController:temp_hiscoreListViewController];
	 [temp_hiscoreListViewController release];
	 // push the hiscore list view controller
	 [[self navigationController] pushViewController:hiscoreListViewController animated:NO];
	 */
	
	// fade out view animation
	[UIView beginAnimations:nil context:NULL]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f];
		// call [self newGame] to start the game
		[UIView setAnimationDidStopSelector:@selector(backToMenu)];
		[[self view] setAlpha:0.0f];
	} [UIView commitAnimations];
	
	[audioEngine fadeOutAndStopBackgroundMusic];
	
}

- (void)backToMenu {
	
	// BUG! Kolla om root view controller finns! om inte stanna här för att testa om det är det som går fel.
	
	//UIViewController *vc = [[[self navigationController] viewControllers] objectAtIndex:0];
	//NSLog(@"Root controller! %@", [vc description]);
	[[self navigationController] popToRootViewControllerAnimated:NO];	
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
