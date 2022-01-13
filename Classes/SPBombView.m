//
//  SPBombView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPBombView.h"

#define kPadding 1.0f

@implementation SPBombView

// the diameter of this circle
@synthesize diameter;
@synthesize red;
@synthesize green;
@synthesize blue;


- (void)dealloc {
	if(pathRef)CFRelease(pathRef);
	if(pathRef2)CFRelease(pathRef2);
	if(pathRef3)CFRelease(pathRef3);
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
		
		// bigger number draws a smaller bomb
		scaling = 1.2f;
		
		float x = diameter / 2.0f;		
		float y = diameter / 2.0f;		

		// create the path object for the circle
		pathRef = CGPathCreateMutable();
		// reverse scaling value
		float reverseScaling = (1.0-(scaling-1.0f));
		// calculate the radius
		float r = (diameter / 2.0f) - diameter / (5.0f * reverseScaling);
		// add circle to pathRef
		CGPathAddArc(pathRef, NULL, x, y, r, 0.0f, 2.0f * M_PI, NO);
		// close circle
		CGPathCloseSubpath(pathRef);
		
		// higher number is SHORTER line 
		// create the secont path object for the fuse base
		pathRef2 = CGPathCreateMutable();
		CGPathMoveToPoint(pathRef2, NULL, x, y);
		CGPathAddLineToPoint(pathRef2, NULL, x + diameter / (4.0f * scaling), y - diameter / (4.0f * scaling) );
		
		
		// draw bomb fuse base
		pathRef3 = CGPathCreateMutable();
		CGPathMoveToPoint(pathRef3, NULL, x + diameter/ (4.0f * scaling), y - diameter/ (4.0f * scaling) );
		CGPathAddCurveToPoint(pathRef3, NULL, 
				      x + diameter/(4.0f * scaling), 
				      y - diameter/(4.0f * scaling), 
				      x + diameter/(4.0f * scaling) + (diameter/(12.0f * scaling)), 
				      y - diameter/(4.0f * scaling) - (diameter/(12.0f * scaling)), 
				      x + diameter/(4.0f * scaling) + (diameter/( 8.0f * scaling)), 
				      y - diameter/(4.0f * scaling) - (diameter/(12.0f * scaling)) );
		
		
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
	
	// set line width to a relative size
	CGContextSetLineWidth(context, diameter / (6.0f * scaling));
	
	// draw bomb fuse base
	CGContextSetRGBStrokeColor(context, red, green, blue, 1.0f);
	CGContextAddPath(context, pathRef2);
	CGContextStrokePath(context);

	// set line width to a relative size
	CGContextSetLineWidth(context, diameter / (18.0f * scaling));
	
	// draw bomb fuse
	CGContextAddPath(context, pathRef3);
	CGContextStrokePath(context);	
	
}


@end
