//
//  SPListView.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SPListView.h"
#import "SPListViewCell.h"
#import "SPCommon.h"
#import "SPDropShadowView.h"
#import "SPCommon.h"

#define kFramesPerSecond (1.0 / 30)

@implementation SPListView

//@synthesize viewer;
@synthesize cells;
@synthesize listView;
@synthesize cellHeight;
@synthesize activeInputCell;
@synthesize dropShadowView;

@synthesize touchPointOffset;
@synthesize velocity;
@synthesize friction;
@synthesize isAutoScrolling;
@synthesize isTouchedFlag;

// @synthesize previousTimeStamp;
@synthesize runTimer;



- (void)dealloc {
	[cells release];
	[listView release];
	[activeInputCell release];
	[dropShadowView release];
	
	if(runTimer) [runTimer invalidate];
	[runTimer release];
		
	[super dealloc];
}

- (id)initWithFrame:(CGRect)frame cellHeight:(float)ch {
    if ((self = [super initWithFrame:frame])) {
	    // Initialization code
	    
	    cellHeight = ch;
	    	    
	    isTouchEnabled = YES;
	    
	    isAutoScrolling = NO;
	    
	    isTouchedFlag = NO;
	    
	    [self setBackgroundColor:[UIColor clearColor]];
	    [self setClipsToBounds:YES];
	    
	    NSMutableArray *temp_cells = [[NSMutableArray alloc] initWithCapacity:6];
	    [self setCells:temp_cells];
	    [temp_cells release];
	    
	    // create the list view
	    UIView *temp_listView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), CGRectGetHeight(frame))];
	    [self setListView:temp_listView];
	    [temp_listView release];

	    [listView setBackgroundColor:[UIColor clearColor]];

	    [self addSubview:listView];
	    	    
	    // create the drop shadow;
	    SPDropShadowView *temp_dropShadowView = [[SPDropShadowView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth(frame), cellHeight * 0.2) color:[SPCommon SPGetDarkRed]];
	    [self setDropShadowView:temp_dropShadowView];
	    [temp_dropShadowView release];
	    
	    [listView addSubview:dropShadowView];
	    	    
    }
    return self;
}

// create a cell with info and title
- (void)addCellWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment {
	CGRect f = CGRectMake(0.0f, 0.0f, CGRectGetWidth([self frame]), cellHeight);
	SPListViewCell *newCell = [[SPListViewCell alloc] initWithFrame:f title:title info:info textAlignment:textAlignment];

	// add new cell to array
	[cells addObject:newCell];
		
	// adjust listView
	[listView setFrame:CGRectMake(CGRectGetMinX([listView frame]), CGRectGetMinY([listView frame]), CGRectGetWidth([listView frame]), [cells count] * CGRectGetHeight([newCell frame]))];
		
	// position center at x
	float x = CGRectGetWidth([self frame]) / 2.0f;
	// calculate position - after all labels
	float y = ([cells count]-1) * CGRectGetHeight([newCell frame]) + CGRectGetHeight([newCell frame]) / 2.0f;
	
	// position cell view
	[newCell setCenter:CGPointMake(x, y)];
	
	// add new cell to listView
	[listView addSubview:newCell];
	
	// release the new cell object
	[newCell release];
	
	// move shadow
	[self updateShadowPosition];
	
}

- (void) updateShadowPosition {
	[dropShadowView setCenter:CGPointMake(
					      CGRectGetWidth([self frame]) * 0.5f, 
					      [cells count] * cellHeight + CGRectGetHeight([dropShadowView frame]) * 0.5f)];	
}

// create a cell with extra small info and title
- (void)addCellWithTitle:(NSString *)title info:(NSString *)info smallInfo:(NSString *)smallInfo smallTitle:(NSString *)smallTitle {
	CGRect f = CGRectMake(0.0f, 0.0f, CGRectGetWidth([self frame]), cellHeight);
	SPListViewCell *newCell = [[SPListViewCell alloc] initWithFrame:f title:title info:info smallInfo:smallInfo smallTitle:smallTitle];
	
	// add new cell to array
	[cells addObject:newCell];
	
	// adjust listView
	[listView setFrame:CGRectMake(CGRectGetMinX([listView frame]), CGRectGetMinY([listView frame]), CGRectGetWidth([listView frame]), [cells count] * CGRectGetHeight([newCell frame]))];
	
	// position center at x
	float x = CGRectGetWidth([self frame]) / 2.0f;
	// calculate position - after all labels
	float y = ([cells count]-1) * CGRectGetHeight([newCell frame]) + CGRectGetHeight([newCell frame]) / 2.0f;
	
	// position cell view
	[newCell setCenter:CGPointMake(x, y)];
	
	// add new cell to listView
	[listView addSubview:newCell];
	
	// release the new cell object
	[newCell release];

	// move shadow
	[self updateShadowPosition];

}

// create an input cell
- (void)addInputCellWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment observer:(id)keyboardObserver {
	[self addCellWithTitle:title info:info textAlignment:textAlignment];
	[self setActiveInputCell:[cells lastObject]];
	[activeInputCell activateInputWithObserver:keyboardObserver];
	// start cursor animation
}

- (NSString *)activeInputContent {
	return [activeInputCell getInput];
}




// animation, touch and movements

- (void) autoScrollToBottom {
	
	[[listView layer] removeAllAnimations];
	
	isAutoScrolling = YES;
	isTouchEnabled = NO;
	
	// only scroll if list is longer than screen
	if( CGRectGetHeight([listView frame]) <= CGRectGetHeight([self frame]) ) return;
	
	// calculate goal position
	float goalPos = ( [listView frame].size.height * 0.5f ) - ( cellHeight * [cells count] - [self frame].size.height );

	//	position the listView at top
	[listView setCenter:CGPointMake([listView frame].size.width * 0.5f, [listView frame].size.height * 0.5f)];
		
	// start focus animation
	[UIView beginAnimations:@"autoScrollToEnd" context:NULL]; 
	{
		[UIView setAnimationDelay:2.0f];
		[UIView setAnimationDelegate:self];
//		[UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDidStopSelector:@selector(autoScrollToTop)];
		[UIView setAnimationDuration:0.5f * [cells count]];
		[listView setCenter:CGPointMake([listView center].x, goalPos)];
	} 
	[UIView commitAnimations];
}


- (void) autoScrollToCell:(int)n {
	
	[listView.layer removeAllAnimations];
	
	isAutoScrolling = YES;
	isTouchEnabled = YES;
	
	// only scroll if list is longer than screen
	if( CGRectGetHeight([listView frame]) <= CGRectGetHeight([self frame]) ) return;
	
	// calculate goal position
	float goalPos = ( [listView frame].size.height * 0.5f ) - ( cellHeight * n - [self frame].size.height );
	
	
	// position the listView at top
	[listView setCenter:CGPointMake([listView frame].size.width * 0.5f, [listView frame].size.height * 0.5f)];
	
	// start focus animation
	[UIView beginAnimations:@"autoScrollToCell" context:[[NSNumber numberWithInt:n] retain]]; 
	{
		[UIView setAnimationDelay:2.0f];
		[UIView setAnimationDelegate:self];
		// [UIView setAnimationCurve:UIViewAnimationCurveLinear];
		[UIView setAnimationDidStopSelector:@selector(autoScrollToTopFromCell:finished:context:)];
		[UIView setAnimationDuration:0.2f * [cells count]];
		[listView setCenter:CGPointMake([listView center].x, goalPos)];
	} 
	[UIView commitAnimations];

}


- (void) autoScrollToTopFromCell:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
		
	isAutoScrolling = YES;
	isTouchEnabled = YES;

	// only scroll if list is longer than screen
	if( CGRectGetHeight([listView frame]) <= CGRectGetHeight([self frame]) ) return;
	
	NSNumber *n = context;
	
	// calculate goal position
	float goalPos = ( [listView frame].size.height * 0.5f ) - ( cellHeight * [n intValue] - [self frame].size.height );
	
	[n release];
	
	//	position the listView at bottom
	[listView setCenter:CGPointMake([listView center].x, goalPos)];
	
	// start focus animation
	[UIView beginAnimations:@"autoScrollToTopFromCell" context:NULL]; 
	{
		[UIView	setAnimationDelegate:self];
		[UIView setAnimationDuration:0.2f * [cells count]];
		[UIView setAnimationDidStopSelector:@selector(autoScrollFinished)];
		[listView setCenter:CGPointMake([listView frame].size.width * 0.5f, [listView frame].size.height * 0.5f)];
	} 
	[UIView commitAnimations];	
}


- (void) autoScrollToTop {

	isAutoScrolling = YES;
	isTouchEnabled = YES;

	// only scroll if list is longer than screen
	if( CGRectGetHeight([listView frame]) <= CGRectGetHeight([self frame]) ) return;
	
	// calculate goal position
	float goalPos = ( [listView frame].size.height * 0.5f ) - ( cellHeight * [cells count] - [self frame].size.height );
		
	// position the listView at bottom
	[listView setCenter:CGPointMake([listView center].x, goalPos)];
	
	// start focus animation
	[UIView beginAnimations:@"autoScrollToTop" context:NULL]; 
	{
		[UIView	setAnimationDelegate:self];
		[UIView setAnimationDuration:0.5f * [cells count]];
		[UIView setAnimationDidStopSelector:@selector(autoScrollFinished)];
		[listView setCenter:CGPointMake([listView frame].size.width * 0.5f, [listView frame].size.height * 0.5f)];
	} 
	[UIView commitAnimations];
}


- (void) autoScrollFinished {
	if(isTouchedFlag) {
		isTouchedFlag = NO;
		return;
	}
	isAutoScrolling = NO;
	// Post a notification that the data has been downloaded  
	NSLog(@"Posting notification!");
	[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_hiscoreListScrollComplete object:nil];
}


- (void) focusOnCell:(int)cell {
	
	// only focus if list is longer than screen
	if( CGRectGetHeight([listView frame]) <= CGRectGetHeight([self frame]) ) return;
	
	// calculate goal position
	float goalPos = ( [listView frame].size.height * 0.5 ) - ( cellHeight * cell );
	
	isAutoScrolling = NO;
	isTouchEnabled = NO;
	
	// start focus animation
	[UIView beginAnimations:@"focusOnCell" context:NULL]; 
	{
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(focusAnimation:finished:context:)];
		[UIView setAnimationDuration:3.0f];	
		[listView setCenter:CGPointMake([listView center].x, goalPos)];
	} 
	[UIView commitAnimations];
}


- (void) focusAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	// animation finished
	isTouchEnabled = YES;
}


- (void) blinkCell:(int)cell {
		
	// boundary check
	if( cell >= [cells count] ) return;

	SPListViewCell *c = [cells objectAtIndex:cell];
	
	[[c layer] removeAllAnimations];
	[c setAlpha:1.0f];
	// start focus animation
	[UIView beginAnimations:@"blinkCell" context:NULL]; 
		[UIView setAnimationDuration:0.5f];
		[UIView setAnimationRepeatAutoreverses:YES];
		[UIView setAnimationRepeatCount:FLT_MAX];
		[c setAlpha:0.5f];
	[UIView commitAnimations];	
}


- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
 	
	// check of listView is currently animating (focusing on current player score cell)
	if(!isTouchEnabled) return;
	
	if(isAutoScrolling) {
		// post notification (user touched hiscorelist)
		NSLog(@"Posting notification!");
		isTouchedFlag = YES;
		[[NSNotificationCenter defaultCenter] postNotificationName:NOTIF_hiscoreListTouched object:nil];
		return;
	}
	
	// [self setCenter:CGPointMake([self center].x - 5.0f, [self center].y - 5.0f) ];
	UITouch *touch = [touches anyObject];
 	CGPoint p = [touch locationInView:self];
	// distance between touch position and current listView center position
	touchPointOffset = p.y - [listView center].y;
	
	// previousTimeStamp = [touch timestamp];
	
	savedTouchTimeA = [NSDate timeIntervalSinceReferenceDate];
	savedTouchTimeB = [NSDate timeIntervalSinceReferenceDate];
		
	//savedTouchTimeA = [touch timestamp];
	//savedTouchTimeB = [touch timestamp];
	
	savedTouchLocationA = [touch locationInView:self].y - touchPointOffset;
	savedTouchLocationB = [touch locationInView:self].y - touchPointOffset;
	
	if(runTimer) {
		[runTimer invalidate];
		runTimer = nil;
		velocity = 0.0f;
		friction = 0.0f;
	}
	
}

- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {

	// check of listView is currently animating (focusing on current player score cell)
	if(!isTouchEnabled) return;
	if(isAutoScrolling) return;
	
	UITouch *touch = [touches anyObject];
	
	// previousTimeStamp = [touch timestamp];
	
	float currentTouchLocation = [touch locationInView:self].y - touchPointOffset;

	// save location and timestamp every 20th of a second
	if( savedTouchTimeA < [NSDate timeIntervalSinceReferenceDate] - 0.05f ) {
		// save time
		savedTouchTimeB = savedTouchTimeA;
		savedTouchTimeA = [NSDate timeIntervalSinceReferenceDate];
		// save location
		savedTouchLocationB = savedTouchLocationA;
		savedTouchLocationA = currentTouchLocation;
	}
	
	// float previousTouchLocation = [touch previousLocationInView:self].y - touchPointOffset;
	
	// float centerOffset = CGRectGetHeight([listView frame]) * 0.5f;

	[listView setCenter:CGPointMake([listView center].x, currentTouchLocation)];
	
}

- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
		
	// check of listView is currently animating (focusing on current player score cell)
	if(!isTouchEnabled) return;
	if(isAutoScrolling) return;
	
	//if( CGRectGetHeight([listView frame]) < CGRectGetHeight([self frame]) ) return;
	
	UITouch *touch = [touches anyObject];
	float currentTouchLocation = [touch locationInView:self].y - touchPointOffset;
	
		
	// save location and timestamp every 20th of a second
	if( savedTouchTimeA < [NSDate timeIntervalSinceReferenceDate] - 0.05f ) {
		// save time
		savedTouchTimeB = savedTouchTimeA;
		savedTouchTimeA = [NSDate timeIntervalSinceReferenceDate];
		// save location
		savedTouchLocationB = savedTouchLocationA;
		savedTouchLocationA = currentTouchLocation;
	}
	
	[listView setCenter:CGPointMake([listView center].x, currentTouchLocation)];
	
	// IF enough time has passed AND the logged positions A and B are NOT the same
	if( savedTouchTimeA - savedTouchTimeB != 0 && ABS( savedTouchLocationA - savedTouchLocationB ) > 3.0f ) {
		velocity = ( (savedTouchLocationA - savedTouchLocationB) / (savedTouchTimeA - savedTouchTimeB) ) / 50.0f;
	} else {
		velocity = 0.0f;
	}
	
	friction = 0.0f;
	
	// start a timer and run
	runTimer = [[NSTimer scheduledTimerWithTimeInterval:kFramesPerSecond target:self selector:@selector( run ) userInfo:nil repeats:YES] retain];
	
}


- (void) run {
	
	float centerOffset = CGRectGetHeight([listView frame]) * 0.5f;
	
	// move at velocity speed (no edge bounce)
	float newLocation = [listView center].y + velocity - friction;
		
	[ listView setCenter:CGPointMake( [listView center].x, newLocation ) ];
	
	// update velocity
	velocity = velocity * 0.9f;

	if( CGRectGetHeight([listView frame]) > CGRectGetHeight([self frame]) ) {
		if( ([listView center].y - centerOffset) > 0 ) {
			friction = MAX( 0, ([listView center].y - centerOffset) / 8.0f );		
		} else if ( (([listView center].y + centerOffset) - CGRectGetHeight([self frame])) < 0 ){
			friction = MIN( 0, ( ([listView center].y + centerOffset) - CGRectGetHeight([self frame]) ) / 8.0f );		
		}
	} else {
		if( [listView center].y - centerOffset != 0 ) friction = ([listView center].y - centerOffset) / 8.0f;
	}
	
	// kill timer and stop moving if velocity is close to 0
	if( ABS(velocity + friction) < 0.01 ) {
		[runTimer invalidate];
		runTimer = nil;
		velocity = 0.0f;
		friction = 0.0f;
	}
	 
}

- (void) removeCells {
	
	// Initialization code		
	for(SPListViewCell *c in cells) {
		[c removeFromSuperview];
	}
	[cells removeAllObjects];
}


@end






