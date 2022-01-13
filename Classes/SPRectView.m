//
//  SPRectView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPRectView.h"

#define kPadding 1.0f

@implementation SPRectView

// the diameter of this circle
@synthesize r;
@synthesize red;
@synthesize green;
@synthesize blue;


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
		
		[self setBackgroundColor:[UIColor clearColor]];

		// get color components as c array
		const float* colors = CGColorGetComponents( [[SPCommon SPGetBlue] CGColor] );
		
		red = colors[0];
		green = colors[1];
		blue = colors[2];
				
		// create the path object used for the outline
		pathRef = CGPathCreateMutable();
		
		CGPathAddRect(pathRef, NULL, r);

	}
	return self;
}

- (void)setColor:(UIColor *)c {
	// get color components as c array
	const float* colors = CGColorGetComponents( [c CGColor] );
	
	red = colors[0];
	green = colors[1];
	blue = colors[2];	

	// tell the view to redraw screen
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	// Drawing code

	// get the current graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// draw an the outline path created earlier in initWithFrame
	CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
	// CGContextSetLineWidth(context, outlineWidth);
	CGContextAddPath(context, pathRef);
	CGContextFillPath(context);	
	
}


@end
