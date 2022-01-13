//
//  SPListViewCell.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPTextField;

@interface SPListViewCell : UIView <UITextFieldDelegate> {
	// size
	float titleHeight;
	float infoHeight;
	float padding;
	
	// views
	UIView *titleView;
	
	// labels
	UILabel *titleLabel;
	UILabel *infoLabel;
	
	// input text field
	SPTextField *infoTextField;
	
	// extra, small info labels
	UILabel *smallTitleLabel;
	UILabel *smallInfoLabel;
	
	BOOL isSmallInfoHidden;
	
	// cursor
	UIView *cursor;

	// fonts
	UIFont *titleFont;
	UIFont *infoFont;	
}


// views
@property (nonatomic, retain) UIView *titleView;
// labels
@property (nonatomic, retain) UILabel *titleLabel;
@property (nonatomic, retain) UILabel *infoLabel;
// input text field
@property (nonatomic, retain) SPTextField *infoTextField;
// small labels
@property (nonatomic, retain) UILabel *smallTitleLabel;
@property (nonatomic, retain) UILabel *smallInfoLabel;
// cursor
@property (nonatomic, retain) UIView *cursor;
// booleans
@property (readonly) BOOL isSmallInfoHidden;

- (id) initWithFrame:(CGRect)frame title:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment;
- (id) initWithFrame:(CGRect)frame title:(NSString *)title info:(NSString *)info smallInfo:(NSString *)smallInfo smallTitle:(NSString *)smallTitle;
- (void) activateInputWithObserver:(id)keyboardObserver;

- (void) setupWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment;
- (void) updateCursorPos;
- (void) killCursor;
- (NSString *) getInput;


@end
