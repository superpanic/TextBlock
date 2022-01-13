//
//  SPBlockViewTimeBomb.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-07-16.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPBlockViewTimeBomb.h"
#import "SPBlockView.h"
#import "SPRectView.h"
#import "SPCircleView.h"
#import "SPBombView.h"
#import "SPSquareView.h"

@implementation SPBlockViewTimeBomb

@synthesize clockFace;
@synthesize bombView;
@synthesize counterLabel;
@synthesize maxSelectedBlocks;
@synthesize timerLabel;

- (void)dealloc {
	[clockFace release];
	[bombView release];
	[counterLabel release];
	[timerLabel release];
	[super dealloc];
}

// init, calls initWithFrame using size as frame
- (id)initWithSize:(float)size {

	if (self = [super initWithSize:size]) {
		maxSelectedBlocks = 3;
		[self createViews];
	}
	return self;
}

- (void) createViews {
	
	[super createViews];
	
	// change color of background
	[[self backgroundSquare] setSquareFillColor:[SPCommon SPGetYellow]];
	[[self backgroundSquare] setDarkEdgeColor:[SPCommon SPGetOrange]];
	[[self backgroundSquare] setLightEdgeColor:[SPCommon SPGetBrightYellow]];
	[[self backgroundSquare] setNeedsDisplay];

	if(!clockFace) {
		// create the clock face
		SPCircleView *temp_clockFace = [[SPCircleView alloc] initWithDiameter:blockSize];
		[self setClockFace:temp_clockFace];
		[temp_clockFace release];
		
		[clockFace setColor:[SPCommon SPGetOffWhite]];
		[clockFace setHidden:YES];
		[[self view] addSubview:clockFace];
	}	
	
	if(!bombView) {
		// create the bomb view
		SPBombView *temp_bombView = [[SPBombView alloc] initWithDiameter:blockSize];
		[self setBombView:temp_bombView];
		[temp_bombView release];
		
		[[self view] addSubview:bombView];
	}	
	
	if(!counterLabel) {
		// create the counter label
		UILabel *temp_counterLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[self setCounterLabel:temp_counterLabel];
		[temp_counterLabel release];
		
		// set the text
		[ [self counterLabel] setText:[NSString stringWithFormat:@"%i", [self maxSelectedBlocks]] ];
		
		UIFont *counterFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.30f];
		
		// label settings
		[counterLabel setBackgroundColor:[UIColor clearColor]];
		[counterLabel setTextColor:[SPCommon SPGetOffWhite]];
		[counterLabel setFont:counterFont];
		[counterLabel setTextAlignment:UITextAlignmentCenter];
		// [counterLabel setCenter:CGPointMake( size * 0.5, size * 0.43 )];
		// [counterLabel setCenter:CGPointMake( blockSize * 0.5, blockSize * 0.5 )];
		[counterLabel setCenter:CGPointMake( blockSize * 0.5, blockSize * 0.43 )];
		
		[[self view] addSubview:counterLabel];

		[counterLabel setHidden:YES];
	}	

	if(!timerLabel) {
		// create the timer label
		UILabel *temp_timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[self setTimerLabel:temp_timerLabel];
		[temp_timerLabel release];
		
		// set the text
		[ timerLabel setText:[NSString stringWithFormat:@"%03i", 0 ]];
		
		UIFont *timerFont = [UIFont fontWithName:@"Helvetica-Bold" size:blockSize * 0.15f];
		
		// label settings
		[timerLabel setBackgroundColor:[UIColor clearColor]];
		[timerLabel setTextColor:[SPCommon SPGetOffWhite]];
		[timerLabel setFont:timerFont];
		[timerLabel setTextAlignment:UITextAlignmentCenter];
		// [timerLabel setCenter:CGPointMake( blockSize * 0.5, blockSize * 0.63 )];
		[timerLabel setCenter:CGPointMake( blockSize * 0.5, blockSize * 0.63 )];

		
		[[self view] addSubview:timerLabel];
		[timerLabel setHidden:YES];
	}
	
	[self animateFadeInFadeOutLoop];
		
}

	
- (void) destroyViews {
	[clockFace release];
	clockFace = nil;
	[bombView release];
	bombView = nil;
	[counterLabel release];
	counterLabel = nil;
	[timerLabel release];
	timerLabel = nil;
	[super destroyViews];
}

- (void) animateFadeInFadeOutLoop {
	// begin animation block
	[[backgroundSquare layer] removeAllAnimations];
	[backgroundSquare setAlpha:1.0f];
	
	// begin animation block
	[UIView beginAnimations:@"fadeBlock" context:NULL]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationRepeatAutoreverses:YES];
		[UIView setAnimationRepeatCount:FLT_MAX];
		[backgroundSquare setAlpha:0.8f];
	} [UIView commitAnimations];
}

- (void) showCounter {
	[counterLabel setHidden:NO];
	[timerLabel setHidden:NO];
}

- (void) updateCounter:(int)value {
	NSString *s = [NSString stringWithFormat:@"%i",maxSelectedBlocks-value];
	[counterLabel setText:s];
}

- (void) updateTimer:(float)value {
	value = floorf(value * 100.0f);
	NSString *s = [NSString stringWithFormat:@"%03i", (int)value];
	[timerLabel setText:s];
}

- (void) touchBlock {
	// mark as touched
	[bombView setColor:[SPCommon SPGetRed]];
	[clockFace setHidden:NO];
	[super touchBlock];
}

- (void) unTouchBlock {
	// [self.layer removeAllAnimations];
	// [self setAlpha:1.0f];
	[bombView setColor:[SPCommon SPGetOffWhite]];
	[clockFace setHidden:YES];
	[super unTouchBlock];
}

- (void) hideIcon {
	[clockFace setHidden:YES];
	[bombView setHidden:YES];
	[counterLabel setHidden:YES];
	[timerLabel setHidden:YES];
	[super hideIcon];
}

@end


