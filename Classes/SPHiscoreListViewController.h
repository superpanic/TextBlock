//
//  SPHiscoreListViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-09-27.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPListView;
@class SimpleAudioEngine;

@interface SPHiscoreListViewController : UIViewController {
	SPListView *listView;
	UIFont *buttonFont;
	UIButton *continueButton;
	CGRect gameScreenRect;
	
	SimpleAudioEngine *audioEngine;
}

@property (nonatomic, retain) SPListView *listView;
@property (nonatomic, retain) UIFont *buttonFont;
@property (nonatomic, retain) UIButton *continueButton;

- (UIButton *) createButtonWithTitle:(NSString *)t action:(SEL)a frame:(CGRect)f;

- (void)buttonTouchUp:(id)sender;
- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;
- (void)buttonContinueAction:(id)sender;
- (void)backToMenu;

@end
