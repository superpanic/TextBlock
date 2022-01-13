//
//  SPBlockCircle.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPCircleView.h"

#define kPadding 1.0f

@implementation SPCircleView

// the diameter of this circle
@synthesize diameter;
@synthesize red;
@synthesize green;
@synthesize blue;


- (void)dealloc {
	if(pathRef)CFRelease(pathRef);
	[super dealloc];
}

- (id)initWithDiameter:(float)d {
	// shrink the diameter to avoid ugly edge drawing artifacts
	diameter = d;
	return [self initWithFrame:CGRectMake(0.0f, 0.0f, [self diameter]+2.0f, [self diameter]+2.0f)];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		// Initialization code
		if(!diameter) diameter = frame.size.width;

		[self setBackgroundColor:[UIColor clearColor]];

		// get color components as c array
		const float* colors = CGColorGetComponents( [[SPCommon SPGetOffWhite] CGColor] );
		
		red = colors[0];
		green = colors[1];
		blue = colors[2];		
		
		// create the path object for the glossy circle
		pathRef = CGPathCreateMutable();
	
		// add circle to pathRef
		CGPathAddArc(pathRef, NULL, diameter/2.0f, diameter/2.0f, (diameter/2.0f)-kPadding, 0.0f, 2.0f*M_PI, NO);
		// close circle
		CGPathCloseSubpath(pathRef);
		
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
	
	// set color to transparent color white
	CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
	// add the circle path
	CGContextAddPath(context, pathRef);
	// fill the highlight circle
	CGContextFillPath(context);	
	
}


@end
