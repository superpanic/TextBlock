//
//  SPBlockViewLetter.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-07-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPBlockView.h"

#import "SPCommon.h"

#import "AppDelegate_Phone.h"
#import "AppDelegate_Pad.h"


@class SPCircleView;

@interface SPBlockViewLetter : SPBlockView {
	// the touch circle
	SPCircleView *touchCircle;
	
	// the label containing the block letter
	UILabel *letterLabel;
	
	// string set to the letter
	NSString *letter;

	// a label displaying the blocks score
	UILabel *scoreLabel;
	
	// a label showing that the current block will add an multiply bonus to the score
	UILabel *bonusLabel;
	
	// this blocks score
	int score;
	
	GameColors col;
	
	BOOL isBonusActive;
	
}


// init method, calls initWithFrame using size as frame
- (id) initWithSize:(float)size blockLetter:(NSString *)l points:(int)points;

- (void) createViews;
- (void) destroyViews;

- (void) activateBonus;

// add bonus multiplier
- (void) multiplyScoreWithBonus:(int)val;
- (void)addScore:(int)val;

// reveal the score
- (void) revealScore;

- (void) touchBlock;
- (void) unTouchBlock;

- (void) hideIcon;

// the highlight circle
@property (nonatomic, retain) SPCircleView *touchCircle;

// the label containing the block letter
@property (nonatomic, retain) UILabel *letterLabel;

// a label containing the blocks score
@property (nonatomic, retain) UILabel *scoreLabel;

// a label showing that the current block will add an multiply bonus to the score
@property (nonatomic, retain) UILabel *bonusLabel;

// string set to the letter
@property (nonatomic, retain) NSString *letter;

// this blocks score
@property (readwrite) int score;

@property (readwrite) BOOL isBonusActive;

@end

