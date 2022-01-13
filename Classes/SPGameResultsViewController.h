//
//  SPGameResultsViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-14.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@class SPListView;
@class SPHiscoreListViewController;
@class Facebook;

@class SimpleAudioEngine;

@interface SPGameResultsViewController : UIViewController <FBRequestDelegate, FBDialogDelegate, FBSessionDelegate> {
	CGRect gameScreenRect;
	SPListView *listView;
	BOOL keyboardVisible;
	
	SPHiscoreListViewController *hiscoreListViewController;
	
	UIFont *buttonFont;
	
	UIButton *continueButton;
	UIButton *facebookButton;
	UIButton *gameCenterButton;
	
	uint playerScore;
	NSArray *playerWords;
	NSArray *playerScores;
	NSString *playerName;
	
	Facebook *facebook;
	
	NSArray *permissions;
	
	SimpleAudioEngine *audioEngine;
	
	NSString *gameOverMusic;
}

- (void) showPlayerScore:(int)s words:(NSMutableArray *)words scores:(NSArray *)scores;
- (UIButton *) createButtonWithTitle:(NSString *)t action:(SEL)a frame:(CGRect)f;

- (void) keyboardDidShow:(NSNotification *)notif;
- (void) keyboardDidHide:(NSNotification *)notif;

- (void)buttonTouchUp:(id)sender;
- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;

- (void)buttonContinueAction:(id)sender;
- (void)buttonFacebookAction:(id)sender;
- (void)buttonGameCenterAction:(id)sender;

- (void)continueToHiscoreList;
- (void)continueToMainMenu;

- (void)publishToStream;

// objects
@property (nonatomic, retain) SPListView *listView;
@property (nonatomic, retain) SPHiscoreListViewController *hiscoreListViewController;
@property (nonatomic, retain) UIButton *continueButton;
@property (nonatomic, retain) UIButton *gameCenterButton;
@property (nonatomic, retain) UIButton *facebookButton;

@property (nonatomic, retain) NSArray *playerWords;
@property (nonatomic, retain) NSArray *playerScores;
@property (nonatomic, retain) NSString *playerName;

@property (nonatomic, retain) Facebook *facebook;

@property (nonatomic, retain) NSString *gameOverMusic;

// var
@property (readonly) CGRect gameScreenRect;
@property (readonly) uint playerScore;

@end
