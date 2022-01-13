//
//  SPBlockCircle.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SPCommon.h"


@interface SPCircleView : UIView {
	float diameter;
	
	float red, green, blue;

	// create a new empty path object
	CGMutablePathRef pathRef;

}

- (id)initWithDiameter:(float)d;

@property (readonly) float diameter;
@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;

- (void)setColor:(UIColor *)c;

@end
