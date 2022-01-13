//
//  SPChainBonusAlertView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2011-08-28.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPChainBonusAlertView.h"
#import "SvgToBezier.h"
#import "SPCommon.h"

@implementation SPChainBonusAlertView

@synthesize bezierPath;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

	    // sizes and positions
	    
	    [self setBackgroundColor:[UIColor clearColor]];
	    
	    CGPoint centerPoint = CGPointMake(frame.size.width * 0.5, frame.size.height * 0.5);
	    
	    // ••• icon •••
	    
	    // draw icon
	    [self addSvgPathIcon:kChainIconSVG];
	    
	    // set icon scale to fit frame
	    float scale = frame.size.width / bezierPath.bounds.size.width;

	    // scale the path
	    CGAffineTransform transformScale;	
	    transformScale = CGAffineTransformMakeScale(scale, scale);
	    [bezierPath applyTransform:transformScale];
	    
	    // move the path
	    CGAffineTransform transformTranslate;
	    transformTranslate = CGAffineTransformMakeTranslation(centerPoint.x - bezierPath.bounds.size.width * 0.5, centerPoint.y - bezierPath.bounds.size.height * 0.5);
	    [bezierPath applyTransform:transformTranslate];

    }
    return self;
}

- (void) addSvgPathIcon:(NSString *)svgString {
	// create svg vector symbol
	SvgToBezier *bezierConverter = [[[SvgToBezier alloc] initFromSVGPathNodeDAttr:svgString inViewBoxSize:CGSizeMake(40.0, 40.0)] autorelease];
	UIBezierPath *temp_bezierPath = [bezierConverter.bezier retain];
	[self setBezierPath:temp_bezierPath];
	[temp_bezierPath release];
	// redraw
	[self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
	
	if(!bezierPath) return;
	
	// get the current graphics context
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	// set the drawing color	
	const float* col = CGColorGetComponents( [[SPCommon SPGetOffWhite] CGColor] );
	CGContextSetRGBFillColor(ctx, col[0], col[1], col[2], 1.0);
	
	// draw the path
	CGContextAddPath(ctx, bezierPath.CGPath);
	CGContextFillPath(ctx);
}

@end
