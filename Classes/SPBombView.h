//
//  SPBombView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SPCommon.h"


@interface SPBombView : UIView {
	float diameter;
	
	float red, green, blue;
	
	float scaling;

	// create a new empty path object
	CGMutablePathRef pathRef;
	CGMutablePathRef pathRef2;
	CGMutablePathRef pathRef3;

}

- (id)initWithDiameter:(float)d;

@property (readonly) float diameter;
@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;

- (void)setColor:(UIColor *)c;

@end
