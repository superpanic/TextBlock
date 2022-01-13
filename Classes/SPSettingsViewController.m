//
//  GameSettingsViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-08-15.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import "SPSettingsViewController.h"
#import "SPCommon.h"

@implementation SPSettingsViewController

@synthesize gameScreenRect;
//@synthesize switchRandomChars;
@synthesize buttonFont;
@synthesize englishButton;
@synthesize swedishButton;
@synthesize backButton;


- (void)dealloc {
	//[switchRandomChars release];
	[buttonFont release];
	[backButton release];
	[swedishButton release];
	[englishButton release];
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	/*
	float testVal = 1.75;
	int counter = 0;
	while (testVal > 0.01) {
		testVal = testVal * 0.995;
		NSLog(@"%i: %f", counter, testVal);
		counter++;
	}
	*/
	
	NSLog(@"SPSettingsViewController loadView");
	
	[super loadView];

	// create a rect for whole screen
	gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);

	// set background color
	[[self view] setBackgroundColor:[SPCommon SPGetBlue]];	

	//***

	// button settings
	CGSize buttonSize = CGSizeMake(gameScreenRect.size.width, gameScreenRect.size.height * 0.15);
	float padding = buttonSize.height / 25.0f;
	
	// button font
	buttonFont = [[UIFont fontWithName:@"Helvetica-Bold" size:buttonSize.height * 0.65f] retain];
	
	
	
	
	
	NSString *backString;
	backString = NSLocalizedString(@"SETTINGS_BACK", @"Button text: go back to the title screen.");
	
	// create and retain continue button
	backButton = [[self 
			   createButtonWithTitle:backString 
			   action:@selector(buttonBackAction:) 
			   frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding)] 
			  retain];
	
	[backButton setBackgroundColor:[SPCommon SPGetRed]];
	
	// set continue button position at bottom of screen
	[backButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) - buttonSize.height * 0.5f)];
	
 	[[self view] addSubview:backButton];
	

	
	
	// create the english button
	NSString *englishString;
	englishString = NSLocalizedString(@"LANGUAGE_ENGLISH", @"Button text: sets game language to english.");
	
	// create and retain continue button
	englishButton = [[SPCommon 
			  createButtonWithTitle:englishString 
			  target:self 
			  action:@selector(buttonSetToEnglishAction:) 
			  frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding) font:buttonFont] 
			 retain];
	
	[englishButton setBackgroundColor:[SPCommon SPGetRed]];
	
	// set continue button position above center
	[englishButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) * 0.5 - buttonSize.height * 0.5)];			 
 	[[self view] addSubview:englishButton];
	

	// create the swedish button
	NSString *swedishString;
	swedishString = NSLocalizedString(@"LANGUAGE_SWEDISH", @"Button text: sets game language to swedish.");
	
	// create and retain continue button
	swedishButton = [[SPCommon 
			  createButtonWithTitle:swedishString 
			  target:self 
			  action:@selector(buttonSetToSwedishAction:) 
			  frame:CGRectMake(0.0f, 0.0f, buttonSize.width, buttonSize.height - padding) font:buttonFont] 
			 retain];
	
	[swedishButton setBackgroundColor:[SPCommon SPGetRed]];
	
	// set continue button position at center
	[swedishButton setCenter:CGPointMake( CGRectGetWidth(gameScreenRect) * 0.5f, CGRectGetHeight(gameScreenRect) * 0.5 + buttonSize.height * 0.5)];			 
 	[[self view] addSubview:swedishButton];
	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	[super viewDidLoad];
	
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
	[sender setBackgroundColor:[SPCommon SPGetRed]];
}

- (void)buttonTouchDown:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetOffWhite]];
}

- (void)buttonTouchUpOutside:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetRed]];
}

- (void)buttonBackAction:(id)sender {
	NSLog(@"BACK");
	/*
	 // create the hiscore list view controller
	 SPHiscoreListViewController *temp_hiscoreListViewController = [[SPHiscoreListViewController alloc] init];
	 [self setHiscoreListViewController:temp_hiscoreListViewController];
	 [temp_hiscoreListViewController release];
	 // push the hiscore list view controller
	 [[self navigationController] pushViewController:hiscoreListViewController animated:NO];
	 */
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buttonSetToEnglishAction:(id)sender {
	NSLog(@"ENGLISH");
	[SPCommon saveLanguageSettings:@"eng"];
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buttonSetToSwedishAction:(id)sender {
	NSLog(@"SWEDISH");	
	[SPCommon saveLanguageSettings:@"swe"];
	[self dismissModalViewControllerAnimated:YES];
}


/*
// Restore preferred time signature
int restoredSignature = [[NSUserDefaults standardUserDefaults] integerForKey:MetronomeTimeSignatureKey];
*/

/*
// Store user's time signature preference, so that it is used the next time the app is launched
[[NSUserDefaults standardUserDefaults] setInteger:self.timeSignature forKey:MetronomeTimeSignatureKey];
*/



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Overriden to allow any orientation.
	return NO;
}




@end

