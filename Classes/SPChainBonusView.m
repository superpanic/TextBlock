//
//  SPChainBonusView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2011-08-09.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SPChainBonusView.h"
#import "SvgToBezier.h"
#import "SPCommon.h"

#define kChainIconSVG @"M128.184,18.797C128.184,8.433,119.752,0,109.387,0H86.504C76.139,0,67.707,8.433,67.707,18.797c0,4.403,1.525,8.455,4.07,11.662h3.883c2.641,0,4.941-1.465,6.144-3.623c-2.759-1.619-4.617-4.615-4.617-8.039c0-5.137,4.181-9.316,9.317-9.316h22.883c5.138,0,9.316,4.179,9.316,9.316c0,0.106-0.001,0.211-0.005,0.316c-0.167,4.992-4.28,9-9.312,9H96.215c-0.818,3.593-2.551,6.842-4.947,9.48h18.119C119.752,37.594,128.184,29.162,128.184,18.797zM60.477,18.797C60.477,8.433,52.045,0,41.68,0H18.797C8.432,0,0,8.433,0,18.797c0,10.365,8.432,18.797,18.797,18.797h18.374c-2.396-2.639-4.13-5.888-4.948-9.479H18.797c-5.137,0-9.317-4.179-9.317-9.316c0-0.097,0.001-0.194,0.005-0.291c0.154-5.002,4.273-9.025,9.312-9.025H41.68c5.138,0,9.317,4.179,9.317,9.316c0,3.344-1.772,6.281-4.426,7.925c1.184,2.221,3.521,3.737,6.206,3.737h3.628C58.951,27.252,60.477,23.2,60.477,18.797zM94.457,23.43c0-4.403-1.525-8.454-4.07-11.661h-3.883c-2.641,0-4.942,1.464-6.145,3.622c2.76,1.619,4.617,4.615,4.617,8.039c0,5.138-4.18,9.317-9.316,9.317H52.777c-5.137,0-9.315-4.18-9.315-9.317c0-3.344,1.771-6.281,4.425-7.925c-1.183-2.22-3.52-3.736-6.206-3.736h-3.628c-2.546,3.207-4.071,7.258-4.071,11.661c0,10.365,8.433,18.798,18.797,18.798H75.66C86.025,42.228,94.457,33.795,94.457,23.43zM57.286,4.633c2.396,2.639,4.13,5.888,4.947,9.48h3.716c0.818-3.593,2.551-6.842,4.947-9.48H57.286z"


@implementation SPChainBonusView

@synthesize isActive;
@synthesize pausePrinterUntilTime;
@synthesize scale;
@synthesize bonusLabel;
@synthesize scoreLabel;
@synthesize bezierPath;
@synthesize goalPoint;
@synthesize outsidePoint;
@synthesize score;

@synthesize goalPointTop;
@synthesize goalPointLeft;
@synthesize goalPointRight;
@synthesize goalPointBottom;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	if (self) {
				
		// ••• init variables •••
		
		isActive = NO;
		pausePrinterUntilTime = 0.0;
		score = 0;
		
		// sizes and positions
		goalPoint = [self center];
		outsidePoint = goalPoint;
		
		goalPointTop = goalPoint;
		goalPointRight = goalPoint;
		goalPointBottom = goalPoint;
		goalPointLeft = goalPoint;
		
		// CGRectMake(blockSize * 0.1, [gameHeader frame].size.height + blockSize * 0.1, blockSize * 1.9, blockSize * 0.4)
		// goalPointTop =
		
		singlePadding = CGRectGetHeight([self frame]) * 0.2;
		doublePadding = singlePadding * 2.0;
		centerPoint = CGPointMake([self frame].size.width * 0.5, [self frame].size.height * 0.5);		

//		[self setBackgroundColor:[SPCommon SPGetRed]];
		[self setBackgroundColor:[UIColor clearColor]];		
		
		// ••• icon •••
		
		// draw icon
		[self setScale:0.4];
		[self addSvgPathIcon:kChainIconSVG];
		
		// scale the path
		CGAffineTransform transformScale;	
		transformScale = CGAffineTransformMakeScale(scale, scale);
		[bezierPath applyTransform:transformScale];
		
		// move the path
		CGAffineTransform transformTranslate;
		transformTranslate = CGAffineTransformMakeTranslation(singlePadding, centerPoint.y - bezierPath.bounds.size.height * 0.5);
		[bezierPath applyTransform:transformTranslate];

		CGSize iconSize = bezierPath.bounds.size;
		
		float labelWidth = iconSize.width + doublePadding;

		// ••• labels •••
		
		// create the font used
		UIFont *bonusFont = [[UIFont fontWithName:@"Helvetica-Bold" size:CGRectGetHeight([self frame]) * 0.9] retain];
		
		// create the title label
		CGRect bonusLabelFrame = CGRectMake(labelWidth, 0.0,frame.size.width - labelWidth, [bonusFont ascender] + 1.0);
		bonusLabel = [[UILabel alloc] initWithFrame:bonusLabelFrame];
		//[bonusLabel setCenter:CGPointMake(centerPoint.x + iconSize.width * 0.5 + singlePadding, centerPoint.y)];
		[bonusLabel setCenter:CGPointMake([bonusLabel center].x, centerPoint.y)];
		[bonusLabel setFont:bonusFont];
		[bonusLabel setBackgroundColor:[UIColor clearColor]];
		[bonusLabel setTextColor:[SPCommon SPGetOffWhite]];
		[bonusLabel setTextAlignment:UITextAlignmentLeft];
		[bonusLabel setText:@"× 1"];
		[self addSubview:bonusLabel];
		
		
		// create the score label
		CGRect scoreLabelFrame = CGRectMake(labelWidth, 0.0, frame.size.width - labelWidth, [bonusFont ascender] + 1.0);
		scoreLabel = [[UILabel alloc] initWithFrame:scoreLabelFrame];
		[scoreLabel setCenter:CGPointMake([scoreLabel center].x, centerPoint.y)];
		[scoreLabel setFont:bonusFont];
		[scoreLabel setBackgroundColor:[UIColor clearColor]];
		[scoreLabel setTextColor:[SPCommon SPGetOffWhite]];
		[scoreLabel setTextAlignment:UITextAlignmentLeft];
		[scoreLabel setText:@"0000"];
		[scoreLabel setHidden:YES];
		[self addSubview:scoreLabel];
		
		// release the font
		[bonusFont release];
		
	}
	return self;
}

- (void) showBonusMultiplier {
	[scoreLabel setHidden:YES];
	[bonusLabel setHidden:NO];
	[bonusLabel setAlpha:1.0];
}

- (void) showChainBonus {
	[bonusLabel setAlpha:1.0];
	[scoreLabel setAlpha:0.0];
	[scoreLabel setHidden:NO];

	// start animation #1
	[UIView beginAnimations:@"hideBonusLabel" context:NULL]; {
		[UIView setAnimationDuration:0.25];
		[bonusLabel setAlpha:0.0];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideBonusLabel)];
	} [UIView commitAnimations];	

	// start animation #2
	[UIView beginAnimations:@"showScoreLabel" context:NULL]; {
		[UIView setAnimationDelay:0.25];
		[UIView setAnimationDuration:0.25];
		[scoreLabel setAlpha:1.0];
	} [UIView commitAnimations];	

}

- (void) hideScoreLabel {
	if(!bonusLabel) return;
	[scoreLabel setHidden:YES];
}

- (void) hideBonusLabel {
	if(!scoreLabel) return;
	[bonusLabel setHidden:YES];
}

- (void) setBonusMultiplier:(int)value {
	NSString *val = [[NSString stringWithFormat:@"× %i", value] retain];
	[bonusLabel setText:val];
	[val release];
}

- (void) setScore:(int)value {
	score = score + value;
	[scoreLabel setText:[NSString stringWithFormat:@"%04i", score]];
}

- (BOOL) isPrintingScore {
	if([scoreLabel isHidden]) return YES;
	if(score == 0) return NO;
	if(![scoreLabel isHidden] && pausePrinterUntilTime < [NSDate timeIntervalSinceReferenceDate]) {
		if(score - 10 <= 0) {
			score = 0;
		} else {
			score = score - 10;
		}
		NSString *scoreString = [NSString stringWithFormat:@"%04i", score];
		[scoreLabel setText:scoreString];
	}
	return YES;
}

- (int) printAndReturnScore {
	if( [scoreLabel isHidden] ) return 0;
	if( score == 0 ) return 0;
	if( pausePrinterUntilTime > [NSDate timeIntervalSinceReferenceDate] ) return 0;
	
	
	int delta = 10;
	
	if (score >= 10000) {
		delta = score / 10;
	} else if(score >= 5000) {
		delta = 500;
	} else if (score >= 1000) {
		delta = 100;
	} else if (score >= 500) {
		delta = 50;
	}
		
	int returnVal = delta;
	if(score - returnVal <= 0) {
		returnVal = returnVal - score;
		score = 0;
	} else {
		score = score - returnVal;
	}
	
	NSString *scoreString = [NSString stringWithFormat:@"%04i", score];
	[scoreLabel setText:scoreString];
	return returnVal;
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

- (void) dealloc {
	[bonusLabel release];
	[scoreLabel release];
	[bezierPath release];
	[super dealloc];
}

@end
