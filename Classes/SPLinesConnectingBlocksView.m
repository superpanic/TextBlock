//
//  LineView.m
//  TouchSpell
//
//  Created by Fredrik Josefsson on 2009-09-09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SPLinesConnectingBlocksView.h"

@implementation SPLinesConnectingBlocksView

#define kLineWidth 10.0f

@synthesize points;
@synthesize lineCenterOffset;
@synthesize lineSinMultiplier;
@synthesize lineWidth;
@synthesize lineOverlap;

@synthesize red;
@synthesize green;
@synthesize blue;




- (void)dealloc {
	// release the path object
	if(touchPathRef) CFRelease(touchPathRef);
	[points release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame blockSize:(float)blockSize {
	if (self = [super initWithFrame:frame]) {
				
		// Initialization code
		[self setBackgroundColor:[UIColor clearColor]];

		NSMutableArray *p = [[NSMutableArray alloc] init];
		[self setPoints:p];
		[p release];
		
		
		const float* colors = CGColorGetComponents( [[SPCommon SPGetOffWhite] CGColor] );
		
		red = colors[0];
		green = colors[1];
		blue = colors[2];
		
		
		// line offset
		lineCenterOffset = blockSize / 2.0f;
		
		// multiplier used to calculate line diagonal length
		lineSinMultiplier = sin( M_PI / 4.0f );

		// line width
		lineWidth = blockSize / 5.0f;
		
		// line overlap to avoid glitches
		lineOverlap = blockSize * 0.075f;
				
		// a mutable path reference used to draw a path along the selected blocks
		//CGMutablePathRef tpf = CGPathCreateMutable();
		//touchPathRef = tpf;
		//CFRelease(tpf);

		// touchPathRef = CGPathCreateMutable();
	}
	// NSLog(@"Init LineView ok!");
	return self;
}

- (void)savePointXPos:(float)x yPos:(float)y {
	// NSLog(@"LineView trying to save point values to an array!");
	// save the point to array
	NSNumber *numx = [NSNumber numberWithFloat: x ];
	NSNumber *numy = [NSNumber numberWithFloat: y ];
	
	// [points addObject:[ [NSArray alloc] initWithObjects: numx, numy, nil ] ];
	[ points addObject:[NSArray arrayWithObjects: numx, numy, nil] ];
	
	// NSLog(@"LineView save point position ok!");
}
	
- (void)newPathAtXPos:(float)x yPos:(float)y {	
	
	// NSLog(@"Starting new path!");
	
	// save point to array
	[self savePointXPos:x yPos:y];

	// release existing path object
	if(touchPathRef) CFRelease(touchPathRef);

	// create a new path object
	touchPathRef = CGPathCreateMutable();
}

- (void)addLineAtXPos:(float)x yPos:(float)y {

	// NSLog(@"Adding line to path!");
	
	if(![points count]) {
		[self newPathAtXPos:x yPos:y];
		return;
	}

	// get the last position 	
	float lastX = [[[points lastObject] objectAtIndex:0] floatValue];
	float lastY = [[[points lastObject] objectAtIndex:1] floatValue];	

	// line offset variable
	float lineOffset = 19.0;

	// calculate offset based on destination, 
	// if straight line the offset is longer.
	if( lastX == x || lastY == y ) lineOffset = lineCenterOffset - lineOverlap;
	else lineOffset = ((lineCenterOffset - lineOverlap) * lineSinMultiplier);

	// fel här!
	
// 	NSLog( "Cos on 45 deg (in rad): %f", cos(M_PI * 0.25f) );

	// offset variables (must be set to 0)
	float xOffset = 0.0;
	float yOffset = 0.0;
	
	// xoffset
	if( lastX < x ) xOffset = lineOffset;
	if( lastX > x ) xOffset = lineOffset * -1;
	// yoffset
	if( lastY < y ) yOffset = lineOffset;
	if( lastY > y ) yOffset = lineOffset * -1;
		
	// start new path
	CGPathMoveToPoint(touchPathRef, NULL, lastX + xOffset, lastY + yOffset);

	// save destination point to array
	[self savePointXPos:x yPos:y];

	// draw line (uses '-' as desination offset is negative to start offset)
	CGPathAddLineToPoint(touchPathRef, NULL, x - xOffset, y - yOffset);

	[self setNeedsDisplay];
	
}

- (void)clearPointsOfPath:(int)numberOfPointsToClear {
	
	// safety check
	if(numberOfPointsToClear > [points count]) return;

	// if needed release existing path object
	if(touchPathRef) CFRelease(touchPathRef);

	// create a new path object
	touchPathRef = CGPathCreateMutable();
		
	// adjust array (delete the number of points)
	for(int i = 0; i<numberOfPointsToClear; i++) {
		if([points count]) [points removeLastObject];
	}
	
	// REDRAW THE PATH
	
	// redraw the rest of the entire path
	if([points count]>1) {
		
		// create position floats, changes with each iteration
		float x;
		float y;
		float lastX;
		float lastY;
		float xOffset;
		float yOffset;
		
		// set line offset (static)
		float lineOffset = 19.0f; 

		// redraw all lines
		for(int j = 0; j<[points count]-1; j++) {

			// get the last position 	
			lastX = [[[points objectAtIndex:j] objectAtIndex:0] floatValue];
			lastY = [[[points objectAtIndex:j] objectAtIndex:1] floatValue];
			
			// get destination position
			x = [[[points objectAtIndex:j+1] objectAtIndex:0] floatValue];
			y = [[[points objectAtIndex:j+1] objectAtIndex:1] floatValue];


			// calculate offset based on destination, 
			// if straight line the offset is longer.
			if( lastX == x || lastY == y ) lineOffset = lineCenterOffset - lineOverlap;
			else lineOffset = (lineCenterOffset * lineSinMultiplier) - lineOverlap;

			// offset variables (must be set to 0)
			xOffset = 0.0;
			yOffset = 0.0;
			
			// xoffset
			if( lastX < x ) xOffset =  lineOffset;
			if( lastX > x ) xOffset = lineOffset * -1;
			// yoffset
			if( lastY < y ) yOffset =  lineOffset;
			if( lastY > y ) yOffset = lineOffset * -1;
				
			// start new path
			CGPathMoveToPoint(touchPathRef, NULL, lastX + xOffset, lastY + yOffset);

			// draw line to destination (uses '-' as desination offset is negative to start offset)
			CGPathAddLineToPoint(touchPathRef, NULL, x - xOffset, y - yOffset);
		}
		
	}
	
	// tell the view to redraw screen
	[self setNeedsDisplay];
	
	// NSLog(@"LineView clear points! Number of points: %i", numberOfPointsToClear);
};

- (void)clearPath {
	// delete all points on array
	[points removeAllObjects];
	// release existing path object
	if(touchPathRef) CFRelease(touchPathRef);
	// create a new empty path object
	touchPathRef = CGPathCreateMutable();
	// update display with empty path
	[self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	if(!touchPathRef)return;
	// Drawing code
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetRGBStrokeColor(context, red, green, blue, 1.0);
	CGContextSetLineWidth(context, lineWidth);
	CGContextAddPath(context, touchPathRef);
	CGContextStrokePath(context);
	// NSLog(@"LineView draw rect to screen!");
}


@end
