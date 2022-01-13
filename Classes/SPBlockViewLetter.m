//
//  SPBlockViewLetter.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-07-17.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPBlockViewLetter.h"

#import "SPBlockView.h"
#import "SPCircleView.h"
#import "SPSquareView.h"

#define MULTIPLICATION_SIGN @"×"

@implementation SPBlockViewLetter


// the circle used to mark touched letters
@synthesize touchCircle;

// the label containing the block letter
@synthesize letterLabel;

// a label containing the block score
@synthesize scoreLabel;

// a label showing that the current block will add an multiply bonus to the score
@synthesize bonusLabel;

// string set to the letter
@synthesize letter;

// score of this block
@synthesize score;


@synthesize isBonusActive;


- (void)dealloc {
	[touchCircle release];
	[letterLabel release];
	[letter release];
	[scoreLabel release];
	[bonusLabel release];

	[super dealloc];
}


// init, calls initWithFrame using size as frame
- (id)initWithSize:(float)size blockLetter:(NSString *)l points:(int)points {
	if((self = [super initWithSize:size])) {
						
		[self setLetter:l];
		
		// set block score
		[self setScore:points];

		[self createViews];
		
		[self setIsBonusActive:NO];
		
		col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
		
	}
	return self;
}

- (void) createViews {
	[super createViews];
	
	if(!touchCircle) {
		/*** touch circle ***/
		SPCircleView *temp_touchCircle = [ [SPCircleView alloc] initWithDiameter:blockSize ];
		[self setTouchCircle:temp_touchCircle];
		[temp_touchCircle release];
		// add as subview
		[[self view] addSubview:touchCircle];
		[touchCircle setHidden:YES];
	}
	
	if(!letterLabel) {
		/*** letter label ***/
		// create the label object
		UILabel *temp_letterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[self setLetterLabel:temp_letterLabel];
		[temp_letterLabel release];
		
		// set or change the letter
		[ [self letterLabel] setText:[self letter] ];
		
		UIFont *letterFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.75f];
		
		// label settings
		[letterLabel setBackgroundColor:[UIColor clearColor]];
		[letterLabel setTextColor:[SPCommon SPGetOffWhite]];
		[letterLabel setFont:letterFont];
		[letterLabel setTextAlignment:UITextAlignmentCenter];
		[letterLabel setCenter:CGPointMake( blockSize / 2.0f, blockSize / 2.0f + 2.0f )];
		
		// add the blockLetterLabel to the view
		[[self view] addSubview:letterLabel];
	}
	
	if(!scoreLabel) {
		/*** score label ***/
		UILabel *temp_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize-4.0f, blockSize-4.0f)];
		[self setScoreLabel:temp_scoreLabel];
		[temp_scoreLabel release];
		
		// score font
		UIFont *scoreFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.5f];
		
		// score label settings
		[scoreLabel setBackgroundColor:[UIColor clearColor]];
		[scoreLabel setTextColor:[SPCommon SPGetBlue]];
		[scoreLabel setFont:scoreFont];
		// adjust font size
		[scoreLabel setAdjustsFontSizeToFitWidth:YES];
		[scoreLabel setTextAlignment:UITextAlignmentCenter];
		[scoreLabel setCenter:CGPointMake(blockSize/2.0f, blockSize/2.0f)];
		
		[scoreLabel setText:[NSString stringWithFormat:@"%i", score]];
		
		[scoreLabel setHidden:YES];
		
		// add the score label to the view
		[[self view] addSubview:scoreLabel];
	}
	
	if(!bonusLabel) {
		/*** bonus label ***/
		UILabel *temp_bonusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize * 0.25, blockSize * 0.25)];
		[self setBonusLabel:temp_bonusLabel];
		[temp_bonusLabel release];
		
		// bonus font
		UIFont *bonusFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.2f];
		
		// bonus label settings
		[bonusLabel setBackgroundColor:[UIColor clearColor]];
		[bonusLabel setTextColor:[SPCommon SPGetOffWhite]];
		[bonusLabel setFont:bonusFont];
		[bonusLabel setTextAlignment:UITextAlignmentCenter];
		// position label in upper right corner
		[bonusLabel setCenter:CGPointMake( ( blockSize / 6.0f ) * 5.0f, blockSize / 7.0f )];
		[bonusLabel setText:@"x2"];
		[bonusLabel setHidden:YES];
		
		// add the bonus label to the view
		[[self view] addSubview:bonusLabel];
	}
	
}

- (void) destroyViews {
	[letterLabel release];
	letterLabel = nil;
	[touchCircle release];
	touchCircle = nil;
	[scoreLabel release];
	scoreLabel = nil;
	[bonusLabel release];
	bonusLabel = nil;
	[super destroyViews];
}

- (void)activateBonus {
	
	// 1 set boolean bonus flag
	[self setIsBonusActive:YES];

	[bonusLabel setHidden:NO];
	
	// [[self backgroundSquare] highLight];
	
}

- (void)multiplyScoreWithBonus:(int)val {

	// ONLY USED FOR THE NSLog BELOW!
	// #############################
	// int originalScore = score;
	// #############################
	
	if(val <= 0) return;
	
	if([self isBonusActive]) {
		[self setScore:([self score] * val) * 2];
		[scoreLabel setText:[NSString stringWithFormat:@"%i", score]];
		// [scoreLabel setText:[NSString stringWithFormat:@"%i%@2", score/2, MULTIPLICATION_SIGN]];
		[scoreLabel setTextColor:[SPCommon SPGetRed]];
	} else {
		[self setScore:[self score] * val];
		[scoreLabel setText:[NSString stringWithFormat:@"%i", score]];
	}
	
	// NSLog(@"Letter:%@ score:%i multiplier:%i score:%i", [self letter], originalScore, val, score);

}

- (void)addScore:(int)val {
	if(val <= 0) return;
	if([self isBonusActive]) val*=2;
	[self setScore:([self score] + val)];
	[scoreLabel setText:[NSString stringWithFormat:@"%i", score]];	
}

- (void) revealScore {
	[letterLabel setHidden:YES];
	[scoreLabel setHidden:NO];
	[bonusLabel setHidden:YES];
}

- (void) touchBlock {
	[super touchBlock];
	
	// special case:
	if((int)col == kInvertedColors) [letterLabel setTextColor:[SPCommon SPGetBlue]];
	else [letterLabel setTextColor:[SPCommon SPGetRed]];
	
	[touchCircle setHidden:NO];
	[bonusLabel setHidden:YES];
}

- (void) unTouchBlock {
	[super unTouchBlock];
	[letterLabel setTextColor:[SPCommon SPGetOffWhite]];
	[touchCircle setHidden:YES];
	// only reveal the bonus label is bonus is active
	if(isBonusActive)[bonusLabel setHidden:NO];
}

- (void) hideIcon {
	[touchCircle setHidden:YES];
	[letterLabel setHidden:YES];
	[bonusLabel setHidden:YES];
	[super hideIcon];
}

@end
