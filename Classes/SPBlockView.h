//
//  BlockView.h
//  Block
//
//  Created by Fredrik Josefsson on 2010-02-10.
//  Copyright 2010 Superpanic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@class SPSquareView;

#pragma mark -
#pragma mark interface

@interface SPBlockView : NSObject {
 
	UIView *view;
	
	// size of a block
	float blockSize;

	// thickness of inactive slide touch padding border edge
	float touchPadding;

	// the block background plate
	SPSquareView *backgroundSquare;
		
	// YES if a block is currently falling down
	BOOL isFalling;

	// YES if the blocks is marked as touched
	BOOL isTouched;
	
	// YES if the block is marked for deletion
	BOOL isDeleted;
	
	// YES if the block should be deleted
	BOOL isMarkedForDeletion;
	
	// YES if the block is currently exploding
	BOOL isExploding;
	
	// YES if the block is bombed
	BOOL isBombed;
		
	// the position a block 'wants' to fall down to
	CGPoint goalPosition;

	// the falling velocity of a block
	float velocity;
	
	// the game over explosion velocity
	CGPoint xyVelocity;
	
	// the highest velocity a block can fall
	float maximumVelocity;
	
	// a blocks time stamp (since last moved) in seconds
	//double timeStamp;
	
	// shard views (used to animate exploding splinter effect)
	NSMutableArray *shardViews;
	
	// offset position
	int shakeCounter;
	CGPoint shakeVector;
	CGPoint shakeOffset;
	
	// saved position
	CGPoint savedPos;
	
}

#pragma mark -
#pragma mark methods


- (id) initWithSize:(float)size;

- (void) createViews;
- (void) destroyViews;

- (void) explode;
- (void) calcRandomXYVelocity:(int)val;

// touch/untouch
- (void) touchBlock;
- (void) unTouchBlock;

- (void) hideIcon;
- (void) hideBlockView;
- (void) showBlockView;

- (void) fadeOutBlockView;

- (void) animateFadeInFadeOutLoop;

- (void) shake;
- (void) shakeReset;

- (CGPoint) goalPosWithShakeOffset;

// stop block
- (void) stop;

- (void) fragExplosion;
- (void) animateFragFadeOut:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) markForDeletion;

#pragma mark -
#pragma mark object properties (needs release)

@property (nonatomic, retain) UIView *view;

// block background plate
@property (nonatomic, retain) SPSquareView *backgroundSquare;
@property (nonatomic, retain) NSMutableArray *shardViews;



#pragma mark value properties

// size of this block
@property (readwrite) float blockSize;

// thickness of inactive slide touch padding border edge
@property (readonly) float touchPadding;

// the position a block wants to fall down to
@property (readwrite) CGPoint goalPosition;

// a blocks falling velocity
@property (readwrite) float velocity;

// a blocks explosion velocity (use for animating game over)
@property (readwrite) CGPoint xyVelocity;

// a blocks time stamp (since last moved)
//@property (readwrite) double timeStamp;

// the highest velocity a block can fall
@property (readonly) float maximumVelocity;

@property (readwrite) CGPoint shakeVector;
@property (readwrite) CGPoint shakeOffset;

@property (readwrite) CGPoint savedPos;


#pragma mark boolean flags

// is the block falling
@property (readwrite) BOOL isFalling;

// is the block touched
@property (readwrite) BOOL isTouched;

// is the block deleted
@property (readwrite) BOOL isDeleted;

// is marked for deletion
@property (readwrite) BOOL isMarkedForDeletion;

// is the block exploding
@property (readonly) BOOL isExploding;

@property (readwrite) BOOL isBombed;


@end

