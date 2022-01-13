//
//  SPBlockSquare.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPInfoBarView.h"

#define kPadding 1.0f

@implementation SPInfoBarView

// the diameter of this circle
@synthesize barSize;
@synthesize titleSize;

@synthesize isTitleBarSmooth;
@synthesize red;
@synthesize green;
@synthesize blue;
@synthesize cornerRadius;
@synthesize edgePadding;


#pragma mark -
#pragma mark defines


- (void)dealloc {
	if(pathRef)CFRelease(pathRef);
	[super dealloc];
}

- (id)initWithBarSize:(CGSize)bs titleSize:(CGSize)ts cornerRadius:(float)r smoothTitleBar:(BOOL)b {
	
	barSize = bs;
	titleSize = ts;
	cornerRadius = r;
	isTitleBarSmooth = b;

	CGRect f = CGRectMake(0.0f, 0.0f, barSize.width, barSize.height + titleSize.height);
	
	if ((self = [super initWithFrame:f])) {

		// Initialization code
		
		[self setBackgroundColor:[UIColor clearColor]];
				
		const float* colors = CGColorGetComponents( [[SPCommon SPGetOffWhite] CGColor] );
		
		red = colors[0];
		green = colors[1];
		blue = colors[2];
		
		// create the path object used for the outline
		pathRef = CGPathCreateMutable();
		
		/*
		 rounded corners:
		      
		1/-----\2
		 |     |__________ 
		 |     2b         \3
		 |                |
		5\________________/4
		 
		 */
		
		// Corner 1
		CGPathAddArc(pathRef, NULL, cornerRadius, cornerRadius, cornerRadius, M_PI, M_PI * 1.5f, NO);
		CGPathAddLineToPoint(pathRef, NULL, titleSize.width - cornerRadius, 0.0f);
		
		// Corner 2
		CGPathAddArc(pathRef, NULL, titleSize.width - cornerRadius, cornerRadius, cornerRadius, M_PI * 1.5, 0.0f, NO);
		
		if( isTitleBarSmooth ) {
			// Corner 2b
			CGPathAddLineToPoint(pathRef, NULL, titleSize.width, titleSize.height-cornerRadius);
			CGPathAddArc(pathRef, NULL, titleSize.width + cornerRadius, titleSize.height - cornerRadius, cornerRadius, M_PI, 0.5f * M_PI, YES);
		} else {
			CGPathAddLineToPoint(pathRef, NULL, titleSize.width, titleSize.height);
		}
				
		// Corner 3
		CGPathAddArc(pathRef, NULL, barSize.width - cornerRadius, titleSize.height + cornerRadius, cornerRadius, M_PI * 1.5, 0.0f, NO);
		CGPathAddLineToPoint(pathRef, NULL, barSize.width, titleSize.height + barSize.height - cornerRadius);
		
		// Corner 4
		CGPathAddArc(pathRef, NULL, barSize.width - cornerRadius, titleSize.height + barSize.height - cornerRadius, cornerRadius, 0.0f, 0.5f * M_PI, NO);
		CGPathAddLineToPoint(pathRef, NULL, cornerRadius, titleSize.height + barSize.height);
		
		// Corner 5
		CGPathAddArc(pathRef, NULL, cornerRadius, titleSize.height + barSize.height - cornerRadius, cornerRadius, 0.5f * M_PI, M_PI, NO);
		CGPathCloseSubpath(pathRef);
		
	}
	return self;
}

- (void) setColor:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	
	red = colors[0];
	green = colors[1];
	blue = colors[2];
	
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
	// Drawing code
	
	// get the current graphics context
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	// draw an the outline path created earlier in initWithFrame
	CGContextSetRGBFillColor(context, red, green, blue, 1.0f);
	CGContextAddPath(context, pathRef);
	CGContextFillPath(context);
}


@end
