//
//  SPGameHeader.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPFloatingInfoBar.h"
#import "SPCommon.h"
#import "SPInfoBarView.h"
#import "SPGameViewController.h"

#define kMaxMovement 200.0f
#define kMinMovement 3.0f
#define kFramesPerSecond (1.0 / 30)
#define kTouchTimerInterval (1.0 / 4)

@implementation SPFloatingInfoBar

@synthesize scoreLabel;
@synthesize titleLabel;
@synthesize infoBar;

@synthesize barSize;
@synthesize titleSize;

@synthesize superRect;

@synthesize runTimer;
@synthesize touchPointOffset;
@synthesize velocity;

@synthesize wOffset;
@synthesize hOffset;

@synthesize gameViewController;
@synthesize previousTimeStamp;

@synthesize buttonPause;

@synthesize score;
@synthesize displayScore;


- (void)dealloc {
	[scoreLabel release];
	[infoBar release];
	[gameViewController release];
	[titleLabel release];
	[buttonPause release];
	[runTimer release];
	[super dealloc];
}

- (id)initWithFrame:(CGRect)r {

	if ((self = [super initWithFrame:r])) {
		
		[self setBackgroundColor:[UIColor clearColor]];
		
		wOffset = [self frame].size.width / 2.0f;
		hOffset = [self frame].size.height / 2.0f;
		
		superRect = [[self superview] frame];
		
		/*** info bar ***/
		
		barSize = CGSizeMake( [self frame].size.width, [self frame].size.height * 0.76f );
		titleSize = CGSizeMake( [self frame].size.width * 0.3f, [self frame].size.height - barSize.height);

		float padding = [self frame].size.width / 64.0f;
		
		// title font size
		UIFont *titleFont = [UIFont fontWithName:@"Helvetica-Bold" size:titleSize.height * 0.9];
				
		// calculate title size
		CGSize titleStringSize = [@"SCORE" sizeWithFont:titleFont];
		
		titleSize.width = titleStringSize.width + padding * 2.0f;

		// info font size
		UIFont *infoFont = [UIFont fontWithName:@"Helvetica-Bold" size:barSize.height];
		
		float cornerRadius = titleSize.height * 0.4f;
		
		/*** infoBar ***/
		SPInfoBarView *temp_infoBar = [[SPInfoBarView alloc] initWithBarSize:barSize titleSize:titleSize cornerRadius:cornerRadius smoothTitleBar:YES];
		[self setInfoBar:temp_infoBar];
		[temp_infoBar release];
		
		[self addSubview:infoBar];
		
		
		
		/*** title label ***/
		UILabel *temp_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake( padding, titleSize.height * 0.2f, titleSize.width - padding, titleSize.height * 0.8f )];
		[self setTitleLabel:temp_titleLabel];
		[temp_titleLabel release];
		
		// title label settings
		[titleLabel setBackgroundColor:[UIColor clearColor]];
		[titleLabel setTextColor:[SPCommon SPGetBlue]];
		[titleLabel setFont:titleFont];
		[titleLabel setTextAlignment:UITextAlignmentLeft];
		[titleLabel setText:@"SCORE"];
		
		[self addSubview:titleLabel];
		
		
		
		/*** scoreLabel ***/
		// create the score label
		UILabel *temp_scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake( padding, titleSize.height + barSize.height * 0.1f, barSize.width * 0.7f, barSize.height * 0.8f )];
		[self setScoreLabel:temp_scoreLabel];
		[temp_scoreLabel release];
		
		// score label settings
		[scoreLabel setBackgroundColor:[UIColor clearColor]];
		[scoreLabel setTextColor:[SPCommon SPGetRed]];
		[scoreLabel setFont:infoFont];
		[scoreLabel setTextAlignment:UITextAlignmentLeft];
				
		score = 0;
		displayScore = 0;
		
		NSString *scoreString = [NSString stringWithFormat:@"%05d", score];		
		[scoreLabel setText:scoreString];
		[self addSubview:scoreLabel];

		
		
		/*** pause button ***/
		// create the button object
		UIButton *temp_buttonPause = [[UIButton alloc] initWithFrame:CGRectMake( 0.0f, 0.0f, barSize.width * 0.3, barSize.height * 0.75 )];
		[self setButtonPause:temp_buttonPause];
		[temp_buttonPause release];
		// position the button
		[buttonPause setCenter:CGPointMake(barSize.width - barSize.width * 0.175, titleSize.height + barSize.height * 0.5)];		
		// set the button title
		[ [buttonPause titleLabel] setFont:titleFont];
		[buttonPause setTitle:@"PAUSE" forState:UIControlStateNormal];
		// button colors
		[buttonPause setBackgroundColor:[SPCommon SPGetWhite]];
		[buttonPause setTitleColor:[SPCommon SPGetBlue] forState:UIControlStateNormal];
		// rounded corners
		[ [buttonPause layer] setCornerRadius:cornerRadius];
		// add a light gray border
		// [ [buttonPause layer] setBorderWidth:1.0f];
		// [ [buttonPause layer] setBorderColor:[[UIColor lightGrayColor] CGColor]];
		
		[self addSubview:buttonPause];
		
		// set button actions
		
		[buttonPause addTarget:self action:@selector(buttonPauseAction:) forControlEvents:UIControlEventTouchUpInside];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchDown:) forControlEvents:UIControlEventTouchDown];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
		[buttonPause addTarget:self action:@selector(buttonPauseTouchUp:) forControlEvents:UIControlEventTouchUpInside];
		
		velocity = CGPointMake(0.0f, 0.0f);
		
		
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
	// reverse the game paused BOOL
	if(gameViewController) {
		if([gameViewController isGamePaused]) {
			[gameViewController resumeFromPausedGame];
		} else {
			[gameViewController pauseGame];
		}
	}
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 	
	// [self setCenter:CGPointMake([self center].x - 5.0f, [self center].y - 5.0f) ];
	UITouch *touch = [touches anyObject];
 	CGPoint p = [touch locationInView:[self superview]];
	touchPointOffset = CGPointMake(p.x - [self center].x, p.y - [self center].y);
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint p = [touch locationInView:[self superview]];
	previousTimeStamp = [touch timestamp];
	
	// move the view
	float px = p.x - touchPointOffset.x;
	float py = p.y - touchPointOffset.y;
	
	px = MAX(px, 0 + wOffset);
	px = MIN(px, superRect.size.width - wOffset);
	py = MAX(py, 0 + hOffset - titleSize.height + superRect.origin.y);
	py = MIN(py, superRect.size.height - hOffset + superRect.origin.y);
	
	[self setCenter:CGPointMake(px, py)];

}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *touch = [touches anyObject];
	CGPoint currentLocation = [touch locationInView:[self superview]];
	CGPoint previousLocation = [touch previousLocationInView:[self superview]];
	NSTimeInterval timeSinceLastTouchMutation = [touch timestamp] - previousTimeStamp;
	// calculate velocity
	double velocityx = ((currentLocation.x - previousLocation.x) / timeSinceLastTouchMutation) / 100.0f;
	double velocityy = ((currentLocation.y - previousLocation.y) / timeSinceLastTouchMutation) / 100.0f;
	velocity = CGPointMake(velocityx, velocityy);
	// start a timer and run
	runTimer = [[NSTimer scheduledTimerWithTimeInterval:kFramesPerSecond target:self selector:@selector( run ) userInfo:nil repeats:YES] retain];
}


- (void)run {
	
	// move at velocity speed (no edge bounce)
	float px = [self center].x + velocity.x;
	float py = [self center].y + velocity.y;
	
	px = MAX(px, 0 + wOffset);
	px = MIN(px, superRect.size.width - wOffset);
	py = MAX(py, 0 + hOffset - titleSize.height + superRect.origin.y);
	py = MIN(py, superRect.size.height - hOffset + superRect.origin.y);
	
	[self setCenter:CGPointMake(px, py)];
	
	// update velocity
	velocity.x = velocity.x * 0.9f;
	velocity.y = velocity.y * 0.9f;
	// kill timer and stop moving if velocity is close to 0
	if( ABS(velocity.x) + ABS(velocity.y) < 0.01 ) {
		[runTimer invalidate];
		runTimer = nil;
		velocity.x = 0.0f;
		velocity.y = 0.0f;
	}
}


- (void) updateScore:(int)value {
	score = value;
}

- (BOOL) printScore {
	if(displayScore == score) return NO;
	
	if(displayScore + 10 >= score) {
		displayScore = score;
	} else {
		displayScore = displayScore + 10;
	}
	
	NSString *scoreString = [NSString stringWithFormat:@"%05d", displayScore];
	[scoreLabel setText:scoreString];
	return YES;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
