//
//  GameMenuViewController.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-29.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

//@class SPGameViewController;

@interface SPPauseViewController : UIViewController {
	CGRect gameScreenRect;
	UIButton *buttonContinueGame;	
	UIButton *buttonMenu;
	UIView *buttonGroupView;
	
//	SPGameViewController *gameViewController;
	
}

- (void)buttonTouchUp:(id)sender;
- (void)buttonTouchDown:(id)sender;
- (void)buttonTouchUpOutside:(id)sender;
- (void)buttonContinueGameAction:(id)sender;
- (void)buttonMenuAction:(id)sender;
- (void)quitGame;

// values
@property (readonly) CGRect gameScreenRect;

// objects
@property (nonatomic, retain) UIView *buttonGroupView;
@property (nonatomic, retain) UIButton *buttonContinueGame;
@property (nonatomic, retain) UIButton *buttonMenu;
//@property (nonatomic, retain) SPGameViewController *gameViewController;


@end
