//
//  Common.m
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SPCommon.h"
#import <CommonCrypto/CommonDigest.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SPGameViewController.h"
#import "AppDelegate_Phone.h"
#import "AppDelegate_Pad.h"


// Name of notification
NSString *const NOTIF_hiscoreListScrollComplete = @"HiscoreListScrollComplete";
NSString *const NOTIF_hiscoreListTouched = @"HiscoreListTouched";

NSString *const NOTIF_pauseButtonPressed = @"PauseButtonPressed";
NSString *const NOTIF_quitGame = @"QuitGame";

@implementation SPCommon

// int BLOCK_ROWS = 7;
// int BLOCK_COLUMNS = 5;


#pragma mark -
#pragma mark color


+ (UIColor *)SPGetBlue { // block base color

	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
			//return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:20.0f/255.0f green:20.0f/255.0f blue:20.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:245.0f/255.0f green:0.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:0.0f/255.0f green:114.0f/255.0f blue:54.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:161.0f/255.0f green:134.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];			
			break;
			
			
	}

	// default
	return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:245.0f/255.0f alpha:1.0f];		
}

+ (UIColor *)SPGetDarkBlue { // block shadow
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:0.0f/255.0f green:62.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
			//return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f - 0.2 blue:245.0f/255.0f - 0.2 alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;

		case kBlackColors:
			return [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:158.0f/255.0f green:0.0f/255.0f blue:57.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:0.0f/255.0f green:88.0f/255.0f blue:38.0f/255.0f alpha:1.0f];			
			break;
			
		case kSand:
			return [UIColor colorWithRed:105.0f/255.0f green:76.0f/255.0f blue:44.0f/255.0f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;
			
	}
	
	// default
	return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f - 0.2 blue:245.0f/255.0f - 0.2 alpha:1.0f];
}

+ (UIColor *)SPGetLightBlue { // block high light
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:0.0f/255.0f green:200.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
			//return [UIColor colorWithRed:0.0f/255.0f green:200.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
			break;
			
		case kInvertedColors:
			return [UIColor colorWithRed:220.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;

		case kBlackColors:
			return [UIColor colorWithRed:80.0f/255.0f green:80.0f/255.0f blue:80.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:57.0f/255.0f green:181.0f/255.0f blue:74.0f/255.0f alpha:1.0f];
			break;
			
		case kSand:
			return [UIColor colorWithRed:215.0f/255.0f green:189.0f/255.0f blue:159.0f/255.0f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;

	}
	
	// default
	return [UIColor colorWithRed:0.0f/255.0f green:200.0f/255.0f blue:255.0f/255.0f alpha:1.0f];
}

+ (UIColor *)SPGetRed { // game background
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:255.0f/255.0f green:100.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			//return [UIColor colorWithRed:255.0f/255.0f green:40.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kInvertedColors:
			return [UIColor colorWithRed:0.0f/255.0f green:113.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:55.0f/255.0f green:55.0f/255.0f blue:55.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:45.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:63.0f/255.0f green:39.0f/255.0f blue:24.0f/255.0f alpha:1.0f];
			break;
			
		case kSand:
			return [UIColor colorWithRed:237.0f/255.0f green:201.0f/255.0f blue:175.0f/255.0f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:255.0f/255.0f alpha:1.0f];			
			break;
			
	}
	
	// default
	return [UIColor colorWithRed:255.0f/255.0f green:40.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (UIColor *) SPGetDarkRed { // used for interface drop shadow
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:0.0f/255.0f green:62.0f/255.0f blue:194.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:40.0f/255.0f green:40.0f/255.0f blue:40.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:0.0f/255.0f green:230.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:43.0f/255.0f green:19.0f/255.0f blue:4.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:161.0f/255.0f green:134.0f/255.0f blue:101.0f/255.0f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:30.0f/255.0f green:30.0f/255.0f blue:30.0f/255.0f alpha:1.0f];			
			break;

	}
	
	// default
	return [UIColor colorWithRed:200.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}


+ (UIColor *)SPGetYellow { // bomb base color
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:255.0f/255.0f green:200.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kInvertedColors:
			return [UIColor colorWithRed:255.0f/255.0f green:200.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:0.0f/255.0f green:255.0f/255.0f blue:50.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:108.0f/255.0f green:92.0f/255.0f blue:73.0f/255.0f alpha:1.0f];
			break;

		case kWireFrame:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0/255.0f blue:255.0f/255.0f alpha:1.0f];			
			break;
			
	}
	
	// default
	return [UIColor colorWithRed:255.0f/255.0f green:200.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (UIColor *)SPGetBrightYellow { // bomb high light

	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:200.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:188.0f/255.0f green:255.0f/255.0f blue:93.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:143.0f/255.0f green:124.0f/255.0f blue:102.0f/255.0f alpha:1.0f];
			break;

		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;

	}

	// default
	return [UIColor colorWithRed:255.0f/255.0f green:255.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (UIColor *)SPGetOrange { // bomb shadow
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:220.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:220.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:240.0f/255.0f green:240.0f/255.0f blue:240.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:255.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:135.0f/255.0f green:200.0f/255.0f blue:45.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:52.0f/255.0f green:43.0f/255.0f blue:32.0f/255.0f alpha:1.0f];
			break;

		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;
			
	}
	
	// default
	return [UIColor colorWithRed:220.0f/255.0f green:150.0f/255.0f blue:0.0f/255.0f alpha:1.0f];
}

+ (UIColor *)SPGetOffWhite { // text color
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:245.0f/255.0f green:245.0f/255.0f blue:245.0f/255.0f alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:255.0f/255.0f green:205.0f/255.0f blue:205.0f/255.0f alpha:1.0f];
			break;

		case kSand:
			return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;
			
	}

	// default
	return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
}

+ (UIColor *)SPGetWhite { // text color
	
	GameColors col = [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kGameColors];
	
	switch (col) {
		case kClassicColors:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;

		case kInvertedColors:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;
			
		case kBlackColors:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;
			
		case kNeonColors:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;
			
		case kNatureColors:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;
			
		case kSand:
			return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0f];
			break;
			
		case kWireFrame:
			return [UIColor colorWithRed:0.0f/255.0f green:0.0f/255.0f blue:0.0f/255.0f alpha:1.0f];			
			break;
			
	}
	
	// default
	return [UIColor colorWithRed:0.95f green:0.9f blue:0.9f alpha:1.0f];
}

+ (void)printColorComponents:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	float red = colors[0]*255;
	float green = colors[1]*255;
	float blue = colors[2]*255;
	// print the color components to console
	NSLog(@"\n\n      red: %f\n    green: %f\n     blue: %f\n\n", red, green, blue);
}


+ (float)UIColorGetRedVal:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	return colors[0]*255;	
}

+ (float)UIColorGetGreenVal:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	return colors[1]*255;	
}

+ (float)UIColorGetBlueVal:(UIColor *)c {
	const float* colors = CGColorGetComponents( [c CGColor] );
	return colors[2]*255;	
}

#pragma mark -
#pragma mark game settings

+ (BOOL) isTutorialActive {
	return [ (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate] kTutorial];
}

#pragma mark -
#pragma mark tools and math

// math
+ (CGFloat) distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB {
	CGFloat dx = pointB.x - pointA.x;
	CGFloat dy = pointB.y - pointA.y;
	return sqrt(dx*dx + dy*dy );
}

+ (NSString *) getMD5FromString:(NSString *)str {
	const char *cStr = [str UTF8String];
	unsigned char result[16];
	CC_MD5( cStr, strlen(cStr), result );
	return [[NSString stringWithFormat:
		@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
		result[0], result[1], result[2], result[3], 
		result[4], result[5], result[6], result[7],
		result[8], result[9], result[10], result[11],
		result[12], result[13], result[14], result[15]
	] lowercaseString];
}


#pragma mark -
#pragma mark saving and reading game

+ (BOOL) shouldResumeActiveGame {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	if([prefs boolForKey:@"isGameActive"]) return YES;
	return NO;
}

+ (void) resetActiveGame {
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];	
	// the game has been read, set active game var to NO
	[prefs setObject:[NSNumber numberWithBool:NO] forKey:@"isGameActive"];
}



#pragma mark -
#pragma mark hiscore

// hiscore

+ (void) savePlayerScore:(uint)score name:(NSString *)name words:(NSArray *)allWords wordScores:(NSArray *)allWordScores {
	// get longest word
//	NSString *longWord = [self getLongestWordFromArray:allWords];
	
	// get best word
	NSString *bestWord = @"-";
	int bestScore = 0;

	int index = [self getHighestScoreIndexFrom:allWordScores];
	if(index >= 0 && index < [allWords count] && [allWords count] == [allWordScores count] ) {
		bestWord = [allWords objectAtIndex:index];
		bestScore = [[allWordScores objectAtIndex:index] intValue];
	}
	
	// create a dictionary
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score], @"score", name, @"name", [NSNumber numberWithInt:bestScore], @"bestWordScore", bestWord, @"longword", allWords, @"words", nil];
	[self saveNewHiscore:d];
} 

/*
+ (void) savePlayerScore:(uint)score name:(NSString *)name words:(NSArray *)allWords {
	// get longest word
	NSString *longWord = [self getLongestWordFromArray:allWords];
	// create a dictionary
	NSDictionary *d = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:score], @"score", name, @"name", longWord, @"longword", allWords, @"words", nil];
	[self saveNewHiscore:d];
} 
*/

+ (void) saveNewHiscore:(NSDictionary *)playerHiscoreInfo {

	// get the user defaults object
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];	

	// get current score
	NSNumber *score;
	if( ! (score = [playerHiscoreInfo objectForKey:@"score"]) ) {
		NSLog(@"### WARNING: Save hiscore dictionary does not contain key *score*. Setting *score* to 0.");
		score = [NSNumber numberWithInt:0];
	}
	
	
	// get the array with all saved hiscores 
	NSMutableArray *allHiscoreInfoArray;
	
	// try to read the hiscore ARRAY
	// make sure it returns a mutable copy
	// no need to retain a mutableCopy
	if( ! (allHiscoreInfoArray = [[prefs objectForKey:@"allHiscoreInfoArray"] mutableCopy] ) ) {
		// not able to read dictionary - create new dictionary 
		allHiscoreInfoArray = [[NSMutableArray alloc] initWithCapacity:10];
		// save the hiscore dictionary
		[prefs setObject:allHiscoreInfoArray forKey:@"allHiscoreInfoArray"];
	}

	
		
	
	int ranking = 0;
	
	if([allHiscoreInfoArray count]) {
		// sort and add the player hiscore info at the right place in the array
		int counter = 0;
		BOOL isScoreLow = YES;
		for( NSDictionary *tempHiscoreInfo in allHiscoreInfoArray ) {
			if( [score intValue] > [[tempHiscoreInfo objectForKey:@"score"] intValue] ) {
				// add hiscore to array
				NSLog(@"allHiscoreInfoArray: %@", [allHiscoreInfoArray isMemberOfClass:[NSMutableArray class]]);
				// safe to do inside loop? yes should be. we BREAK the loop below.
				[allHiscoreInfoArray insertObject:playerHiscoreInfo atIndex:counter];
				isScoreLow = NO;
				ranking = counter;
				break;
			}
			counter++;
			if(counter >= kHiscoreDBMax) break;			
		}
		// score is lower than the lowest score in the array, add it last
		if (isScoreLow) {
			[allHiscoreInfoArray addObject:playerHiscoreInfo];
			ranking = [allHiscoreInfoArray count]-1;
		}
	} else {
		// just add the playerHiscoreInfo to the empty list
		[allHiscoreInfoArray addObject:playerHiscoreInfo];
		ranking = 0;
	}	   			   
	
	// is hiscorelist too long?
	if([allHiscoreInfoArray count] > kHiscoreDBMax) {
		// cap the hiscore list to kHiscoreDBMax length
		NSRange r;
		r.location = kHiscoreDBMax;
		r.length = [allHiscoreInfoArray count] - kHiscoreDBMax;
		[allHiscoreInfoArray removeObjectsInRange:r];
	}
	
	
	// ### checksum
	
	// add all scores
	// int scoreSum = [score intValue];
	int scoreSum = 0;
	for( NSDictionary *tempHiscoreInfo in allHiscoreInfoArray ) {
		scoreSum = scoreSum + [[tempHiscoreInfo objectForKey:@"score"] intValue];
	}
	
	// create a checksum from scoreSum
	NSString *checksum = [self getMD5FromString:[NSString stringWithFormat:@"%iLDgaqm80Mqmu9YrLByog", scoreSum ]];
	
	// set the checksum in prefs file
	[prefs setValue:checksum forKey:@"checksum"];

	// ###
	
	
	// set the hiscore array info
	[prefs setValue:allHiscoreInfoArray forKey:@"allHiscoreInfoArray"];
	
	NSNumber *currentRanking = [NSNumber numberWithInt:ranking];
	
	[prefs setValue:currentRanking forKey:@"currentRanking"];
	
	NSString *playerName;
	if( (playerName = [playerHiscoreInfo objectForKey:@"name"]) ) {
		[prefs setValue:playerName forKey:@"lastUsedName"];
	 }

	// write to file
	[prefs synchronize];
		
	[allHiscoreInfoArray release];
	allHiscoreInfoArray = nil;
	
}

+ (NSString *) readLastUsedName {
	// retrieving user defaults
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// return last used name (will be autoreleased)
	NSLog(@"%@", [prefs objectForKey:@"lastUsedName"]);
	NSString *s = [prefs objectForKey:@"lastUsedName"];
	if(s) {
		return s;
	} else {
		return @"";
	}
}

+ (int) readLastRanking {
	// retrieving last players ranking
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	NSNumber *n = [prefs objectForKey:@"currentRanking"];
	if(n) {
		return [n intValue];
	} else {
		return 0;
	}
}

+ (NSArray *) readHiscores {
	// retrieving user defaults
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	NSArray *allHiscoreInfoArray;
	
	if( !(allHiscoreInfoArray = [NSArray arrayWithArray:[prefs objectForKey:@"allHiscoreInfoArray"]]) ) {
		NSLog(@"WARNING: No hiscore info found!");
		return nil;
	}
	
	// ### checksum
	
	// add all scores
	int scoreSum = 0;
	for( NSDictionary *tempHiscoreInfo in allHiscoreInfoArray ) {
		scoreSum = scoreSum + [[tempHiscoreInfo objectForKey:@"score"] intValue];
	}
	
	// create a checksum from scoreSum
	NSString *checksum = [self getMD5FromString:[NSString stringWithFormat:@"%iLDgaqm80Mqmu9YrLByog", scoreSum ]];

	// compare the checksum with previously saved checksum
	if( ! [checksum isEqualToString:[prefs objectForKey:@"checksum"]] ) {
		// something is wrong with the hiscores reset the hiscore list
		[prefs setValue:nil forKey:@"allHiscoreInfoArray"];
		[prefs synchronize];
		NSLog(@"WARNING Checksum is wrong! May have been tampered with? Resetting highscore!");
		[self clearAllHiscores];
		return nil;
	}
	
	// ### ok - passed the checksum test!
	return allHiscoreInfoArray;
}


+ (void) saveLanguageSettings:(NSString *)language {
	// retrieving user defaults
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	
	BOOL isLanguageSupported = NO;
	
	if([language compare:@"swe"] == NSOrderedSame) {
		isLanguageSupported = YES;
		NSLog(@"Saving swedish language setting");
	}
	if([language compare:@"eng"] == NSOrderedSame) {
		isLanguageSupported = YES;
		NSLog(@"Saving english language setting");
	}
	
	if (isLanguageSupported) {
		// set the hiscore array info
		[prefs setValue:language forKey:@"gameLanguage"];
		// write to file
		[prefs synchronize];
		NSLog(@"Saved %@ as game language.", language);
	} else {
		NSLog(@"W A R N I N G: Saving language settings failed!");
	}
	
}


+ (NSString *)readLanguageSettings {
	// retrieving user defaults
	NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
	// return last used name (will be autoreleased)
	NSString *s = [prefs objectForKey:@"gameLanguage"];
	if( s ) {
		return s;
	} else {
		// if no language setting is found - return current locale language		
		if( [[[NSLocale currentLocale] objectForKey: NSLocaleLanguageCode] isEqualToString:@"sv"] ) {
			return @"swe";
		}
		// default language:
		return @"eng";
	}
}


+ (void) clearAllHiscores {
	// clear all settings and hiscores
	
	// fortsätt här:
	NSLog(@"############### CLEARING NSUserDefauls ######################");
	// Clear all user settings and hiscore - DON'T!
	//[[NSUserDefaults standardUserDefaults] setPersistentDomain:[NSDictionary dictionary] forName:[[NSBundle mainBundle] bundleIdentifier]];
	
	[[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"allHiscoreInfoArray"];	
	
}


+ (int) getHighestScoreIndexFrom:(NSArray *)allScores {
	
	if(!allScores) return -1;
	if ([allScores count]==0) return -1;
	
	int bestScore = 0;
	int counter = 0; 
	int index = 0;
	
	for( NSNumber *aScore in allScores ) {
		if( [aScore intValue] > bestScore ) {
			bestScore = [aScore intValue];
			index = counter;
		}
		counter++;
	}
	
	return index;
}


+ (NSString *) getLongestWordFromArray:(NSArray *)allWords {
	if(!allWords) return [NSString stringWithFormat:@"-"];
	if ([allWords count]==0) return [NSString stringWithFormat:@"-"];
	NSString *longestWord = [NSString stringWithFormat:@"-"];
	for( NSString *aWord in allWords ) {
		if( [aWord length] > [longestWord length] ) {
			longestWord = [NSString stringWithString:aWord];
		} 
	}
	return longestWord;
}

#pragma mark -
#pragma mark standard ui elements

+ (UIButton *) createButtonWithTitle:(NSString *)t target:(id)target action:(SEL)a frame:(CGRect)f font:(UIFont *)font {
	// will auto-release!
	UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
	
	// button settings
	[b setFrame:f];
	[ [b titleLabel] setFont:font ];
	[b setTitle:t forState:UIControlStateNormal];
	[b setTitleColor:[SPCommon SPGetOffWhite] forState:UIControlStateNormal];
	[b setTitleColor:[SPCommon SPGetRed] forState:UIControlStateHighlighted];
	[b setBackgroundColor:[SPCommon SPGetBlue]];
	
	// new game button, targets and actions
	[b addTarget:target action:a forControlEvents:UIControlEventTouchUpInside];
	[b addTarget:target action:@selector(buttonTouchDown:) forControlEvents:UIControlEventTouchDown];
	[b addTarget:target action:@selector(buttonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
	[b addTarget:target action:@selector(buttonTouchUp:) forControlEvents:UIControlEventTouchUpInside];
	
	// remember to retain the returned object
	return b;
}

/*
// saving
NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

for( id item in infoDict ) {

	 
	 // saving an NSString
	 [prefs setObject:@"TextToSave" forKey:@"keyToLookupString"];
	 
	 // saving an NSInteger
	 [prefs setInteger:42 forKey:@"integerKey"];
	 
	 // saving a Double
	 [prefs setDouble:3.1415 forKey:@"doubleKey"];
	 
	 // saving a Float
	 [prefs setFloat:1.2345678 forKey:@"floatKey"];
	 
	 // This is suggested to synch prefs, but is not needed (I didn't put it in my tut)
	 [prefs synchronize];


// retrieving
NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];

// getting an NSString
NSString *myString = [prefs stringForKey:@"keyToLookupString"];

// getting an NSInteger
NSInteger myInt = [prefs integerForKey:@"integerKey"];

// getting an Float
float myFloat = [prefs floatForKey:@"floatKey"];

*/
		 
@end
