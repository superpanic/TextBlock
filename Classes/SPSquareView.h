//
//  SPBlockSquare.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SPCommon.h"

@interface SPSquareView : UIView {
	float squareSize;
	
	UIColor *squareFillColor;
	UIColor *darkEdgeColor;
	UIColor *lightEdgeColor;
	
	float roundingRadius;
	float edgePadding;
	
	// the fill path
	CGMutablePathRef fillPathRef;
	
	// the outline path
	CGMutablePathRef outlinePathRef;
	
}

- (id) initWithSize:(float)d;
- (void) highLight;

@property (readonly) float squareSize;

@property (nonatomic, retain) UIColor *squareFillColor;
@property (nonatomic, retain) UIColor *darkEdgeColor;
@property (nonatomic, retain) UIColor *lightEdgeColor;

@property (readonly) float roundingRadius;
@property (readonly) float edgePadding;

@end
