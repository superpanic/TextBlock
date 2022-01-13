//
//  SPChainBonusView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2011-08-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SPChainBonusView : UIView {
	float scale;
	BOOL isActive;
	UIBezierPath *bezierPath;
	UILabel *bonusLabel;
	UILabel *scoreLabel;
	float singlePadding;
	float doublePadding;
	CGPoint centerPoint;
	CGPoint goalPoint;
	
	CGPoint goalPointTop;
	CGPoint goalPointRight;
	CGPoint goalPointBottom;
	CGPoint goalPointLeft;
	
	CGPoint outsidePoint;
	NSTimeInterval pausePrinterUntilTime;
	int score;
}

- (void) showBonusMultiplier;
- (void) showChainBonus;

- (void) hideScoreLabel;
- (void) hideBonusLabel;


- (void) addSvgPathIcon:(NSString *)svgString;
- (void) setBonusMultiplier:(int)value;
- (void) setScore:(int)value;
- (BOOL) isPrintingScore;
- (int) printAndReturnScore;

@property (readwrite) BOOL isActive;
@property (readwrite) NSTimeInterval pausePrinterUntilTime;
@property (readwrite) float scale;
@property (readwrite) CGPoint goalPoint;
@property (readwrite) CGPoint outsidePoint;
@property (readonly) int score;
@property (nonatomic, retain) UILabel *bonusLabel;
@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UIBezierPath *bezierPath;

@property (readwrite) CGPoint goalPointTop;
@property (readwrite) CGPoint goalPointLeft;
@property (readwrite) CGPoint goalPointRight;
@property (readwrite) CGPoint goalPointBottom;

@end
