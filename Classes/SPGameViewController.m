//
//  MainViewController.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-02-20.
//  Copyright 2010 Superpanic. All rights reserved.
//

#import "SPGameViewController.h"
#import "SPBlockView.h"
#import "SPBlockViewLetter.h"
#import "SPBlockViewTimeBomb.h"
#import "SPDictionary.h"
#import "SPLinesConnectingBlocksView.h"
#import "SPGameHeader.h"
#import "SPAreaLimitView.h"
#import "SPGameResultsViewController.h"
#import "SPDropShadowView.h"
#import "SPChainBonusView.h"
#import "SPChainBonusAlertView.h"

#import "SPPauseViewController.h"

// #import "SPFloatingInfoBar.h"

/*
// audio
#import "Finch.h"
#import "Sound.h"
#import "RevolverSound.h"
*/

#import "SimpleAudioEngine.h"
 
#import "SPCommon.h"


#pragma mark -
#pragma mark defines


#define kStartingRows 4
#define kTouchedBlockDelay 1.0f
#define kTimeBombDelay 3.0f
#define kGravity 40.0f
#define kShortestWordLength 3

#define kGameOverTimerLimit 10.0

//
//#define kBombTriggerValue 3000
#define kBombTriggerValue 10000

#define kNumberOfLettersNeededToDropBomb 5

#define kMaxDropFrequency 0.2
#define kDropFrequencyMultiplier 0.97

#define kDropPauseTime 1.75
#define kDropPauseTimeLimit 0.5
#define kDropPauseTimeMultiplier 0.9990


// bonus timer
//#define kBonusTime 1.0
// #define kBlockValueMultiplier is defined in SPCommon
#define kBlockBonus 100

// macro for getting ReSouRCe file path
#define RSRC(x) [[NSBundle mainBundle] pathForResource:x ofType:nil]

#pragma mark -
#pragma mark implementation
@implementation SPGameViewController

#pragma mark -
#pragma mark synthesize object properties
@synthesize wordList;
@synthesize gameGrid;
@synthesize touchTimer;
@synthesize timer;
@synthesize timers;
@synthesize nextBlockLetter;
@synthesize selectedBlocks;
@synthesize connectingLines;
@synthesize gameHeader;
@synthesize blackMask;
@synthesize columnDropMarker;
@synthesize userWords;
@synthesize userWordScores;
@synthesize gameOverDisplay;

@synthesize gameResultsViewController;
@synthesize pauseViewController;

//@synthesize debugOutput;

#pragma mark -
#pragma mark synthesize flag properties
@synthesize isGameLoaded;
@synthesize isGamePaused;
@synthesize isGameOver;
@synthesize deviceOrientationChanged;
@synthesize deviceOrientationChangedWhileSelection;
@synthesize isUserTouchingBlock;
@synthesize isBlockDoubleTouched;
@synthesize isBlockSlideSelected;
@synthesize gameHeaderIsHidden;
@synthesize isBombActive;
@synthesize isNextBlockABomb;
@synthesize isBonusActive;
@synthesize isDropPaused;

#pragma mark -
#pragma mark bonus counter
@synthesize bonusCounter;
//@synthesize bonusTime;
@synthesize bonusChainCountDown;
@synthesize bonusView;
@synthesize bonusAlertView;
@synthesize wordScoreLabel;

#pragma mark -
#pragma mark synthesize value properties
@synthesize dropNextBlockAtTime;
@synthesize dropBlockFrequency;
@synthesize dropBlockPauseUntilTime;

@synthesize dropPauseTime;

@synthesize score;
@synthesize blockOffset;

@synthesize touchTimerTriggersAtDate;

// @synthesize lastOrientation;
@synthesize gameTimeStamp;

//@synthesize gameOverTimerLabels;


#pragma mark -
#pragma mark c arrays
// used to shake the whole game view when a block has fallen down
// float shakeViewOffsetValues[16] = { 0.0, 0.1, 0.2, 0.4, 0.6, 0.8, 1.0, 1.5, 2.0, 1.5, 1.0, 0.8, 0.6, 0.4, 0.2, 0.1 };
const float shakeViewOffsetValues[32] = { 0.0, 0.1, 0.2, 0.3, 0.39, 0.48, 0.56, 0.64, 0.72, 0.78, 0.84, 0.89, 0.93, 0.96, 0.99, 1.0, 1.0, 0.99, 0.97, 0.95, 0.91, 0.86, 0.81, 0.75, 0.68, 0.6, 0.52, 0.43, 0.33, 0.24, 0.14, 0.04 };
const float kShakeHeight = 4.0;
const int kShakeArraySize = 32;
int shakeCounters[kBlockColumns] = { 0 };


#pragma mark -
#pragma mark c functions
// Quick C function
SPGridPos SPGridPosMake(uint x, uint y) { SPGridPos p; p.x = x; p.y = y; return p; }


#pragma mark -
#pragma mark memory warnings and dealloc
- (void)dealloc {
	
	// remove all observers
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[wordList release];
	[gameGrid release];
	[touchTimer release];

	[timers release];
	
	[nextBlockLetter release];
	/* 
	 // There is no need to release or invalidate the timer object here as 'dealloc' would never be called if the timer object still owned a reference to this (self) object.
	if(timer)
		if([timer isValid]) 
			[timer invalidate];
	[timer release];
	*/
	
	[selectedBlocks release];
	[connectingLines release];
	[gameHeader release];
	[bonusView release];
	[bonusAlertView release];
	[wordScoreLabel release];
	
	[userWords release];
	[userWordScores release];
	[blackMask release];
	[columnDropMarker release];
	[gameResultsViewController release];
	[pauseViewController release];
	
	[gameOverDisplay release];

	// audio
	[self unloadAudio];
		
	// tell the audio engine class to shut down
	//[SimpleAudioEngine end];
	
	/* DON'T...
	// sound engine
	[soundEngine release];
	 audioEngine = nil;
	*/
	
	
	// sound paths
	[soundOfCollidingBlocks release];
	[soundOfNewBlock release];
	[soundOfTouchingBlock release];
	[soundOfDissapearingBlock release];
	[soundOfRevealedScore release];
	[soundOfFragExplosion release];
	[soundOfExplodingBlocks release];
	[soundOfChainBonus release];
	[soundOfWordBonus release];
		
//	[gameOverTimerLabels release];
	 
	[super dealloc];
}

- (void) didReceiveMemoryWarning {
	
	NSLog(@"\n\n didReceiveMemoryWarning %@\n\n", [self title]);
	
	// Releases the view if it doesn't have a superview.
	[super didReceiveMemoryWarning];
	// Release any cached data, images, etc that aren't in use.
}


- (void) viewDidUnload {
	NSLog(@"\n\n	viewDidUnload %@\n\n", [self title]);
	[super viewDidUnload];
	
	isGameLoaded = YES;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_quitGame object:nil];
	
	// release all block views and set them to nil
	for(NSArray *col in gameGrid) {
		for(SPBlockView *b in col) {
			if([b isEqual:[NSNull null]]) continue;
			[b destroyViews];
		}
	}

	// release the word list dictionary
	[wordList release];
	wordList = nil;
	
	// release the connecting lines view
	[connectingLines release];
	connectingLines = nil;
	
	// release the black mask
	if(blackMask) {
		[blackMask release];
		blackMask = nil;
	}
	
	// release the game over display
	if(gameOverDisplay) {
		[gameOverDisplay release];
		gameOverDisplay = nil;
	}
	
	[nextBlockLetter release];
	nextBlockLetter = nil;
	
	[bonusView release];
	bonusView = nil;
	
	[bonusAlertView release];
	bonusAlertView = nil;
	
	[wordScoreLabel release];
	wordScoreLabel = nil;
	
	// release the game header
	[gameHeader release];
	gameHeader = nil;
	
	// release the columnDropMarker
	[columnDropMarker release];
	columnDropMarker = nil;
		
	// used for debuging
//	[gameOverTimerLabels release];
//	gameOverTimerLabels = nil;
	
	[self unloadAudio];
	
}


// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void) loadView {

	// load view is running first time when initing the view
	// Your custom implementation of this method should NOT call super.

	// doing it anyway!
	[super loadView];
	
	NSLog(@"\n\n	loadView %@\n\n", [self title]);
	
	NSLog(@"isGameLoaded %@", (isGameLoaded ? @"YES" : @"NO"));
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(quitGame) name:NOTIF_quitGame object:nil];
		
	// the type of game play used in this game
	// gameType = kArcade;
	gameType = kRotation;
	
	// reset all shakeCounters to 0
	for (int i=0; i<kBlockColumns; i++) {
		if(shakeCounters[i]) NSLog(@"shakeCounters[%i] is %i", i, shakeCounters[i]);
		shakeCounters[i] = 0;
	}
	
	// read active game variables
	NSDictionary *activeGame = [self readActiveGame];
	if(activeGame) NSLog(@"Successfully loaded terminated active game from file!");
	
	if (!isGameLoaded) {	// only do this once - if game is not already loaded
		// create a rect for whole screen
		gameScreenRect = CGRectMake(0.0f, 0.0f, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height);
	
		// calculate the size of the game blocks
		blockSize = gameScreenRect.size.width / kBlockColumns;

		// set to YES to pause game
		isGamePaused = NO;
		
		NSMutableArray *temp_timers = [[NSMutableArray alloc] initWithCapacity:10];
		[self setTimers:temp_timers];
		[temp_timers release];
	
		if(activeGame) score = [[activeGame objectForKey:@"score"] intValue];
		else score = 0;

		// game over
		[self setIsGameOver:NO];
	
		// bomb flag, set to YES when a bomb is activated
		if(activeGame) [self setIsBombActive:[[activeGame objectForKey:@"isBombActive"] boolValue]];
		else [self setIsBombActive:NO];
	
		if(activeGame) [self setIsNextBlockABomb:[[activeGame objectForKey:@"isNextBlockABomb"] boolValue]];
		else [self setIsNextBlockABomb:NO];
		
		if(activeGame) [self setIsBombActive:[[activeGame objectForKey:@"isBonusActive"] boolValue]];
		else [self setIsBonusActive:NO];
	
		if(activeGame) [self setIsDropPaused:[[activeGame objectForKey:@"isDropPaused"] boolValue]];
		[self setIsDropPaused:NO];
			
		// bomb tigger values
		if(activeGame) bombTriggeringCounter = [[activeGame objectForKey:@"bombTriggeringCounter"] intValue];
		else bombTriggeringCounter = 0;
		if(activeGame) bombTriggeredAtScore = [[activeGame objectForKey:@"bombTriggeredAtScore"] intValue];
		else bombTriggeredAtScore = 0;
		
	
		// used for checking if device orientation changed
		[self setDeviceOrientationChanged:NO];
		[self setDeviceOrientationChangedWhileSelection:NO];
	
		// save the current interface orientation
		currentDeviceOrientation = 1;

		// set to YES while user is touching a block
		[self setIsUserTouchingBlock:NO];
		
		touchTimerTriggersAtDate = 0.0f;
	
	}
	
	// set background color
	[[self view] setBackgroundColor:[SPCommon SPGetRed]];	
	

	// get pointer to the singleton sound engine
	if(!audioEngine) audioEngine = [SimpleAudioEngine sharedEngine];
	// prepare path strings and load audio
	[self prepareAudio];

	if (!wordList){
		// create the game dictionary
		NSString *wordListLang = [SPCommon readLanguageSettings];
		NSLog(@"Read language settings: %@", wordListLang);
		SPDictionary *temp_wordList = [[SPDictionary alloc] initWithLang:wordListLang];
		// SPDictionary *temp_wordList = [[SPDictionary alloc] initWithLang:@"swe"];
		[self setWordList:temp_wordList];
		[temp_wordList release];
	}
	
	
	if (!gameGrid) {

		[self setBlockOffset:CGPointMake(0.0f, 0.0f)];

		NSMutableArray *temp_selectedBlocks = [[NSMutableArray alloc] initWithCapacity:10];
		[self setSelectedBlocks:temp_selectedBlocks];
		[temp_selectedBlocks release];
		
		// create the columns containing blocks
		NSMutableArray *temp_gameGrid = [[NSMutableArray alloc] initWithCapacity:kBlockColumns];
		[self setGameGrid:temp_gameGrid];
		[temp_gameGrid release];
		
		NSArray *gameGridInfoArray;
		if(activeGame) {
			gameGridInfoArray = [NSArray arrayWithArray:[activeGame objectForKey:@"gameGridInfo"]];
		}
		
		// create the game grid of blocks
		for(int x = 0; x < kBlockColumns; x++ ) {
			NSMutableArray *row = [[NSMutableArray alloc] initWithCapacity:kBlockRows];

			for (int y = 0; y < kBlockRows; y++) {
				
				if(!activeGame) {
					
					if(y >= kStartingRows ) { // original code
						// fill the game array gaps with null objects
						[ row addObject : [NSNull null] ];
						continue;
					}	
					
					unichar c = [wordList getRandomChar];
					int p = [wordList getCharValue:c];
					NSString *blockLetter = [NSString stringWithFormat:@"%C", c];
					
					// create a single block and set the letter
					SPBlockViewLetter *block = [ [SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:blockLetter points:p ];
					
					// set block goal position at inverted y
					[block setGoalPosition:CGPointMake( blockSize * x + blockSize / 2.0f + blockOffset.x, gameScreenRect.size.height - (blockSize * y + blockSize / 2.0f + blockOffset.y) )];
					// move block to goal position
					[[block view] setCenter:[block goalPosition]];
					
					// add block to row array
					[row addObject:block];
					
					// add block as subview to the main view 
					[[self view] addSubview:[block view]];
					
					// update the time stamp on current block view
					// [block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
					
					// release the block from memory
					[block release];
					
				} else {
					// create blocks from info from saved game file
					NSDictionary *blockInfo = [NSDictionary dictionaryWithDictionary:[[gameGridInfoArray objectAtIndex:x] objectAtIndex:y]];
					
					if([[blockInfo objectForKey:@"isEmpty"] boolValue]) {
						// fill the game array gaps with null objects
						[ row addObject : [NSNull null] ];
						continue;						
					}
					
					SPBlockView *block;
					
					// letter block specifics
					if([[blockInfo objectForKey:@"isLetter"] boolValue]) {
						// create a single block and set the letter
						NSString *blockLetter = [NSString stringWithString:[blockInfo objectForKey:@"letter"]];
						int p = [[blockInfo objectForKey:@"score"] intValue];
						block = [ [SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:blockLetter points:p ];
						[(SPBlockViewLetter *)block setIsBonusActive:[[blockInfo objectForKey:@"isBonusActive"] boolValue]];
					
						[block setIsFalling:[[blockInfo objectForKey:@"isFalling"] boolValue]];
						[block setGoalPosition:CGPointMake([[blockInfo objectForKey:@"goalPositionX"] floatValue], [[blockInfo objectForKey:@"goalPositionY"] floatValue])];
						[block setVelocity:[[blockInfo objectForKey:@"velocity"] floatValue]];
						[block setIsMarkedForDeletion:[[blockInfo objectForKey:@"isMarkedForDeletion"] boolValue]];

						// move block to goal position
						[[block view] setCenter:[block goalPosition]];
												
						// add block to row array
						[row addObject:block];
						
						// add block as subview to the main view 
						[[self view] addSubview:[block view]];
						
						[block release];						
					}

					// bomb block specifics					
					if([[blockInfo objectForKey:@"isBomb"] boolValue]) {
						// create a time bomb block
						block = [[SPBlockViewTimeBomb alloc] initWithSize:blockSize];

						[block setIsFalling:[[blockInfo objectForKey:@"isFalling"] boolValue]];
						[block setGoalPosition:CGPointMake([[blockInfo objectForKey:@"goalPositionX"] floatValue], [[blockInfo objectForKey:@"goalPositionY"] floatValue])];
						[block setVelocity:[[blockInfo objectForKey:@"velocity"] floatValue]];
						[block setIsMarkedForDeletion:[[blockInfo objectForKey:@"isMarkedForDeletion"] boolValue]];

						// move block to goal position
						[[block view] setCenter:[block goalPosition]];
												
						// add block to row array
						[row addObject:block];
						
						// add block as subview to the main view 
						[[self view] addSubview:[block view]];
						
						[block release];						
					}
					
					
				}
				
			}
			[gameGrid addObject:row];
			[row release]; 
			
		}

	} else {
		// game grids and objects already exist, recreate and add their views to main view
		for(NSArray *col in gameGrid) {
			for(SPBlockView *b in col) {
				if([b isEqual:[NSNull null]]) continue;
				[b createViews];
				[[self view] addSubview:[b view]];
			}
		}
	}
	
	if (activeGame) {
		[self setUserWords:[[activeGame objectForKey:@"userWords"] retain]];
		[self setUserWordScores:[[activeGame objectForKey:@"userWordScores"] retain]];
	}
		
	if (!userWords) {
		// create an array for saving all the words the user has scored with
		NSMutableArray *temp_userWords = [[NSMutableArray alloc] initWithCapacity:20];
		[self setUserWords:temp_userWords];
		[temp_userWords release];
	}
	
	if (!userWordScores) {
		// create an array for saving all the word scores the user has scored
		NSMutableArray *temp_userWordScores = [[NSMutableArray alloc] initWithCapacity:20];
		[self setUserWordScores:temp_userWordScores];
		[temp_userWordScores release];
	}
	
	if (!connectingLines) {
		// create a separate view to draw lines on
		SPLinesConnectingBlocksView *temp_connectingLines = [[SPLinesConnectingBlocksView alloc] initWithFrame:gameScreenRect blockSize:blockSize];
		[self setConnectingLines:temp_connectingLines];
		[temp_connectingLines release];
		// add line view as a sub view
		[[self view] addSubview:connectingLines];
	}
	

	
	if (!blackMask) {
		// create a black mask if game area does not match with block sizes evenly
		if( gameScreenRect.size.height - blockSize * kBlockRows > 0.0f ) {
			NSLog(@"created a black mask %f", gameScreenRect.size.height - blockSize * kBlockRows );
			SPDropShadowView *temp_blackMask = [[SPDropShadowView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, gameScreenRect.size.width, gameScreenRect.size.height - blockSize * kBlockRows)];
			[self setBlackMask:temp_blackMask];
			[temp_blackMask release];
			[ blackMask setCenter:CGPointMake(gameScreenRect.size.width/2.0f, [blackMask frame].size.height / 2.0f) ];
			[ [self view] addSubview:blackMask ];
			[ [self view] sendSubviewToBack:blackMask];
			// no user interaction
			[blackMask setUserInteractionEnabled:NO];
		}
	}
	
	if (!columnDropMarker) {
		UIView *temp_columnDropMarker = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[self setColumnDropMarker:temp_columnDropMarker];
		[temp_columnDropMarker release];
		[columnDropMarker setBackgroundColor:[SPCommon SPGetOffWhite]];
		[columnDropMarker setHidden:YES];
		[[self view] addSubview:columnDropMarker];
	}
	
	if (!gameHeader) {
		// create the game header	
		SPGameHeader *temp_gameHeader = [[SPGameHeader alloc] initWithHeight:blockSize/2.0f portraitWidth:gameScreenRect.size.width landscapeWidth:gameScreenRect.size.height hasDropShadow:NO];
		[self setGameHeader:temp_gameHeader];
		[temp_gameHeader release];
		// move into position
		[gameHeader setCenter:CGPointMake(gameScreenRect.size.width/2.0f, -[gameHeader frame].size.height/2.0f)];
		// register self as the game view controller
		// [gameHeader setGameViewController:self];
		// hide the game header
		[self setGameHeaderIsHidden:YES];
		// set shyness to NO
		[gameHeader setIsShy:NO];
		// add game header to game screen
		[[self view] addSubview:gameHeader];
		// show the game header
		[self showGameHeader];
	}	
	
	if (!bonusView) {
		float bonusViewPadding = blockSize * 0.1;
		float bonusViewWidth = blockSize * 1.9;
		float bonusViewHeight = blockSize * 0.4;
		SPChainBonusView *temp_bonusView = [[SPChainBonusView alloc] initWithFrame:CGRectMake(blockSize * 0.1, [gameHeader frame].size.height + blockSize * 0.1, blockSize * 3.0, blockSize * 0.4)];
		[self setBonusView:temp_bonusView];
		[temp_bonusView release];
		[bonusView setOutsidePoint:CGPointMake(-[bonusView frame].size.width * 0.5, [bonusView goalPoint].y)];
		[bonusView setUserInteractionEnabled:NO];
		[bonusView setAlpha:0.75];

		// set rotation positions
		[bonusView setGoalPointTop:[bonusView goalPoint]];
		[bonusView setGoalPointLeft:CGPointMake(gameScreenRect.size.width - [gameHeader frame].size.height - bonusViewHeight * 0.5 - bonusViewPadding, bonusViewPadding + bonusViewWidth * 0.5)];
		[bonusView setGoalPointRight:CGPointMake([gameHeader frame].size.height + bonusViewPadding + bonusViewHeight * 0.5, gameScreenRect.size.height - bonusViewPadding - bonusViewWidth * 0.5)];
		[bonusView setGoalPointBottom:CGPointMake(gameScreenRect.size.height - bonusViewPadding - bonusViewHeight * 0.5, gameScreenRect.size.width - bonusViewPadding - bonusViewWidth * 0.5)];
		
		[[self view] addSubview:bonusView];
		[self hideChainBonusView:0.0];
	}
	
	if (!bonusAlertView) {
		//SPChainBonusAlertView *temp_bonusAlertView = [[SPChainBonusAlertView alloc] initWithFrame:CGRectMake(0.0, 0.0, 200.0, 200.0)];
		SPChainBonusAlertView *temp_bonusAlertView = [[SPChainBonusAlertView alloc] initWithFrame:CGRectMake(0.0, 0.0, blockSize * 3.0, blockSize * 3.0)];
		[self setBonusAlertView:temp_bonusAlertView];
		[temp_bonusAlertView release];
		[bonusAlertView setCenter:[[self view] center]];
		[bonusAlertView setUserInteractionEnabled:NO];
		[bonusAlertView setAlpha:0.75];
		[[self view] addSubview:bonusAlertView];
		[bonusAlertView setHidden:YES];
	}
	
	if(!wordScoreLabel) {
		UIFont *wordScoreFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.5];
		int fontH = [wordScoreFont capHeight]; 
		UILabel *temp_wordScoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, blockSize * 2.0, fontH + blockSize * 0.2)];
		[self setWordScoreLabel:temp_wordScoreLabel];
		[temp_wordScoreLabel release];
		[wordScoreLabel setFont:[UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.5]];
		[wordScoreLabel setTextAlignment:UITextAlignmentCenter];
		[wordScoreLabel setBackgroundColor:[SPCommon SPGetOffWhite]];
		[wordScoreLabel setTextColor:[SPCommon SPGetRed]];
		[[wordScoreLabel layer] setCornerRadius:blockSize * 0.1];
		[wordScoreLabel setUserInteractionEnabled:NO];
		[wordScoreLabel setAlpha:0.5];
		[wordScoreLabel setHidden:YES];
		[wordScoreLabel setCenter:[[self view] center]];
		[[self view] addSubview:wordScoreLabel];
	}
	
	if (!isGameLoaded) {
		// seconds between each new block drop
		if(activeGame) [self setDropBlockFrequency:[[activeGame objectForKey:@"dropBlockFrequency"] doubleValue]];
		else [ self setDropBlockFrequency:4.2f ];
		
		if(activeGame) [self setDropPauseTime:[[activeGame objectForKey:@"dropPauseTime"] floatValue]];
		else [self setDropPauseTime:kDropPauseTime];
	
		// set timer for next drop block event
		if(activeGame) [self setDropNextBlockAtTime:[NSDate timeIntervalSinceReferenceDate] + [[activeGame objectForKey:@"dropNextBlockAtTime"] doubleValue]];
		else [self setDropNextBlockAtTime:[NSDate timeIntervalSinceReferenceDate] + dropBlockFrequency];
		NSLog(@"dropNextBlockAtTime: %f", dropNextBlockAtTime);

		// set timer for block drop pause
		if(activeGame) dropBlockPauseUntilTime = [NSDate timeIntervalSinceReferenceDate] + [[activeGame objectForKey:@"dropBlockPauseUntilTime"] doubleValue];
		else dropBlockPauseUntilTime = 0.0f;
		NSLog(@"dropBlockPauseUntilTime: %f", dropBlockPauseUntilTime);

		// set bonus counter
		if(activeGame) 
			[self setBonusCounter:[[activeGame objectForKey:@"bonusCounter"] intValue]];
		else 
			[self resetBonusCounter];
		
		// set bonusChainCountDown
		if(activeGame) [self setBonusChainCountDown:[[activeGame objectForKey:@"bonusChainCountDown"] intValue]];
		else [self setBonusChainCountDown:0];

		
		if(activeGame) bonusChainSelectionFlag = [[activeGame objectForKey:@"bonusChainSelectionFlag"] boolValue];
		else bonusChainSelectionFlag = NO;
		
		

		/*
		// read difference in bonus time
		if(activeGame) [self setBonusTime:[NSDate timeIntervalSinceReferenceDate] + [[activeGame objectForKey:@"bonusTime"] doubleValue]];
		else [self setBonusTime:0.0];
		 */
		
	}

	if(activeGame) {
		[self setNextBlockLetter:[[activeGame objectForKey:@"nextBlockLetter"] retain]];
	} else {
		// get next random char from the dictionary
		unichar c = [wordList getRandomChar];
		// get random block character from the dictionary
		NSString *temp_nextBlockLetter = [[NSString stringWithFormat:@"%C", c] retain];
		[self setNextBlockLetter:temp_nextBlockLetter];
		[temp_nextBlockLetter release];
	}
	
	
	// gameOverTimers
	if (activeGame) {
		// read saved game over array
		NSArray *temp_array = [activeGame objectForKey:@"gameOverTimers"];
		int counter = 0;
		for(NSNumber *n in temp_array) {
			if(counter < kBlockColumns) gameOverTimers[counter] = [n doubleValue];
			counter++;
		}
	} else {
		// set all game over timers to 0
		for(int i=0; i<kBlockColumns; i++) {
			gameOverTimers[i] = 0.;
		}
	}
		
	if (!gameOverDisplay) {
		UIView *temp_gameOverDisplay = [[UIView alloc] initWithFrame:gameScreenRect];
		[self setGameOverDisplay:temp_gameOverDisplay];
		[temp_gameOverDisplay release];
		[gameOverDisplay setBackgroundColor:[SPCommon SPGetOffWhite]];
		[gameOverDisplay setAlpha:0.5];
		[gameOverDisplay setHidden:YES];
		[[self view] addSubview:gameOverDisplay];
	}
	

	// always reset the game timer stamp
	[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
		
	if (!timer) {
		// start a running game loop - the method [self run:(NSTimer*)t] will be called kFramesPerSecond
		NSTimer *temp_timer = [ [ NSTimer scheduledTimerWithTimeInterval:kFramesPerSecond target:self selector:@selector( run: ) userInfo:nil repeats:YES ] retain];
		// save the timer object
		[self setTimer:temp_timer];
		// release the temporary timer object
		[temp_timer release];
	}
	
/*	
	if (!gameOverTimerLabels) {
		CGRect labelRect = CGRectMake(0, 0, blockSize * 0.8, blockSize * 0.4);
		NSArray *temp_gameOverTimerLabels = [ [NSArray alloc] initWithObjects:						     
						     [[UILabel alloc] initWithFrame:labelRect],
						     [[UILabel alloc] initWithFrame:labelRect],
						     [[UILabel alloc] initWithFrame:labelRect],
						     [[UILabel alloc] initWithFrame:labelRect],
						     [[UILabel alloc] initWithFrame:labelRect],
						     nil];

		[self setGameOverTimerLabels:temp_gameOverTimerLabels];
		[temp_gameOverTimerLabels release];
		
		for(int i = 0; i<[gameOverTimerLabels count]; i++) {
			[[gameOverTimerLabels objectAtIndex:i] setFont:[UIFont fontWithName:@"Helvetica-Bold" size:22]]; 
			[[gameOverTimerLabels objectAtIndex:i] setText:@"0.00"];
			[[gameOverTimerLabels objectAtIndex:i] setBackgroundColor:[UIColor blackColor]];
			[[gameOverTimerLabels objectAtIndex:i] setTextColor:[UIColor yellowColor]];
			[[gameOverTimerLabels objectAtIndex:i] setTextAlignment:UITextAlignmentCenter];
			[[gameOverTimerLabels objectAtIndex:i] setCenter:CGPointMake((blockSize*i)+(blockSize*0.5), blockSize)];
			[[self view] addSubview:[gameOverTimerLabels objectAtIndex:i]];
		}
	}
*/
	
	// if the user resumed a terminated game, go directly into pause mode
	// where the player can decide whether to continue or not.
	if (activeGame) [self pauseGame];
	
}


- (void) saveActiveGame {
	
	if(isGameOver) {
		// save hiscore
		[SPCommon savePlayerScore:score 
				     name:[SPCommon readLastUsedName]
				    words:userWords
			       wordScores:userWordScores];
		// reset active game (no need to continue this game after restart as it is already game over)
		[SPCommon resetActiveGame];
		return;
	}
	
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSMutableDictionary *activeGameDict = [NSMutableDictionary dictionaryWithCapacity:15];
	
	// all the blocks currently in game grid
	[activeGameDict setObject:[self gameGridInfo] forKey:@"gameGridInfo"];
	
	// save score and words
	[activeGameDict setObject:userWords forKey:@"userWords"];
	[activeGameDict	setObject:userWordScores forKey:@"userWordScores"];
	[activeGameDict setObject:[NSNumber numberWithInt:score] forKey:@"score"];
	[activeGameDict setObject:nextBlockLetter forKey:@"nextBlockLetter"];
	
	// save bomb info
	[activeGameDict setObject:[NSNumber numberWithBool:isBombActive] forKey:@"isBombActive"];
	[activeGameDict setObject:[NSNumber numberWithBool:isNextBlockABomb] forKey:@"isNextBlockABomb"];
	[activeGameDict setObject:[NSNumber numberWithInt:bombTriggeringCounter] forKey:@"bombTriggeringCounter"];
	[activeGameDict setObject:[NSNumber numberWithInt:bombTriggeredAtScore] forKey:@"bombTriggeredAtScore"];
		
	// save block timers
	[activeGameDict setObject:[NSNumber numberWithBool:isDropPaused] forKey:@"isDropPaused"];
	[activeGameDict setObject:[NSNumber numberWithDouble:dropBlockFrequency] forKey:@"dropBlockFrequency"];
	
	// NOPE! Don't save difference on dropPauseTime, it's already taken care of in the get-handlers just the time value
	[activeGameDict setObject:[NSNumber numberWithDouble:[self getDropNextBlockAtTime]] forKey:@"dropNextBlockAtTime"];
	[activeGameDict setObject:[NSNumber numberWithDouble:[self getDropBlockPauseUntilTime]] forKey:@"dropBlockPauseUntilTime"];
	
	// NOPE! This is correct. Don't save difference on dropPauseTime
	[activeGameDict setObject:[NSNumber numberWithFloat:[self dropPauseTime]] forKey:@"dropPauseTime"];

	[activeGameDict setObject:[NSNumber numberWithBool:isBonusActive] forKey:@"isBonusActive"];
	
	// save current difference in bonus timer
	//[activeGameDict setObject:[NSNumber numberWithDouble:[self bonusTime] - [NSDate timeIntervalSinceReferenceDate]] forKey:@"bonusTime"];	
	
	// bonus values
	[activeGameDict setObject:[NSNumber numberWithInt:[self bonusCounter]] forKey:@"bonusCounter"];
	[activeGameDict setObject:[NSNumber numberWithInt:[self bonusChainCountDown]] forKey:@"bonusChainCountDown"];
	[activeGameDict setObject:[NSNumber numberWithBool:bonusChainSelectionFlag] forKey:@"bonusChainSelectionFlag"];
	
	// saving gameOverTimers
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:kBlockColumns];
	for(int i=0; i<kBlockColumns; i++) [arr addObject:[NSNumber numberWithDouble:gameOverTimers[i]]];
	[activeGameDict setObject:arr forKey:@"gameOverTimers"];
	
	// [activeGameDict setObject:checkSum forKey:@"checkSum"];	
	[prefs setObject:activeGameDict forKey:@"activeGame"];
	
	NSLog(@"Saving game info: %@", [activeGameDict description]);
	[prefs setObject:[NSNumber numberWithBool:YES] forKey:@"isGameActive"];	

	[prefs synchronize];
}

- (NSDictionary *) readActiveGame {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	// is there an active game?
	if(![prefs boolForKey:@"isGameActive"]) return nil;
	
	// reset active game
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isGameActive"];
	
	NSLog(@"Read saved game file");
	NSLog(@"From file before read and cleanup: %@", [[prefs objectForKey:@"activeGame"] description]);
	NSDictionary *readGame = [NSDictionary dictionaryWithDictionary:[prefs dictionaryForKey:@"activeGame"]];
	
	// clear the terminated game file
	NSLog(@"Clear saved game file");
	
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isGameActive"];
	[prefs setObject:nil forKey:@"activeGame"];
	[prefs synchronize]; // write to disk
	
	// return the active game info dictionary
	return readGame;
}

- (NSArray *) gameGridInfo {
	NSLog(@"Collecting gameGridInfo from saved file");
	
	NSMutableArray *ggi = [[NSMutableArray arrayWithCapacity:kBlockColumns] autorelease];

	for(int x=0; x<kBlockColumns; x++) {
		NSMutableArray *row = [NSMutableArray arrayWithCapacity:kBlockRows];
		for(int y=0; y<kBlockRows; y++) {
			NSMutableDictionary *blockInfo = [NSMutableDictionary dictionaryWithCapacity:5];
			SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
			
			if([block isEqual:[NSNull null]]) {
				[blockInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isEmpty"];
				[row addObject:blockInfo];
				continue;
			}
			
			if([block isMarkedForDeletion] || [block isDeleted] || [block isExploding]) {
				[blockInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isEmpty"];
				[row addObject:blockInfo];
				continue;
			}
			
			[blockInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isEmpty"];
			[blockInfo setObject:[NSNumber numberWithBool:[block isMarkedForDeletion]] forKey:@"isMarkedForDeletion"];
			
			[blockInfo setObject:[NSNumber numberWithBool:[block isFalling]] forKey:@"isFalling"];
			[blockInfo setObject:[NSNumber numberWithFloat:[block velocity]] forKey:@"velocity"];
			[blockInfo setObject:[NSNumber numberWithFloat:[block goalPosition].x] forKey:@"goalPositionX"];
			[blockInfo setObject:[NSNumber numberWithFloat:[block goalPosition].y] forKey:@"goalPositionY"];

			if([block isMemberOfClass:[SPBlockViewTimeBomb class]]) {
				[blockInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isBomb"];
			} else {
				[blockInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isBomb"];
			}
			
			// letter specific saves
			if([block isMemberOfClass:[SPBlockViewLetter class]]) {
				[blockInfo setObject:[NSNumber numberWithBool:YES] forKey:@"isLetter"];
				[blockInfo setObject:[NSString stringWithString:[(SPBlockViewLetter *)block letter]] forKey:@"letter"];
				[blockInfo setObject:[NSNumber numberWithInt:[(SPBlockViewLetter *)block score]] forKey:@"score"];
				[blockInfo setObject:[NSNumber numberWithBool:[(SPBlockViewLetter *)block isBonusActive]] forKey:@"isBonusActive"];
			} else {
				[blockInfo setObject:[NSNumber numberWithBool:NO] forKey:@"isLetter"];
			}
			
			[row addObject:blockInfo];

		}
		[ggi addObject:row];
	}
	NSLog(@"Returning gameGridInfo");
	return ggi;
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void) viewDidLoad {
	[super viewDidLoad];
	// add code here
}



#pragma mark -
#pragma mark view will appear/disappear


- (void) viewWillAppear:(BOOL) animated {
	[super viewWillAppear:animated];
	NSLog(@"Adding the device orientation observer");
	// add a device orientation observer

	[[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
	[[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(receivedRotate:) name: UIDeviceOrientationDidChangeNotification object: nil];

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:NOTIF_pauseButtonPressed object:nil];

	[[self view] setAlpha:0.0f];
}

- (void) viewDidAppear:(BOOL) animated {
	[super viewDidAppear:animated];
	[self resumeFromPausedGame];
	// fade in main view
	[UIView beginAnimations:nil context:NULL];
		[UIView setAnimationDuration:0.5f];
		[[self view] setAlpha:1.0f];
	[UIView commitAnimations];	
}

- (void) viewWillDisappear:(BOOL) animated {
	[super viewWillDisappear:animated];
	NSLog(@"Removing the device orientation observer");
	// remove the device orientation observer
//	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:NOTIF_pauseButtonPressed object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
//	[[NSNotificationCenter defaultCenter] removeObserver: self];
	[[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
}



#pragma mark -
#pragma mark setup and load audio



- (void)prepareAudio {

	// get path and preload sound effects

	soundOfCollidingBlocks = [[NSString stringWithString:RSRC(@"blockhit.wav")] retain];
	NSLog(@"soundOfCollidingBlocks: %@", soundOfCollidingBlocks);
	
	soundOfNewBlock = [[NSString stringWithString:RSRC(@"newblock.wav")] retain];
	NSLog(@"soundOfNewBlock: %@", soundOfNewBlock);

	
	soundOfTouchingBlock = [[NSString stringWithString:RSRC(@"touch.wav")] retain];
	NSLog(@"soundOfTouchingBlock: %@", soundOfTouchingBlock);

	
	soundOfDissapearingBlock = [[NSString stringWithString:RSRC(@"acceptword.wav")] retain];
	NSLog(@"soundOfDissapearingBlock: %@", soundOfDissapearingBlock);
	
	
	soundOfRevealedScore = [[NSString stringWithString:RSRC(@"revealscore.wav")] retain];
	NSLog(@"soundOfRevealedScore: %@", soundOfRevealedScore);
	
	
	soundOfFragExplosion = [[NSString stringWithString:RSRC(@"bomb.wav")] retain];
	NSLog(@"soundOfFragExplosion: %@", soundOfFragExplosion);
	
	
	soundOfExplodingBlocks = [[NSString stringWithString:RSRC(@"explode.wav")] retain];
	NSLog(@"soundOfExplodingBlocks: %@", soundOfExplodingBlocks);

	soundOfChainBonus = [[NSString stringWithString:RSRC(@"chain.wav")] retain];
	NSLog(@"soundOfChainBonus: %@", soundOfChainBonus);

	soundOfWordBonus = [[NSString stringWithString:RSRC(@"bonus.wav")] retain];
	NSLog(@"soundOfWordBonus: %@", soundOfWordBonus);

	
	stressMusic = [[NSString stringWithString:RSRC(@"m_stress.caf")] retain];
	NSLog(@"stress music: %@", stressMusic);
	
	[self loadAudio];

}

- (void) loadAudio {
	[audioEngine preloadEffect:soundOfCollidingBlocks];
	[audioEngine preloadEffect:soundOfNewBlock];
	[audioEngine preloadEffect:soundOfTouchingBlock];
	[audioEngine preloadEffect:soundOfDissapearingBlock];
	[audioEngine preloadEffect:soundOfRevealedScore];
	[audioEngine preloadEffect:soundOfFragExplosion];
	[audioEngine preloadEffect:soundOfExplodingBlocks];
	[audioEngine preloadEffect:soundOfChainBonus];
	[audioEngine preloadEffect:soundOfWordBonus];
	[audioEngine preloadBackgroundMusic:stressMusic];
}


/* block positions, x.y
 
 1.5  2.5  3.5
 1.4  2.4  3.4
 1.3  2.3  3.3
 1.2  2.2  3.2
 1.1  2.1  3.1
 1.0  2.0  3.0 
 
 */

#pragma mark -
#pragma mark running the game

- (void) run:(NSTimer*)t {
	
	if(isGamePaused) return;
	
//	[ debugOutput setText:[NSString stringWithFormat:@"selected blocks: %i", [selectedBlocks count] ]];
	
	if(isGameOver) {
		[self runGameOver];
		return;
	}
	
	if( [self deviceOrientationChanged] ) {
		// animate - game over display
		[self animateGameOverDisplay];
		// before returning update global game timer - too avoid unsynchronised delay
		[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
		return;
	}
	
	double gameTimeElapsed = [NSDate timeIntervalSinceReferenceDate] - gameTimeStamp;
	
	// Oh my god, the array is full of YES!
	BOOL fullColumns[kBlockColumns];
	for(int i=0;i<kBlockColumns;i++) fullColumns[i] = YES;
		
	// go through the columns in the game grid
	for(uint x = 0; x < kBlockColumns; x++ ) {
		// go through the rows in the game grid
		for(uint y = 0; y<kBlockRows; y++) {
			
			// used for reversing values at some orientations
			uint gridX = x;
			uint gridY = y;
			
			if( currentDeviceOrientation == UIDeviceOrientationPortrait ) {
				// reverse y
				gridY = kBlockRows - y - 1;
			}
			
			if( currentDeviceOrientation == UIDeviceOrientationLandscapeLeft ) {
				// reverse x
				gridX = kBlockColumns - x - 1;
			}
			
			
			// get pointer to the block from the game grid!
			
			// get current block
			SPBlockView *block = [[gameGrid objectAtIndex:gridX] objectAtIndex:gridY];
			
			// is current block empty then continue to next block
			if([block isEqual:[NSNull null]]) {
				fullColumns[gridX] = NO;
				continue;
			}
			
			if([block isDeleted]) {
				fullColumns[gridX] = NO;
				continue;
			}
			
			if([block isMarkedForDeletion]) {
				fullColumns[gridX] = NO;
				[self removeBlockInColumn:gridX atRow:gridY];
				continue;
			}
			
			if([block isFalling]) fullColumns[gridX] = NO;
			
			// check next block
			
			// set out of bounds value to NO - check after switch block below if it is still set to NO
			BOOL nextBlockIsOutOfBounds = NO;
			
			
			// create next block object, make sure it is nil
			SPBlockView *nextBlock = nil;
			
			
			
			// assign next block
			// WARNING! nextBlock will NOT always be assigned
			switch ((int)currentDeviceOrientation) {
					
				case UIDeviceOrientationPortrait: {
					if( gridY < 1 ) {
						nextBlockIsOutOfBounds = YES;
					} else {
						nextBlock = [[gameGrid objectAtIndex:gridX] objectAtIndex:gridY-1];
					}
					break;
				}
					
				case UIDeviceOrientationPortraitUpsideDown: {
					if( gridY + 1 >= kBlockRows ) {
						nextBlockIsOutOfBounds = YES;
					} else {
						nextBlock = [[gameGrid objectAtIndex:gridX] objectAtIndex:gridY+1];
					}
					break;
				}
					
				case UIDeviceOrientationLandscapeLeft: {
					if( gridX < 1 ) {
						nextBlockIsOutOfBounds = YES;
					} else {
						nextBlock = [[gameGrid objectAtIndex:gridX-1] objectAtIndex:gridY];
					}
					break;
				}
					
				case UIDeviceOrientationLandscapeRight: {
					if( gridX + 1 >= kBlockColumns ) {
						nextBlockIsOutOfBounds = YES;
					} else {
						nextBlock = [[gameGrid objectAtIndex:gridX+1] objectAtIndex:gridY];
					}
					break;
				}
					
			}
			
			
			// if block is not falling and not touched and not out of bounds, check if it should start falling
			if( ! [block isTouched] && ! [block isFalling] && ! nextBlockIsOutOfBounds ) {
				
				// set startFalling to NO, and check if still NO after the 'if' block
				BOOL startFalling = NO;
				
				// check if next block is empty
				if( [nextBlock isEqual:[NSNull null]] ) {
					startFalling = YES;
				} else if([nextBlock isFalling]) {
					startFalling = YES;
				}
				
				if( startFalling ) {
					
					// GAME OVER TIMERS CHECK
					// If game just was rotated - make complicated check for game over timers.
					if( [self swapGameOverTimer:gridX] ) fullColumns[gridX] = NO;
					
					// space below is empty - make current block fall
					[block setIsFalling:YES];
					// set a position for the block to move (fall) to
					[self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];

				}
				
			}
			
			
			
			// block is falling, accelerate, move and test for collision
			if( [block isFalling] ) {
				
				// accelerate the block!
				
				// accelerate falling blocks
				if([block velocity] < [block maximumVelocity]) {
					// increase the velocity by adding gravity (but not more than the maximum velocity)
					[block setVelocity:MIN( [block velocity] + kGravity, [block maximumVelocity] )]; 
				}
				
				
				// calculate movement
				
				// temporary time stamp to calculate time since last move
				// double timeElapsed = [NSDate timeIntervalSinceReferenceDate] - [block timeStamp];	
				
				
				// calculate time based x&y-movement
				// float movementSinceLastTimeStamp = timeElapsed * [block velocity];
				float movementSinceLastTimeStamp = gameTimeElapsed * [block velocity];
				
				
				float newPosition;
				
				// set continue to fall to NO - check if it is still set to NO after the switch block below
				BOOL continueToFall = NO;
				
				// move the block
				switch (currentDeviceOrientation) {
						
					case UIDeviceOrientationPortrait: {
						
						// calculate next position after movement
						newPosition = [[block view] center].y + movementSinceLastTimeStamp;
						
						// has the block NOT reached its final goal position?
						if( newPosition <= [block goalPosition].y ) {
							// move block to new position
							[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];
							// make extra check for collision as block can fall through nextBlock (block might have higher velocity than nextBlock)
							[self resolveCollisionBetweenBlock:block andBlock:nextBlock];
						} else {
							// is next space NOT out of bounds?
							if( ! nextBlockIsOutOfBounds ) {
								// is next block empty (and within bounds)
								if ( [nextBlock isEqual:[NSNull null]] ) {	
									continueToFall = YES;
								} else {
									if ( [nextBlock isFalling] ) {
										continueToFall = YES;
									}
								}	
							}
							if( continueToFall ) {
								
								// continue to move the block set new goal to move to and swap blocks in game array
								if ( [nextBlock isEqual:[NSNull null]] ) [self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];
								// move block to new position - like nothing happened...
								[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];
								
							} else {
								[block stop];
								// ### play sound
								[audioEngine playEffect:soundOfCollidingBlocks];
								// [soundOfCollidingBlocks play];
							}
						}
						
						break;
					}
						
						
						
					case UIDeviceOrientationPortraitUpsideDown: {
						
						// calculate next position after movement
						newPosition = [[block view] center].y - movementSinceLastTimeStamp;
						
						// has the block NOT reached its goal position
						if(newPosition >= [block goalPosition].y) {
							// move block to new position
							[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];
							// make extra check for collision as block can fall through nextBlock (block might have higher velocity than nextBlock)
							[self resolveCollisionBetweenBlock:block andBlock:nextBlock];
						} else {
							// is next space NOT out of bounds?
							if( ! nextBlockIsOutOfBounds ) {
								// is next space empty (and within bounds)
								if( [nextBlock isEqual:[NSNull null]] ) {
									continueToFall = YES;
								} else {
									if( [nextBlock isFalling] ) {
										continueToFall = YES;
									}
								}
							}
							if( continueToFall ) {
								// next block is empty - continue to move the block set new goal to move to and swap blocks in game array
								if ( [nextBlock isEqual:[NSNull null]] ) [self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];
								// move block to new position - like nothing happened...
								[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];
							} else {
								[block stop];
								// ### play sound
								[audioEngine playEffect:soundOfCollidingBlocks];
								// [soundOfCollidingBlocks play];
							}
						}
						break;
					}
						
						
						
					case UIDeviceOrientationLandscapeRight: {
						
						// calculate next position after movement
						newPosition = [[block view] center].x + movementSinceLastTimeStamp;
						
						if(newPosition <= [block goalPosition].x) {
							// move block to new position
							[[block view] setCenter:CGPointMake(newPosition, [[block view] center].y)];
							// make extra check for collision as block can fall through nextBlock (block might have higher velocity than nextBlock)
							[self resolveCollisionBetweenBlock:block andBlock:nextBlock];
						} else {
							// is next space NOT out of bounds?
							if( ! nextBlockIsOutOfBounds ) {
								// is next space empty (and within bounds)
								if( [nextBlock isEqual:[NSNull null]] ) {
									continueToFall = YES;
								} else {
									if( [nextBlock isFalling] ) {
										continueToFall = YES;
									}
								}
							}
							if( continueToFall ) {

								// Make check for game over timers.
								if( [self swapGameOverTimer:gridX] ) fullColumns[gridX] = NO;
								
								// next block is empty - continue to move the block set new goal to move to and swap blocks in game array
								if ( [nextBlock isEqual:[NSNull null]] ) [self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];
								// move block to new position - like nothing happened...
								[[block view] setCenter:CGPointMake(newPosition, [[block view] center].y)];
							} else {
								[block stop];
								// ### play sound
								[audioEngine playEffect:soundOfCollidingBlocks];
								// [soundOfCollidingBlocks play];
							}
						}
						break;
					}
						
						
						
					case UIDeviceOrientationLandscapeLeft: {
						
						// calculate next position after movement
						newPosition = [[block view] center].x - movementSinceLastTimeStamp;
						
						if(newPosition >= [block goalPosition].x) {
							// move block to new position
							[[block view] setCenter:CGPointMake(newPosition, [[block view] center].y)];
							// make extra check for collision as block can fall through nextBlock (block might have higher velocity than nextBlock)
							[self resolveCollisionBetweenBlock:block andBlock:nextBlock];
						} else {
							// is next space NOT out of bounds?
							if( ! nextBlockIsOutOfBounds ) {
								// is next space empty (and within bounds)
								if( [nextBlock isEqual:[NSNull null]] ) {
									continueToFall = YES;
								} else {
									if( [nextBlock isFalling] ) {
										continueToFall = YES;
									}
								}
							}
							if( continueToFall ) {

								// Make check for game over timers.
								if( [self swapGameOverTimer:gridX] ) fullColumns[gridX] = NO;

								// next block is empty - continue to move the block set new goal to move to and swap blocks in game array
								if ( [nextBlock isEqual:[NSNull null]] ) [self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];
								// move block to new position - like nothing happened...
								[[block view] setCenter:CGPointMake(newPosition, [[block view] center].y)];
							} else {
								[block stop];
								// ### play sound
								[audioEngine playEffect:soundOfCollidingBlocks];
								// [soundOfCollidingBlocks play];
							}
						}
						
						
						
						break;
					}		
						
						
						
					default: {
						
						NSLog(@"Default orientation is running!");
						
						// calculate next position after movement
						newPosition = [[block view] center].y + movementSinceLastTimeStamp;
						// has the block NOT reached its final goal position?
						if( newPosition <= [block goalPosition].y ) {
							// move block to new position
							[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];
							// make extra check for collision as block can fall through nextBlock (block might have higher velocity than nextBlock)
							[self resolveCollisionBetweenBlock:block andBlock:nextBlock];
						} else {
							// is next space NOT out of bounds?
							if( ! nextBlockIsOutOfBounds ) {
								// is next block empty (and within bounds)
								if ( [nextBlock isEqual:[NSNull null]] ) {	
									continueToFall = YES;
								} else {
									if ( [nextBlock isFalling] ) {
										continueToFall = YES;
									}
								}	
							}
							if( continueToFall ) {
								
								// Make check for game over timers.
								if( [self swapGameOverTimer:gridX] ) fullColumns[gridX] = NO;

								// continue to move the block set new goal to move to and swap blocks in game array
								if ( [nextBlock isEqual:[NSNull null]] ) [self setGoalPositionAndSwitchBlocksInColumn:(uint)gridX atRow:(uint)gridY withBlock:block];
								// move block to new position - like nothing happened...
								[[block view] setCenter:CGPointMake([[block view] center].x, newPosition)];							
							} else {
								[block stop];
								// ### play sound
								[audioEngine playEffect:soundOfCollidingBlocks];
								// [soundOfCollidingBlocks play];
							}
						}
						
						break;						
					}
						
						
				}
				
				// update the time stamp on current block view
				//[block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
				
				
			}
			
		} // END for(y++)
		
	} // END for(x++)
	
	

	float maxGameOverTimer = 0.;
	
	// ### check and shake any full columns ###
	for(int i=0; i < kBlockColumns; i++) {
		int tempCol = i;
		
		// SPECIAL CASE! Reverse column value if device is in left landscape orientation
		if( currentDeviceOrientation == UIDeviceOrientationLandscapeLeft ) {
			tempCol = ABS(i-kBlockColumns)-1;
		}
				
		if(fullColumns[tempCol]) {
			// if column is full but the game over timer is still 0
			if(gameOverTimers[tempCol] == 0.) {
				// set current columns game-over timer to current time
				gameOverTimers[tempCol] = [NSDate timeIntervalSinceReferenceDate];
			} else {
				// the current game over timer has passed it's limit
				if(gameOverTimers[tempCol] < [NSDate timeIntervalSinceReferenceDate] - kGameOverTimerLimit) {
					
					// final game over check:
					BOOL gameOverFlag = [self checkForGameOver];
					NSLog(@"checkForGameOver returned: %@", gameOverFlag ? @"YES" : @"NO");
					
					if(gameOverFlag) {
						// game is over!
						[audioEngine stopBackgroundMusic];
						// hide the game over display
						[gameOverDisplay setHidden:YES];
						// set current game over timer to 0 again 
						gameOverTimers[tempCol] = 0.;
					
						// ##################################################
						// GAME IS OVER! Return out of loop to avoid game over crash?
						return;
						// ##################################################
					}
					
				} else {
					// the current game over timer is counting ...
					// is current game over timer more than maxGameOverTimer?
					if([NSDate timeIntervalSinceReferenceDate] - gameOverTimers[tempCol] > maxGameOverTimer) { //i
						// set maxGameOverTimer
						maxGameOverTimer = [NSDate timeIntervalSinceReferenceDate] - gameOverTimers[tempCol]; //i
					}
				}
			}
			
			// shake the current column
			[self shakeColumn:tempCol];
			
		} else {
			// set current game over timer to 0 again
			if(gameOverTimers[tempCol] > 0.) gameOverTimers[tempCol] = 0.;
			// if current column is NOT shaking and shake counter is NOT 0
			if(shakeCounters[tempCol] != 0) { 
				// stop shaking columns
				[self shakeColumnStop:tempCol];
			}			
		}
	}

	// ### show, hide and move the gameover display ###
	if(maxGameOverTimer > 0.) {
		// if maxGameOverTimer is more than 0
		if([gameOverDisplay isHidden] && !isGameOver) {
			// if game over display is hidden and game is not over
			// show the game over display
			[audioEngine playBackgroundMusic:stressMusic loop:NO];
			[gameOverDisplay setHidden:NO];
		}
		
		// position the game over display
		
		// original pos
		float y1 = gameScreenRect.size.height + [gameOverDisplay frame].size.height * 0.5f;
		// final pos
		float y2 = [gameOverDisplay frame].size.height * 0.5f;
		// delta
		float delta = (y1-y2) / kGameOverTimerLimit;
		// position is depending on the game over timer (game over timer moves accross screen)
		[gameOverDisplay setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, y1 - delta * maxGameOverTimer)];

	} else if(![gameOverDisplay isHidden]) {
		// if max game over timer is 0. (should indicate that none of the columns are full).
		// hide game over display
		[gameOverDisplay setHidden:YES];
		[audioEngine stopBackgroundMusic];
	}
	
/*	
	for(int i=0; i<[gameOverTimerLabels count]; i++) {

		//[[gameOverTimerLabels objectAtIndex:i] setText:[NSString stringWithFormat:@"%i", shakeCounters[i]]];
		
		if(gameOverTimers[i] == 0) 
			[[gameOverTimerLabels objectAtIndex:i] setText:[NSString stringWithFormat:@"%.1f", 0.]];
		else
			[[gameOverTimerLabels objectAtIndex:i] setText:[NSString stringWithFormat:@"%.1f", [NSDate timeIntervalSinceReferenceDate] - gameOverTimers[i]]];
		
	}
*/	
	
	// ### if a bomb is ative, shake all the active blocks
	if(isBombActive) {
		for(SPBlockView *b in selectedBlocks) {
			// update shake values
			[b shake];
			// adjust block position adding shake offset
			[[b view] setCenter:[b goalPosWithShakeOffset]];
		}
		if([selectedBlocks count]) {
			if([[selectedBlocks objectAtIndex:0] isMemberOfClass:[SPBlockViewTimeBomb class]]) {
				// calculate time and tell bombblock to update timer (the last -0.01 is subtracted to make sure the bomb displays 000 before exploding)
				[[selectedBlocks objectAtIndex:0] updateTimer:MAX(0.0f, touchTimerTriggersAtDate - [NSDate timeIntervalSinceReferenceDate]-0.01f)];
			}
		}
	}

	
	// ### update global game timer - too avoid unsynchronised delay
	[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];


	if( [NSDate timeIntervalSinceReferenceDate] >= dropBlockPauseUntilTime ) {
		if(isDropPaused){
			[self setDropNextBlockAtTime:[NSDate timeIntervalSinceReferenceDate] + dropBlockFrequency];			
			isDropPaused = NO;
		} else {
			float dTimer = MAX(0.0f, dropNextBlockAtTime - [NSDate timeIntervalSinceReferenceDate]);
			[gameHeader updateDropTimer:dTimer withLetter:[self nextBlockLetter]];
			// [ gameHeader updateDropTimer:MAX(0.0f, dropNextBlockAtTime - [NSDate timeIntervalSinceReferenceDate]) ];
			if( [NSDate timeIntervalSinceReferenceDate] >= dropNextBlockAtTime ) {
				[self dropNewBlock:-1];
				[self updateBlockDropTimers];
			}
		}
	}
	
	if( [bonusView score] > 0 )
		[self addScore:[bonusView printAndReturnScore]];
	else if( [bonusView isActive] )
			[self hideChainBonusView:1.0];
	
	// ### try to print score and hide game header if score printer is finished
	if( [gameHeader printScoreFast] == NO && gameHeaderIsHidden == NO && [gameHeader isShy]) [self hideGameHeaderWithDelay:2.0f];

	// ### try to print bonus and hide bonus view if bonus printer is finished 
	// if( ![bonusView isPrintingScore] ) [self hideChainBonusView:1.0];
	
}


- (BOOL) animateGameOverDisplay {
	
	// NSLog(@"animateGameOverDisplay");
	// NSLog(@"gameOverTimers %f, %f, %f, %f, %f", gameOverTimers[0], gameOverTimers[1], gameOverTimers[2], gameOverTimers[3], gameOverTimers[4]);
	
	float maxGameOverTimer = 0.;
	
	for(int i=0; i<kBlockColumns; i++) {
		if( gameOverTimers[i] > 0. ) {
			NSLog(@"%f, %f", [NSDate timeIntervalSinceReferenceDate], gameOverTimers[i]);
			maxGameOverTimer = MAX(maxGameOverTimer, [NSDate timeIntervalSinceReferenceDate] - gameOverTimers[i]);
		}
	}
	
	// ### show, hide and move the gameover display ###
	if(maxGameOverTimer > 0.) {
		// NSLog(@"gameOverDisplay isHidden: %@", ([gameOverDisplay isHidden] ? @"YES" : @"NO"));

		// position the game over display
	
		// original pos
		float y1 = gameScreenRect.size.height + [gameOverDisplay frame].size.height * 0.5f;
		// final pos
		float y2 = [gameOverDisplay frame].size.height * 0.5f;
		// delta
		float delta = (y1-y2) / kGameOverTimerLimit;
		// position is depending on the game over timer (game over timer moves accross screen)
		[gameOverDisplay setCenter:CGPointMake(gameScreenRect.size.width * 0.5f, y1 - delta * maxGameOverTimer)];
		NSLog(@"New postition of gameOverDisplay: %f", [gameOverDisplay center].y);
		return YES;
	}
	
	return NO;
}


- (void) shakeColumn:(int)x {
	for(int y=0; y<kBlockRows; y++) {

		SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
		if([block isEqual:[NSNull null]]) {
			NSLog(@"ERROR: Found empty space in a supposedly full column of blocks.");
			return;
		}

		shakeCounters[x] = shakeCounters[x]+1;
		if( shakeCounters[x] >= kShakeArraySize ) shakeCounters[x] = 0;
		// move block in x column in y axis
		[[block view] setCenter:CGPointMake([block goalPosition].x, [block goalPosition].y - shakeViewOffsetValues[ shakeCounters[x] ] * kShakeHeight )];

	}
}

- (void) shakeColumnStop:(int)x {
	NSLog(@"### stop shaking column %i", x);
	
	for(int y=0; y<kBlockRows; y++) {		
		SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
		if([block isEqual:[NSNull null]]) {
			NSLog(@"ERROR: Found empty space in a supposedly full column of blocks.");
			return;
		}
		shakeCounters[x] = 0;
		// reset position
		[[block view] setCenter:CGPointMake( [block goalPosition].x, [block goalPosition].y )];
	}
}


- (BOOL) swapGameOverTimer:(int)gridX {
	// 1. check if device is in landscape
	if(currentDeviceOrientation == UIDeviceOrientationLandscapeLeft || 
	   currentDeviceOrientation == UIDeviceOrientationLandscapeRight) {
		// 2. check if column is full
		if([self isColumnFull:gridX]) {
			// if(fullColumns[gridX]) {
			
			if(currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) NSLog(@"Full column switch orientation: left");
			else NSLog(@"Full column switch orientation: right");
			
			// 3. If game over counter for this column is active
			if( gameOverTimers[gridX] > 0.) {
				int n = 1;
				// make n negative if landscape left
				if(currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) n = -1;
				NSLog(@"%i, %i", [self isColumnFull:gridX], [self isColumnFull:gridX+n]);
				// move the game over timer value
				gameOverTimers[gridX+n] = gameOverTimers[gridX];
				gameOverTimers[gridX] = 0.;
				return YES;
			}
		}
	}
	return NO;
}


- (BOOL) isColumnFull:(int)col {
	for(uint row=0; row<kBlockRows; row++) {
		// get current block
		SPBlockView *block = [[gameGrid objectAtIndex:col] objectAtIndex:row];
		// is current block empty then return NO
		if([block isEqual:[NSNull null]]) {
			// no need to search further - column is not empty
			return NO;
		} else {
			// if some blocks are just selected and accepted as a word they are deleted (and logically empty)
			if( [block isDeleted] ) {
				// no need to search further - column is not empty
				return NO;
			}
		}
	}
	return YES;
}


- (BOOL)checkForGameOver {
		
	int countFullColumns = 0;
	
	// go through the columns in the game grid
	for(uint x = 0; x < kBlockColumns; x++ ) {

		BOOL foundEmptySpace = NO;
		
		// go through the rows in the game grid
		for(uint y = 0; y < kBlockRows; y++) {
			// get current block
			SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
			// is current block empty then return NO
			if([block isEqual:[NSNull null]]) {
				foundEmptySpace = YES;
				// no need to search further
				break;
			} else {
				// if the block is activated for bomb-explosion, wait.
				if([block isBombed]) {
					foundEmptySpace = YES;
					break;
				}
				// if some blocks are just selected and accepted as a word they are deleted (and logically empty)
				if( [block isDeleted] ) {
					foundEmptySpace = YES;
					// no need to search further
					break;
				}
			}
		}

		if(!foundEmptySpace) countFullColumns++;

	}

	switch (gameType) {
		case kArcade:
			if(countFullColumns == 0) return NO;
			break;
		case kRotation:
			if(countFullColumns == 0) return NO;
			break;			
		default:
			if(countFullColumns < kBlockColumns) return NO;
			break;
	}
	
	// set game over flag to YES
	[self setIsGameOver:YES];
	
	// unselect all currently selected blocks
	[self unselectBlocks];
	
	// play game over explosion vibration
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
	
	// play game over explosion sound
	[audioEngine playEffect:soundOfExplodingBlocks];
	
	// all blocks are full, return YES
	return YES;
}

- (void)runGameOver {
	
	double gameTimeElapsed = [NSDate timeIntervalSinceReferenceDate] - gameTimeStamp;
	
	BOOL allBlocksAreGone = YES;
	
	// go through the columns in the game grid
	for(uint x = 0; x < kBlockColumns; x++ ) {
		// go through the rows in the game grid
		for(uint y = 0; y < kBlockRows; y++) {
			
			// get current block
			SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
			
			// is current block empty then continue to next block
			if([block isEqual:[NSNull null]]) continue;
			
			allBlocksAreGone = NO;
			
			// check if block is exploding
			if([block isExploding] == NO) {
				[block explode];
				continue;
			}
			
			float xMovementSinceLastTimeStamp = gameTimeElapsed * [block xyVelocity].x;
			float yMovementSinceLastTimeStamp = gameTimeElapsed * [block xyVelocity].y;
			
			// move block
			[[block view] setCenter:CGPointMake([[block view] center].x + xMovementSinceLastTimeStamp, [[block view] center].y + yMovementSinceLastTimeStamp)];
			
			// if block is out of bounds, remove the block
			if( [[block view] center].x > gameScreenRect.size.width + blockSize/2.0f || [[block view] center].x < -blockSize/2.0f || [[block view] center].y > gameScreenRect.size.height + blockSize/2.0f || [[block view] center].y < - blockSize/2.0f ) {
				SPGridPos pos = [self findBlock:block];
				[self removeBlockInColumn:pos.x atRow:pos.y];
			}
			
		}
	}
	
	
	if( allBlocksAreGone ) {
		NSLog(@"Game Over animation is done, show game over screen ...");

		// invaludate the main game run loop timer
		[[self timer] invalidate];
				
		// create the game results view controller
		if(!gameResultsViewController) {
			SPGameResultsViewController *temp_gameResultsViewController = [[SPGameResultsViewController alloc] init];
			[self setGameResultsViewController:temp_gameResultsViewController];
			[temp_gameResultsViewController release];
			
			// set the title
			[gameResultsViewController setTitle:@"The Game Results View Controller"];
		}
		
		[gameResultsViewController showPlayerScore:[self score] words:[self userWords] scores:[self userWordScores]];
		
		// unload audio
		[self unloadAudio];
		
		// push the game over view controller
		[[self navigationController] pushViewController:gameResultsViewController animated:NO];
		
	}
	
	// update global game timer - too avoid unsynchronised delay
	[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
	
}

- (void) quitGame {
	[self killGameLoop];
	[self unloadAudio];
//	[[self view] setHidden:YES];
	[self dismissModalViewControllerAnimated:NO];
	[[self navigationController] popToRootViewControllerAnimated:NO];
}

- (void) killGameLoop {
	if(touchTimer)
		[self stopTouchTimer];
	if(timer)
		if([timer isValid])
			[[self timer] invalidate];
	if([timers count]) NSLog(@"\n••••••••••••••••••••••••\n\nW A R N I N G:\nSome NSTimers left: %i Ivalidating them now.\n\n••••••••••••••••••••••••\n", [timers count]);
	[timers makeObjectsPerformSelector:@selector(invalidate)];
	[timers removeAllObjects];
}

- (void) unloadAudio {
	[audioEngine unloadEffect:soundOfCollidingBlocks];
	[audioEngine unloadEffect:soundOfNewBlock];
	[audioEngine unloadEffect:soundOfTouchingBlock];
	[audioEngine unloadEffect:soundOfDissapearingBlock];
	[audioEngine unloadEffect:soundOfRevealedScore];
	[audioEngine unloadEffect:soundOfFragExplosion];
	[audioEngine unloadEffect:soundOfExplodingBlocks];
	[audioEngine unloadEffect:soundOfChainBonus];
	[audioEngine unloadEffect:soundOfWordBonus];
}


- (void)resolveCollisionBetweenBlock:(SPBlockView *)block andBlock:(SPBlockView *)nextBlock {
	
	// sometimes when a new falling block accelerates to a higher velocity than a 
	// falling block below they dont really collide and the new block is passing the block below
	// use this function to stop that from happening. 
	
	// return if nextBlock is empty
	if( [nextBlock isEqual:[NSNull null]] ) return;
	
	// return if nextBlock is NOT falling
	if( ! [nextBlock isFalling] ) return;
	
	// make collision check
	switch ( (int)currentDeviceOrientation ) {
			
		case UIDeviceOrientationPortrait: {
			// check for collision
			if( [[block view] center].y + blockSize - 1.0f > [[nextBlock view] center].y ) {
				// move block adjacent to nextBlock
				[[block view] setCenter:CGPointMake([[block view] center].x, [[nextBlock view] center].y - blockSize)];
				// is block velocity higher than nextBlock velocity
				if ([block velocity] > [nextBlock velocity]) {
					// calculate the difference in velocity (and divide it in 2)
					float vDiff = ([block velocity] - [nextBlock velocity])/2.0f;
					// increase nextBlock velocity
					[nextBlock setVelocity:[nextBlock velocity]+vDiff];
					// decrease block velocity
					[block setVelocity:[block velocity]-vDiff];
				}
				// ### play sound
				[audioEngine playEffect:soundOfCollidingBlocks];
				// [soundOfCollidingBlocks play];
			}
			break;
		}
			
		case UIDeviceOrientationPortraitUpsideDown: {
			// check for collision
			if( [[block view] center].y - blockSize + 1.0f < [[nextBlock view] center].y ) {
				// move block adjacent to nextBlock
				[[block view] setCenter:CGPointMake([[block view] center].x, [[nextBlock view] center].y + blockSize)];
				// is block velocity higher than nextBlock velocity
				if ([block velocity] > [nextBlock velocity]) {
					// calculate the difference in velocity (and divide it in 2)
					float vDiff = ([block velocity] - [nextBlock velocity])/2.0f;
					// increase nextBlock velocity
					[nextBlock setVelocity:[nextBlock velocity]+vDiff];
					// decrease block velocity
					[block setVelocity:[block velocity]-vDiff];
				}
				// ### play sound
				[audioEngine playEffect:soundOfCollidingBlocks];
				// [soundOfCollidingBlocks play];
			}
			break;
		}

		case UIDeviceOrientationLandscapeRight: {			
			// check for collision
			if( [[block view] center].x + blockSize - 1.0f > [[nextBlock view] center].x ) {
				// move block adjacent to nextBlock
				[[block view] setCenter:CGPointMake([[nextBlock view] center].x - blockSize, [[block view] center].y)];
				// is block velocity higher than nextBlock velocity
				if ([block velocity] > [nextBlock velocity]) {
					// calculate the difference in velocity (and divide it in 2)
					float vDiff = ([block velocity] - [nextBlock velocity])/2.0f;
					// increase nextBlock velocity
					[nextBlock setVelocity:[nextBlock velocity]+vDiff];
					// decrease block velocity
					[block setVelocity:[block velocity]-vDiff];
				}
				// ### play sound
				[audioEngine playEffect:soundOfCollidingBlocks];
				// [soundOfCollidingBlocks play];
			}
			break;
		}
			
		case UIDeviceOrientationLandscapeLeft: {
			// check for collision
			if( [[block view] center].x - blockSize + 1.0f < [[nextBlock view] center].x ) {
				// move block adjacent to nextBlock
				[[block view] setCenter:CGPointMake([[nextBlock view] center].x + blockSize, [[block view] center].y)];
				// is block velocity higher than nextBlock velocity
				if ([block velocity] > [nextBlock velocity]) {
					// calculate the difference in velocity (and divide it in 2)
					float vDiff = ([block velocity] - [nextBlock velocity])/2.0f;
					// increase nextBlock velocity
					[nextBlock setVelocity:[nextBlock velocity]+vDiff];
					// decrease block velocity
					[block setVelocity:[block velocity]-vDiff];
				}
				// ### play sound
				[audioEngine playEffect:soundOfCollidingBlocks];
				// [soundOfCollidingBlocks play];
			}
			break;
		}
			
	}
	
}


- (SPBlockView *) createNewBlock {
	// create a new block
	
	// is bomb active - create a bomb and return
	if([self isNextBlockABomb]) {
		// create a bomb
		// needs to be autoreleased as it is allocateed and not released before it is returned
		SPBlockViewTimeBomb *block = [[[SPBlockViewTimeBomb alloc] initWithSize:blockSize] autorelease];
		[self setIsNextBlockABomb:NO];
		// display new letter on game header
		return block;
	}
	
	// get char score and multiply
	
	if( nextBlockLetter == nil ) {
		NSLog(@"Error: nextBlockLetter is nil. (Getting a new letter.)");
		unichar c = [wordList getRandomChar];
		[self setNextBlockLetter:[NSString stringWithFormat:@"%C", c]];
	}

	int p = [wordList getCharValue:[nextBlockLetter characterAtIndex:0]];
	
	// create new block with letter
	// needs to be autoreleased as it is alloced and not released before it is returned
	SPBlockViewLetter *block = [[[SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:nextBlockLetter points:p] autorelease];

	// prepare next letter:
	// get next random char from the dictionary
	unichar c = [wordList getRandomChar];
	NSString *s = [[NSString stringWithFormat:@"%C", c] retain];
	[self setNextBlockLetter:s];
	[s release];

	// display new letter on game header
	[gameHeader printLetter:@" "];
	
	// activete bonus
	if([self isBonusActive]) {
		[block activateBonus];
		[self setIsBonusActive:NO];
	}
		
	return block;
}


- (BOOL)dropNewBlock:(int)inColumn {
	
	// if game is paused return
	if(isGamePaused) return NO;
		
	switch ( (int)currentDeviceOrientation ) {
			
		case UIDeviceOrientationPortrait: {
			
			NSMutableArray *availableColumns = [NSMutableArray arrayWithCapacity:kBlockRows];
			
			// go through all the columns in the game grid
			for( uint x = 0; x < kBlockColumns; x++ ) {
				// get pointer to block view
				SPBlockView *b = [[gameGrid objectAtIndex:x] objectAtIndex:kBlockRows-1];
				// continue if the block is NOT empty (and if the occupied block is not falling)
				if( ![b isEqual:[NSNull null]] ) continue;
				// the column is empty (at the top), save the number of this column
				[availableColumns addObject:[NSNumber numberWithInt:x]];
			}
			
			if([availableColumns count] == 0) return NO;
			
			int col;
			
			if(inColumn >= 0) {
				NSNumber *n = [NSNumber numberWithInt:inColumn];
				if( [availableColumns containsObject:n] ) {
					col = inColumn;
				} else return NO;
			} else {	
				// if inColumn is -1 use random selection of column		
				col = [[availableColumns objectAtIndex: arc4random() % ( [availableColumns count] )] intValue];
			}
			
			int row = kBlockRows-1;
			
			// create new block
			SPBlockView *block = [self createNewBlock];
			
			// set block goal position
			[block setGoalPosition:CGPointMake(blockSize * col + blockSize / 2.0f + blockOffset.x, gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			
			// move block to one blocks offset from goal position
			[[block view] setCenter:CGPointMake([block goalPosition].x, [block goalPosition].y - blockSize)];
			
			// add block to game grid
			[ [gameGrid objectAtIndex:col] replaceObjectAtIndex:row withObject:block ];
			// add block as subview
			[[self view] insertSubview:[block view] belowSubview:connectingLines];
			
			// update timestamp
			//[block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
			// start to fall
			[block setIsFalling:YES];
			
			// release the allocated block
			// [block release];
			
			break;
		}
			
		case UIDeviceOrientationPortraitUpsideDown: {
			
			NSMutableArray *availableColumns = [NSMutableArray arrayWithCapacity:kBlockRows];
			
			// go through all the columns in the game grid
			for( uint x = 0; x < kBlockColumns; x++ ) {
				// get pointer to block view
				SPBlockView *b = [[gameGrid objectAtIndex:x] objectAtIndex:0];
				// continue if the block is NOT empty (and if the occupied block is not falling)
				if( ![b isEqual:[NSNull null]] ) continue;
				// the column is empty (at the top), save the number of this column
				[availableColumns addObject:[NSNumber numberWithInt:x]];
			}
			
			if([availableColumns count] == 0) return NO;
		
			int col;
			
			if(inColumn >= 0) {
				NSNumber *n = [NSNumber numberWithInt:inColumn];
				if( [availableColumns containsObject:n] ) {
					col = inColumn;
				} else return NO;
			} else {
				// if inColumn is -1 use random selection of column		
				col = [[availableColumns objectAtIndex: arc4random() % ( [availableColumns count] )] intValue];
			}
			
			int row = 0;
			
			// create new block
			SPBlockView *block = [self createNewBlock];
						
			// set block goal position
			[block setGoalPosition:CGPointMake(blockSize * col + blockSize / 2.0f + blockOffset.x, gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			
			// move block to one blocks offset from goal position
			[[block view] setCenter:CGPointMake([block goalPosition].x, [block goalPosition].y + blockSize)];
			
			// add block to game grid
			[ [gameGrid objectAtIndex:col] replaceObjectAtIndex:row withObject:block ];
			// add block as subview
			[[self view] insertSubview:[block view] belowSubview:connectingLines];
			// update timestamp
			//[block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
			// start to fall
			[block setIsFalling:YES];
			
			// rotate block
			
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
			// apply the transform to the block
			block.view.transform = transform;
			
			// release the allocated block
			// [block release];
			
			break;
		}
			
			
			
		case UIDeviceOrientationLandscapeRight: {
			
			NSMutableArray *availableRows = [NSMutableArray arrayWithCapacity:kBlockRows];
			
			// go through the first row in the game grid
			for( uint y = 0; y < kBlockRows; y++ ) {
				// get pointer to block view
				SPBlockView *b = [[gameGrid objectAtIndex:0] objectAtIndex:y];
				// continue if the block is NOT empty (and if the occupied block is not falling)
				if( ![b isEqual:[NSNull null]] ) continue;
				// the column is empty (at the top), save the number of this column
				[availableRows addObject:[NSNumber numberWithInt:y]];
			}
						
			// break if all rows are occupied for drop
			if( [availableRows count] == 0 ) return NO;
			
			int col = 0;
			int row;
			
			if(inColumn >= 0) {
				NSNumber *n = [NSNumber numberWithInt:inColumn];
				if( [availableRows containsObject:n] ) {
					row = inColumn;
				} else return NO;
			} else {
				// if inColumn is -1 use random selection of row
				row = [[availableRows objectAtIndex: arc4random() % ( [availableRows count] )] intValue];
			}
						
			// create new block
			SPBlockView *block = [self createNewBlock];
			 
			// set block goal position
			[block setGoalPosition:CGPointMake(blockSize * col + blockSize / 2.0f + blockOffset.x , gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			// move block to one blocks offset from goal position
			[[block view] setCenter:CGPointMake([block goalPosition].x - blockSize, [block goalPosition].y)];
			
			// add block to game grid
			[ [gameGrid objectAtIndex:col] replaceObjectAtIndex:row withObject:block ];
			// add block as subview
			[[self view] insertSubview:[block view] belowSubview:connectingLines];
			// update timestamp
			//[block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
			// start to fall
			[block setIsFalling:YES];
			
			// rotate block
			
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI + M_PI/2.0f);
			// apply the transform to the block
			block.view.transform = transform;
			
			// release the allocated block
			// [block release];
			
			break;
			
		}
			
		case UIDeviceOrientationLandscapeLeft: {
			
			NSMutableArray *availableRows = [NSMutableArray arrayWithCapacity:kBlockRows];
			
			// go through the first row in the game grid
			for( uint y = 0; y < kBlockRows; y++ ) {
				// get pointer to block view
				SPBlockView *b = [[gameGrid objectAtIndex:kBlockColumns-1] objectAtIndex:y];
				// continue if the block is NOT empty (and if the occupied block is not falling)
				if( ![b isEqual:[NSNull null]] ) continue;
				// the column is empty (at the top), save the number of this column
				[availableRows addObject:[NSNumber numberWithInt:y]];
			}
			
			// break if all rows are occupied for drop
			if( [availableRows count] == 0 ) return NO;
			
			int col = kBlockColumns-1;
			int row;
			
			if(inColumn >= 0) {
				NSNumber *n = [NSNumber numberWithInt:inColumn];
				if( [availableRows containsObject:n] ) {
					row = inColumn;
				} else return NO;
			} else {
				// if inColumn is -1 use random selection of row
				row = [[availableRows objectAtIndex: arc4random() % ( [availableRows count] )] intValue];
			}
						
			// create new block
			SPBlockView *block = [self createNewBlock];
						 
			// set block goal position
			[block setGoalPosition:CGPointMake(blockSize * col + blockSize / 2.0f + blockOffset.x , gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			// move block to one blocks offset from goal position
			[[block view] setCenter:CGPointMake([block goalPosition].x + blockSize, [block goalPosition].y)];
			
			// add block to game grid
			[ [gameGrid objectAtIndex:col] replaceObjectAtIndex:row withObject:block ];
			// add block as subview
			[[self view] insertSubview:[block view] belowSubview:connectingLines];
			// update timestamp
			//[block setTimeStamp:[NSDate timeIntervalSinceReferenceDate]];
			// start to fall
			[block setIsFalling:YES];
			
			// rotate block
			
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2.0f);
			// apply the transform to the block
			block.view.transform = transform;
			
			// release the allocated block
			// [block release];
			
			break;
			
		}
			
	}
	
	// play birth cry of the new block
	// ### play sound
	[audioEngine playEffect:soundOfNewBlock];
	// [soundOfNewBlock play];
	return YES;
}

- (void)updateBlockDropTimers {
	// change drop frequency
	if(dropBlockFrequency*kDropFrequencyMultiplier > kMaxDropFrequency) dropBlockFrequency *= kDropFrequencyMultiplier;
	else dropBlockFrequency = kMaxDropFrequency;
	
	// reset drop block pause
	dropBlockPauseUntilTime = [NSDate timeIntervalSinceReferenceDate] + [self dropPauseTime];
	
	// change drop pause time
	if(dropPauseTime * kDropPauseTimeMultiplier > kDropPauseTimeLimit) dropPauseTime *= kDropPauseTimeMultiplier;
	else dropPauseTime = kDropPauseTimeLimit;
	
	isDropPaused = YES;
}


- (double)getDropBlockPauseUntilTime {
	return dropBlockPauseUntilTime - [NSDate timeIntervalSinceReferenceDate];
}

- (double)getDropNextBlockAtTime {
	return dropNextBlockAtTime - [NSDate timeIntervalSinceReferenceDate];
}


- (void) pauseGame {
	
	NSLog(@"••• PAUSE GAME •••");
	
	isGamePaused = YES;
	
	[self unselectBlocks];
	
	[self unloadAudio];
	
	// save those:
	if( dropBlockPauseUntilTime ) dropBlockPauseUntilTime = dropBlockPauseUntilTime - [NSDate timeIntervalSinceReferenceDate];
	if( dropNextBlockAtTime ) dropNextBlockAtTime = dropNextBlockAtTime - [NSDate timeIntervalSinceReferenceDate];
	
	for(int i = 0; i<kBlockColumns; i++) {
		if(gameOverTimers[i] > 0.) {
			gameOverTimers[i] = (gameOverTimers[i] + kGameOverTimerLimit) - [NSDate timeIntervalSinceReferenceDate]; 
			NSLog(@"gameOverTimer[%i] %f", i, gameOverTimers[i]);
		}
	}
	
	if( !pauseViewController ) {
		SPPauseViewController *temp_pauseViewController = [[SPPauseViewController alloc] init];
		[self setPauseViewController:temp_pauseViewController];
		[temp_pauseViewController release];
		[pauseViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
		//[pauseViewController setGameViewController:self];
		[pauseViewController setTitle:@"The Pause View Controller"];
	}
	
	[[self navigationController] presentModalViewController:pauseViewController animated:NO]; 

	NSLog(@"••• PAUSE GAME FINISHED •••");

}

- (void) resumeFromPausedGame {
	// is game really paused?
	if(!isGamePaused) return;
		
	// go through the game grid
	for(uint x = 0; x < kBlockColumns; x++ ) {
		// start counting on 1 (jump the last row)
		for(uint y = 0; y < kBlockRows; y++) {
			
			// get pointer to current block
			SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];
			
			// is current block empty then continue to next block
			if([block isEqual:[NSNull null]]) continue;
			
			// update animation on bomb
			if([block isMemberOfClass:[SPBlockViewTimeBomb class]]) {
				[block animateFadeInFadeOutLoop];
			}
			
			if([block isBombed]) {
				// blow up the bombed block right away!
				[self fragExplosionOnBlock:block];
			}
		}
	}
	
	[self loadAudio];
	
	// reset those:
	if(dropBlockPauseUntilTime) dropBlockPauseUntilTime = [NSDate timeIntervalSinceReferenceDate] + dropBlockPauseUntilTime;
	if(dropNextBlockAtTime) dropNextBlockAtTime = [NSDate timeIntervalSinceReferenceDate] + dropNextBlockAtTime;
	
	// update game over timers
	for(int i = 0; i<kBlockColumns; i++) {
		if(gameOverTimers[i] > 0.) { 
			gameOverTimers[i] = (gameOverTimers[i] - kGameOverTimerLimit) + [NSDate timeIntervalSinceReferenceDate]; 
			NSLog(@"gameOverTimer[%i] %f", i, gameOverTimers[i]);
		}
	}	
	
	// update global game timer
	[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];	

	// game is not paused
	isGamePaused = NO;
}


- (void) setGoalPositionAndSwitchBlocksInColumn:(uint)col atRow:(uint)row withBlock:(SPBlockView *)block {
	// switch blocks
	switch ( (int)currentDeviceOrientation) {
			
		case UIDeviceOrientationPortrait: {
			// UIDeviceOrientationPortrait
			// set new block goal position, calculate y from bottom of game screen
			[block setGoalPosition:CGPointMake( (blockSize * col + blockSize / 2.0f) + blockOffset.x, gameScreenRect.size.height - (blockSize * (row-1) + blockSize / 2.0f) + blockOffset.y )];
			// swap aBlock with the empty space in game grid
			[self swapBlockAtX1:(uint)col Y1:(uint)row withX2:(uint)col Y2:(uint)row-1];
			break;
		}							
		case UIDeviceOrientationPortraitUpsideDown: {
			// set new block goal position, calculate y from bottom of game screen
			[block setGoalPosition:CGPointMake( (blockSize * col + blockSize / 2.0f) + blockOffset.x, gameScreenRect.size.height - (blockSize * (row+1) + blockSize / 2.0f) + blockOffset.y)];
			// swap aBlock with the empty space in game grid
			[self swapBlockAtX1:(uint)col Y1:(uint)row withX2:(uint)col Y2:(uint)row+1];
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			// set new block goal position, calculate y from bottom of game screen
			[block setGoalPosition:CGPointMake( (blockSize * (col-1) + blockSize / 2.0f) + blockOffset.x, gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			// swap aBlock with the empty space in game grid
			[self swapBlockAtX1:(uint)col Y1:(uint)row withX2:(uint)col-1 Y2:(uint)row];
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			// set new block goal position, calculate y from bottom of game screen
			[block setGoalPosition:CGPointMake( (blockSize * (col+1) + blockSize / 2.0f) + blockOffset.x, gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			// swap aBlock with the empty space in game grid
			[self swapBlockAtX1:(uint)col Y1:(uint)row withX2:(uint)col+1 Y2:(uint)row];
			break;
		}
			
	}
}

- (void) swapBlockAtX1:(uint)x1 Y1:(uint)y1 withX2:(uint)x2 Y2:(uint)y2 {
	// error check
	if(x1 >= kBlockColumns) {
		NSLog(@"\n\n ERROR: Index out of bounds in swapBlockAt:%i,%i withBlockAt:%i,%i\n\n", x1, y1, x2, y2);
		return;
	}
	if(y1 >= kBlockRows) {
		NSLog(@"\n\n ERROR: Index out of bounds in swapBlockAt:%i,%i withBlockAt:%i,%i\n\n", x1, y1, x2, y2);
		return;
	}
	if(x2 >= kBlockColumns) {		
		NSLog(@"\n\n ERROR: Index out of bounds in swapBlockAt:%i,%i withBlockAt:%i,%i\n\n", x1, y1, x2, y2);
		return;
	}
	
	if(y2 >= kBlockRows) {
		NSLog(@"\n\n ERROR: Index out of bounds in swapBlockAt:%i,%i withBlockAt:%i,%i\n\n", x1, y1, x2, y2);
		return;
	}
	// make swap (retain objects, otherwise one of the objects will be lost in the switch)
	SPBlockView *blockA = [[[gameGrid objectAtIndex:x1] objectAtIndex:y1] retain];
	SPBlockView *blockB = [[[gameGrid objectAtIndex:x2] objectAtIndex:y2] retain];
	
	// ok, make the swap
	[[gameGrid objectAtIndex:x1] replaceObjectAtIndex:y1 withObject:blockB];
	[[gameGrid objectAtIndex:x2] replaceObjectAtIndex:y2 withObject:blockA];
	
	// release the retained objects
	[blockA release];
	[blockB release];
	
}




#pragma mark -
#pragma mark word and text search

- (void) acceptWord {
	
	if(isGameOver || isGamePaused) return;
	
	// do not accept word if user is still touching a block
	if(isUserTouchingBlock) {	
		[self resetTouchTimerTo:kTouchedBlockDelay];
		return;
	}
	 
	if(isBombActive) {
		int counter = 0;
		for(SPBlockView *b in [self selectedBlocks]) {
			// move subview to top (but below the game header interface)
			[[self view] insertSubview:[b view] belowSubview:gameHeader];
			// [[self view] insertSubview:b belowSubview:infoBar];
			// explosion effect
			NSTimer *t = [ NSTimer scheduledTimerWithTimeInterval:counter * 0.2 target:self selector:@selector( fragExplosion: ) userInfo:b repeats:NO ];				
			[timers addObject:t];
			// hide the icon
			counter++;
		}
		[self unselectBlocks];
		[self setIsBombActive:NO];
		return;		
	}
		
	// if the selected word is too short - unselect and return
	if( [[self selectedBlocks] count] < kShortestWordLength ) {
		[self unselectBlocks];
		return;
	}
	
	// create a mutable string
	NSMutableString *word = [[NSMutableString alloc] initWithString:@""]; 
	// build a string from the selected chars
	for(int i = 0; i<[selectedBlocks count]; i++) {
		[word appendString:[[selectedBlocks objectAtIndex:i] letter]];
	}
	
	// check word against dictionary
	if([wordList checkWord:word]) {
		// SUCCESS! Add score and remove all the selected blocks
		NSLog(@"\n\nWord: %@ is accepted!\n\n", word);

		
		// ••• bonus stuff •••
		
		[self checkForBonusAfterWord];
		[self removeSelectedBlocks];
		
		//if( bonusChainCountDown > 0 ) {
		bonusChainSelectionFlag = YES;
		//NSLog(@"••• Turning ON bonusChainSelectionFlag •••");		
		//}

		// •••
		
		
		// save the succesfull word in user word list
		[userWords addObject:[NSString stringWithString:word]];		

	} else {
		[self unselectBlocks];
	}
		
	// release word
	[word release];
}

- (void) addScore:(int)scoreValue {
	score = score + scoreValue;
	[gameHeader updateScore:score];
	[self checkForBombTrigger];
}



#pragma mark -
#pragma mark chain bonus methods

- (void) resetBonusCounter {
	// Should not be set to 0
	bonusCounter = 1;
}

- (void) checkForBonusAfterWord {
	// called each time a word is accepted
	if( bonusChainCountDown > 0 || bonusChainSelectionFlag ) {
		[self showBonusAlert];
		// bonus counter should never be 0
		if( bonusCounter == 0 )[self resetBonusCounter];
		// increase the bonus counter
		bonusCounter++;
	} 
	// add number of selected blocks to counter
	bonusChainCountDown = bonusChainCountDown + [selectedBlocks count];	
}

- (void) checkForBonusAfterBlock {

	if( [selectedBlocks count] > 0 ) return;
	if( bonusChainCountDown > 0 ) return;
	if( bonusCounter <= 1) {
		bonusChainSelectionFlag = NO;
		return;
	}

	int s = 0;
	
	for (int i=0; i<bonusCounter; i++) {
		int j = [userWordScores count] - 1 - i;
		s = s + [[userWordScores objectAtIndex:j] intValue];
	}
	// multiply bonus with number of words in chain
	s = s * bonusCounter;
	
	
	[bonusView setScore:s];
//	score = score + s;
	
	[bonusView showChainBonus];
	[bonusView setPausePrinterUntilTime:[NSDate timeIntervalSinceReferenceDate] + 1.5];
		
	bonusChainSelectionFlag = NO;

	[self resetBonusCounter];
}

- (void) showChainBonusView {
	// slide in the chain bonus view
	[bonusView setIsActive:YES];
	[bonusView showBonusMultiplier];
	[bonusView setAlpha:0.0];
	[bonusView setHidden:NO];
	[UIView beginAnimations:@"showChainBonusView" context:NULL]; {
		[UIView setAnimationDuration:0.2];
		//[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		//[bonusView setCenter:[bonusView goalPoint]];
		[bonusView setAlpha:1.0];
	} [UIView commitAnimations];
}

- (void) hideChainBonusView:(float)delay {
	if(bonusChainCountDown > 0 || bonusChainSelectionFlag) return;
	// slide out the chain bonus view
	[bonusView setIsActive:NO];
	[UIView beginAnimations:@"hideChainBonusView" context:NULL]; {
		[UIView setAnimationDelay:delay];
		[UIView setAnimationDuration:0.2];
		//[UIView setAnimationDelegate:self];
		//[UIView setAnimationDidStopSelector:@selector(bonusViewSetHiddenToYES)];
		//[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		//[bonusView setCenter:[bonusView outsidePoint]];
		[bonusView setAlpha:0.0];
	} [UIView commitAnimations];
}

- (void) showBonusAlert {
	// show the bonus alert
	[bonusAlertView setHidden:NO];
	[bonusAlertView setAlpha:0.0];
	[bonusAlertView setCenter:[[self view] center]];
	
	CGAffineTransform transformScale;	
	transformScale = CGAffineTransformMakeScale(0.5f, 0.5f);
	[bonusAlertView setTransform:transformScale];
	
	transformScale = CGAffineTransformMakeScale(1.0f, 1.0f);	
	
	[UIView beginAnimations:@"showBonusAlert" context:NULL]; {
		[UIView setAnimationDuration:0.15];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideBonusAlert)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[bonusAlertView setAlpha:0.75];
		[bonusAlertView setTransform:transformScale];
	} [UIView commitAnimations];
	
	[audioEngine playEffect:soundOfChainBonus];

}

- (void) hideBonusAlert {
	CGAffineTransform transformScale;	
	transformScale = CGAffineTransformMakeScale(0.5f, 0.5f);

	[UIView beginAnimations:@"hideBonusAlert" context:NULL]; {
		[UIView setAnimationDelay:0.1];
		[UIView setAnimationDuration:0.5];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(revealBonus)];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[bonusAlertView setTransform:transformScale];
		[bonusAlertView setAlpha:0.2];
		[bonusAlertView setCenter:[bonusView center]];
	} [UIView commitAnimations];
}

- (void) revealBonus {
	[bonusAlertView setHidden:YES];
	// show bonus view
	if(![bonusView isActive])[self showChainBonusView];
	[bonusView setBonusMultiplier:bonusCounter];
}

- (int) getWordBonus {
	int lCount = [selectedBlocks count];
	
	int bonusValue = 0;
	
	if(lCount >= 10) {
		bonusValue = 200000 + (lCount - 10) * 100000;
	} else if(lCount == 9) {
		bonusValue = 150000;
	} else if(lCount == 8) {
		bonusValue = 100000;
	} else if(lCount == 7) {
		bonusValue = 50000;
	} else if(lCount == 6) {
		bonusValue = 25000;
	} else if(lCount == 5) {
		bonusValue = 10000;
	} else if(lCount == 4) {
		bonusValue = 1000;
	}
	
	return bonusValue;
}


// - (void) bonusAlertSetHiddenToYES { [bonusAlertView setHidden:YES]; }



- (void) moveBonusView {
	switch ((int)currentDeviceOrientation) {
		case UIDeviceOrientationPortrait: {
			[self moveBonusViewToTop];
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			[self moveBonusViewToBottom];
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			[self moveBonusViewToRight];
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			[self moveBonusViewToLeft];
			break;
		}
	}
}

- (void) moveBonusViewToTop {
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(0.0f);
	// apply the transform to the block
	bonusView.transform = transform;
	
//	if([bonusView isActive]) {
		[bonusView setCenter:[bonusView goalPointTop]];
//	} else {
//		[bonusView setCenter:[bonusView outsidePoint]];
//	}
	
}

- (void) moveBonusViewToBottom {		
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
	// apply the transform to the block
	bonusView.transform = transform;
	
//	if([bonusView isActive]) {
		[bonusView setCenter:[bonusView goalPointBottom]];
//	} else {
//		[bonusView setCenter:CGPointMake([bonusView goalPointBottom].x, gameScreenRect.size.height + [bonusView frame].size.height)];
//	}
}

- (void) moveBonusViewToRight {
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI + M_PI / 2.0f);
	// apply the transform to the block
	bonusView.transform = transform;
	
//	if([bonusView isActive]) {
		[bonusView setCenter:[bonusView goalPointRight]];
//	} else {
//		[bonusView setCenter:CGPointMake(gameScreenRect.size.width + [bonusView frame].size.height, [bonusView goalPointRight].y)];
//	}
}

- (void) moveBonusViewToLeft {
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
	// apply the transform to the block
	bonusView.transform = transform;
	
//	if([bonusView isActive]) {
		[bonusView setCenter:[bonusView goalPointLeft]];
//	} else {
//		[bonusView setCenter:CGPointMake(-[bonusView frame].size.height, [bonusView goalPointLeft].y)];
//	}
}



#pragma mark -
#pragma mark word score methods

- (void) showWordScoreLabel {
	if(![selectedBlocks count]) return;
	[wordScoreLabel setHidden:NO];
	[wordScoreLabel setAlpha:0.0];
	CGRect r = [self getSelectedBoundingRect];
	float x = r.origin.x + r.size.width * 0.5;
	float y = r.origin.y + r.size.height * 0.5;
	
	x = MAX([wordScoreLabel frame].size.width * 0.5, x);
	x = MIN(gameScreenRect.size.width - [wordScoreLabel frame].size.width * 0.5, x);
	y = MAX([wordScoreLabel frame].size.height * 0.5, y);
	y = MIN(gameScreenRect.size.height - [wordScoreLabel frame].size.height * 0.5, y);
	
	[wordScoreLabel setCenter: CGPointMake(x, y)];
	
	CGPoint goalPoint = CGPointMake(x, y - blockSize);
	
	switch ((int)currentDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:
			goalPoint = CGPointMake(x, y + blockSize);
			break;
		case UIDeviceOrientationLandscapeRight:
			goalPoint = CGPointMake(x - blockSize, y);
			break;
		case UIDeviceOrientationLandscapeLeft:
			goalPoint = CGPointMake(x + blockSize, y);
			break;			
	}
		
	[UIView beginAnimations:@"showWordScore" context:NULL]; {
		[UIView setAnimationDelay:0.5];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[wordScoreLabel setAlpha:0.75];
		[wordScoreLabel setCenter:goalPoint];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideWordScoreLabel)];
	} [UIView commitAnimations];
	
	[audioEngine playEffect:soundOfWordBonus];

}

- (void) hideWordScoreLabel {
	[UIView beginAnimations:@"hideWordScore" context:NULL]; {
		[UIView setAnimationDelay:0.75];
		[UIView setAnimationDuration:0.2];
		[wordScoreLabel setAlpha:0.0];
	} [UIView commitAnimations];	
}

- (CGRect) getSelectedBoundingRect {
	// set r to right lower corner at size 0
	CGRect r = CGRectMake(gameScreenRect.size.width, gameScreenRect.size.height, 0.0, 0.0);
	// calculate smallest bounding rect for all selected blocks
	for(SPBlockView *b in selectedBlocks) {
		r.origin.x = MIN(r.origin.x, [[b view] frame].origin.x );
		r.origin.y = MIN(r.origin.y, [[b view] frame].origin.y );
		r.size.width = MAX(r.size.width, [[b view] frame].origin.x + [[b view] frame].size.width);
		r.size.height = MAX(r.size.height, [[b view] frame].origin.y + [[b view] frame].size.height);
	}
	// adjust width and height
	r.size.width -= r.origin.x;
	r.size.height -= r.origin.y;
	// returns a rect of size 0 if no blocks are selected.
	return r;
}

		 

#pragma mark -
#pragma mark touch blocks


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event { 
	
	// can't touch any block if game is paused
	if(isGamePaused) return;
	
	// can't touch any block if game is over
	if(isGameOver) return;
	
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint p = [touch locationInView:[self view]];
	
	if([self isGameHeaderTouched:p]) {
		[gameHeader setIsTouched:YES];
		return;
	}
	
	// reset the double touch
	[self setIsBlockDoubleTouched:NO];
	
	// reset the slide selected flag
	[self setIsBlockSlideSelected:NO];
	
	// calculate touched row and column in game grid
	int row = (uint)((gameScreenRect.size.height - p.y + (blockOffset.y * 1.5f)) / blockSize);
	int col = (uint)((p.x + (blockOffset.x * 1.5f)) / blockSize);
		
	// touch block
	if( [self tryToSelectTouchedBlockInColumn:col atRow:row withPoint:p] ) {
		// get the newly touched block
		SPBlockView *touchedBlock = [selectedBlocks lastObject];
		
		if([selectedBlocks count]==1) {
			// start new path
			//[connectingLines newPathAtXPos:[[touchedBlock view] center].x yPos:[[touchedBlock view] center].y];
			[connectingLines newPathAtXPos:[touchedBlock goalPosition].x yPos:[touchedBlock goalPosition].y];
			// user has started to select a new word while the last word is still active
		} else {
			// update the current path
			//[connectingLines addLineAtXPos:[[touchedBlock view] center].x yPos:[[touchedBlock view] center].y];
			[connectingLines addLineAtXPos:[touchedBlock goalPosition].x yPos:[touchedBlock goalPosition].y];
		}
	}
	
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event { 
	
	if(isGamePaused) return;

	// get the current touch screen location
	UITouch *touch = [[event allTouches] anyObject];
	CGPoint p = [touch locationInView:[self view]];
	
	if([gameHeader isTouched]) {
		// if still touched, then let is be touched and return
		if([self isGameHeaderTouched:p]) return;
		// game header is no longer touched
		[gameHeader setIsTouched:NO];
	}
	
	// is user is not touching any blocks, return
	if(![self isUserTouchingBlock]) return;
	
	// count the number of currently selected blocks
	uint touchedBlocksArrayCount = [[self selectedBlocks] count];
	
	// if no blocks are selected, then return
	if( touchedBlocksArrayCount == 0 ) return;
	
	// get the last selected block
	SPBlockView *lastBlock = [[self selectedBlocks] objectAtIndex:touchedBlocksArrayCount-1];

	// calculate touched row and column in game grid
	int row = (uint)((gameScreenRect.size.height - p.y + (blockOffset.y * 1.5f)) / blockSize);
	int col = (uint)((p.x + (blockOffset.x * 1.5f)) / blockSize);
	 
	// are indexes within the boundary of the game grid?
	if( col >= kBlockColumns || row >= kBlockRows ) return;
	
	// get pointer to currently touched object
	SPBlockView *block = [[gameGrid objectAtIndex:col] objectAtIndex:row];
	
	// if the blocks are the same, then return
	if( [ lastBlock isEqual:block ] ) return;
	
	// if currently selected block is empty
	if( [ block isEqual:[NSNull null] ] ) return;
	
	// a new block is touched (but not neccesarily selected) by sliding
	[self setIsBlockSlideSelected:YES];
	
	// try to select the block
	if( [self tryToSelectTouchedBlockInColumn:col atRow:row withPoint:p] ) {
		// reset the double touch
		[self setIsBlockDoubleTouched:NO];	
		// user is slide selecting - don't use the touchtimer
		[self stopTouchTimer];
		// update the current path
		[connectingLines addLineAtXPos:[[block view] center].x yPos:[[block view] center].y];
	}
	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event { 
	
	if(isGamePaused) return;

	if([gameHeader isTouched]) {
		[gameHeader switchShyness];
		if([gameHeader isShy]) {
			[self hideGameHeader];
		} else {
			[self showGameHeader];
		}
		[gameHeader setIsTouched:NO];
		return;
	}
	
	
	// restart the touch timer (should come first!)
	if(!isBombActive)[self resetTouchTimerTo:kTouchedBlockDelay];
	
	
	// user is not touching block any more
	[self setIsUserTouchingBlock:NO];	
	
	// check for double touch
	if( isBlockDoubleTouched || isBlockSlideSelected ) {
		[self stopTouchTimer];
		[self acceptWord];
	}
		
	// reset slide selection
	[self setIsBlockSlideSelected:NO];
	// reset double touch
	[self setIsBlockDoubleTouched:NO];
	
}


// actions to take when a user touches a block
- (BOOL) tryToSelectTouchedBlockInColumn:(uint)col atRow:(uint)row withPoint:(CGPoint)p {
	
	// are indexes within the boundary of the game grid?
	if( col >= kBlockColumns ) return NO;
	if( row >= kBlockRows ) return NO;
	
	
	// get pointer to block object
	SPBlockView *block = [[gameGrid objectAtIndex:col] objectAtIndex:row];
	
	// if user has touched empty area, drop a bonus block
	if( [ block isEqual:[NSNull null] ] ) {
		
		// drop a new (bonus) block
		if (currentDeviceOrientation == UIDeviceOrientationPortrait || currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
			
			// activate bonus
			[self setIsBonusActive:YES];
			if(![self dropNewBlock:col]) { 
				[self setIsBonusActive:NO];
				return NO;
			}
			[self flashColumnMarker:col];
			// update drop timers
			[self updateBlockDropTimers];
			return NO;
			
		} else if (currentDeviceOrientation == UIDeviceOrientationLandscapeLeft || currentDeviceOrientation == UIDeviceOrientationLandscapeRight) {
			
			// activate bonus
			[self setIsBonusActive:YES];
			if(![self dropNewBlock:row]) {
				[self setIsBonusActive:NO];
				return NO;
			}
			[self flashColumnMarker:row];
			// update drop timers
			[self updateBlockDropTimers];
			return NO;
		}
		
	}
		
	// check if selected block is a time bomb block
	if([block isMemberOfClass:[SPBlockViewTimeBomb class]]) {
		// a bomb can only be the first selected block
		if([selectedBlocks count] > 0) {
			// is the user slide selecting, then return no
			if([self isBlockSlideSelected]) return NO;
			// user is TOUCH selecting a new word, accept the old
			[self stopTouchTimer];
			[self acceptWord];
		}
		// touch, select and add the block
		[self touchBlock:block];
		[self startTimeBomb:block];
		return NO; // return NO - returning YES will draw a line to next block (we don't need lines in bomb mode)
	}
	
	
	// if bomb is active
	if( [self isBombActive] ) {
		
		if([selectedBlocks count] > [[selectedBlocks objectAtIndex:0] maxSelectedBlocks]) {
			//[self stopTouchTimer];
			//[self acceptWord];
			return NO;
		}
		
		// if the block is a previously selected block, return NO
		int indexOfSelectedBlock = [selectedBlocks indexOfObject:block];
		// is the block already touched?
		if( indexOfSelectedBlock != NSNotFound ) {
			return NO;
		}
		
		// no need to check if blocks are one step away from the block, in bomb mode any blocks can be selected
		
		// is the touch at the center of the block
		if( isBlockSlideSelected && [selectedBlocks count] > 0 ) {
			// check x distance from touch x-location
			if( MAX( ABS(p.x - [[block view] center].x), ABS(p.y - [[block view] center].y) ) > ([block blockSize] - ([block touchPadding]*2.0f)) / 2.0f ) {
				return NO;
			}
		}
		
		// if block is moving return
		if( [block isFalling] ) return NO;
		
		// if block is marked for deletion return
		if( [block isDeleted] ) return NO;

		
		/*
		// if the user is doing a successfull "double touch" on the last block, the current word is accepted
		if( [block isTouched] && !isBlockSlideSelected ) {
			// check if it is the last block or not - accept word if last block
			if( [ block isEqual:[ [self selectedBlocks] lastObject] ] ) {
				NSLog(@"double touch!");
				[self setIsBlockDoubleTouched:YES];
				[self setIsUserTouchingBlock:YES];
			}
			return NO;
		}
		*/
		
		// touch, select and add the block
		[self touchBlock:block];
		[block setIsBombed:YES];
		
		// the first block is the bomb
		[[selectedBlocks objectAtIndex:0] updateCounter:[selectedBlocks count]-1];
		
		return NO;
		
	}
	
	
	// if the block is a previously selected block, shorten the selection
	int indexOfSelectedBlock = [selectedBlocks indexOfObject:block];
	// is the block already touched and it's not the last block?
	if( indexOfSelectedBlock != NSNotFound && indexOfSelectedBlock != [selectedBlocks count]-1 ) {
		// shorten the selection
		[self shortenSelection:(uint)indexOfSelectedBlock];
		return NO;
	}
	
	
	
	// are indexes one step from last selected block?
	if([selectedBlocks count] > 0) {
		SPGridPos lastPos = [self findBlock:[selectedBlocks lastObject]];
		if( ABS( (int)col - (int)lastPos.x ) > 1 || ABS( (int)row - (int)lastPos.y ) > 1 ) {
			// is the user slide selecting, then return no
			if([self isBlockSlideSelected]) return NO;
			// user is TOUCH selecting a new word, accept the old
			[self stopTouchTimer];
			[self acceptWord];
		}
	}
	
	
	
	// is the touch at the center of the block
	if( isBlockSlideSelected && [selectedBlocks count] > 0 ) {
		// check x distance from touch x-location
		if( MAX( ABS(p.x - [[block view] center].x), ABS(p.y - [[block view] center].y) ) > ([block blockSize] - ([block touchPadding]*2.0f)) / 2.0f ) {
			return NO;
		}
	}	
	
	// if block is moving return
	if( [block isFalling] ) return NO;
	
	// if block is marked for deletion return
	if( [block isDeleted] ) return NO;
	
	// if the user is doing a successfull "double touch" on the last block, the current word is accepted
	if( [block isTouched] && !isBlockSlideSelected ) {
		// check if it is the last block or not - accept word if last block
		if( [ block isEqual:[ [self selectedBlocks] lastObject] ] ) {
			NSLog(@"double touch!");
			[self setIsBlockDoubleTouched:YES];
			[self setIsUserTouchingBlock:YES];
		}
		return NO;
	}
		
	// fine. then touch, select and add the block
	[self touchBlock:block];
	
	return YES;
}

- (void)touchBlock:(SPBlockView *)block {
	// mark block as touched
	[block touchBlock];
	
	// add block to array of currently touched blocks
	[selectedBlocks addObject:block];
	
	[self setIsUserTouchingBlock:YES];
	
	if(!isBlockSlideSelected || !isBombActive) [self resetTouchTimerTo:kTouchedBlockDelay];
	else if([block isMemberOfClass:[SPBlockViewTimeBomb class]]) [self resetTouchTimerTo:kTouchedBlockDelay * (float)[(SPBlockViewTimeBomb*)block maxSelectedBlocks]];
	
	// ### play sound
	// float pitch = MIN(10.0, 1.0f + (float)[selectedBlocks count] * 0.5);
	// [soundOfTouchingBlock setPitch:pitch];
	[audioEngine playEffect:soundOfTouchingBlock];	
	// [soundOfTouchingBlock play];
}


// shorten the array of selected blocks
- (void) shortenSelection: (uint)index {
	// we know index if more than 0 (uint)
	// if index is the same or more than the last selected block return
	if ( index >= [selectedBlocks count] - 1 ) return;
	
	// untouch the blocks	
	for( int i = index+1; i < [selectedBlocks count]; i++ ) {
		[[selectedBlocks objectAtIndex:i] unTouchBlock];
	}
	
	// clear connecting lines between the blocks that are deleted
	[connectingLines clearPointsOfPath:[selectedBlocks count] - (index+1)];
	
	// make selection range
	NSRange r = NSMakeRange( (int)index+1, [selectedBlocks count] - (index+1) );
	
	// remove the selection range from array
	[selectedBlocks removeObjectsInRange:r];
}

// unselect all the selected blocks
- (void) unselectBlocks {

	// before pause; mark all bombs for deletion then return
	if([self isBombActive] && [self isGamePaused]) {
		for(SPBlockView *block in selectedBlocks) {
			[block setIsMarkedForDeletion:YES];
		}
		[selectedBlocks removeAllObjects];
		[self setIsBombActive:NO];
		return;
	}
	
	// ok unselect all blocks
	for(SPBlockView *block in selectedBlocks) {
		if(![self isBombActive])[block unTouchBlock];
		[block shakeReset];
		[[block view] setCenter:[block goalPosition]];
	}
	// remove all objects from array
	[selectedBlocks removeAllObjects];
	// clear the connecting lines
	[connectingLines clearPath];
	
	if(bonusCounter > 1 && bonusChainCountDown <= 0) {
		// a bonus has been built up, cash it in
		[self checkForBonusAfterBlock];
	}

	bonusChainSelectionFlag = NO;
	// NSLog(@"••• Turning OFF bonusChainSelectionFlag •••");

	[self resetBonusCounter];
	[self setBonusChainCountDown:0];
	
	// if the orientation has changed while blocks were selected
	if(deviceOrientationChangedWhileSelection) [self orientationDidChange];
}

// find a block in the game grid
- (SPGridPos)findBlock:(SPBlockView *)block {
	if(!gameGrid) return SPGridPosMake(0, 0);

	// loop through all columns
	uint x, y = 0;
	//for (x = 0; x < kBlockColumns; x++) {
	for (x = 0; x < [gameGrid count]; x++) {
		// try to find block in column
		y = [[gameGrid objectAtIndex:x] indexOfObject:block];
		// block is found (if result is NOT NotFound...)
		if( y != NSNotFound ) break;
	}
	return SPGridPosMake(x, y);
}







#pragma mark -
#pragma mark touch timer

- (void) resetTouchTimerTo:(double)t {
	
	// t is usually set to kTouchedBlockDelay	
	if( [self touchTimer] ){
		[[self touchTimer] invalidate];
		[self setTouchTimer:nil];
	}
	
	touchTimerTriggersAtDate = [NSDate timeIntervalSinceReferenceDate] + t;
	
	// create the touch timer
	NSTimer *temp_touchTimer = [ [ NSTimer scheduledTimerWithTimeInterval:t target:self selector:@selector( acceptWord ) userInfo:nil repeats:NO ] retain];	
	[self setTouchTimer:temp_touchTimer];
	[temp_touchTimer release];
	
}


// stop the touch timer
- (void) stopTouchTimer {
	// invalidate and stop the touch timer
	if(touchTimer){
		[[self touchTimer] invalidate];
		[self setTouchTimer:nil];
	}	
}





#pragma mark -
#pragma mark removing blocks in five steps

// action to take when the user has successfully selected a series of blocks
- (void) removeSelectedBlocks {
		
	// stop the current touch timer
	[self stopTouchTimer];

	if([selectedBlocks count] == 0) return;

	// calculate simple bonus based on the number of letters in the word
//	int wordBonus = [selectedBlocks count] * kBlockBonus;
	
	int wordBonus = [self getWordBonus];
	
	if(wordBonus > 0) {
		[self addScore:wordBonus];
		// set the word bonus score as text
		[wordScoreLabel setText:[NSString stringWithFormat:@"+%i", wordBonus]];
		// adjust label size to match the current text
		[self adjustWordScoreLabel];
		// show and animate the word score label
		[self showWordScoreLabel];
	}
	
	int totalWordScore = wordBonus;
	
	int counter = 0;
	for(SPBlockViewLetter *block in selectedBlocks) {
		// find b in array
		// SPGridPos p = [self findBlock:block];
		[block setIsDeleted:YES];
		// delayed removal of block
		
		// old score algorithm
		// [block multiplyScoreWithBonus:([selectedBlocks count]-kShortestWordLength) * 2];
		
		// more fun score algorithm
		[block multiplyScoreWithBonus:[selectedBlocks count]*10];
		
		totalWordScore = totalWordScore + [block score];
		
		//score = score + [block score];
		//[gameHeader updateScore:score];
		
		[self addScore:[block score]];
				
		// [infoBar updateScore:score];
		
		// NSArray *gridPos = [ NSArray arrayWithObjects:[ NSNumber numberWithInt:p.x ], [ NSNumber numberWithInt:p.y ], nil ];
		NSTimer *t = [ NSTimer scheduledTimerWithTimeInterval:counter * 0.2 target:self selector:@selector( scoreBlock_shrink: ) userInfo:block repeats:NO ];	
		[timers addObject:t];
		
		// [self removeBlockInColumn:p.x atRow:p.y];
		counter++;
		
	}
	
	[userWordScores addObject:[NSNumber numberWithInt:totalWordScore]];
	
	// update score
	if(gameHeaderIsHidden) [self showGameHeader];	
	
	// remove all blocks from array
	[selectedBlocks removeAllObjects];
	
	// clear connecting lines
	[connectingLines clearPath];
	
	// if the orientation has changed while blocks were selected
	if(deviceOrientationChangedWhileSelection) [self orientationDidChange];
	
}

- (void) adjustWordScoreLabel {

	CGSize textSize = [[wordScoreLabel text] sizeWithFont:[wordScoreLabel font]];

	if (currentDeviceOrientation == UIDeviceOrientationPortrait || currentDeviceOrientation == UIDeviceOrientationPortraitUpsideDown) {
		[wordScoreLabel setFrame:CGRectMake(0.0, 0.0, textSize.width + blockSize * 0.2 , textSize.height + blockSize * 0.2)];
	} else if (currentDeviceOrientation == UIDeviceOrientationLandscapeRight || currentDeviceOrientation == UIDeviceOrientationLandscapeLeft) {
		[wordScoreLabel setFrame:CGRectMake(0.0, 0.0, textSize.height + blockSize * 0.2, textSize.width + blockSize * 0.2)];
	}
	
}


// 1
- (void) scoreBlock_shrink:(NSTimer *)t {
	[timers removeObject:t];
	
	if(isGameOver)
		return;
	
	SPBlockView *block = [t userInfo];
	
	if(!block) return;
	
	float r = 0.0f; // UIDeviceOrientationPortrait
	CGAffineTransform transformRotation;
	CGAffineTransform transformScale;
	
	switch ( (int)currentDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:
			r = M_PI;
			break;
		case UIDeviceOrientationLandscapeRight:
			r = M_PI + M_PI / 2.0f;
			break;
		case UIDeviceOrientationLandscapeLeft:
			r = M_PI / 2.0f;
			break;
	}
	
	transformRotation = CGAffineTransformMakeRotation(r);	
	transformScale = CGAffineTransformMakeScale(0.1f, 0.1f);
	
	// start shrink animation
	[UIView beginAnimations:@"shrink" context:block]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(scoreBlock_revealScore:finished:context:)];
		[UIView setAnimationDuration:0.25f];
		// merge the transformations
		[[block view] setTransform:CGAffineTransformConcat(transformRotation,transformScale)];
	} [UIView commitAnimations];	
}

// 2
- (void) scoreBlock_revealScore:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
		
	if(isGameOver)
		return;
	
	SPBlockViewLetter *block = context;
	if(!block) 
		return;

	// tell block to reveal the score
	[block revealScore];
	
	float r = 0.0f; // UIDeviceOrientationPortrait
	CGAffineTransform transformRotation;
	CGAffineTransform transformScale;
	
	switch ( (int)currentDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:
			r = M_PI;
			break;
		case UIDeviceOrientationLandscapeRight:
			r = M_PI + M_PI / 2.0f;
			break;
		case UIDeviceOrientationLandscapeLeft:
			r = M_PI / 2.0f;
			break;
	}
	
	transformRotation = CGAffineTransformMakeRotation(r);	
	transformScale = CGAffineTransformMakeScale(1.0f, 1.0f);
	
	// start grow animation
	[UIView beginAnimations:@"revealScore" context:block]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(scoreBlock_timedRemoval:finished:context:)];
		[UIView setAnimationDuration:0.25f];
		// merge the transformations
		[[block view] setTransform:CGAffineTransformConcat(transformRotation, transformScale)];
	} [UIView commitAnimations];
	
	// ### play sound
	[audioEngine playEffect:soundOfRevealedScore];	
	// [soundOfRevealedScore play];
}

// 3
- (void) scoreBlock_timedRemoval:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	if(isGameOver) 
		return;
	// create and assign a block object
	SPBlockView *block = context;
	if(!block) return;
	// find b in array
	SPGridPos p = [self findBlock:block];
	// wrap coordinates in an NSArray
	NSArray *coordinates = [ NSArray arrayWithObjects: [NSNumber numberWithInt:p.x], [NSNumber numberWithInt:p.y], nil ];
	// remove the block after timer delay 
	NSTimer *t = [ NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector( callRemoveBlockInColumn: ) userInfo:coordinates repeats:NO ];	
	[timers addObject:t];
}

// 4
- (void) callRemoveBlockInColumn:(NSTimer *)t {
	
	[timers removeObject:t];

	if(isGameOver)
		return;
	
	// ### play sound
	[audioEngine playEffect:soundOfDissapearingBlock];	
	// [soundOfDissapearingBlock play];
	
	// unwrap timers user info
	int col = [[[t userInfo] objectAtIndex:0] intValue];
	int row = [[[t userInfo] objectAtIndex:1] intValue];
	
	// call remove blocks with unwrapped parameters
	[self removeBlockInColumn:col atRow:row];
}

// 5
// animate and remove one block from the game grid
- (void) removeBlockInColumn:(uint)col atRow:(uint)row {
	
	// are indexes within the boundary of the game grid?
	if( col >= kBlockColumns ) return;
	if( row >= kBlockRows ) return;

	if(!gameGrid) return;
	// get pointer to block object
	SPBlockView *block = [[gameGrid objectAtIndex:col] objectAtIndex:row];
	
	// if block is empty return
	if( [ block isEqual:[NSNull null] ] ) return;
	
	// if block is moving return
	
	// if block is falling it should not be removed 
	if( [block isFalling] ) return;
	
	// remove block from display
	// ref count -1
	[[block view] removeFromSuperview];
	
	// replace with empty object
	// ref count -1
	[[gameGrid objectAtIndex:col] replaceObjectAtIndex:row withObject:[NSNull null]];
	
	if( bonusChainCountDown > 0 ) {
		bonusChainCountDown--;
		// Yes! This looks wrong but it is correct (the line above is subtracting bonusChainCountDown):
		[self checkForBonusAfterBlock];
	}
}







#pragma mark -
#pragma mark interface rotation

- (void) receivedRotate: (NSNotification*) notification {
	NSLog(@"Recieves rotate!");
	if(gameType != kRotation) return;
	if(isGameOver) return;
	// rotate and move all game graphics
	[self interfaceTransform];
}


- (void) interfaceTransform {
	
	// Facts:
	// 1. If gameOverTimers are running, they can get mixed up while game rotation occurs.
	// 2. This InterfaceTransform is running just one time after all blocks have rotated and device rotation is completed.
	// 3. While blocks are rotating they are not moving.
	// 4. While blocks are rotating gameOverTimers are not updated or checked.
	// 
	// Fix:
	// 1. Go through all collumns and calculate where the old columns will go and move gameOverTimers accordingly.
	// Possible problems: what if blocks fall more than one step? Can't look too far ahead, 
	// as the running game will change that back to current state any way.
	
	
	UIDeviceOrientation deviceOrientation = [[UIDevice currentDevice] orientation];
	
	// return if there is no change
	if(deviceOrientation == currentDeviceOrientation) {
		NSLog(@"No orientation change!");
		return;
	}

	// return if device orientation is not 1,2,3 or 4.
	if( deviceOrientation < 1 || deviceOrientation > 4 ) return;
	
	// set orientation changed to NO now, then set to YES below when it has changed
	[self setDeviceOrientationChanged:NO];

	switch ( (int)deviceOrientation) {
		
		case UIDeviceOrientationPortrait: {
			// NSLog(@"UIDeviceOrientationPortrait");
			// calculate block position offset
			[self setBlockOffset:CGPointMake(0.0f, 0.0f)];
			[self updateGoalPosition];
			// prepare rotation
			[self rotateAllBlocksRadians:0.0f];
			// [self rotateInfoBar:0.0f];
			[self showGameHeaderAtTop:NO];
			[self moveBonusViewToTop];
			//[gameHeader setIsShy:NO];
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(0.0f);
			// rotate wordscore label
			[wordScoreLabel setTransform:transform];
			// if black mask is used, also move the black mask to top (and rotate it)
			if (blackMask) { 
				[blackMask setCenter:CGPointMake( [blackMask center].x, [blackMask frame].size.height/2.0f )];
				// apply the transform to the block
				blackMask.transform = transform;
			}
			[self setDeviceOrientationChanged:YES];
			break;
		}
		
		case UIDeviceOrientationPortraitUpsideDown: {
			// NSLog(@"UIDeviceOrientationPortraitUpsideDown");
			// calculate block position offset
			float yOffset = (blockSize * kBlockRows - gameScreenRect.size.height);
			[self setBlockOffset:CGPointMake(0.0f, yOffset)];
			[self updateGoalPosition];
			// prepare rotation
			[self rotateAllBlocksRadians:M_PI];
			// [self rotateInfoBar:M_PI];
			[self showGameHeaderAtBottom:NO];
			[self moveBonusViewToBottom];
			//[gameHeader setIsShy:NO];
			// if black mask is used, also move the black mask to bottom (and rotate it)
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
			// rotate wordscore label
			[wordScoreLabel setTransform:transform];
			if (blackMask) { 
				[blackMask setCenter:CGPointMake( [blackMask center].x, gameScreenRect.size.height - [blackMask frame].size.height/2.0f )];
				// apply the transform to the block
				blackMask.transform = transform;				
			}
			[self setDeviceOrientationChanged:YES];
			break;
		}
			
		case UIDeviceOrientationLandscapeRight: {
			// NSLog(@"UIDeviceOrientationLandscapeRight");			
			[self rotateAllBlocksRadians:M_PI + M_PI/2.0f];
			// [self rotateInfoBar:M_PI + M_PI/2.0f];
			[self showGameHeaderAtRight:NO];
			[self moveBonusViewToRight];
			//[gameHeader setIsShy:YES];
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI + M_PI/2.0f);
			// rotate wordscore label
			[wordScoreLabel setTransform:transform];
			[self setDeviceOrientationChanged:YES];
			break;
		}
	
		case UIDeviceOrientationLandscapeLeft: {
			// NSLog(@"UIDeviceOrientationLandscapeLeft");			
			[self rotateAllBlocksRadians:M_PI/2.0f];			
			// [self rotateInfoBar:M_PI/2.0f];
			[self showGameHeaderAtLeft:NO];
			[self moveBonusViewToLeft];
			//[gameHeader setIsShy:YES];
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI/2.0f);
			// rotate wordscore label
			[wordScoreLabel setTransform:transform];
			[self setDeviceOrientationChanged:YES];
			break;
		}
			
	}
			
}

- (void) updateGoalPosition {
	// go through the game grid
	for(uint col = 0; col < kBlockColumns; col++ ) {
		for(uint row = 0; row<kBlockRows; row++) {
			
			// get pointer to current block
			SPBlockView *block = [[gameGrid objectAtIndex:col] objectAtIndex:row];
			
			// is current block empty then continue to next block
			if([block isEqual:[NSNull null]]) continue;
			
			// update goal position with the new block offset
			[block setGoalPosition:CGPointMake(blockSize * col + blockSize / 2.0f + blockOffset.x, gameScreenRect.size.height - (blockSize * row + blockSize / 2.0f) + blockOffset.y )];
			
		}
	}
}



- (void)rotateAllBlocksRadians:(float)rad {
	
	// set to YES when last block is found
	BOOL isLastBlockFound = NO;
	
	// used for finding the last block in array
	int lastX, lastY;
	
	// find the last block searching backwards (reverse search is quicker)
	for( lastX = kBlockColumns-1; lastX >= 0; lastX-- ) {
		for( lastY = kBlockRows-1; lastY >= 0; lastY-- ) {
			if( ! [ [[gameGrid objectAtIndex:lastX] objectAtIndex:lastY] isEqual:[NSNull null] ] ) {
				isLastBlockFound = YES;
				break;
			}
		}
		if(isLastBlockFound) break;
	}
	
	// rotate each block in game grid
	for ( uint x = 0; x < kBlockColumns; x++ ) {
		for ( uint y = 0; y < kBlockRows; y++ ) {
			
			// retain a block object
			SPBlockView *block = [[gameGrid objectAtIndex:x] objectAtIndex:y];	
			
			if([block isEqual:[NSNull null]]) continue;
			
			// begin animation block
			[UIView beginAnimations:nil context:NULL];
			[UIView setAnimationDuration:0.25];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			// make a rotation transform
			CGAffineTransform transform = CGAffineTransformMakeRotation(rad);
			// apply the transform to the block
			block.view.transform = transform;
			// also move the block to its goal position
			[[block view] setCenter:[block goalPosition]];
			// if this is the last block, set the animation did stop selector
			if( x == lastX && y == lastY ) {
				// set self to animation delegate (used for setAnimationDidStopSelector below)
				[UIView setAnimationDelegate:self];
				// when last blocks animation (rotation) has finished, run [self orientationDidChange]
				[UIView setAnimationDidStopSelector:@selector(orientationDidChange)];
			}
			[UIView commitAnimations];
			
			[block stop];
			
		}
	}	
}

- (void) orientationDidChange {
	
	// don't finish the orientation change if blocks are still selected
	if([selectedBlocks count]) {
		[self setDeviceOrientationChangedWhileSelection:YES];
		return;
	} else {
		[self setDeviceOrientationChangedWhileSelection:NO];	
	}
	 
	// rotation and movement is finished, now change the currentDeviceOrientation
	UIDeviceOrientation d = [[UIDevice currentDevice] orientation];
	// only change if normal orientations are between 1-4
	if( d>0 && d<5 ) currentDeviceOrientation = [[UIDevice currentDevice] orientation];
	
	[self setDeviceOrientationChanged:NO];
	
	// update global game timer - too avoid unsynchronised delay
	[self setGameTimeStamp:[NSDate timeIntervalSinceReferenceDate]];

}


#pragma mark -
#pragma mark ui effects

- (void)flashColumnMarker:(int)pos {
	// 0 is at the bottom of the game grid
	int len = 0; 
	CGRect f;
	
	BOOL flash = NO;
	
	switch ( (int)currentDeviceOrientation ) {			
		case UIDeviceOrientationPortrait: {
			if(pos>=kBlockColumns || pos<0) return;
			for(int y=0; y<kBlockRows; y++) {
				SPBlockView *b = [[gameGrid objectAtIndex:pos] objectAtIndex:y];
				if( [b isEqual:[NSNull null]] ) break;
				len++;
			}
			float temp_offset = gameScreenRect.size.height - blockSize * kBlockRows;
			f = CGRectMake( pos * blockSize + blockOffset.x, 0.0f + blockOffset.y, blockSize, (kBlockRows - len) * blockSize + temp_offset);
			flash = YES;
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			if(pos>=kBlockColumns || pos<0) return;
			for(int y=kBlockRows-1; y>=0; y--) {
				SPBlockView *b = [[gameGrid objectAtIndex:pos] objectAtIndex:y];
				if( [b isEqual:[NSNull null]] ) break;
				len++;
			}
			float temp_offset = gameScreenRect.size.height - blockSize * kBlockRows;
			float markerLen = (kBlockRows - len) * blockSize + temp_offset;
			f = CGRectMake( pos * blockSize + blockOffset.x, gameScreenRect.size.height - markerLen + blockOffset.y, blockSize, (kBlockRows - len) * blockSize + temp_offset);
			flash = YES;
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			if(pos>=kBlockRows || pos<0) return;
			for(int x=0; x<kBlockColumns; x++) {
				SPBlockView *b = [[gameGrid objectAtIndex:x] objectAtIndex:pos];
				if( [b isEqual:[NSNull null]] ) break;
				len++;				
			}
			float temp_offset = gameScreenRect.size.height - blockSize * kBlockRows;
			float markerLen = (kBlockColumns - len) * blockSize;
			NSLog(@"offset: %f %f", blockOffset.x, blockOffset.y);
			f = CGRectMake(gameScreenRect.size.width - markerLen + blockOffset.x, (kBlockRows - pos) * blockSize + blockOffset.y - temp_offset, markerLen, blockSize);
			flash = YES;
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			if(pos>=kBlockRows || pos<0) return;
			for(int x=kBlockColumns-1; x>=0; x--) {
				SPBlockView *b = [[gameGrid objectAtIndex:x] objectAtIndex:pos];
				if( [b isEqual:[NSNull null]] ) break;
				len++;				
			}
			float temp_offset = gameScreenRect.size.height - blockSize * kBlockRows;
			float markerLen = (kBlockColumns - len) * blockSize;
			NSLog(@"offset: %f %f", blockOffset.x, blockOffset.y);
			f = CGRectMake(0.0f + blockOffset.x, (kBlockRows - pos) * blockSize + blockOffset.y - temp_offset, markerLen, blockSize);			
			flash = YES;
			break;
		}
	}
	
	if(flash) {
		[columnDropMarker setFrame:f];
		[columnDropMarker setAlpha:0.4f];
		[columnDropMarker setHidden:NO];
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.25];
			[columnDropMarker setAlpha:0.0f];
			// no need to hide, alpha is 0
			//[UIView setAnimationDidStopSelector:@selector(hideDropColumnMarker)];
		}
		[UIView commitAnimations];
	}
}
			
- (void)hideDropColumnMarker {
	[columnDropMarker setHidden:YES];
}

#pragma mark -
#pragma mark time bomb

- (void) checkForBombTrigger {
	if( score - bombTriggeredAtScore >= kBombTriggerValue ) {
		[self setIsNextBlockABomb:YES];
		[self dropNewBlock:-1];
		
		bombTriggeredAtScore += kBombTriggerValue;
		
		// recursive loop!
		if(score - bombTriggeredAtScore >= kBombTriggerValue) 
			[self checkForBombTrigger];

		// bombTriggeredAtScore = score - (score % kBombTriggerValue);
		NSLog(@"###############################");
		NSLog(@"Current score: %i", score);
		NSLog(@"Next bomb trigger at score: %i", bombTriggeredAtScore);
		NSLog(@"###############################");
	}
}


- (BOOL) startTimeBomb:(SPBlockViewTimeBomb *)bomb {
	// ok now start time bomb
	[self setIsBombActive:YES];
	[bomb showCounter];
	return YES;
}

- (void) fragExplosion:(NSTimer *)t {
	[timers removeObject:t];
	if(isGameOver || isGamePaused) return;
	SPBlockView *b = [t userInfo];
	[b fragExplosion];
	// ### play sound
	[audioEngine playEffect:soundOfFragExplosion];	
}

- (void) fragExplosionOnBlock:(SPBlockView *)block {
	// blow up the block
	[block fragExplosion];
	// play sound
	[audioEngine playEffect:soundOfFragExplosion];	
}


#pragma mark -
#pragma mark game header


- (BOOL) isGameHeaderTouched:(CGPoint)p {
	switch ((int)[gameHeader currentOrientation]) {
		case UIDeviceOrientationPortrait: {
			// game header at the top
			if(p.y < [gameHeader center].y + [gameHeader frame].size.height/2.0f + [gameHeader touchPadding]) {
				return YES;
			}
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			// game header at the bottom
			if(p.y > [gameHeader center].y - [gameHeader frame].size.height/2.0f - [gameHeader touchPadding]) {
				return YES;
			}
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			// game header on LEFT side
			if(p.x < [gameHeader center].x + [gameHeader frame].size.width/2.0f + [gameHeader touchPadding]) {
				return YES;
			}
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			// game header on RIGHT side
			if(p.x > [gameHeader center].x - [gameHeader frame].size.width/2.0f - [gameHeader touchPadding]) {
				return YES;
			}
			break;
		}			
	}
	return NO;
}


- (void) hideGameHeaderWithDelay:(double)seconds {
	if(![gameHeader isShy]) return;
	// hide game header after timer delay 
	NSTimer *t = [ NSTimer scheduledTimerWithTimeInterval:seconds target:self selector:@selector( hideGameHeaderT: ) userInfo:nil repeats:NO ];
	[timers addObject:t];
	// game header is hidden
	[self setGameHeaderIsHidden:YES];
}

- (void) hideGameHeaderT:(NSTimer *)t {
	[timers removeObject:t];
	[self hideGameHeader];
}

- (void) hideGameHeader {
	if(![gameHeader isShy]) return;
	// start animation block
	[UIView beginAnimations:nil context:NULL];
	// set animation time
	[UIView setAnimationDuration:0.25];
	switch ((int)[gameHeader currentOrientation]) {
		case UIDeviceOrientationPortrait: {
			// slide game header out of screen at the top
			[gameHeader setCenter:CGPointMake( [gameHeader center].x, -[gameHeader frame].size.height/2.0f + [gameHeader hiddenEdge] )];
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			// slide game header out of screen at the bottom
			[gameHeader setCenter:CGPointMake( [gameHeader center].x, gameScreenRect.size.height + [gameHeader frame].size.height/2.0f - [gameHeader hiddenEdge] )];			
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			// slide game header out of screen on LEFT side
			[gameHeader setCenter:CGPointMake(-[gameHeader frame].size.width/2.0f + [gameHeader hiddenEdge], gameScreenRect.size.height/2.0f)];
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			// slide game header out of screen on RIGHT side
			[gameHeader setCenter:CGPointMake(gameScreenRect.size.width + [gameHeader frame].size.width/2.0f - [gameHeader hiddenEdge], gameScreenRect.size.height/2.0f)];
			break;
		}			
	}	
	[UIView commitAnimations];
	// game header is hidden
	[self setGameHeaderIsHidden:YES];
}

- (void) showGameHeader {
	NSLog(@"deviceOrientation: %i", currentDeviceOrientation);
	switch ((int)currentDeviceOrientation) {
		case UIDeviceOrientationPortrait: {
			[self showGameHeaderAtTop:NO];
			break;
		}
		case UIDeviceOrientationPortraitUpsideDown: {
			[self showGameHeaderAtBottom:NO];
			break;
		}
		case UIDeviceOrientationLandscapeRight: {
			[self showGameHeaderAtRight:NO];
			break;
		}
		case UIDeviceOrientationLandscapeLeft: {
			[self showGameHeaderAtLeft:NO];
			break;
		}			
	}
}

- (void) showGameHeaderAtTop:(BOOL)displayScore {
	
	// important: make rotation transform before moving game header!
	
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(0.0f);
	// apply the transform to the block
	gameHeader.transform = transform;
	
	// hide game header at top
	[gameHeader setCenter:CGPointMake(gameScreenRect.size.width / 2.0f + ([gameHeader frame].size.width - gameScreenRect.size.width) / 2.0f, -[gameHeader frame].size.height / 2.0f + [gameHeader hiddenEdge])];
	
	// show game header
	if( ![gameHeader isShy] || displayScore ) {
		// begin animation block
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.25];
			// move game header to its goal position
			[gameHeader setCenter:CGPointMake(gameScreenRect.size.width / 2.0f + ([gameHeader frame].size.width - gameScreenRect.size.width) / 2.0f, [gameHeader frame].size.height / 2.0f)];
		} [UIView commitAnimations];
	}
	
	// set game header orientation
	[gameHeader setCurrentOrientation:UIDeviceOrientationPortrait];
	// game header is not hidden
	[self setGameHeaderIsHidden:NO];
	// adjust the game header for portrait view
	[gameHeader adjustForPortrait];
}

- (void) showGameHeaderAtBottom:(BOOL)displayScore {
	
	// important: make rotation transform before moving game header!
	
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI);
	// apply the transform to the block
	gameHeader.transform = transform;
	
	// hide game header at bottom
	[gameHeader setCenter:CGPointMake(gameScreenRect.size.width / 2.0f - ([gameHeader frame].size.width - gameScreenRect.size.width)/2.0f, gameScreenRect.size.height + [gameHeader frame].size.height/2.0f - [gameHeader hiddenEdge])];			
	
	// show game header
	if( ![gameHeader isShy] || displayScore ) {
		// begin animation block
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.25];
			// move game header to its goal position
			[gameHeader setCenter:CGPointMake(gameScreenRect.size.width / 2.0f - ([gameHeader frame].size.width - gameScreenRect.size.width)/2.0f, gameScreenRect.size.height - [gameHeader frame].size.height/2.0f)];
		} [UIView commitAnimations];
	}
	
	// set game header orientation
	[gameHeader setCurrentOrientation:UIDeviceOrientationPortraitUpsideDown];
	// game header is not hidden
	[self setGameHeaderIsHidden:NO];
	// adjust the game header for portrait view
	[gameHeader adjustForPortrait];
}

- (void) showGameHeaderAtRight:(BOOL)displayScore {
	
	// important: make rotation transform before moving game header!
	
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI + M_PI / 2.0f);
	// apply the transform to the block
	gameHeader.transform = transform;
	
	// hide game header on left side
	[gameHeader setCenter:CGPointMake( -[gameHeader frame].size.width / 2.0f + [gameHeader hiddenEdge], gameScreenRect.size.height / 2.0f ) ];
	
	// show game header
	if( ![gameHeader isShy] || displayScore ) {
		// begin animation block
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.25];
			// move game header to its goal position
			[gameHeader setCenter:CGPointMake( [gameHeader frame].size.width / 2.0f, gameScreenRect.size.height / 2.0f )];
		} [UIView commitAnimations];
	}
		
	// set game header orientation
	[gameHeader setCurrentOrientation:UIDeviceOrientationLandscapeRight];	
	// game header is not hidden
	[self setGameHeaderIsHidden:NO];
	// adjust the game header for landscape view
	[gameHeader adjustForLandscape];
}

- (void) showGameHeaderAtLeft:(BOOL)displayScore {
	
	// important: make rotation transform before moving game header!
	
	// make a rotation transform
	CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI / 2.0f);
	// apply the transform to the block
	gameHeader.transform = transform;
	
	// hide game header on right side
	[gameHeader setCenter:CGPointMake( gameScreenRect.size.width + ([gameHeader frame].size.width / 2.0f) - [gameHeader hiddenEdge], gameScreenRect.size.height / 2.0f ) ];
	
	// show game header
	if( ![gameHeader isShy] || displayScore ) {
		// begin animation block
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.25];
			// move game header to its goal position
			[gameHeader setCenter:CGPointMake( gameScreenRect.size.width - ([gameHeader frame].size.width / 2.0f), gameScreenRect.size.height / 2.0f )];
		} [UIView commitAnimations];
	}
	
	// set game header orientation
	[gameHeader setCurrentOrientation:UIDeviceOrientationLandscapeLeft];
	// game header is not hidden
	[self setGameHeaderIsHidden:NO];	
	// adjust the game header for landscape view
	[gameHeader adjustForLandscape];
}




@end

