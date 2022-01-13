//
//  SPListViewCell.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPListViewCell.h"
#import "SPCommon.h"
#import "SPTextField.h"

@implementation SPListViewCell

// create getter and setter methods
// views
@synthesize titleView;
// labels
@synthesize titleLabel;
@synthesize infoLabel;
// small labels
@synthesize smallTitleLabel;
@synthesize smallInfoLabel;
// input field
@synthesize infoTextField;
// cursor
@synthesize cursor;
// booleans
@synthesize isSmallInfoHidden;

- (void) dealloc {
		
	// views
	[titleView release];
	[cursor release];
	
	// labels
	[titleLabel release];
	[infoLabel release];
	
	// small labels
	[smallInfoLabel release];
	[smallTitleLabel release];
	
	// input text field
	[infoTextField release];
	
	// fonts
	[titleFont release];
	[infoFont release];

	[super dealloc];
}


- (id) initWithFrame:(CGRect)frame {
	if( (self = [self initWithFrame:frame title:@"n/a" info:@"n/a" textAlignment:UITextAlignmentCenter]) ) {
		// Initialization code
		NSLog(@"WARNING: Empty list cell created!");
	}
	return self;
}


- (id) initWithFrame:(CGRect)frame title:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment {
	if( (self = [super initWithFrame:frame]) ) {
		// Initialization code
		isSmallInfoHidden = YES;
		// create all the labels
		[self setupWithTitle:title info:info textAlignment:textAlignment];
	}
	return self;
}


- (id) initWithFrame:(CGRect)frame title:(NSString *)title info:(NSString *)info smallInfo:(NSString *)smallInfo smallTitle:(NSString *)smallTitle {
		
	if( (self = [super initWithFrame:frame]) ) {
		// Initialization code
		isSmallInfoHidden = NO;
		
		// to fit in all info the alignment has to be set to right
		[self setupWithTitle:title info:info textAlignment:UITextAlignmentRight];
		
		// create the small fonts, will be autoreleased
		UIFont *smallTitleFont = [UIFont fontWithName:@"Helvetica-Bold" size:titleHeight * 0.4f];
		UIFont *smallInfoFont = [UIFont fontWithName:@"Helvetica-Bold" size:titleHeight * 0.75f];
		
		// create the small title label
		UILabel *temp_smallTitleLabel = [[UILabel alloc] 
						 initWithFrame:CGRectMake(CGRectGetWidth([self frame])*0.5f + padding, 
									  titleHeight + infoHeight * 0.5 - ([infoFont capHeight] * 0.5f - [smallInfoFont capHeight]*0.1), 
									  [smallTitle sizeWithFont:smallTitleFont].width, 
									  [smallTitleFont capHeight]+1.0f + [smallInfoFont capHeight]*0.2)
						 ];
		[self setSmallTitleLabel:temp_smallTitleLabel];
		[temp_smallTitleLabel release];
		[smallTitleLabel setBackgroundColor:[UIColor clearColor]];
		[smallTitleLabel setFont:smallTitleFont];
		[smallTitleLabel setAdjustsFontSizeToFitWidth:YES];
		[smallTitleLabel setTextColor:[SPCommon SPGetOffWhite]];
		[smallTitleLabel setTextAlignment:UITextAlignmentLeft];
		[smallTitleLabel setText:smallTitle];
				
		[self addSubview:smallTitleLabel];	
		
		// create the small info label
		UILabel *temp_smallInfoLabel = [[UILabel alloc] 
						initWithFrame:CGRectMake(CGRectGetWidth([self frame])*0.5f + padding, 
									 titleHeight + infoHeight * 0.5 + ([infoFont capHeight] * 0.5f) - [smallInfoFont capHeight] - [smallInfoFont capHeight]*0.1, 
									 [smallInfo sizeWithFont:smallInfoFont].width, 
									 [smallInfoFont capHeight]+1.0f + [smallInfoFont capHeight]*0.2)
						];
		[self setSmallInfoLabel:temp_smallInfoLabel];
		[temp_smallInfoLabel release];
		[smallInfoLabel setBackgroundColor:[UIColor clearColor]];
		[smallInfoLabel setFont:smallInfoFont];
		[smallInfoLabel setAdjustsFontSizeToFitWidth:YES];
		[smallInfoLabel setTextColor:[SPCommon SPGetOffWhite]];
		[smallInfoLabel setTextAlignment:UITextAlignmentLeft];
		[smallInfoLabel setText:smallInfo];
		
		[self addSubview:smallInfoLabel];
		
	}
	return self;
}

- (void) setupWithTitle:(NSString *)title info:(NSString *)info textAlignment:(UITextAlignment)textAlignment {
	
	// set up some measurements
	titleHeight = CGRectGetHeight([self frame]) * 0.3;
	infoHeight = CGRectGetHeight([self frame]) - titleHeight;
	
	if(textAlignment == UITextAlignmentCenter) padding = 0.0f;
	else padding = infoHeight * 0.1;
	
	// create the fonts
	titleFont = [[UIFont fontWithName:@"Helvetica-Bold" size:titleHeight * 0.70f] retain];
	infoFont = [[UIFont fontWithName:@"Helvetica-Bold" size:infoHeight * 0.70f] retain];
	
	// set background of this view to solid red
	[self setBackgroundColor:[SPCommon SPGetRed]];
	
	// create the title view background
	UIView *temp_titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, CGRectGetWidth([self frame]), titleHeight)];
	[self setTitleView:temp_titleView];
	[temp_titleView release];
	// set title view to solid white
	[titleView setBackgroundColor:[SPCommon SPGetOffWhite]];
	// add title view to main view
	[self addSubview:titleView];
	
	// create the title label
	UILabel *temp_titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, 0.0f, CGRectGetWidth([self frame]) - padding * 2.0f, titleHeight)];
	[self setTitleLabel:temp_titleLabel];
	[temp_titleLabel release];
	[titleLabel setBackgroundColor:[UIColor clearColor]];
	[titleLabel setFont:titleFont];
	[titleLabel setAdjustsFontSizeToFitWidth:YES];
	[titleLabel setTextColor:[SPCommon SPGetRed]];
	if (isSmallInfoHidden) {
		[titleLabel setTextAlignment:textAlignment];
	} else {
		[titleLabel setTextAlignment:UITextAlignmentLeft];
	}
	[titleLabel setText:title];
	[self addSubview:titleLabel];
	
	
	// create the info label
	UILabel *temp_infoLabel;
	if(isSmallInfoHidden) {
		temp_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(padding, titleHeight, CGRectGetWidth([self frame]) - padding * 2.0f, infoHeight)];		
	} else {
		temp_infoLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, titleHeight, CGRectGetWidth([self frame]) * 0.5f - padding, infoHeight)];			
	}
	[self setInfoLabel:temp_infoLabel];
	[temp_infoLabel release];
	[infoLabel setBackgroundColor:[UIColor clearColor]];
	[infoLabel setFont:infoFont];
	[infoLabel setAdjustsFontSizeToFitWidth:YES];
	[infoLabel setTextColor:[SPCommon SPGetOffWhite]];
	[infoLabel setTextAlignment:textAlignment];
	[infoLabel setText:info];
		
	[self addSubview:infoLabel];
	
	
	// create hidden text field for keyboard input
	SPTextField *temp_infoTextField = [[SPTextField alloc] initWithFrame:CGRectMake(padding, titleHeight, CGRectGetWidth([self frame]) - padding * 2.0f, infoHeight)];
	[self setInfoTextField:temp_infoTextField];
	[temp_infoTextField release];
	
	// no need to format the design of the text field (it is hidden!)
	
	[infoTextField setDelegate:self];
	[infoTextField setReturnKeyType:UIReturnKeyDone];
	[infoTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
	[infoTextField setAutocapitalizationType:UITextAutocapitalizationTypeAllCharacters];
	[infoTextField setEnablesReturnKeyAutomatically:YES];
	[infoTextField setKeyboardType:UIKeyboardTypeASCIICapable];
	[infoTextField setUserInteractionEnabled:NO];
	
	[infoTextField setCenter:CGPointMake(-500.0f, -500.0f)];
	
	[infoTextField setUserInteractionEnabled:NO];
	[infoTextField setHidden:NO];
	[self addSubview:infoTextField];
}


- (void) activateInputWithObserver:(id)keyboardObserver {

	NSLog(@"activateInputWithObserver!");
	
	// set hidden input text field to same text as the visible labels text
	[infoTextField setText:[infoLabel text]];

	// notify the view controller
	[[NSNotificationCenter defaultCenter] addObserver:keyboardObserver selector:@selector (keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:keyboardObserver selector:@selector (keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];

	if(!cursor) {
		// size of W
		CGSize sizeOfW = [@"W" sizeWithFont:infoFont];
		// create the cursor
		UIView *temp_cursor = [[UILabel alloc] initWithFrame:CGRectMake(0.0f, 0.0f, sizeOfW.width, sizeOfW.height)];
		[self setCursor:temp_cursor];
		[temp_cursor release];
		[self addSubview:cursor];
		// animate cursor

		// begin animation block
		[UIView beginAnimations:nil context:NULL]; {
			[UIView setAnimationDuration:0.5f];
			[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
			[UIView setAnimationRepeatCount:FLT_MAX];
			[UIView setAnimationRepeatAutoreverses:YES];
			[cursor setAlpha:0.0f];
		} [UIView commitAnimations];
	}

	[self updateCursorPos];
	
	/*
	// position cursor
	[cursor setCenter:CGPointMake([infoLabel center].x, 
				      [infoLabel center].y )];
	*/
	
	// show keyboard
	[infoTextField becomeFirstResponder];
	
}

- (void) updateCursorPos {
	//if(!inputActive) return;
	// adjust cursor
	if(!cursor) return;
	float widthOfW = [@"W" sizeWithFont:infoFont].width;
	if( [infoLabel text] ) { 
		if( [[infoLabel text] length] > 0 ) {
			[cursor setCenter:CGPointMake( [infoLabel center].x + [[infoLabel text] sizeWithFont:infoFont].width / 2.0f + widthOfW / 2.0f, [infoLabel center].y )];
			return;
		}
	}
	[cursor setCenter:CGPointMake( [infoLabel center].x, [infoLabel center].y )];
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	// check for backspace
	if(range.length == 1) {
		if([[infoLabel text] length] > 0) {
			[infoLabel setText:[[infoLabel text] stringByPaddingToLength:[[infoLabel text] length]-1 withString:@"" startingAtIndex:0]];
		}
	} else {
		[infoLabel setText:[[[infoLabel text] stringByAppendingString:string] uppercaseString] ];
	}
	[self updateCursorPos];
	// do not change the text
	return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
	[infoTextField resignFirstResponder];
	[self killCursor];
	return NO;
}

- (void) killCursor {
	if(!cursor) return;
	[cursor removeFromSuperview];
	[cursor release];
	cursor = nil;
}

- (NSString *) getInput {
	return [NSString stringWithString:[infoLabel text]];
}

@end





