//
//  SPGameHeader.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPInfoBarView;
@class SPGameViewController;

@interface SPFloatingInfoBar : UIView {
	UILabel *scoreLabel;
	UILabel *titleLabel;
	SPInfoBarView *infoBar;
	
	CGSize barSize;
	CGSize titleSize;
	
	CGRect superRect;
	
	UIButton *buttonPause;
	
	SPGameViewController *gameViewController;
	
	CGPoint touchPointOffset;
	CGPoint velocity;
	
	float wOffset;
	float hOffset;
	
	NSTimeInterval previousTimeStamp;
		
	NSTimer *runTimer;
	
	int score;
	int displayScore;
}

@property (nonatomic, retain) UILabel *scoreLabel;
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) SPInfoBarView *infoBar;

@property (readonly) CGSize barSize;
@property (readonly) CGSize titleSize;

@property (readwrite) CGRect superRect;

@property (nonatomic, retain) SPGameViewController *gameViewController;

@property (nonatomic, retain) UIButton *buttonPause;

@property (nonatomic, retain) NSTimer *runTimer;

@property (readonly) CGPoint touchPointOffset;
@property (readonly) CGPoint velocity;

@property (readonly) float wOffset;
@property (readonly) float hOffset;

@property (readonly) NSTimeInterval previousTimeStamp;

@property (readonly) int score;
@property (readonly) int displayScore;


- (id)initWithFrame:(CGRect)r;

- (void)buttonPauseTouchUp:(id)sender;
- (void)buttonPauseTouchDown:(id)sender;
- (void)buttonPauseTouchUpOutside:(id)sender;
- (void)buttonPauseAction:(id)sender;

- (void)run;

- (void)updateScore:(int)value;
- (BOOL)printScore;

@end
