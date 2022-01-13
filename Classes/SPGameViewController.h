//
//  MainViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-02-20.
//  Copyright 2010 Superpanic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SPCommon.h"

@class SPDictionary;
@class SPBlockView;
@class SPBlockViewLetter;
@class SPBlockViewTimeBomb;
@class SPLinesConnectingBlocksView;
@class SPGameHeader;
@class SPChainBonusView;
@class SPChainBonusAlertView;

@class SPAreaLimitView;
@class SPGameResultsViewController;
@class SPPauseViewController;
@class SPDropShadowView;

@class SimpleAudioEngine;

//@class SPFloatingInfoBar;

/*
//audio
@class Finch;
@class Sound;
@class RevolverSound;
*/


#pragma mark -
#pragma mark enums

// Game type
typedef enum {
	kArcade,
	kRotation,
	kSpeed
} GameType;


#pragma mark -
#pragma mark structs

// Grid pos
struct SPGridPos { uint x; uint y; };
typedef struct SPGridPos SPGridPos;

#pragma mark -
#pragma mark interface

@interface SPGameViewController : UIViewController {
		
	// game type
	GameType gameType;
	
	// the word list dictionary 
	SPDictionary *wordList;

	// size of the active screen
	CGRect gameScreenRect;

	// size of a single block
	float blockSize;
	
	CGPoint blockOffset;
	
	// device orientation changed
	BOOL deviceOrientationChanged;
	BOOL deviceOrientationChangedWhileSelection;
	
	// double lastOrientation;

	// all the columns containing blocks
	NSMutableArray *gameGrid;
	
	// interface orientation (enum)
	UIDeviceOrientation currentDeviceOrientation;
	
	NSMutableArray *selectedBlocks;
		
	double gameTimeStamp;
		
	SPLinesConnectingBlocksView *connectingLines;
		
	SPGameHeader *gameHeader;
	
	SPDropShadowView *blackMask;
	
	UIView *columnDropMarker;
	
	UIView *gameOverDisplay;
	
	UILabel *wordScoreLabel;
	
	
	// C array of NSTimeInterval (double) values used as timers for full columns. (For game over check).
	// This C array is freed automatically - no need to use free() in dealloc!
	NSTimeInterval gameOverTimers[kBlockColumns];

	
	BOOL isGameLoaded;
	
	BOOL gameHeaderIsHidden;
	
	BOOL isGameOver;
	
	BOOL isGamePaused;
		
	BOOL isUserTouchingBlock;
	
	BOOL isBlockDoubleTouched;
	
	BOOL isBlockSlideSelected;
	
	BOOL isBombActive;
	
	BOOL isNextBlockABomb;
	
	BOOL isBonusActive;
	
	
	// new bonus function
	int bonusCounter;
	int bonusChainCountDown;
	BOOL bonusChainSelectionFlag;
	
	SPChainBonusView *bonusView;
	SPChainBonusAlertView *bonusAlertView;
	
	
	// bomb triggering scores
	int bombTriggeringCounter;
	int bombTriggeredAtScore;
	
	
	// game score
	int score;
		
	// array containing the words found in the current game
	NSMutableArray *userWords;
	NSMutableArray *userWordScores;
	
	// timer for dropping new blocks
	double dropNextBlockAtTime;
	double dropBlockFrequency;
	double dropBlockPauseUntilTime;
	BOOL isDropPaused;
	
	float dropPauseTime;
	
	// timer since touch
	NSTimer *touchTimer;
	
	NSTimer *timer;
	
	NSMutableArray *timers;
	
	double touchTimerTriggersAtDate;

	
	NSString *nextBlockLetter;
	
	
	// ### pause view controller
	SPPauseViewController *pauseViewController;
	
	// ### game over view controller
	SPGameResultsViewController *gameResultsViewController;

	
	SimpleAudioEngine *audioEngine;
	
	NSString *soundOfCollidingBlocks;
	NSString *soundOfNewBlock;
	NSString *soundOfTouchingBlock;
	NSString *soundOfDissapearingBlock;
	NSString *soundOfRevealedScore;
	NSString *soundOfFragExplosion;	
	NSString *soundOfExplodingBlocks;
	
	NSString *soundOfChainBonus;
	NSString *soundOfWordBonus;
	
	NSString *stressMusic;
	
	// visual game over timers for debug
	// NSArray *gameOverTimerLabels;
		
}



#pragma mark -
#pragma mark object properties

@property (nonatomic, retain) SPDictionary			*wordList;
@property (nonatomic, retain) NSMutableArray			*gameGrid;
@property (nonatomic, retain) NSTimer				*touchTimer;
@property (nonatomic, retain) NSTimer				*timer;
@property (nonatomic, retain) NSMutableArray			*timers;

@property (nonatomic, retain) NSString				*nextBlockLetter;

@property (nonatomic, retain) NSMutableArray			*selectedBlocks;
@property (nonatomic, retain) SPLinesConnectingBlocksView	*connectingLines;
@property (nonatomic, retain) SPGameHeader			*gameHeader;
@property (nonatomic, retain) SPDropShadowView			*blackMask;
@property (nonatomic, retain) UIView				*columnDropMarker;
@property (nonatomic, retain) NSMutableArray			*userWords;
@property (nonatomic, retain) NSMutableArray			*userWordScores;
@property (nonatomic, retain) UIView				*gameOverDisplay;

@property (nonatomic, retain) UILabel				*wordScoreLabel;

// @property (nonatomic, retain) SPFloatingInfoBar *infoBar;

@property (nonatomic, retain) SPPauseViewController		*pauseViewController;
@property (nonatomic, retain) SPGameResultsViewController	*gameResultsViewController;

//@property (nonatomic, retain) UILabel *debugOutput;

//@property (nonatomic, retain) NSArray				*gameOverTimerLabels;



#pragma mark -
#pragma mark flag properties

@property (readonly)	BOOL	isGameLoaded;
@property (readonly)	BOOL	isGamePaused;
@property (readwrite)	BOOL	isGameOver;
@property (readwrite)	BOOL	deviceOrientationChanged;
@property (readwrite)	BOOL	deviceOrientationChangedWhileSelection;
@property (readwrite)	BOOL	isUserTouchingBlock;
@property (readwrite)	BOOL	isBlockDoubleTouched;
@property (readwrite)	BOOL	isBlockSlideSelected;
@property (readwrite)	BOOL	gameHeaderIsHidden;
@property (readwrite)	BOOL	isBombActive;
@property (readwrite)	BOOL	isNextBlockABomb;
@property (readwrite)	BOOL	isBonusActive;
@property (readwrite)	BOOL	isDropPaused;

@property (readwrite) int	bonusCounter;
//@property (readwrite) double bonusTime;
@property (readwrite) int	bonusChainCountDown;
@property (nonatomic, retain) SPChainBonusView		*bonusView;
@property (nonatomic, retain) SPChainBonusAlertView	*bonusAlertView;

#pragma mark -
#pragma mark value properties

@property (readwrite)	CGPoint	blockOffset;
@property (readwrite)	double	dropNextBlockAtTime;
@property (readwrite)	double	dropBlockFrequency;
@property (readonly)	double	dropBlockPauseUntilTime;

@property (readwrite)	float	dropPauseTime;

@property (readonly)	double	touchTimerTriggersAtDate;

@property (readonly)	int	score;
// @property (readwrite) double lastOrientation;
@property (readwrite)	double	gameTimeStamp;



#pragma mark -
#pragma mark methods


- (void) saveActiveGame;
- (NSDictionary *) readActiveGame;
- (NSArray *) gameGridInfo;

- (void) prepareAudio;

- (void) run:(NSTimer*)t;

- (BOOL) animateGameOverDisplay;
- (void) shakeColumn:(int)col;
- (void) shakeColumnStop:(int)col;

- (BOOL) swapGameOverTimer:(int)gridX;


- (BOOL) isColumnFull:(int)col;
- (BOOL) checkForGameOver;

- (void) runGameOver;
- (void) quitGame;
- (void) killGameLoop;
- (void) loadAudio;
- (void) unloadAudio;


- (void) resolveCollisionBetweenBlock:(SPBlockView *)block andBlock:(SPBlockView *)nextBlock;

- (SPBlockView *)createNewBlock;

- (BOOL) dropNewBlock:(int)inColumn;

- (void) updateBlockDropTimers;

- (double) getDropBlockPauseUntilTime;
- (double) getDropNextBlockAtTime;	

// game state methods
- (void) pauseGame;
- (void) resumeFromPausedGame;


// swap and switch methods
- (void) setGoalPositionAndSwitchBlocksInColumn: (uint)col atRow:(uint)row withBlock:(SPBlockView *)block;
- (void) swapBlockAtX1: (uint)x1 Y1:(uint)y1 withX2:(uint)x2 Y2:(uint)y2;


// word and text search methods
- (void) acceptWord;
- (void) addScore:(int)scoreValue;


// chain bonus methods
- (void) resetBonusCounter;
- (void) checkForBonusAfterWord;
- (void) checkForBonusAfterBlock;
- (void) showChainBonusView;
- (void) hideChainBonusView:(float)delay;
//- (void) bonusViewSetHiddenToYES;

- (void) showWordScoreLabel;
- (void) hideWordScoreLabel;
- (CGRect) getSelectedBoundingRect;

- (void) showBonusAlert;
- (void) hideBonusAlert;
- (void) revealBonus;
- (int) getWordBonus;

//- (void) bonusAlertSetHiddenToYES;

- (void) moveBonusView;
- (void) moveBonusViewToTop;
- (void) moveBonusViewToBottom;
- (void) moveBonusViewToRight;
- (void) moveBonusViewToLeft;



// touch blocks methods
- (BOOL) tryToSelectTouchedBlockInColumn: (uint)col atRow:(uint)row withPoint:(CGPoint)p;
- (void) touchBlock:(SPBlockView *)block;
- (void) shortenSelection: (uint)index;
- (void) unselectBlocks;
- (SPGridPos) findBlock:(SPBlockView *)block;


// touch timer methods
- (void) resetTouchTimerTo:(double)t;
- (void) stopTouchTimer;

// methods for removing blocks in five steps
- (void) removeSelectedBlocks;
- (void) adjustWordScoreLabel;
- (void) scoreBlock_shrink:(NSTimer *)t;
- (void) scoreBlock_revealScore:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) scoreBlock_timedRemoval:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) callRemoveBlockInColumn:(NSTimer *)t;
- (void) removeBlockInColumn: (uint)col atRow:(uint)row;


// interface rotation methods
- (void) receivedRotate: (NSNotification *) notification;
- (void) interfaceTransform;
- (void) updateGoalPosition;
- (void) rotateAllBlocksRadians: (float) rad;
- (void) orientationDidChange;

// - (void)rotateInfoBar:(float)rad;

// ui effects
- (void) flashColumnMarker:(int)pos;
- (void) hideDropColumnMarker;

// game header methods
- (BOOL) isGameHeaderTouched:(CGPoint)point;
- (void) hideGameHeaderWithDelay: (double) seconds;
- (void) hideGameHeaderT:(NSTimer *)t;
- (void) hideGameHeader;
- (void) showGameHeader;
- (void) showGameHeaderAtTop:(BOOL)displayScore;
- (void) showGameHeaderAtBottom:(BOOL)displayScore;
- (void) showGameHeaderAtRight:(BOOL)displayScore;
- (void) showGameHeaderAtLeft:(BOOL)displayScore;


// time bomb methods
- (void) checkForBombTrigger;
- (BOOL) startTimeBomb:(SPBlockView *)bomb;

- (void) fragExplosion:(NSTimer *)t;
- (void) fragExplosionOnBlock:(SPBlockView *)block;

@end
