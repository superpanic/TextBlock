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

@interface SPInfoBarView : UIView {
	CGSize barSize;
	CGSize titleSize;
	
	BOOL isTitleBarSmooth;

	float red, green, blue;
	
	float cornerRadius;
	
	// create a new empty path object
	CGMutablePathRef pathRef;

}

- (id)initWithBarSize:(CGSize)bs titleSize:(CGSize)ts cornerRadius:(float)r smoothTitleBar:(BOOL)b;

- (void) setColor:(UIColor *)c;

@property (readonly) CGSize barSize;
@property (readonly) CGSize titleSize;

@property (readonly) BOOL isTitleBarSmooth;

@property (readonly) float red;
@property (readonly) float green;
@property (readonly) float blue;
@property (readonly) float cornerRadius;
@property (readonly) float edgePadding;

@end
