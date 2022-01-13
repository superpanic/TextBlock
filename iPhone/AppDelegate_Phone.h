//
//  AppDelegate_Phone.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-02-20.
//  Copyright Superpanic 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"
#import "SPCommon.h"

//@class SPMenuViewController;
@class Facebook;


@interface AppDelegate_Phone : NSObject <UIApplicationDelegate, UINavigationControllerDelegate, FBSessionDelegate> {
	UIWindow *window;
	
	UINavigationController *navigationController;

	// SPMenuViewController *gameMenuViewController;
	
	Facebook *facebook;
	
	BOOL kTutorial;
	GameColors kGameColors;
	BOOL kSoundEffects;
	BOOL kMusic;

}

// read application settings
- (BOOL) readSettings;
- (void) prepare;

// - (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url;

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) UINavigationController *navigationController;
//@property (nonatomic, retain) SPMenuViewController *gameMenuViewController;

@property (nonatomic, retain) Facebook *facebook;

@property (readwrite) BOOL kTutorial;
@property (readwrite) GameColors kGameColors;
@property (readwrite) BOOL kSoundEffects;
@property (readwrite) BOOL kMusic;

@end