//
//  SPBlockSquare.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPSquareView.h"

#define kPadding 1.0f

@implementation SPSquareView

// the diameter of this circle
@synthesize squareSize;

@synthesize squareFillColor;
@synthesize darkEdgeColor;
@synthesize lightEdgeColor;

@synthesize roundingRadius;
@synthesize edgePadding;


#pragma mark -
#pragma mark defines


- (void)dealloc {
	[squareFillColor release];
	[darkEdgeColor release];
	[lightEdgeColor release];
	
	if(fillPathRef)CFRelease(fillPathRef);
	if(outlinePathRef)CFRelease(outlinePathRef);
	[super dealloc];
}

- (id)initWithSize:(float)d {
	// shrink the size to avoid ugly edge drawing artifacts
	squareSize = d;
	
	roundingRadius = squareSize / 10.0f;
	edgePadding = squareSize / 64.0f;
	
	return [self initWithFrame:CGRectMake(0.0f, 0.0f, [self squareSize]+2.0f, [self squareSize]+2.0f)];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {

		// Initialization code
		
		if(!squareSize) squareSize = frame.size.width;

		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setSquareFillColor:[SPCommon SPGetBlue]];
		[self setDarkEdgeColor:[SPCommon SPGetDarkBlue]];
		[self setLightEdgeColor:[SPCommon SPGetLightBlue]];
		
// 		const float* colors = CGColorGetComponents( [fillColor CGColor] );
		
//		red = colors[0];
//		green = colors[1];
//		blue = colors[2];
		
		// create the path object used for the outline
		fillPathRef = CGPathCreateMutable();
		
		// draw fill path - with rounded corners
		CGPathAddArc(fillPathRef, NULL, roundingRadius + edgePadding, roundingRadius + edgePadding, roundingRadius, M_PI, 1.5f*M_PI, NO);
		CGPathAddArc(fillPathRef, NULL, squareSize - roundingRadius - edgePadding, roundingRadius + edgePadding, roundingRadius, 1.5f*M_PI, 0.0f, NO);
		CGPathAddArc(fillPathRef, NULL, squareSize - roundingRadius - edgePadding, squareSize - roundingRadius - edgePadding, roundingRadius, 0.0f, M_PI * 0.5f, NO);
		CGPathAddArc(fillPathRef, NULL, roundingRadius + edgePadding, squareSize - roundingRadius - edgePadding, roundingRadius, M_PI * 0.5f, M_PI, NO);
		CGPathCloseSubpath(fillPathRef);
		
		// create the outline path
		outlinePathRef = CGPathCreateMutable();

		
		// draw ouline path
		
		CGPathAddArc(outlinePathRef, NULL, roundingRadius + edgePadding, squareSize - roundingRadius - edgePadding, roundingRadius, M_PI * 0.75f, M_PI * 1.0f, NO);		
		
		//CGPathMoveToPoint(outlinePathRef, NULL, edgePadding, squareSize - roundingRadius - edgePadding);
		CGPathAddLineToPoint(outlinePathRef, NULL, edgePadding, roundingRadius + edgePadding);
		
		CGPathAddArc(outlinePathRef, NULL, roundingRadius + edgePadding, roundingRadius + edgePadding, roundingRadius, M_PI, 1.5f*M_PI, NO);
		
		CGPathMoveToPoint(outlinePathRef, NULL, roundingRadius + edgePadding, edgePadding);
		CGPathAddLineToPoint(outlinePathRef, NULL, squareSize - roundingRadius - edgePadding, edgePadding);

		CGPathAddArc(outlinePathRef, NULL, squareSize - roundingRadius - edgePadding, roundingRadius + edgePadding, roundingRadius, M_PI * 1.5f, M_PI * 1.75f, NO);

		
	}
	return self;
}

- (void) highLight {
	
	[self setSquareFillColor:[SPCommon SPGetLightBlue]];
	[self setDarkEdgeColor:[SPCommon SPGetBlue]];
	[self setLightEdgeColor:[SPCommon SPGetOffWhite]];

	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
	// Drawing code
	
	// get the current graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const float* c;
	

	c = CGColorGetComponents( [[self squareFillColor] CGColor] );	
	// draw an the outline path created earlier in initWithFrame
	CGContextSetRGBFillColor(context, c[0], c[1], c[2], 1.0f);
	CGContextAddPath(context, fillPathRef);
	// fill
	CGContextFillPath(context);
	
	
	c = CGColorGetComponents( [[self darkEdgeColor] CGColor] );
	// draw an the outline path created earlier in initWithFrame
	CGContextSetRGBStrokeColor(context, c[0], c[1], c[2], 1.0f);
	CGContextAddPath(context, fillPathRef);
	CGContextSetLineWidth(context, squareSize / 64.0f);
	// outline
	CGContextStrokePath(context);	
	
	c = CGColorGetComponents( [[self lightEdgeColor] CGColor] );
	// draw an the outline path created earlier in initWithFrame
	CGContextSetRGBStrokeColor(context, c[0], c[1], c[2], 1.0f);
	CGContextSetLineWidth(context, squareSize / 64.0f);
	CGContextAddPath(context, outlinePathRef);
	// outline
	CGContextStrokePath(context);	
	
	
}


@end
