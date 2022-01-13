//
//  AppDelegate_Pad.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-02-20.
//  Copyright Superpanic 2010. All rights reserved.
//

#import "AppDelegate_Pad.h"
#import "SPCommon.h"
#import "Facebook.h"
#import "SPMenuViewController.h"
#import "SPGameViewController.h"
#import "SPPauseViewController.h"

@implementation AppDelegate_Pad

@synthesize window;
@synthesize navigationController;
@synthesize gameMenuViewController;
@synthesize facebook;

@synthesize kTutorial;
@synthesize kGameColors;
@synthesize kSoundEffects;
@synthesize kMusic;

- (void)dealloc {
	[gameMenuViewController release];
	[navigationController release];
	[window release];
	[facebook release];
	[super dealloc];
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// print a warning if zombie variables are enabled
	if( getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled") ) {
		NSLog(@"\n\n	NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!\n\n");
	}

	// running on iPad
	NSLog(@"\n\n	init application iPad\n\n");
	
	// Override point for customization after application launch

	[self readSettings];
	
	// create the facebook object
	Facebook *tempFacebook = [[Facebook alloc] init];
	[self setFacebook:tempFacebook];
	[tempFacebook release];
	
	[facebook logout:self];
	
	[self prepare];

	/* // used to reda stored local variables on the phone, see also below in the commented applicatioWillTerminate method
	// Restore preferred time signature
	int restoredSignature = [[NSUserDefaults standardUserDefaults] integerForKey:MetronomeTimeSignatureKey];
	if ((restoredSignature >= TimeSignatureTwoFour ) && (restoredSignature <= TimeSignatureFourFour )) {
		self.timeSignature = restoredSignature;
	}
	 */
	
	return YES;
}

// Invoked immediately before the application terminates.
- (void)applicationWillTerminate:(UIApplication *)application {
	NSLog(@"WARNING: App will terminate now!");
	
	UIViewController *currentViewCon = [navigationController visibleViewController];
	
	if( [[currentViewCon title] compare:@"The Game View Controller"] == NSOrderedSame ) {
		NSLog(@"WARNING: Game will terminate while RUNNING game!");
		
		if([currentViewCon respondsToSelector:@selector(saveActiveGame)]) {
			// unselect any selected blocks
			//[(SPGameViewController *)currentViewCon pauseGame];
			[(SPGameViewController *)currentViewCon unselectBlocks];
			// save game
			NSLog(@"Saving full game (will reload when game is restarted");
			[(SPGameViewController *)currentViewCon saveActiveGame];
		}
		
	} else {
		NSLog(@"WARNING: Game will terminate while NOT running game!");
	}
	
}

- (void)applicationWillResignActive:(UIApplication *)application {
	
	NSLog(@"app will resign active");
	
	NSLog(@"navigationController title: %@", [navigationController title]);
	
	UIViewController *currentViewCon = [navigationController visibleViewController];
	
	if( [[currentViewCon title] compare:@"The Game View Controller"] == NSOrderedSame ) {
		NSLog(@"WARNING: Game entered background while game was running!");
		if([currentViewCon respondsToSelector:@selector(pauseGame)]) {
			[(SPGameViewController *)currentViewCon pauseGame];
		}
	} else {
		NSLog(@"WARNING: Game entered background while game was NOT running!");	
	}

}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	NSLog(@"app did enter background");
	// do nothing, using will resign active instead
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	NSLog(@"app will enter foreground");
	// read the settings!
	if([self readSettings]) {
		// if settings changed - restart app.
		[self prepare];
	}
}

// read application settings
- (BOOL) readSettings {
	
	BOOL settingsChangedFlag = NO;
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	BOOL s = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound_effects_preference"];
	BOOL m = [[NSUserDefaults standardUserDefaults] boolForKey:@"music_preference"];
	int col = [[NSUserDefaults standardUserDefaults] integerForKey:@"color_preference"];
	BOOL tut = [[NSUserDefaults standardUserDefaults] integerForKey:@"tutorial"];
	
	NSLog(@"tut: %i kTutorial %i", (int)tut, (int)kTutorial );
	if(tut != [self kTutorial]) {
		settingsChangedFlag = YES;
		[self setKTutorial:tut];
	}
	
	NSLog(@"s: %i kSoundEffects: %i", (int)s, (int)kSoundEffects);
	if (s != [self kSoundEffects]) {
		settingsChangedFlag = YES;
		[self setKSoundEffects:s];
	}
	NSLog(@"m: %i kMusic: %i", (int)m, (int)kMusic);
	if (m != [self kMusic]) {
		settingsChangedFlag = YES;
		[self setKMusic:m];
	}
	NSLog(@"col: %i kGameColors: %i", (int)col, (int)kGameColors);
	if (col != [self kGameColors]) {
		settingsChangedFlag = YES;
		[self setKGameColors:col];
	}
	
	NSLog(@"settings changed: %@", settingsChangedFlag ? @"YES" : @"NO");
	
	if(settingsChangedFlag) {
		NSLog(@"soundeffects:%i, music:%i, colors:%i, tutorial:%i", (int)s, (int)m, col, (int)tut);
	}
	
	return settingsChangedFlag;
}

- (void)prepare {
	// re-create the game menu view controller
	NSLog(@"################## appDelegate prepare ###################");
	
	if(navigationController) {
		
		// ask pauseViewController to quit game
		UIViewController *currentViewCon = [navigationController visibleViewController];
		if( [currentViewCon isMemberOfClass:[SPPauseViewController class]] ) {
			[(SPPauseViewController *)currentViewCon quitGame];
		}
		
		// if a modal view controller is currently active, dismiss
		//[[navigationController topViewController] dismissModalViewControllerAnimated:NO];
		// pop all stacked viewcontrollers
		[navigationController popToRootViewControllerAnimated:NO];
		
		NSLog(@"[navigationController viewControllers]: %@", [navigationController viewControllers]);
		//[[navigationController viewControllers] makeObjectsPerformSelector:@selector(release)];
		[[navigationController view] removeFromSuperview];
		[navigationController release];
		navigationController = nil;
	}	
	
	if(gameMenuViewController) {
		[gameMenuViewController killMenuItems];
		// restart game
		[gameMenuViewController release];
		gameMenuViewController = nil;
	}
	
	SPMenuViewController *temp_gameMenuViewController = [[SPMenuViewController alloc] init];
	[self setGameMenuViewController:temp_gameMenuViewController];
	[temp_gameMenuViewController release];
	
	// set the title for the game view controller
	[gameMenuViewController setTitle:@"The Game Menu View Controller"];
	
	
	// create the navigation controller
	UINavigationController *temp_navigationController = [[UINavigationController alloc] initWithRootViewController:gameMenuViewController];
	[self setNavigationController:temp_navigationController];
	[temp_navigationController release];
	// tell the navigation controller to send events to this application delegate (self) 
	[navigationController setDelegate:self];
	
	// hide the navigation bar
	[[navigationController navigationBar] setHidden:YES];
	
	// set the window background color
	// [window setBackgroundColor:[UIColor blackColor]];
	[window setBackgroundColor:[SPCommon SPGetRed]];
	
	// Add the main view
	[window addSubview:[navigationController view]];
	
	// show window
	[window makeKeyAndVisible];
	
}

// triggered by event sent to the navigation controllers delegate (self)
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSLog(@"Did show view controller: %@", [viewController title]);
	// [viewController viewDidAppear:animated];
}

// triggered by event sent to the navigation controllers delegate (self)
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
	NSLog(@"Will show view controller: %@", [viewController title]);
	// [viewController viewWillAppear:animated];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
	NSLog(@"application handleOpenURL (iPad)");
	return [facebook handleOpenURL:url];
}

/**
 * Called when the request logout has succeeded.
 */
- (void)fbDidLogout {
	NSLog(@"logged out!");
	// [self.label setText:@"Please log in"];
}

@end