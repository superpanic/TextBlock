//
//  GameSettingsViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-08-15.
//  Copyright (c) 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface SPSettingsViewController : UIViewController {
	CGRect gameScreenRect;
	
	// UISwitch *switchRandomChars;
	
	UIFont *buttonFont;
	
	UIButton *backButton;
	
	UIButton *swedishButton;
	UIButton *englishButton;
	
	
	// UISegmentedControl *
}

// - (void)switchRandomChars:(id)sender;
- (UIButton *) createButtonWithTitle:(NSString *)t action:(SEL)a frame:(CGRect)f;

- (void)buttonTouchUp:(id)sender;
- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;
- (void)buttonBackAction:(id)sender;

- (void)buttonSetToEnglishAction:(id)sender;
- (void)buttonSetToSwedishAction:(id)sender;

// values
@property (readonly) CGRect gameScreenRect;
// @property (nonatomic, retain) UISwitch *switchRandomChars;
@property (nonatomic, retain) UIFont *buttonFont;
@property (nonatomic, retain) UIButton *swedishButton;
@property (nonatomic, retain) UIButton *englishButton;
@property (nonatomic, retain) UIButton *backButton;


@end
