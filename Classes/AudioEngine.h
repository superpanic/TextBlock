//
//  SPAudioManager.h
//  TextBlock
//
//  Created by Fredrik Josefsson on 2010-06-15.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioPlayer.h>

@interface AudioEngine : NSObject {
	NSMutableDictionary *players;
}
@property (retain, nonatomic) NSMutableDictionary *players;

+ (AudioEngine *) sharedEngine;

- (void) addSound:(NSString *)key name:(NSString *)theName ofType:(NSString *)theType delegate:(id)theDelegate loop:(BOOL)loopFlag;
- (AVAudioPlayer *) getPlayer:(NSString *)key;
- (void) playSoundWithKey:(NSString *)key volume:(double)gain;
- (void) stopSoundWithKey:(NSString *)key;
- (BOOL) isSoundPlaying:(NSString *)key;
- (void) vibrate;

@end
