//
//  SPGameHeader.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPGameHeader.h"
#import "SPCommon.h"
//#import "SPGameViewController.h"
#import "SPDropShadowView.h"

#define kScoreCounterIncrement 30

@implementation SPGameHeader

@synthesize scoreLabel;
@synthesize score;
@synthesize displayScore;

@synthesize padding;

@synthesize dropShadowView;

@synthesize isShy;
@synthesize isTouched;
@synthesize hasDropShadow;
@synthesize hiddenEdge;
@synthesize touchPadding;

@synthesize buttonPause;

//@synthesize gameViewController;

@synthesize dropTimerLabel;
@synthesize dropTime;

@synthesize currentOrientation;

- (void)dealloc {
	[scoreLabel release];
	[dropTimerLabel release];
	[buttonPause release];
	[dropShadowView release];
//	[gameViewController release];
	[super dealloc];
}

- (id)initWithHeight:(float)h portraitWidth:(float)pw landscapeWidth:(float)lw hasDropShadow:(BOOL)dropShadow {
	
	CGRect f = CGRectMake(0.0f, 0.0f, lw, h);

	if ((self = [super initWithFrame:f])) {
				
		[self setBackgroundColor:[SPCommon SPGetOffWhite]];

		currentOrientation = 0;

		portraitWidth = pw;
		landscapeWidth = lw;
		
		padding = h/4.0f;
		touchPadding = h/4.0f;

		isShy = NO;
		isTouched = NO;
		hiddenEdge = h/8.0f;
		hasDropShadow = dropShadow;
		
		// font size
		UIFont *scoreFont = [UIFont fontWithName:@"Helvetica-Bold" size:f.size.height];
		// adjust font size
		// [scoreFont setAdjustsFontSizeToFitWidth:YES];		
		
		/*** scoreLabel ***/
		
		// score label width
		float sWidth = (f.size.width / 10.0f) * 6.5f;
		
		// create the score label
		UILabel *temp_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f + padding, 0.0f, sWidth, f.size.height)];
		[self setScoreLabel:temp_scoreLabel];
		[temp_scoreLabel release];

		// score label settings
		[scoreLabel setBackgroundColor:[UIColor clearColor]];
		[scoreLabel setTextColor:[SPCommon SPGetRed]];
		[scoreLabel setFont:scoreFont];
		[scoreLabel setTextAlignment:UITextAlignmentLeft];
		
		score = 0;
		displayScore = 0;
		
		NSString *scoreString = [NSString stringWithFormat:@"%05d", score];		
		[scoreLabel setText:scoreString];
		[self addSubview:scoreLabel];

		
		
		
		/*** pause button ***/
		
		// font size
		UIFont *buttonFont = [UIFont fontWithName:@"Helvetica-Bold" size:f.size.height * 0.4];
		
		// pause button label width
		float pWidth = (f.size.width / 10.0f) * 1.5f;
		
		// create the button object
		UIButton *temp_buttonPause = [[UIButton alloc] initWithFrame:CGRectMake(f.size.width - pWidth - padding, padding/2.0f, pWidth, f.size.height - padding)];
		[self setButtonPause:temp_buttonPause];
		[temp_buttonPause release];
		// set the button title
		[ [buttonPause titleLabel] setFont:buttonFont];
		
		NSString *pauseString;
		pauseString = NSLocalizedString(@"HEADER_PAUSE", @"Button: pause game.");
		
		[buttonPause setTitle:pauseString forState:UIControlStateNormal];
		// button colors
		[buttonPause setBackgroundColor:[SPCommon SPGetWhite]];
		[buttonPause setTitleColor:[SPCommon SPGetBlue] forState:UIControlStateNormal];
		// rounded corners
		[ [buttonPause layer] setCornerRadius:f.size.height/10.0f];
		// add a light gray border
		// [ [buttonPause layer] setBorderWidth:1.0f];
		// [ [buttonPause layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
		
		[self addSubview:buttonPause];
		
		// set button actions
		
		[buttonPause addTarget:self action:@selector(buttonPauseAction:) forControlEvents:UIControlEventTouchUpInside];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchDown:) forControlEvents:UIControlEventTouchDown];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
		
		
	
		/*** wordCountLabel ***/
		
		// word count label width
		float wWidth = (f.size.width / 10.0f) * 3.0f;
		float wOffset = (f.size.width / 10.0f) * 3.5f;
		
		// create the word count label
		UILabel *temp_wordCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(f.size.width - wOffset, 0.0f, wWidth, f.size.height)];
		[self setDropTimerLabel:temp_wordCountLabel];
		[temp_wordCountLabel release];

		// word count label settings
		[dropTimerLabel setBackgroundColor:[UIColor clearColor]];
		[dropTimerLabel setTextColor:[SPCommon SPGetBlue]];
		[dropTimerLabel setFont:scoreFont];
		[dropTimerLabel setTextAlignment:UITextAlignmentRight];

		dropTime = 0;

		NSString *wordCountString = [NSString stringWithFormat:@"%03d", dropTime];
		[dropTimerLabel setText:wordCountString];		
		[self addSubview:dropTimerLabel];

		if(hasDropShadow){
			/*** drop shadow view ***/
			// calculate shadow height
			float shadowHeight = f.size.height / 4.0f;
			// create the shadow view
			SPDropShadowView *temp_dropShadowView = [[SPDropShadowView alloc] initWithFrame:CGRectMake(0.0f, f.size.height, f.size.width, shadowHeight) color:[SPCommon SPGetDarkRed] ];
			[self setDropShadowView:temp_dropShadowView];
			[temp_dropShadowView release];
			[self addSubview:dropShadowView];
		}		
		
	}
	return self;
}




- (void)buttonPauseTouchUp:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetWhite]];
}

- (void)buttonPauseTouchDown:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetOffWhite]];
}

- (void)buttonPauseTouchUpOutside:(id)sender {
	[sender setBackgroundColor:[SPCommon SPGetWhite]];
}

- (void)buttonPauseAction:(id)sender {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_pauseButtonPressed object:nil];
	
	/*
	if(gameViewController) {
		if([gameViewController isGamePaused]) {
			[gameViewController resumeFromPausedGame];
		} else {
			[gameViewController pauseGame];
		}
	}
	*/
	
}

- (void) switchShyness {
	[self setIsShy:!isShy];
}



- (void) adjustForPortrait {
	[buttonPause setCenter:CGPointMake(portraitWidth - buttonPause.frame.size.width/2.0f - padding, [buttonPause center].y)];
	[dropTimerLabel setCenter:CGPointMake(portraitWidth - buttonPause.frame.size.width - dropTimerLabel.frame.size.width/2.0f - padding *2.0f, [buttonPause center].y)];
}

- (void) adjustForLandscape {
	[buttonPause setCenter:CGPointMake(landscapeWidth - buttonPause.frame.size.width/2.0f - padding, [buttonPause center].y)];	
	[dropTimerLabel setCenter:CGPointMake(landscapeWidth - buttonPause.frame.size.width - dropTimerLabel.frame.size.width/2.0f - padding *2.0f, [buttonPause center].y)];
}

- (void) updateScore:(int)value {
//	NSLog(@"score: %i", value);
	score = value;
}

- (BOOL) printScore {
	if(displayScore == score) return NO;
	
	if(displayScore + kScoreCounterIncrement >= score) {
		displayScore = score;
	} else {
		displayScore = displayScore + kScoreCounterIncrement;
	}
	
	NSString *scoreString = [NSString stringWithFormat:@"%05d", displayScore];
	[scoreLabel setText:scoreString];
	return YES;
}

- (BOOL) printScoreSlow {
	if(displayScore == score) return NO;
	
	int difference = score - displayScore;
	int delta = MAX(1, difference / 10);
	
	if(displayScore + delta >= score) {
		displayScore = score;
	} else {
		displayScore = displayScore + delta;
	}
	
	NSString *scoreString = [NSString stringWithFormat:@"%05d", displayScore];
	[scoreLabel setText:scoreString];
	return YES;
}

- (BOOL) printScoreFast {
	if(displayScore == score) return NO;
	
	int diff = score - displayScore;

	int delta = 10;
	
	if (diff >= 10000) {
		delta = diff / 10;
	} else if (diff >= 5000) {
		delta = 500;
	} else if (diff >= 1000) {
		delta = 100;
	} else if (diff >= 500) {
		delta = 50;
	}
	
	//NSLog(@"delta: %i score: %i", delta, score);
	if(displayScore + delta >= score) {
		displayScore = score;
	} else {
		displayScore = displayScore + delta;
	}
	
	NSString *scoreString = [NSString stringWithFormat:@"%05d", displayScore];
	[scoreLabel setText:scoreString];
	return YES;
}


- (void) printLetter:(NSString *)letter {
	NSString *letterString = [NSString stringWithFormat:@"%@ 000", letter];
	[dropTimerLabel setText:letterString];
}

- (void) updateDropTimer:(float)value withLetter:(NSString *)letter {
	// NSLog(@"WordCount: %f", value);
	dropTime = value*100;
	NSString *wordCountString = [NSString stringWithFormat:@"%@ %03d", letter, dropTime];
	[dropTimerLabel setText:wordCountString];		
}

- (void) updateDropTimer:(float)value {
	// NSLog(@"WordCount: %f", value);
	dropTime = value*100;
	NSString *wordCountString = [NSString stringWithFormat:@"%03d", dropTime];
	[dropTimerLabel setText:wordCountString];		
}




@end
