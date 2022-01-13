//
//  SPMenuViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//@class SPGameViewController;
@class SPSettingsViewController;
@class SPTutorialViewController;

@class SPHiscoreListView;

@class SPFlyingBlocks;

@class SimpleAudioEngine;

//@class SPHandView;

@interface SPMenuViewController : UIViewController <UIAlertViewDelegate> {
	CGRect gameScreenRect;
	
	UIButton *buttonNewGame;	
	UIButton *buttonSettings;
	
	UIButton *buttonClearHiscore;
	

	UIAlertView *alertClearHiscore;
	
	
	UILabel *labelTitleA;
	UILabel *labelTitleB;
	
	CGPoint labelTitleAPortraitPos;
	CGPoint labelTitleALandscapePos;
	CGPoint labelTitleBPortraitPos;
	CGPoint labelTitleBLandscapePos;
	
	UILabel *labelDeveloperA;
	UILabel *labelDeveloperB;
	
	CGPoint labelDeveloperAPortraitPos;
	CGPoint labelDeveloperBPortraitPos;
	CGPoint labelDeveloperALandscapePos;
	CGPoint labelDeveloperBLandscapePos;
	float buttonGroupViewBottomPos;
	
	float padding;
		
	UILabel *labelURL;
	
	UIFont *titleFont;
	UIFont *urlFont;
	
	UIView *buttonGroupView;
	
//	SPGameViewController *gameViewController;
	SPSettingsViewController *gameSettingsViewController;
	SPTutorialViewController *tutorialViewController;

	SPHiscoreListView *hiscoreListView;

	SPFlyingBlocks *flyingBlocks;
	
	BOOL isResumingSavedGame;
		
	SimpleAudioEngine *audioEngine;
	
	//SPHandView *hand;
	
	NSString *titleMusic;
	
}
- (void) prepareAudio;
- (void) createFlyingBlocks;
- (void) createHiscoreListView;

- (void) showHiscore;
- (void) runHiscore;
- (void) fadeHiscoreWithDelay;
- (void) fadeHiscore;
- (void) restartHiscore;

- (void) runTests;

- (void)buttonTouchUp:(id)sender;
- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;


- (void)buttonNewGameAction:(id)sender;
- (void)buttonSettingsAction:(id)sender;
- (void)buttonClearHiscoreAction:(id)sender;

- (BOOL)tryResumeGame;

- (void)newGame;

- (void)killMenuItems;

// alert view delegare methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
- (void)didPresentAlertView:(UIAlertView *)alertView;
- (void)willPresentAlertView:(UIAlertView *)alertView;
- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;
- (void)alertViewCancel:(UIAlertView *)alertView;

// values
@property (readonly) CGRect gameScreenRect;

// objects
@property (nonatomic, retain) UIView *buttonGroupView;
@property (nonatomic, retain) UIButton *buttonNewGame;
@property (nonatomic, retain) UIButton *buttonSettings;

@property (nonatomic, retain) UIButton *buttonClearHiscore;
@property (nonatomic, retain) UIAlertView *alertClearHiscore;

@property (nonatomic, retain) UILabel *labelTitleA;
@property (nonatomic, retain) UILabel *labelTitleB;

@property (nonatomic, retain) UILabel *labelDeveloperA;
@property (nonatomic, retain) UILabel *labelDeveloperB;

@property (nonatomic, retain) UILabel *labelURL;

@property (nonatomic, retain) UIFont *titleFont;
@property (nonatomic, retain) UIFont *urlFont;

//@property (nonatomic, retain) SPGameViewController *gameViewController;
@property (nonatomic, retain) SPSettingsViewController *gameSettingsViewController;
@property (nonatomic, retain) SPTutorialViewController *tutorialViewController;

@property (nonatomic, retain) SPHiscoreListView *hiscoreListView;

@property (nonatomic, retain) SPFlyingBlocks *flyingBlocks;

@property (readwrite) BOOL isResumingSavedGame;


@end
