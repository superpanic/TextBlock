//
//  SPGameTutorialAViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 07 Jan 2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPHandView;
@class SPBlockViewLetter;

@class SPGameViewController;

@class SPLinesConnectingBlocksView;

@class SimpleAudioEngine;


// state
typedef enum {
	kStart,
	kTutorialA1,
	kTutorialA2,
	kTutorialA3,
	kTutorialA4,
	kTutorialA5,
	kTutorialA6,
	kStartGame,
	kPrintScoreState,
	kWaitForNextState,
	kPause
} State;

@interface SPTutorialViewController : UIViewController {
	SPHandView *hand;
	SPGameViewController *gameViewController;

	SPLinesConnectingBlocksView *connectingLinesView;
	
	CGSize screenSize;
	float blockSize;
	State state;
	State nextState;
	
	SPBlockViewLetter *tBlock1;
	SPBlockViewLetter *eBlock;
	SPBlockViewLetter *xBlock;
	SPBlockViewLetter *tBlock2;
	
	NSMutableArray *columnBlocks;
	
	UILabel *tutorialTextLabelA;
	UILabel *tutorialTextLabelB;
	UILabel *tapToContinueTextLabel;
	
	UILabel *scoreLabel;
	int score;
	int displayScore;
	
	float blockGoalPos;
	
	int idleCounter;
	
	NSTimer *timer;
	
	BOOL isSceneActive;
	
	// AUDIO
	SimpleAudioEngine *audioEngine;
	
	NSString *soundOfCollidingBlocks;
	NSString *soundOfTouchingBlock;
	NSString *soundOfDissapearingBlock;
	NSString *soundOfRevealedScore;

	// AUDIO END
	
}

- (void) run:(NSTimer *)t;

- (void) playSoundOfCollidingBlocks;

- (void) runNextState:(State)sta inSeconds:(float)sec;
- (void) setTimedState:(NSTimer *)t;

- (void) adjustTutorialTextLabelPosition:(UILabel *)tl;
- (void) createHandAnimation;

- (void) touchBlockWithConnectingLine:(NSTimer *)t;

- (void) hideScoreLabel;

- (void) shrinkBlock:(NSTimer *)t;
- (void) revealBlockScore:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) hideBlock:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (BOOL) printScore;

- (void) newGameWithTransition;
- (void) newGame;

- (void) unloadAudio;


@property (nonatomic, retain) SPHandView *hand;
@property (nonatomic, retain) SPGameViewController *gameViewController;
@property (nonatomic, retain) SPLinesConnectingBlocksView *connectingLinesView;
@property (readwrite) State state;
@property (readwrite) State nextState;
@property (readwrite) int idleCounter;

@property (nonatomic, retain) SPBlockViewLetter *tBlock1;
@property (nonatomic, retain) SPBlockViewLetter *eBlock;
@property (nonatomic, retain) SPBlockViewLetter *xBlock;
@property (nonatomic, retain) SPBlockViewLetter *tBlock2;

@property (nonatomic, retain) UILabel *tutorialTextLabelA;
@property (nonatomic, retain) UILabel *tutorialTextLabelB;
@property (nonatomic, retain) UILabel *tapToContinueTextLabel;
@property (nonatomic, retain) UILabel *scoreLabel;

@property (nonatomic, retain) NSMutableArray *columnBlocks;

@property (nonatomic, retain) NSTimer *timer;

@end
