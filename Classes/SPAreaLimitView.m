//
//  SPAreaLimitView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPAreaLimitView.h"
#import "SPCommon.h"

#define kNumberOfLines 10

@implementation SPAreaLimitView

// the diameter of this circle
@synthesize r;
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize lineWidth;


#pragma mark -
#pragma mark defines

- (void)dealloc {
	if(pathRef)CFRelease(pathRef);
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {

		// Initialization code
		
		r = frame;
		
		// mask drawing to rect area
		[[self layer] setMasksToBounds:YES];

		// set background to red
		[self setBackgroundColor:[SPCommon SPGetRed]];
		
		// set line width
		lineWidth = frame.size.width / (kNumberOfLines*4.0f);
		NSLog(@"%f", lineWidth);
		
		// set drawing color to SP blue
		[self setColor:[SPCommon SPGetBlue]];
		
		// create the path object used for the outline
		pathRef = CGPathCreateMutable();
		
		// draw diagonal lines
		// for(int i = 1; i <= kNumberOfLines+(kNumberOfLines/4); i++) {
		for(int i = 1; i <= kNumberOfLines+1+(kNumberOfLines/10); i++) {
			CGPathMoveToPoint(pathRef, NULL, (lineWidth * 4.0f) * (float)i, -lineWidth);
			CGPathAddLineToPoint(pathRef, NULL, ((lineWidth * 4.0f) * (float)i) -frame.size.height - (lineWidth * 4.0f), frame.size.height + lineWidth);
		}
	}
	return self;
}

- (void)setColor:(UIColor *)c {
	// get color components as c array
	const float* colors = CGColorGetComponents( [c CGColor] );
	
	red = colors[0];
	green = colors[1];
	blue = colors[2];
}

- (void)drawRect:(CGRect)rect {
	// Drawing code

	// get the current graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
	// outline the lines (path) created earlier in initWithFrame	
	CGContextSetLineWidth(context, lineWidth);
	CGContextSetRGBStrokeColor(context, red, green, blue, 1.0f);
	CGContextAddPath(context, pathRef);
	CGContextStrokePath(context);
}


@end
