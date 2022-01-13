//
//  SPDropShadow.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-07.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPDropShadowView.h"
#import "SPCommon.h"

@implementation SPDropShadowView

@synthesize shadowColor;

- (void)dealloc {
	[shadowColor release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
	    [self setBackgroundColor:[UIColor clearColor]];
	    [self setShadowColor:[SPCommon SPGetDarkRed]];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame color:(UIColor *)c {
	if ((self = [super initWithFrame:frame])) {
		// Initialization code
		[self setBackgroundColor:[UIColor clearColor]];
		[self setShadowColor:c];
	}
	return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect 
{
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	CGGradientRef glossGradient;
	CGColorSpaceRef rgbColorspace;
	
	const float* colors = CGColorGetComponents( [ shadowColor CGColor ] );
	float red = colors[0];
	float green = colors[1];
	float blue = colors[2];	
	 
	size_t num_locations = 2;
	
	CGFloat locations[2] = { 0.0, 1.0 };

	CGFloat components[8] = { red, green, blue, 1.0,  // Start color
		red, green, blue, 0.0 }; // End color
	
//	CGFloat components[8] = { 0.0f, 0.0f, 0.0f, 1.0f,  // Start color
//		0.0f, 0.0f, 0.0f, 0.0f }; // End color

	rgbColorspace = CGColorSpaceCreateDeviceRGB();
	glossGradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, num_locations);
	
	CGRect currentBounds = [self bounds];
	CGPoint topCenter = CGPointMake(CGRectGetMidX(currentBounds), 0.0f);
	CGPoint bottomCenter = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
	
	CGContextDrawLinearGradient(currentContext, glossGradient, topCenter, bottomCenter, 0);
	
	CGGradientRelease(glossGradient);
	CGColorSpaceRelease(rgbColorspace); 
}




@end
