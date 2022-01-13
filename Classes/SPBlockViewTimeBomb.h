//
//  SPBlockViewTimeBomb.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-07-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SPBlockView.h"

@class SPBlockView;
@class SPCircleView;
@class SPBombView;

@interface SPBlockViewTimeBomb : SPBlockView {
	SPCircleView *clockFace;
	SPBombView *bombView;
	UILabel *counterLabel;
	int maxSelectedBlocks;
	UILabel *timerLabel;
}

@property (nonatomic, retain) SPCircleView *clockFace;
@property (nonatomic, retain) SPBombView *bombView;
@property (nonatomic, retain) UILabel *counterLabel;
@property (readonly) int maxSelectedBlocks;
@property (nonatomic, retain) UILabel *timerLabel;

- (id) initWithSize:(float)size;

- (void) createViews;
- (void) destroyViews;
- (void) animateFadeInFadeOutLoop;

- (void) touchBlock;
- (void) unTouchBlock;

- (void) showCounter;
- (void) updateCounter:(int)value;
- (void) updateTimer:(float)value;

- (void) hideIcon;


@end
