//
//  SPFlyingBlocks.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 11 Nov 2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPBlockViewLetter;

@interface SPFlyingBlocks : UIView {
	NSMutableArray *flyingBlocks;
	int blockSize;
	BOOL isPaused;
	NSTimer *timer;
}

@property (nonatomic, retain) NSMutableArray *flyingBlocks;
@property (nonatomic, retain) NSTimer *timer;
@property (readwrite) BOOL isPaused;

- (void) start;
- (SPBlockViewLetter *)createNewBlock;
- (void) prepareBlock:(SPBlockViewLetter *)block;
- (void) stop;
- (void) run;

- (void) pause;
- (void) unPause;	

@end
