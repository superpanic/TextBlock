//
//  SPFlyingBlocks.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 11 Nov 2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPFlyingBlocks.h"
#import "SPBlockViewLetter.h"
#import "SPCommon.h"

#define kNumberOfBlocks 10
#define kScaleBlocks NO

@implementation SPFlyingBlocks

@synthesize flyingBlocks;
@synthesize timer;
@synthesize isPaused;

char letterChars[26] = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
int letterCharsLength = 26;

- (void)dealloc {
	[flyingBlocks release];
	if(timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	if ((self = [super initWithFrame:frame])) {
		
		blockSize = CGRectGetWidth(frame) / kBlockColumns;
		
		// Initialization code
		NSMutableArray *tempFlyingBlocks = [[NSMutableArray alloc] initWithCapacity:kNumberOfBlocks];
		[self setFlyingBlocks:tempFlyingBlocks];
		[tempFlyingBlocks release];
		
		[self setIsPaused:YES];
		
	}
	return self;
}

- (void) start {
	// create and start animating the flying blocks
	// fill the mutable array with n blocks
	for (int i = 0; i < kNumberOfBlocks; i++) {
		
		SPBlockViewLetter *block = [[self createNewBlock] retain];
		
		[flyingBlocks addObject:block];
		[self addSubview:[block view]];
		
		[self prepareBlock:block];
		[block release];

	}
	
	if(timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
	NSTimer *tempTimer = [[NSTimer scheduledTimerWithTimeInterval:kFramesPerSecond target:self selector:@selector( run ) userInfo:nil repeats:YES ] retain];
	[self setTimer:tempTimer];
	[tempTimer release];
	
	[self setIsPaused:NO];
	
}

- (SPBlockViewLetter *)createNewBlock {
	// pick a random letter
//	int randInt = arc4random() % strlen(letterChars);
	int randInt = arc4random() % letterCharsLength;

	char c = letterChars[randInt];
	NSString *blockLetter = [NSString stringWithFormat:@"%C", c];
	// NSLog(@"%C", c);
	// create a single block and set the letter
	SPBlockViewLetter *block = [ [ [SPBlockViewLetter alloc] initWithSize:blockSize blockLetter:blockLetter points:0 ] autorelease ];
	return block;
}

- (void) prepareBlock:(SPBlockViewLetter *)block {
	// x or y
	int isX = arc4random() % 2;
	int isPositive = arc4random() % 2;
	// position
	float randx = (float)( arc4random() % (int)CGRectGetWidth([self frame]) );
	float randy = (float)( arc4random() % (int)CGRectGetHeight([self frame]) );
	float maxx = CGRectGetWidth([self frame]);
	float maxy = CGRectGetHeight([self frame]);
	float offset = CGRectGetWidth([[block view] frame]) * 0.5f;
	
	int val = 10;
	// value between 1 and 10
	float xvel = ( (float)( arc4random() % val+1 ) );
	float yvel = ( (float)( arc4random() % val+1 ) );
	
	if(kScaleBlocks) {
		// scale blocks
		float scale = ((xvel+yvel) * 0.5) * 0.1;
		CGAffineTransform transformScale;	
		transformScale = CGAffineTransformMakeScale(scale, scale);
		[[block view] setTransform:transformScale];
	}
	
	// position the blocks
	if( isX ) {
		if( isPositive ) {
			[[block view] setCenter:CGPointMake( -offset, randy)];
		} else {
			[[block view] setCenter:CGPointMake( maxx + offset , randy)];
			 xvel = -xvel;
		}
	} else {
		if( isPositive ) {
			[[block view] setCenter:CGPointMake( randx, -offset )];
		} else {
			[[block view] setCenter:CGPointMake( randx, maxy + offset )];
			yvel = -yvel;
		}
	}
	
	// start fade animation
	// [block animateFadeInFadeOutLoop];
	
	// set the blocks velocity
	[block setXyVelocity:CGPointMake(xvel, yvel)];
}


- (void) stop {
	
	if([flyingBlocks count] > 0){
		// remove all blocks from superview
		for(int i = 0; i<[flyingBlocks count]; i++) [[[flyingBlocks objectAtIndex:i] view] removeFromSuperview];
		// remove all blocks from array
		[flyingBlocks removeAllObjects];
	}
	
	// stop, hide and kill all flying blocks
	if(timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}
	
}

- (void) run {
	if(isPaused) return;
	float xvel, yvel, xpos, ypos, offset;
	BOOL isBlockOutside;
	NSMutableArray *deletedObjects = [NSMutableArray array];
	for (SPBlockViewLetter *block in flyingBlocks) {	
		// the loop that animates the blocks
		xvel = [block xyVelocity].x;
		yvel = [block xyVelocity].y;
		xpos = [[block view] center].x + xvel;
		ypos = [[block view] center].y + yvel;
		
		offset = CGRectGetWidth([[block view] frame]) * 0.5f;

		isBlockOutside = NO;

		// check x bounds
		if(xvel > 0) if(xpos - offset > CGRectGetWidth([self frame])) isBlockOutside = YES;
		if(xvel < 0) if(xpos + offset < 0.0f) isBlockOutside = YES;
		// check y bounds
		if(yvel > 0) if(ypos - offset > CGRectGetHeight([self frame])) isBlockOutside = YES;
		if(yvel < 0) if(ypos + offset < 0.0f) isBlockOutside = YES;
		
		if(isBlockOutside) {
			[[block view] removeFromSuperview];
			[deletedObjects addObject:block];
			// delete block and create a new
		} else {
			// move block to new position
			[[block view] setCenter:CGPointMake(xpos, ypos)];
		}
	}	

	int newBlocks = [deletedObjects count];
	[flyingBlocks removeObjectsInArray:deletedObjects];

	// create new blocks to replace the dead ones
	if(newBlocks > 0) {
		for( int i = 0; i < newBlocks; i++ ) {
			SPBlockViewLetter *block = [[self createNewBlock] retain];
			[self prepareBlock:block];
			[flyingBlocks addObject:block];
			[self addSubview:[block view]];
			[block release];
		}
	}
}

- (void) pause {
	[self setIsPaused:YES];
}

- (void) unPause {
	[self setIsPaused:NO];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
	// Drawing code
}
*/


@end

