//
//  SPListView.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPListViewCell;
@class SPDropShadowView;

@interface SPListView : UIView {
	NSMutableArray *cells;
	// UIView *viewer;
	UIView *listView;
	float cellHeight;
	SPListViewCell *activeInputCell;
	SPDropShadowView *dropShadowView;
	
	// NSTimeInterval timeSinceLastTouchMutation;
	float savedTouchLocationA;
	float savedTouchLocationB;
	double savedTouchTimeA;
	double savedTouchTimeB;
	
	float velocity;
	float friction;
	
	float touchPointOffset;
	
	BOOL isTouchEnabled;
	BOOL isAutoScrolling;
	
	BOOL isTouchedFlag;
	
	NSTimer *runTimer;
	
}

- (id)initWithFrame:(CGRect)frame cellHeight:(float)cellHeight;
- (void)addCellWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment;
- (void)addInputCellWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment observer:(id)keyboardObserver;
- (void)addCellWithTitle:(NSString *)title info:(NSString *)info smallInfo:(NSString *)smallInfo smallTitle:(NSString *)smallTitle;
- (NSString *)activeInputContent;
- (void) updateShadowPosition;

- (void) autoScrollToCell:(int)n;
- (void) autoScrollToTopFromCell:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;

- (void) autoScrollToBottom;
- (void) autoScrollToTop;

- (void) autoScrollFinished;

- (void) focusOnCell:(int)cell;
- (void) focusAnimation:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void) blinkCell:(int)cell;

- (void) removeCells;

@property (nonatomic, retain) NSMutableArray *cells;
@property (nonatomic, retain) UIView *listView;
@property (readonly) float cellHeight;
@property (nonatomic, retain) SPListViewCell *activeInputCell;
@property (nonatomic, retain) SPDropShadowView *dropShadowView;


@property (readonly) float touchPointOffset;
@property (readonly) float velocity;
@property (readonly) float friction;
@property (readonly) BOOL isAutoScrolling;
@property (readwrite) BOOL isTouchedFlag;

@property (nonatomic, retain) NSTimer *runTimer;

@end

