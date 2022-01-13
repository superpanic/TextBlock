//
//  SPHandView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 06 Jan 2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SPCommon.h"

@interface SPHandView : UIView {
	float red, green, blue;
	CGMutablePathRef pathRef;
}

@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;

- (void)setColor:(UIColor *)c;


@end
