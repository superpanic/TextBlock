//
//  SPGameHeader.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>

//@class SPGameViewController;
@class SPDropShadowView;

@interface SPGameHeader : UIView {
	UILabel *scoreLabel;
	int score;
	int displayScore;
	
	UIButton *buttonPause;
	
	SPDropShadowView *dropShadowView;

	//SPGameViewController *gameViewController;
	
	BOOL isShy;
	BOOL isTouched;
	BOOL hasDropShadow;
	float hiddenEdge;
	float touchPadding;
	
	UILabel *dropTimerLabel;
	int dropTime;
	
	float portraitWidth;
	float landscapeWidth;
	float padding;
	

	UIDeviceOrientation currentOrientation;
}

@property (nonatomic, retain) UILabel *scoreLabel;
@property (readonly) int score;
@property (readonly) int displayScore;

@property (readonly) float padding;

@property (nonatomic, retain) SPDropShadowView *dropShadowView;

@property (readwrite) BOOL isShy;
@property (readwrite) BOOL isTouched;
@property (readonly) BOOL hasDropShadow;
@property (readonly) float hiddenEdge;
@property (readonly) float touchPadding;

@property (nonatomic, retain) UIButton *buttonPause;

//@property (nonatomic, retain) SPGameViewController *gameViewController;

@property (nonatomic, retain) UILabel *dropTimerLabel;
@property (readonly) int dropTime;

@property (readwrite) UIDeviceOrientation currentOrientation;

- (id) initWithHeight:(float)h portraitWidth:(float)pw landscapeWidth:(float)lw hasDropShadow:(BOOL)dropShadow;

- (void) buttonPauseTouchUp:(id)sender;
- (void) buttonPauseTouchDown:(id)sender;
- (void) buttonPauseTouchUpOutside:(id)sender;
- (void) buttonPauseAction:(id)sender;

- (void) switchShyness;

- (void) updateScore:(int)value;

- (BOOL) printScore;
- (BOOL) printScoreSlow;
- (BOOL) printScoreFast;

- (void) printLetter:(NSString *)letter;

- (void) adjustForPortrait;
- (void) adjustForLandscape;	

- (void) updateDropTimer:(float)value withLetter:(NSString *)letter;
- (void) updateDropTimer:(float)value;

@end
