//
//  LineView.h
//  TouchSpell
//
//  Created by Fredrik Josefsson on 2009-09-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SPCommon.h"

@interface SPLinesConnectingBlocksView : UIView {
	CGMutablePathRef touchPathRef;
	NSMutableArray *points;
	float lineCenterOffset;
	float lineSinMultiplier;
	float lineWidth;
	float lineOverlap;
	float red, green, blue;
}

- (id)initWithFrame:(CGRect)frame blockSize:(float)blockSize;

- (void)newPathAtXPos:(float)x yPos:(float)y;
- (void)addLineAtXPos:(float)x yPos:(float)y;
- (void)clearPointsOfPath:(int)numberOfPointsToClear;
- (void)savePointXPos:(float)x yPos:(float)y;
- (void)clearPath;

@property (readonly) float lineSinMultiplier;
@property (readonly) float lineCenterOffset;
@property (readonly) float lineWidth;
@property (readonly) float lineOverlap;
@property (nonatomic, retain) NSMutableArray *points;
@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;

@end
