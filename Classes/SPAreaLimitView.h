//
//  SPAreaLimitView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SPCommon.h"

@interface SPAreaLimitView : UIView {
	CGRect r;

	float red, green, blue;
	
	float lineWidth;
	
	// create a new empty path object
	CGMutablePathRef pathRef;
	
}

@property (readonly) CGRect r;
@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;
@property (readonly) float lineWidth;

- (void)setColor:(UIColor *)c;

@end
