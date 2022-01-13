    //
//  SPGameTutorialAViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 07 Jan 2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#pragma mark -
#pragma mark import

#import "SPTutorialViewController.h"
#import "SPHandView.h"
#import "SPGameViewController.h"
#import "SPBlockViewLetter.h"
#import "SPLinesConnectingBlocksView.h"

#import "SimpleAudioEngine.h"

#import "SPCommon.h"


#pragma mark -
#pragma mark define

#define kBigTutorialFontSize 0.45f
#define kSmallTutorialFontSize 0.20f

// macro for getting ReSouRCe file path
#define RSRC(x) [[NSBundle mainBundle] pathForResource:x ofType:nil]



@implementation SPTutorialViewController

@synthesize hand;
@synthesize state;
@synthesize nextState;
@synthesize idleCounter;

@synthesize timer;

@synthesize tBlock1;
@synthesize eBlock;
@synthesize xBlock;
@synthesize tBlock2;

@synthesize tutorialTextLabelA;
@synthesize tutorialTextLabelB;
@synthesize tapToContinueTextLabel;
@synthesize scoreLabel;

@synthesize columnBlocks;

@synthesize gameViewController;

@synthesize connectingLinesView;

- (void)dealloc {
	[hand release];
	[gameViewController release];
	[connectingLinesView release];
	[timer release];
	
	[tBlock1 release];
	[eBlock release];
	[xBlock release];
	[tBlock2 release];
	
	[tutorialTextLabelA release];
	[tutorialTextLabelB release];
	[tapToContinueTextLabel release];
	[scoreLabel release];
	
	[columnBlocks release];

	// unload audio
	[self unloadAudio];
	
	// tell the audio engine to shut down
	//[SimpleAudioEngine end];
	
	// release all sound strings
	[soundOfCollidingBlocks release];
	[soundOfTouchingBlock release];
	[soundOfDissapearingBlock release];
	[soundOfRevealedScore release];
	
	[super dealloc];
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc. that aren't in use.
}



- (void)viewDidUnload {
	[super viewDidUnload];
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
	
	[hand release];
	hand = nil;
	
	[tBlock1 release];
	tBlock1 = nil;
	[eBlock release];
	eBlock = nil;
	[xBlock release];
	xBlock = nil;
	[tBlock2 release];
	tBlock2 = nil;
	
	[tutorialTextLabelA release];
	tutorialTextLabelA = nil;

	[tutorialTextLabelB release];
	tutorialTextLabelB = nil;
	
	[tapToContinueTextLabel release];
	tapToContinueTextLabel = nil;
	
	[scoreLabel release];
	scoreLabel = nil;
		
	[columnBlocks release];
	columnBlocks = nil;
	
	[connectingLinesView release];
	connectingLinesView = nil;
	
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
	[super loadView];
		
	
	// AUDIO
	// get pointer to the singleton sound engine
	if(!audioEngine) audioEngine = [SimpleAudioEngine sharedEngine];
	
	soundOfCollidingBlocks = [[NSString stringWithString:RSRC(@"blockhit.wav")] retain];
	NSLog(@"soundOfCollidingBlocks: %@", soundOfCollidingBlocks);
	[audioEngine preloadEffect:soundOfCollidingBlocks];

	soundOfTouchingBlock = [[NSString stringWithString:RSRC(@"touch.wav")] retain];
	NSLog(@"soundOfTouchingBlock: %@", soundOfTouchingBlock);
	[audioEngine preloadEffect:soundOfTouchingBlock];
	
	soundOfDissapearingBlock = [[NSString stringWithString:RSRC(@"acceptword.wav")] retain];
	NSLog(@"soundOfDissapearingBlock: %@", soundOfDissapearingBlock);
	[audioEngine preloadEffect:soundOfDissapearingBlock];

	soundOfRevealedScore = [[NSString stringWithString:RSRC(@"revealscore.wav")] retain];
	NSLog(@"soundOfRevealedScore: %@", soundOfRevealedScore);
	[audioEngine preloadEffect:soundOfRevealedScore];

	// AUDIO END
	
	
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];
	
	// size of main screen
	screenSize = [[UIScreen mainScreen] bounds].size;
	// calculate dunamic block size
	blockSize = screenSize.width / kBlockColumns;

	// used for block base position on screen
	blockGoalPos = screenSize.height * 0.72;

	score = 0;
	displayScore = 0;
	
	[self setIdleCounter:0];
	
	// create the  T E X T  blocks
	if(!tBlock1) {
		SPBlockViewLetter *temp_tBlock1 = [[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:@"T" points:2 * kBlockValueMultiplier];
		[self setTBlock1:temp_tBlock1];
		[temp_tBlock1 release];
		[[tBlock1 view] setHidden:YES];
		[[self view] addSubview:[tBlock1 view]];
	}
	
	if(!eBlock) {
		SPBlockViewLetter *temp_eBlock = [[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:@"E" points:2 * kBlockValueMultiplier];
		[self setEBlock:temp_eBlock];
		[temp_eBlock release];
		[[eBlock view] setHidden:YES];
		[[self view] addSubview:[eBlock view]];
	}

	
	if(!xBlock) {
		SPBlockViewLetter *temp_xBlock = [[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:@"X" points:4 * kBlockValueMultiplier];
		[self setXBlock:temp_xBlock];
		[temp_xBlock release];
		[[xBlock view] setHidden:YES];
		[[self view] addSubview:[xBlock view]];
	}
	
	if(!tBlock2) {
		SPBlockViewLetter *temp_tBlock2 = [[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:@"T" points:2 * kBlockValueMultiplier];
		[self setTBlock2:temp_tBlock2];
		[temp_tBlock2 release];
		[[tBlock2 view] setHidden:YES];
		[[self view] addSubview:[tBlock2 view]];
	}
	
	if(!columnBlocks) {
		NSMutableArray *temp_columnBlocks =[[NSMutableArray alloc] initWithCapacity:kBlockRows];
		[self setColumnBlocks:temp_columnBlocks];
		[temp_columnBlocks release];

		char letters[26] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
		int lettersLength = 26;
	
		// create the array of column blocks
		for( int i = 0; i < kBlockRows; i++ ) {
			int randomIndex = arc4random() % ( lettersLength-1 );
			char letter = letters[randomIndex];
			SPBlockViewLetter *tempBlock = [[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:[NSString stringWithFormat:@"%C", letter] points:1];
			[columnBlocks addObject:tempBlock];
			[tempBlock release];
			[[[columnBlocks lastObject] view] setHidden:YES];
			[[self view] addSubview:[[columnBlocks lastObject] view]];
		}
	}
	
	// get localized tutorial string
	// [NSLocalizedString(@"TUTORIAL_1", @"Tutorial text 1") retain];
	
	// create the tutorial text label
	if(!tutorialTextLabelA) {

		CGRect f = CGRectMake(0.0f, screenSize.height / 10.0f, screenSize.width, screenSize.height);
		UILabel *temp_tutorialTextLabel = [[UILabel alloc] initWithFrame:f];
		[self setTutorialTextLabelA:temp_tutorialTextLabel];
		[temp_tutorialTextLabel release];
		
		[tutorialTextLabelA setBackgroundColor:[UIColor clearColor]];
		[tutorialTextLabelA setTextColor:[SPCommon SPGetOffWhite]];
		[tutorialTextLabelA setFont:[UIFont fontWithName:@"Helvetica-Bold" size:blockSize * kBigTutorialFontSize]];
		
		[tutorialTextLabelA setText:NSLocalizedString(@"TUTORIAL_1", @"Tutorial text 1")];
		[tutorialTextLabelA setNumberOfLines:0];
		// [tutorialTextLabel sizeToFit];
		[tutorialTextLabelA setTextAlignment:UITextAlignmentCenter];
		
		[[self view] addSubview:tutorialTextLabelA];
	}
	[tutorialTextLabelA setHidden:YES];
	[tutorialTextLabelA setAlpha:0.0f];
	
	// create the tutorial text label
	if(!tutorialTextLabelB) {
		
		CGRect f = CGRectMake(0.0f, screenSize.height / 10.0f, screenSize.width, screenSize.height);
		UILabel *temp_tutorialTextLabelB = [[UILabel alloc] initWithFrame:f];
		[self setTutorialTextLabelB:temp_tutorialTextLabelB];
		[temp_tutorialTextLabelB release];
		
		[tutorialTextLabelB setBackgroundColor:[UIColor clearColor]];
		[tutorialTextLabelB setTextColor:[SPCommon SPGetOffWhite]];
		[tutorialTextLabelB setFont:[UIFont fontWithName:@"Helvetica-Bold" size:blockSize * kBigTutorialFontSize]];
		
		[tutorialTextLabelB setText:NSLocalizedString(@"TUTORIAL_2", @"Tutorial text 2")];
		[tutorialTextLabelB setNumberOfLines:0];
		[tutorialTextLabelB setTextAlignment:UITextAlignmentCenter];
		
		[[self view] addSubview:tutorialTextLabelB];
	}
	[tutorialTextLabelB setHidden:YES];
	[tutorialTextLabelB setAlpha:0.0f];
	
	if(!tapToContinueTextLabel) {
		UIFont *tapToContinueTextFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * kSmallTutorialFontSize];
		float fHeight = [tapToContinueTextFont ascender] + [tapToContinueTextFont descender];
		CGRect f = CGRectMake(0.0f, screenSize.height - screenSize.height / 10.0f, screenSize.width, fHeight * 2.0f);
		UILabel *temp_tapToContinueTextLabel = [[UILabel alloc] initWithFrame:f];
		[self setTapToContinueTextLabel:temp_tapToContinueTextLabel];
		[temp_tapToContinueTextLabel release];
		
		[tapToContinueTextLabel setBackgroundColor:[UIColor clearColor]];
		[tapToContinueTextLabel setTextColor:[SPCommon SPGetOffWhite]];
		[tapToContinueTextLabel setFont:tapToContinueTextFont];
		[tapToContinueTextLabel setText:NSLocalizedString(@"TAP_SCREEN_TO_SKIP_TUTORIAL", @"Tap screen to continue / skip the tutorial")];
		[tapToContinueTextLabel setTextAlignment:UITextAlignmentCenter];
		[[self view] addSubview:tapToContinueTextLabel];
	}

	if(!scoreLabel) {
		// font
		UIFont *fnt = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.60f];		
		// white background frame
		CGSize textSize = [@"888" sizeWithFont:fnt];
		float framePadding = blockSize * 0.2;
		
		// frame size
		CGRect f = CGRectMake(screenSize.width * 0.5f - textSize.width * 0.5f - framePadding, 
				      blockGoalPos - blockSize * 3.0f, 
				      textSize.width + framePadding * 2.0f, 
				      textSize.height);
				
		// score label
		UILabel *temp_scoreLabel = [[UILabel alloc] initWithFrame:f];
		[self setScoreLabel:temp_scoreLabel];
		[temp_scoreLabel release];
				
		[scoreLabel setBackgroundColor:[SPCommon SPGetOffWhite]];
		[scoreLabel setTextColor:[SPCommon SPGetRed]];
		[scoreLabel setFont:fnt];
		[scoreLabel setTextAlignment:UITextAlignmentCenter];
		
		[[scoreLabel layer] setCornerRadius:blockSize * 0.05];
		
		[[self view] addSubview:scoreLabel];
	}
	[scoreLabel setText:@""];
	[scoreLabel setHidden:YES];
	//[scoreLabel setAlpha:0.0f];
	
	// create the hand
	if(!hand) {
		SPHandView *tempHand = [[SPHandView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize * 1.0f, blockSize * 1.0f)];
		[self setHand:tempHand];
		[tempHand release];		
		// add hand to main view
		[[self view] addSubview:hand];
	}

	[hand setHidden:YES];
	
	
	if(!connectingLinesView) {
		SPLinesConnectingBlocksView *temp_connectingLinesView = [[SPLinesConnectingBlocksView alloc] initWithFrame:[[self view] frame] blockSize:blockSize];
		[self setConnectingLinesView:temp_connectingLinesView];
		[temp_connectingLinesView release];
		
		[[self view] addSubview:connectingLinesView];
	}
	
	
}


- (void)adjustTutorialTextLabelPosition:(UILabel *)tl {
	// find the new height
	CGRect labelrect = [tl textRectForBounds:tl.bounds limitedToNumberOfLines:5];
	// reset the height
	CGRect f = tl.frame;
	f.size.height = labelrect.size.height;
	tl.frame = f;
	// position
	[tl setCenter:CGPointMake(screenSize.width * 0.5, ( screenSize.height / 8.0f) + (f.size.height * 0.5f) )];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}


- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];

	isSceneActive = YES;
	
	// create and reset the main game view
	if(gameViewController) {
		NSLog(@"R E S E T   G A M E");
		NSLog(@"Setting game view controller to nil.");
		[gameViewController release];
		gameViewController = nil;
	}
		
	// create the main view controller (preload here, it takes too long too load when user tap the screen)
	SPGameViewController *temp_gameViewController = [[SPGameViewController alloc] init];
	[self setGameViewController:temp_gameViewController];
	[temp_gameViewController release];
	
	[gameViewController setTitle:@"The Game View Controller"];
	
	
	

	// hide main view (fade in later)
	[[self view] setAlpha:0.0f];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	// fade in main view
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[[self view] setAlpha:1.0f];
	[UIView commitAnimations];
	
	
	if(timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	state = kStart;
	nextState = kStart;
	
	// start a running game loop - the method [self run:(NSTimer*)t] will be called kFramesPerSecond
	NSTimer *temp_timer = [ [ NSTimer scheduledTimerWithTimeInterval:kFramesPerSecond target:self selector:@selector( run: ) userInfo:nil repeats:YES ] retain];
	// save the timer object
	[self setTimer:temp_timer];
	// release the temporary timer object
	[temp_timer release];
}


- (void) playSoundOfCollidingBlocks {
	[audioEngine playEffect:soundOfCollidingBlocks];
}


- (void) run:(NSTimer*)t {
	// this will loop kFramesPerSecond
	switch (state) {
		case kStart: {
			state = kTutorialA1;
			break;
		}
			
		case kTutorialA1: {
			
			// display tutorial text label
			[self adjustTutorialTextLabelPosition:tutorialTextLabelA];
			[tutorialTextLabelA setAlpha:0.0f];
			[tutorialTextLabelA setHidden:NO];
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDuration:0.5];
				[tutorialTextLabelA setAlpha:1.0f];
			} [UIView commitAnimations];
			
			// position the letter blocks
			[[tBlock1 view] setCenter:CGPointMake(screenSize.width * 0.5f - blockSize * 0.5f, -(blockSize*0.5f))];
			[[eBlock view]  setCenter:CGPointMake(screenSize.width * 0.5f + blockSize * 0.5f, -(blockSize*0.5f))];
			[[xBlock view]  setCenter:CGPointMake(screenSize.width * 0.5f - blockSize * 0.5f, -(blockSize*0.5f))];
			[[tBlock2 view] setCenter:CGPointMake(screenSize.width * 0.5f + blockSize * 0.5f, -(blockSize*0.5f))];
			[[tBlock1 view] setHidden:NO];
			[[eBlock view]  setHidden:NO];
			[[xBlock view]  setHidden:NO];
			[[tBlock2 view] setHidden:NO];
			
			float animationDelay = 0.0f;
			
			// start animations
			animationDelay = animationDelay + 0.5f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:animationDelay];
				//////////////////////////////////////////
				[UIView setAnimationDuration:0.5f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[[tBlock1 view] setCenter:CGPointMake([[tBlock1 view] center].x, blockGoalPos)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(playSoundOfCollidingBlocks)];
			} [UIView commitAnimations];
			
			animationDelay = animationDelay + 0.5f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:animationDelay];
				//////////////////////////////////////////
				[UIView setAnimationDuration:0.5f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[[eBlock view] setCenter:CGPointMake([[eBlock view] center].x, blockGoalPos)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(playSoundOfCollidingBlocks)];
			} [UIView commitAnimations];

			animationDelay = animationDelay + 0.5f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:animationDelay];
				//////////////////////////////////////////
				[UIView setAnimationDuration:0.5f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[[xBlock view] setCenter:CGPointMake([[xBlock view] center].x, blockGoalPos - blockSize)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(playSoundOfCollidingBlocks)];
			} [UIView commitAnimations];

			animationDelay = animationDelay + 0.5f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:animationDelay];
				//////////////////////////////////////////
				[UIView setAnimationDuration:0.5f];
				[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
				[[tBlock2 view] setCenter:CGPointMake([[tBlock2 view] center].x, blockGoalPos - blockSize)];
				[UIView setAnimationDelegate:self];
				[UIView setAnimationDidStopSelector:@selector(playSoundOfCollidingBlocks)];
			} [UIView commitAnimations];
						
			animationDelay = animationDelay + 1.0f;
			
			[self runNextState:kTutorialA2 inSeconds:animationDelay];
			
			break;
		}
			
		case kTutorialA2:
			
			// position hand outside screen
			[hand setCenter:CGPointMake(screenSize.width + [hand bounds].size.width * 0.5f, blockGoalPos - blockSize)];
			[hand setHidden:NO];
			
			float animationDelay = 0.0f;
			
			// move hand
			animationDelay = animationDelay + 0.5f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDuration:0.5f];
				// move the hand to position
				[hand setCenter:CGPointMake(screenSize.width * 0.5f + blockSize * 1.5f, blockGoalPos - blockSize)];
			}
			[UIView commitAnimations];
			
			
			// rotate hand
			animationDelay = animationDelay + 1.0f;
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:animationDelay];
				//////////////////////////////////////////
				[UIView setAnimationDuration:0.25];
				// make a rotation transform
				CGAffineTransform transform = CGAffineTransformMakeRotation(-0.25*M_PI);
				// apply the rotation transform to the hand
				hand.transform = transform;
			}
			[UIView commitAnimations];
			
			// fade out tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDuration:0.25];
				[tutorialTextLabelA setAlpha:0.0f];
			}
			[UIView commitAnimations];
			
			// prepare tutorial text B
			[tutorialTextLabelB setText:NSLocalizedString(@"TUTORIAL_2", @"Tutorial text 2")];
			[self adjustTutorialTextLabelPosition:tutorialTextLabelB];
			[tutorialTextLabelB setAlpha:0.0f];
			[tutorialTextLabelB setHidden:NO];
			// fade in tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:0.25f];
				[UIView setAnimationDuration:0.25f];
				[tutorialTextLabelB setAlpha:1.0f];
			}
			[UIView commitAnimations];
			
			
			animationDelay = animationDelay + 0.5f;
			
			[self runNextState:kTutorialA3 inSeconds:animationDelay];

			break;
		
		case kTutorialA3:
			
			
			// do touch animation
			[self createHandAnimation];
			
			[self runNextState:kTutorialA4 inSeconds:5.0f];
			
			break;
			
		case kTutorialA4: {
		
			
			// fade out tutorial text B
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDuration:0.25];
				[tutorialTextLabelB setAlpha:0.0f];
			}
			[UIView commitAnimations];
			
			// prepare tutorial text A
			[tutorialTextLabelA setText:NSLocalizedString(@"TUTORIAL_3", @"Tutorial text 3")];
			[self adjustTutorialTextLabelPosition:tutorialTextLabelB];
			[tutorialTextLabelA setAlpha:0.0f];
			[tutorialTextLabelA setHidden:NO];
			// fade in tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:0.25f];
				[UIView setAnimationDuration:0.25f];
				[tutorialTextLabelA setAlpha:1.0f];
			}
			[UIView commitAnimations];
			
						
			[scoreLabel setText:@"000"];
			[scoreLabel setAlpha:0.0f];
			[scoreLabel setHidden:NO];
			[scoreLabel setCenter:CGPointMake(screenSize.width * 0.5, blockGoalPos - blockSize * 1.5f)];
			[UIView beginAnimations:@"fadeInScore" context:NULL]; {
				[UIView setAnimationDelay:0.25f];
				[UIView setAnimationDuration:0.25];
				[scoreLabel setAlpha:1.0f];
				[scoreLabel setCenter:CGPointMake(screenSize.width * 0.5, blockGoalPos - blockSize * 2.5f)];
			}
			[UIView commitAnimations];
			
			[self runNextState:kTutorialA5 inSeconds:2.0f];
			
			break;
		}
			
		case kTutorialA5: {
			
			[connectingLinesView clearPath];
			
			float scoreDelay = 0.0f;
			
			//NSTimer *st1 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:tBlock1 selector:@selector( revealScore ) userInfo:nil repeats:NO ];
			NSTimer *st1 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:self selector:@selector( shrinkBlock: ) userInfo:tBlock1 repeats:NO ];
			// avoid compiler warning: unused variable
#pragma unused(st1)
			scoreDelay = scoreDelay + 0.2f;
						
			//NSTimer *st2 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:eBlock  selector:@selector( revealScore ) userInfo:nil repeats:NO ];
			NSTimer *st2 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:self selector:@selector( shrinkBlock: ) userInfo:eBlock repeats:NO ];
			// avoid compiler warning: unused variable
#pragma unused(st2)
			scoreDelay = scoreDelay + 0.2f;

			// NSTimer *st3 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:xBlock  selector:@selector( revealScore ) userInfo:nil repeats:NO ];
			NSTimer *st3 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:self selector:@selector( shrinkBlock: ) userInfo:xBlock repeats:NO ];
			// avoid compiler warning: unused variable
#pragma unused(st3)
			scoreDelay = scoreDelay + 0.2f;

			// NSTimer *st4 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:tBlock2 selector:@selector( revealScore ) userInfo:nil repeats:NO ];
			NSTimer *st4 = [ NSTimer scheduledTimerWithTimeInterval:scoreDelay target:self selector:@selector( shrinkBlock: ) userInfo:tBlock2 repeats:NO ];
			// avoid compiler warning: unused variable
#pragma unused(st4)
			
			// hide the block after timer delay 
			NSTimer *hideScoreTimer = [ NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector( hideScoreLabel ) userInfo:nil repeats:NO ];	
#pragma unused(hideScoreTimer)
			
			[UIView beginAnimations:@"handAnimationFadeOut" context:NULL]; {
				[UIView setAnimationDelay:5.0f];
				[UIView setAnimationDuration:0.3f];
				[hand setAlpha:0.0f];
				[hand setCenter:CGPointMake(screenSize.width + [hand frame].size.width, [hand center].y)];
			}
			[UIView commitAnimations];
			
			
			// fade out tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:5.0f];
				[UIView setAnimationDuration:0.25];
				[tutorialTextLabelA setAlpha:0.0f];
			}
			[UIView commitAnimations];
			
			// prepare tutorial text B
			[tutorialTextLabelB setText:NSLocalizedString(@"TUTORIAL_4", @"Tutorial text 4")];
			//[self adjustTutorialTextLabelPosition:tutorialTextLabelB];
			[tutorialTextLabelB setAlpha:0.0f];
			[tutorialTextLabelB setHidden:NO];
			// fade in tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:5.3f];
				[UIView setAnimationDuration:0.25f];
				[tutorialTextLabelB setAlpha:1.0f];
			}
			[UIView commitAnimations];
			
			[self runNextState:kTutorialA6 inSeconds:7.5f];
			
			break;
		}
			
		case kTutorialA6: {
			// fade out tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:0.0f];
				[UIView setAnimationDuration:0.25];
				[tutorialTextLabelB setAlpha:0.0f];
			}
			[UIView commitAnimations];
			
			// prepare tutorial text B
			[tutorialTextLabelA setText:NSLocalizedString(@"TUTORIAL_6", @"Tutorial text 6")];
			//[self adjustTutorialTextLabelPosition:tutorialTextLabelB];
			[tutorialTextLabelA setAlpha:0.0f];
			[tutorialTextLabelA setHidden:NO];
			// fade in tutorial text
			[UIView beginAnimations:nil context:NULL]; {
				[UIView setAnimationDelay:0.3];
				[UIView setAnimationDuration:0.25f];
				[tutorialTextLabelA setAlpha:1.0f];
			}
			[UIView commitAnimations];
			
			[self runNextState:kStartGame inSeconds:1.5f];
			
			break;
		}

		case kStartGame: {
			// pause this run loop
			[self setState:kPause];
			// start game
			[self newGameWithTransition];
			break;
		}

		case kPrintScoreState:
			if(![self printScore]) [self setState:kPause];
			break;
			
		case kWaitForNextState:
			if(idleCounter > 0) idleCounter--;
			else [self setState:nextState];
			break;
			
		case kPause:
			// do nothing
			break;
			
		default:
			break;
	}
}

- (void) runNextState:(State)sta inSeconds:(float)sec {
	[self setState:kPause];	
	NSNumber *staInt = [NSNumber numberWithInt:sta];
	NSTimer *t = [ NSTimer scheduledTimerWithTimeInterval:sec target:self selector:@selector( setTimedState: ) userInfo:staInt repeats:NO ];
	// avoid compiler warning: unused variable
#pragma unused(t)	
}

- (void) setTimedState:(NSTimer *)t {
	//NSNumber *n = [[t userInfo] objectAtIndex:0];
	int n = [[t userInfo] intValue];
	[self setState: n];
}


- (void) createHandAnimation {
	
	// create a keyframe animation to follow a path
	CAKeyframeAnimation *tapAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];	
	[tapAnimation setRemovedOnCompletion:YES];
	
	CGFloat animationDuration = 4.0f;
	[tapAnimation setDuration:animationDuration];
	[tapAnimation setCalculationMode:kCAAnimationLinear];
	
	// create the path for the animation
	CGMutablePathRef thePath = CGPathCreateMutable();
	
	// used later when we need to calculate index finger as center
	CGPoint fingerOffset = CGPointMake([hand frame].size.width * 0.3f, -[hand frame].size.height * 0.2f); 
	
	// used for animation key timing
	NSMutableArray *timeKeyValues = [NSMutableArray arrayWithCapacity:11];
	
	// ### OBSERVE! It seems like an arc uses one KEYFRAME per quarter - even if it is added as one path!
	
	// place hand at current pos
	CGPathMoveToPoint(thePath, NULL, [hand center].x, [hand center].y);
	// start
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.0f]];
	
	// move to tBlock1
	CGPathAddLineToPoint(thePath, NULL, 
			     [[tBlock1 view] center].x + fingerOffset.x, 
			     [[tBlock1 view] center].y + fingerOffset.y );
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.1f]];
	
	NSTimer *t1 = [ NSTimer scheduledTimerWithTimeInterval:0.1f * animationDuration target:self selector:@selector( touchBlockWithConnectingLine: ) userInfo:tBlock1 repeats:NO ];	
	// avoid compiler warning: unused variable
#pragma unused(t1)
	
	
	// move hand to eBlock
	float rad = blockSize * 0.5f;
	CGPathAddArc(thePath, NULL, 
		     [[tBlock1 view] center].x + fingerOffset.x + rad, 
		     [[tBlock1 view] center].y + fingerOffset.y, 
		     rad, M_PI, 0.0f, NO);
	
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.1f]];
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.2f]];
	// stay
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.3f]];
	
	NSTimer *t2 = [ NSTimer scheduledTimerWithTimeInterval:0.3f * animationDuration target:self selector:@selector( touchBlockWithConnectingLine: ) userInfo:eBlock repeats:NO ];	
	// avoid compiler warning: unused variable
#pragma unused(t2)
	
	
	// move hand to xBlock
	rad = [SPCommon distanceBetweenPointA:[[eBlock view] center] pointB:[[xBlock view] center]] * 0.5f;
	// rad = blockSize * 0.5f;
	CGPathAddArc(thePath, NULL, 
		     screenSize.width * 0.5f + fingerOffset.x, 
		     blockGoalPos - blockSize * 0.5 + fingerOffset.y, 
		     rad, M_PI * 0.25f, M_PI * 1.25f, YES);
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.3f]];
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.4f]];
	// stay
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.5f]];
	
	NSTimer *t3 = [ NSTimer scheduledTimerWithTimeInterval:0.5f * animationDuration target:self selector:@selector( touchBlockWithConnectingLine: ) userInfo:xBlock repeats:NO ];	
	// avoid compiler warning: unused variable
#pragma unused(t3)
	
	
	// move hand to last tBlock2
	rad = blockSize * 0.5f;
	CGPathAddArc(thePath, NULL, 
		     screenSize.width * 0.5f + fingerOffset.x, 
		     blockGoalPos - blockSize + fingerOffset.y, 
		     rad, M_PI * 1.0f, M_PI * 0.0f, NO);
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.5f]];
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.5f]];
	// stay
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.6f]];
	
	
	// lift hand
	rad = blockSize * 0.3f;
	CGPathAddArc(thePath, NULL, 
		     [[tBlock2 view] center].x + fingerOffset.x + rad, 
		     blockGoalPos - blockSize + fingerOffset.y, 
		     rad, M_PI * 1.0f, M_PI * 1.5f, NO);
	
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.7f]];
	
	NSTimer *t4 = [ NSTimer scheduledTimerWithTimeInterval:0.7f * animationDuration target:self selector:@selector( touchBlockWithConnectingLine: ) userInfo:tBlock2 repeats:NO ];	
	// avoid compiler warning: unused variable
#pragma unused(t4)
	
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.7f]];
	// stay
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.8f]];
	
	// move to side
	CGPathAddLineToPoint(thePath, NULL, screenSize.width * 0.5f + blockSize * 1.5f, blockGoalPos - blockSize + fingerOffset.y - rad);
	// move
	[timeKeyValues addObject:[NSNumber numberWithFloat:0.9f]];
	// goal pos
	[timeKeyValues addObject:[NSNumber numberWithFloat:1.0f]];
		
	[tapAnimation setKeyTimes:timeKeyValues];
	
	[tapAnimation setPath:thePath];
	CGPathRelease(thePath);
	
	// set delegate to self to catch animation ended event
	[tapAnimation setDelegate:self];
	
	// add (start) animation to hand layer
	[[hand layer] addAnimation:tapAnimation forKey:nil];
	
	// move hand to final position (will show here when animation is finished)
	[hand setCenter:CGPointMake(screenSize.width * 0.5f + blockSize * 1.5f, blockGoalPos - blockSize + fingerOffset.y - rad)];
	
}

- (void)touchBlockWithConnectingLine:(NSTimer *)t {
	if(!isSceneActive) return;
	// unwrap user info
	// THIS NEEDS SAFETY WRAPPING:
	SPBlockViewLetter *b = [t userInfo];
	[b touchBlock];
	// ###
	
	[audioEngine playEffect:soundOfTouchingBlock];
	
	[connectingLinesView addLineAtXPos:[[b view] center].x yPos:[[b view] center].y];
	
}


- (void) hideScoreLabel {
	if(!isSceneActive) return;
	// hide tutorial text and hide score label
	[UIView beginAnimations:@"hideScoreLabel" context:NULL]; {
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationDuration:0.2f];
		[scoreLabel setAlpha:0.0f];
		[scoreLabel setCenter:CGPointMake([scoreLabel center].x, [scoreLabel center].y - blockSize * 0.5f)];
	}
	[UIView commitAnimations];
}

// 1
- (void) shrinkBlock:(NSTimer *)t {
	if(!isSceneActive) return;
	SPBlockViewLetter *b = [t userInfo];
	
	CGAffineTransform transformScale;
	
	transformScale = CGAffineTransformMakeScale(0.1f, 0.1f);
	
	// start shrink animation
	[UIView beginAnimations:@"shrink" context:b]; {	
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(revealBlockScore:finished:context:)];
		[UIView setAnimationDuration:0.25f];
		// merge the transformations
		[[b view] setTransform:transformScale];
	}	
	[UIView commitAnimations];	
}

// 2
- (void) revealBlockScore:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if(!isSceneActive) return;

	SPBlockViewLetter *b = context;
	
	// print score
	score = score + [b score];
	[self setState:kPrintScoreState];
	
	// tell block to reveal the score
	[b revealScore];
	
	CGAffineTransform transformScale;
	transformScale = CGAffineTransformMakeScale(1.0f, 1.0f);
	
	// start grow animation
	[UIView beginAnimations:@"revealScore" context:b]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideBlock:finished:context:)];
		[UIView setAnimationDuration:0.25f];
		// merge the transformations
		[[b view] setTransform:transformScale];
	}
	[UIView commitAnimations];
	// ### play sound
	[audioEngine playEffect:soundOfRevealedScore];	

}

// 3
- (void) hideBlock:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if(!isSceneActive) return;

	// create and assign a block object
	SPBlockViewLetter *b = context;	
	// hide the block after timer delay 
	//NSTimer *tr = [ NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector( shrinkBlock: ) userInfo:b repeats:NO ];	

	// hide the block after timer delay 
	NSTimer *tr = [ NSTimer scheduledTimerWithTimeInterval:3.0f target:b selector:@selector( fadeOutBlockView ) userInfo:nil repeats:NO ];	
#pragma unused(tr)
}

- (BOOL) printScore {
	if(!isSceneActive) return NO;

	if(displayScore == score) return NO;
	/*
	if([scoreLabel isHidden]) {
		[scoreLabel setHidden:NO];
	}
	 */
	if(displayScore + 2 >= score) displayScore = score;
	else displayScore = displayScore + 2;
	NSString *scoreString = [NSString stringWithFormat:@"%02d", displayScore];
	[scoreLabel setText:scoreString];
	return YES;
}



- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag {
	//Animation delegate method called when the animation's finished:
	// restore the transform and reenable user interaction
	//	placardView.transform = CGAffineTransformIdentity;
	//	self.userInteractionEnabled = YES;
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
 	CGPoint p = [touch locationInView:[self view]];
#pragma unused(p)
	// kill the run loop
	[timer invalidate];
	// fade out view animation
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f];
		// call [self newGame] to start the game
		[UIView setAnimationDidStopSelector:@selector(newGame)];
		[[self view] setAlpha:0.0f];
	[UIView commitAnimations];
}


- (void)newGameWithTransition {
	// fade out view animation
	[UIView beginAnimations:nil context:NULL]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f];
		// call [self newGame] to start the game
		[UIView setAnimationDidStopSelector:@selector(newGame)];
		[[self view] setAlpha:0.0f];
	}
	[UIView commitAnimations];
}


- (void)unloadAudio {
	// unload audio
	[audioEngine unloadEffect:soundOfCollidingBlocks];
	[audioEngine unloadEffect:soundOfTouchingBlock];
	[audioEngine unloadEffect:soundOfDissapearingBlock];
	[audioEngine unloadEffect:soundOfRevealedScore];	
}

- (void)newGame {
	
	isSceneActive = NO;
	
	// end this run loop and start game
	if(timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	// unload audio
	[self unloadAudio];
	
	// start new game
	if(gameViewController) {
		[[self navigationController] pushViewController:gameViewController animated:NO];
		
		[gameViewController release];
		gameViewController = nil;
	}
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return NO;
}

@end
