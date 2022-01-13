//
//  SPHandView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 06 Jan 2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPHandView.h"

@implementation SPHandView

@synthesize red;
@synthesize green;
@synthesize blue;

- (void)dealloc {
	if(pathRef)CFRelease(pathRef);
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {
		// transparent background
		[self setBackgroundColor:[UIColor clearColor]];
		
		[self setClipsToBounds:NO];
		
		// get color components as c array
		const float* colors = CGColorGetComponents( [[SPCommon SPGetOffWhite] CGColor] );
		
		red = colors[0];
		green = colors[1];
		blue = colors[2];
		
		// create the path object for the hand
		pathRef = CGPathCreateMutable();
		
		float w = frame.size.width;
		float h = frame.size.height;
		float fiTh = h * 0.16f;
		float fiPa = h * 0.03f;
		float fingerBase = w * 0.65;
		
	
		// back of hand
		CGPathMoveToPoint(pathRef, NULL, w, h * 0.25f);
		CGPathAddLineToPoint(pathRef, NULL, w, h);
		
		// pinky
		CGPathAddLineToPoint(pathRef, NULL, w * 0.60f, h);
		CGPathAddArc(pathRef, NULL, w * 0.60f, h-fiTh*0.5, fiTh * 0.5f, M_PI * 0.5f, M_PI * 1.5f, NO);
		CGPathAddLineToPoint(pathRef, NULL, fingerBase, h-fiTh);
		CGPathAddArc(pathRef, NULL, fingerBase, h-fiTh-fiPa * 0.5f, fiPa*0.5f, M_PI * 0.5f, M_PI * 1.5f, YES);
		
		// ring
		CGPathAddLineToPoint(pathRef, NULL, w * 0.48f, h - fiTh - fiPa);
		CGPathAddArc(pathRef, NULL, w * 0.48f, h - fiTh - fiPa - fiTh * 0.5f, fiTh * 0.5f, M_PI * 0.5f, M_PI * 1.5f, NO);
		CGPathAddLineToPoint(pathRef, NULL, fingerBase, h - fiTh - fiPa - fiTh);
		CGPathAddArc(pathRef, NULL, fingerBase, h - fiTh - fiPa - fiTh - fiPa * 0.5, fiPa * 0.5, M_PI * 0.5f, M_PI * 1.5f, YES);
		
		// long
		CGPathAddLineToPoint(pathRef, NULL, w * 0.36f, h - fiTh - fiPa - fiTh - fiPa);
		CGPathAddArc(pathRef, NULL, w * 0.36f, h - fiTh - fiPa - fiTh - fiPa - fiTh * 0.5, fiTh * 0.5, M_PI * 0.5f, M_PI * 1.5f, NO);
		CGPathAddLineToPoint(pathRef, NULL, fingerBase, h - fiTh * 3.0f - fiPa * 2.0f);
		CGPathAddArc(pathRef, NULL, fingerBase, h - fiTh * 3.0f - fiPa * 2.0f - fiPa * 0.5, fiPa * 0.5, M_PI * 0.5f, M_PI * 1.5f, YES);
		
		// index
		CGPathAddLineToPoint(pathRef, NULL, w * 0.08f, h - fiTh * 3.0f - fiPa * 3.0f);
		CGPathAddArc(pathRef, NULL, w * 0.08f, h - fiTh * 3.0f - fiPa * 3.0f - fiTh * 0.5f, fiTh * 0.5f, M_PI * 0.5f, M_PI * 1.5f, NO);
		CGPathAddLineToPoint(pathRef, NULL, w * 0.77f, h - fiTh * 4.0f - fiPa * 3.0f);
		
		// thumb
		CGPathAddLineToPoint(pathRef, NULL, w * 0.66f, h * 0.14f);
		CGPathAddArc(pathRef, NULL, w * 0.70f, h * 0.07f, fiTh * 0.5, M_PI * 0.75, M_PI * 1.75, NO);
		
		// close path
		CGPathCloseSubpath(pathRef);
		
	}
	return self;
}

- (void)setColor:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	
	red = colors[0];
	green = colors[1];
	blue = colors[2];
	
	[self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// get the current graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
	// draw an outline path created earlier in initWithFrame
	//CGContextSetRGBStrokeColor(context, 0.0f, 1.0f, 0.0f, 1.0f);
	//CGContextSetLineWidth(context, 2.0f);
	CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
	CGContextAddPath(context, pathRef);
	//CGContextStrokePath(context);
	CGContextFillPath(context);
}

@end

