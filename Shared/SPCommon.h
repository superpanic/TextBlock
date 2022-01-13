//
//  Common.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-05-13.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


#define kBlockRows 7
#define kBlockColumns 5

// #define kBlockRows 7
// #define kBlockColumns 8

//#define kBlockRows 8
//#define kBlockColumns 6

#define kBlockValueMultiplier 10
#define kFramesPerSecond (1.0 / 30)

// svg graphics
#define kChainIconSVG @"M128.184,18.797C128.184,8.433,119.752,0,109.387,0H86.504C76.139,0,67.707,8.433,67.707,18.797c0,4.403,1.525,8.455,4.07,11.662h3.883c2.641,0,4.941-1.465,6.144-3.623c-2.759-1.619-4.617-4.615-4.617-8.039c0-5.137,4.181-9.316,9.317-9.316h22.883c5.138,0,9.316,4.179,9.316,9.316c0,0.106-0.001,0.211-0.005,0.316c-0.167,4.992-4.28,9-9.312,9H96.215c-0.818,3.593-2.551,6.842-4.947,9.48h18.119C119.752,37.594,128.184,29.162,128.184,18.797zM60.477,18.797C60.477,8.433,52.045,0,41.68,0H18.797C8.432,0,0,8.433,0,18.797c0,10.365,8.432,18.797,18.797,18.797h18.374c-2.396-2.639-4.13-5.888-4.948-9.479H18.797c-5.137,0-9.317-4.179-9.317-9.316c0-0.097,0.001-0.194,0.005-0.291c0.154-5.002,4.273-9.025,9.312-9.025H41.68c5.138,0,9.317,4.179,9.317,9.316c0,3.344-1.772,6.281-4.426,7.925c1.184,2.221,3.521,3.737,6.206,3.737h3.628C58.951,27.252,60.477,23.2,60.477,18.797zM94.457,23.43c0-4.403-1.525-8.454-4.07-11.661h-3.883c-2.641,0-4.942,1.464-6.145,3.622c2.76,1.619,4.617,4.615,4.617,8.039c0,5.138-4.18,9.317-9.316,9.317H52.777c-5.137,0-9.315-4.18-9.315-9.317c0-3.344,1.771-6.281,4.425-7.925c-1.183-2.22-3.52-3.736-6.206-3.736h-3.628c-2.546,3.207-4.071,7.258-4.071,11.661c0,10.365,8.433,18.798,18.797,18.798H75.66C86.025,42.228,94.457,33.795,94.457,23.43zM57.286,4.633c2.396,2.639,4.13,5.888,4.947,9.48h3.716c0.818-3.593,2.551-6.842,4.947-9.48H57.286z"

#define kHiscoreDBMax 20

// macro for getting ReSouRCe file path
#define RSRC(x) [[NSBundle mainBundle] pathForResource:x ofType:nil]


// Game type
typedef enum {
	kClassicColors,
	kInvertedColors,
	kBlackColors,
	kNeonColors,
	kNatureColors,
	kSand,
	kWireFrame
} GameColors;


struct SPColorComponents {
	float red;
	float green;
	float blue;
};
typedef struct SPColorComponents SPColorComponents;	

@interface SPCommon : NSObject { 

}

// For name of notification
extern NSString *const NOTIF_hiscoreListScrollComplete;
extern NSString *const NOTIF_hiscoreListTouched;

extern NSString *const NOTIF_pauseButtonPressed;
extern NSString *const NOTIF_quitGame;


// colors
+ (UIColor *) SPGetDarkBlue;
+ (UIColor *) SPGetBlue;
+ (UIColor *) SPGetLightBlue;
+ (UIColor *) SPGetDarkRed;
+ (UIColor *) SPGetRed;
+ (UIColor *) SPGetYellow;
+ (UIColor *) SPGetBrightYellow;
+ (UIColor *) SPGetOrange;
+ (UIColor *) SPGetOffWhite;
+ (UIColor *) SPGetWhite;
+ (void) printColorComponents:(UIColor *)c;

+ (float)UIColorGetRedVal:(UIColor *)c;
+ (float)UIColorGetGreenVal:(UIColor *)c;
+ (float)UIColorGetBlueVal:(UIColor *)c;	

// game settings
+ (BOOL) isTutorialActive;

// math
+ (CGFloat) distanceBetweenPointA:(CGPoint)pointA pointB:(CGPoint)pointB;
+ (NSString *) getMD5FromString:(NSString *)str;

// save game
+ (BOOL) shouldResumeActiveGame;
+ (void) resetActiveGame;

// hiscore
+ (void) savePlayerScore:(uint)score name:(NSString *)name words:(NSArray *)allWords wordScores:(NSArray *)allWordScores;
//+ (void) savePlayerScore:(uint)score name:(NSString *)name words:(NSArray *)words;
+ (void) saveNewHiscore:(NSDictionary *)playerHiscoreInfo;
+ (NSString *) readLastUsedName;
+ (int) readLastRanking;
+ (NSArray *) readHiscores;
+ (void) clearAllHiscores;
+ (int) getHighestScoreIndexFrom:(NSArray *)allScores;
+ (NSString *) getLongestWordFromArray:(NSArray *)words;
+ (void) saveLanguageSettings:(NSString *)language;
+ (NSString *)readLanguageSettings;

// standard ui elements
+ (UIButton *) createButtonWithTitle:(NSString *)t target:(id)target action:(SEL)a frame:(CGRect)f font:(UIFont *)font;

@end
