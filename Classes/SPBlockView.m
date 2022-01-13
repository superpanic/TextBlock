//
//  BlockView.m
//  Block
//
//  Created by Fredrik Josefsson on 2010-02-10.
//  Copyright 2010 Superpanic. All rights reserved.
//

#import "SPBlockView.h"
#import "SPSquareView.h"
#import "SPCommon.h"



@implementation SPBlockView

#pragma mark -
#pragma mark object properties (needs release)

// the main view
@synthesize view;

// background of block
@synthesize backgroundSquare;




#pragma mark value properties

// size of this block
@synthesize blockSize;

@synthesize shardViews;


// thickness of inactive slide touch padding border edge
@synthesize touchPadding;

// the position the block wants to fall down to
@synthesize goalPosition;

// the blocks falling velocity
@synthesize velocity;

// the blocks exploding velocity
@synthesize xyVelocity;

// the blocks time stamp (since last moved)
// @synthesize timeStamp;

// the highest velocity a block can fall
@synthesize maximumVelocity;

// angle of shake offset
@synthesize shakeVector;

@synthesize shakeOffset;

@synthesize savedPos;


#pragma mark boolean flags

// is the block falling
@synthesize isFalling;

// is the block touched
@synthesize isTouched;

// is the block deleted
@synthesize isDeleted;

// is marked for deletion
@synthesize isMarkedForDeletion;

// is the block exploding
@synthesize isExploding;

@synthesize isBombed;

#pragma mark -
#pragma mark defines

#define kPadding 0.0f
#define kRoundingRadius 8.0f
#define kNumberOfSharpnel 4



#pragma mark -
#pragma mark c arrays


float shakeOffsetValues[5] = { 1.0, 2.0, 3.0, 2.0, 1.0 };
const int kShakeOffsetValuesLength = 5;


#pragma mark -
#pragma mark memory management

- (void) dealloc {
	[view release];
	[backgroundSquare release];
	[shardViews release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark init and creation

- (id) initWithSize:(float)size {

	// set size of the block
	[self setBlockSize:size];
	
	// set falling to no
	[self setIsFalling:NO];
	
	// the block is not touched
	[self setIsTouched:NO];
	
	// the block is not deleted
	[self setIsDeleted:NO];
	
	// the block is not marked for deletion
	[self setIsMarkedForDeletion:NO];
	
	[self setIsBombed:NO];

	// the block is not exploding
	isExploding = NO;
	
	// thickness of inactive slide touch padding border edge (25% of block width)
	touchPadding = blockSize/4.0f;
	
	// set velocity to 0
	[self setVelocity:0.0f];
	
	// set maximumVelocity
	maximumVelocity = 2000.0f;
	
	// set the exploding velcity to 0,0
	[self setXyVelocity:CGPointMake(0.0f, 0.0f)];

	// set goal position to center of frame
	[self setGoalPosition:CGPointMake(blockSize/2.0f, blockSize/2.0f)];
	
	[self setSavedPos:goalPosition];
	
	// prepare shake offset variables
	shakeCounter = 0;
	shakeVector = CGPointMake(0.0f, 0.0f);
	
	return self;
}


- (void) createViews {
	/*** main view ***/
	if(!view) {
		UIView *temp_view = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[self setView:temp_view];
		[temp_view release];
		// add main view
		[[[self view] layer] setMasksToBounds:NO];
		// make background transparent
		[[self view] setBackgroundColor:[UIColor clearColor]];
		// this view is added directly as subview to the view controllers main view
		[[self view] setCenter:savedPos];
	}

	if(!backgroundSquare) {
		/*** background plate ***/
		SPSquareView *temp_backGroundSquare = [ [SPSquareView alloc] initWithSize:blockSize ];
		[self setBackgroundSquare:temp_backGroundSquare];
		[temp_backGroundSquare release];
		[backgroundSquare setHidden:NO];	
		// add background square
		[[self view] addSubview:backgroundSquare];
	}
}


- (void) destroyViews {
	// save position
	savedPos = [[self view] center];
	// destroy the views
	[view release];
	view = nil;
	[backgroundSquare release];
	backgroundSquare = nil;
}

- (void) explode {
	[self calcRandomXYVelocity:700];

	// set the falling state to NO
	isFalling = NO;
	
	// the block is exploding
	isExploding = YES;
	
}

- (void) calcRandomXYVelocity:(int)val {
	// set a random velocity value
	float x = ( (float)( arc4random() % val ) ) + (float)val * 0.1;
	float y = ( (float)( arc4random() % val ) ) + (float)val * 0.1;
	
	// set random negative or positive movement
	if( (arc4random() % 2)-1 ) x = -x;
	if( (arc4random() % 2)-1 ) y = -y;
	
	// set the explosion velocity
	[self setXyVelocity:CGPointMake(x, y)];	
}

- (void) touchBlock {
	// mark as touched
	[self setIsTouched:YES];
	[backgroundSquare setHidden:YES];
}

- (void) unTouchBlock {
	// mark as not touched
	[self setIsTouched:NO];
	[backgroundSquare setHidden:NO];
}

- (void) hideIcon {
	[backgroundSquare setHidden:YES];
}

- (void) hideBlockView {
	[view setHidden:YES];
}

- (void) fadeOutBlockView {
	[UIView beginAnimations:@"fadeBlockView" context:NULL]; {
		[UIView setAnimationDelay:0.0f];
		[UIView setAnimationDuration:0.2];
		[[self view] setAlpha:0.0f];
	}
	[UIView commitAnimations];
}

- (void) showBlockView {
	[view setHidden:NO];
}

- (void) animateFadeInFadeOutLoop {	
	// change color of background
	[backgroundSquare setSquareFillColor:[SPCommon SPGetLightBlue]];
	[backgroundSquare setNeedsDisplay];
	// begin animation block
	[[backgroundSquare layer] removeAllAnimations];
	[backgroundSquare setAlpha:1.0f];
	[UIView beginAnimations:@"fadeBlock" context:NULL]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationRepeatAutoreverses:YES];
		[UIView setAnimationRepeatCount:FLT_MAX];
		[backgroundSquare setAlpha:0.8f];
	} [UIView commitAnimations];
}

- (void) shake {
	if(shakeCounter == 0) {
		// create a random vector value
		int p = (int)((M_PI*2.0f)*100.0f);
		float r = ((float)(arc4random() % p))/100.0f;
		double x = cos(r);
		double y = sin(r);
		[self setShakeVector:CGPointMake(x, y)];
		// reset counter
		shakeCounter = kShakeOffsetValuesLength-1;
	}
	// adjust offset values
	shakeOffset = CGPointMake(shakeOffsetValues[shakeCounter]*shakeVector.x, shakeOffsetValues[shakeCounter]*shakeVector.y);
	// subtract to next step
	shakeCounter--;
}

- (void) shakeReset {
	shakeCounter = 0;
	shakeOffset = CGPointMake(0.0f, 0.0f);
}

- (CGPoint) goalPosWithShakeOffset {
	return CGPointMake([self goalPosition].x + [self shakeOffset].x, [self goalPosition].y + [self shakeOffset].y);
}

- (void) stop {
	[[self view] setCenter:CGPointMake( [self goalPosition].x, [self goalPosition].y) ];
	[self setIsFalling:NO];
	[self setVelocity:0.0f];	
}



- (void) fragExplosion {
	
	// set define kNumberOfSharpnel at the beginning of file
	
	// this effect can only be done once, if the shard view list already is filled with shards then return
	if(shardViews)return;
	
	// ### 1 - calculate the random radian values adding upp to a whole circle
	// list of random values between 0 and 999
	NSMutableArray *randomValues = [NSMutableArray arrayWithCapacity:kNumberOfSharpnel];
	// used to add all the random values together
	int total = 0;
	// populate the list with random values
	for(int i=0; i<kNumberOfSharpnel; i++ ) {
		[randomValues addObject:[NSNumber numberWithInt:arc4random() % 1000]]; 
		// add values to total
		total = total + [[randomValues lastObject] intValue];
	}
	// calculate delta from 'total' and a full circle in radians
	float delta = (2.0f * M_PI) / (float)total;
	// array of random radian values all adding up to a full circle
	NSMutableArray *circleParts = [NSMutableArray arrayWithCapacity:kNumberOfSharpnel];
	// populate the array with radian values
	for( NSNumber *p in randomValues ) {
		// calculate the float radian values from total and delta
		[circleParts addObject:[ NSNumber numberWithFloat:[p floatValue] * delta ] ];
	}
	
	// ### 2 - create the image views
	
	// create the shard view mutable array
	NSMutableArray *temp_shardViews = [[NSMutableArray alloc] initWithCapacity:kNumberOfSharpnel];
	[self setShardViews:temp_shardViews];
	[temp_shardViews release];
	
	// create and add empty image views to the array
	for(int j = 0; j<kNumberOfSharpnel; j++) {
		UIImageView *v = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, blockSize, blockSize)];
		[[self shardViews] addObject:v];
		[v release];
	}
	
	
	// get a random rotation value
	int fullCircleValue = (int)((M_PI * 2.0f) * 1000.0f);
	float randomRotationValue = (float)(arc4random() % fullCircleValue);
	float randomRadianOffset = randomRotationValue/1000.0f;


	// ### 3 - mask and copy all images to the UIViews
	// now set the image of all image views to the same image
	// start at a random offset radian value
	float radianCounter = randomRadianOffset;
	int imageCounter = 0;
	for(UIImageView *img in [self shardViews]) {
		
		// create a graphics context block
		UIGraphicsBeginImageContext(self.view.bounds.size);
		// create the mask
		CGContextBeginPath(UIGraphicsGetCurrentContext());
		// get rad value
		float r = [[circleParts objectAtIndex:imageCounter] floatValue];
		// draw arc
		CGContextAddArc(UIGraphicsGetCurrentContext(), blockSize/2.0f, blockSize/2.0f, blockSize/2.0f, radianCounter, radianCounter + r, 0);
		// draw line
		CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), blockSize/2.0f, blockSize/2.0f);
		// close path
		CGContextClosePath(UIGraphicsGetCurrentContext());
		// mask using the current path
		CGContextClip(UIGraphicsGetCurrentContext());
		// render current UIView image into the new graphics context
		[self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
		// create a UIImage from the contents of the craphics context
		UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
		// end the graphics context block
		UIGraphicsEndImageContext();
		
		[img setImage:viewImage];
		
		radianCounter = radianCounter + [[circleParts objectAtIndex:imageCounter] floatValue];
		imageCounter++;
	}
	

	// test displaying the images
	for(UIImageView *img in [self shardViews]) {
		[[self view] addSubview:img];
		[img setCenter:CGPointMake(0.0f + blockSize / 2.0f, 0.0f + blockSize / 2.0f)];
	}
	
	// ### 4 - animate movement
	// reset local variables radianCounter and imageCounter from above
	radianCounter = randomRadianOffset;
	imageCounter = 0;
	for(NSNumber *cp in circleParts) {
		// will yield a higher number than full circle, but cos and sin is modular
		// get rad value
		
		// calculate radian direction angle
		float r = radianCounter + [[circleParts objectAtIndex:imageCounter] floatValue] - ([[circleParts objectAtIndex:imageCounter] floatValue]/2.0f);
		// fix the value overflow
		//r = [self fmod:r value:(M_PI * 2.0f)];
		
		// get the vector
		double x = cos(r);
		double y = sin(r);
				
		float speed = 50.0f;
		
		UIImageView *frag = [[self shardViews] objectAtIndex:imageCounter];
		
		NSString *id = [NSString stringWithFormat:@"fragID_%i", imageCounter];
		
		// begin animation block
		[UIView beginAnimations:id context:frag]; {
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.3f];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
			[UIView setAnimationDidStopSelector:@selector(animateFragFadeOut:finished:context:)];
			// move game header to its goal position
			[frag setCenter:CGPointMake( [frag center].x + x * speed, [frag center].y + y * speed )];
			// [frag setAlpha:0.0f];
		} [UIView commitAnimations];

		radianCounter = radianCounter + [[circleParts objectAtIndex:imageCounter] floatValue];
		imageCounter++;
	}

	[self hideIcon];
}

- (void) animateFragFadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	UIImageView *frag = context;
	NSString *id = [NSString stringWithFormat:@"fadeID_%i", [finished intValue]];
	[UIView beginAnimations:id context:NULL]; {
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDuration:0.2f];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		// move game header to its goal position
		[frag setAlpha:0.0f];
		[UIView setAnimationDidStopSelector:@selector(markForDeletion)];
	} [UIView commitAnimations];
}

- (void)markForDeletion {
	[self setIsMarkedForDeletion:YES];
}

#pragma mark -
#pragma mark draw

// - (void)drawRect:(CGRect)rect { }

@end

