/*
 Copyright (c) 2010 Steve Oldmeadow
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 $Id$
 */

#import "SimpleAudioEngine.h"
#import "AppDelegate_Phone.h"

@implementation SimpleAudioEngine

@synthesize fadeTimer;

/* 
 SUPERPANIC: 
 A static variable of this very same object. As it is declared 
 inside the implementation it is shared as a class variable. 
 */

static SimpleAudioEngine *sharedEngine = nil;

static BOOL musicIsOn = YES;
static BOOL soundEffectsIsOn = YES;

static CDSoundEngine* soundEngine = nil;
static CDAudioManager *am = nil;
static CDBufferManager *bufferManager = nil;


// call this class method to get the class variable sharedEngine. smart.
+ (SimpleAudioEngine *) sharedEngine {
	@synchronized(self)     {
		if (!sharedEngine)
			sharedEngine = [[SimpleAudioEngine alloc] init];
	}
		
	AppDelegate_Phone *appDelegate = (AppDelegate_Phone *)[[UIApplication sharedApplication] delegate];
	musicIsOn = appDelegate.kMusic;
	soundEffectsIsOn = appDelegate.kSoundEffects;
	
	// SUPERPANIC: sharedEngine is a static obj var!
	return sharedEngine;
}

// Init

+ (id) alloc {
	@synchronized(self)     {
		NSAssert(sharedEngine == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

-(id) init {
	if((self=[super init])) {
		am = [CDAudioManager sharedManager];
		soundEngine = am.soundEngine;
		bufferManager = [[CDBufferManager alloc] initWithEngine:soundEngine];
		mute_ = NO;
		enabled_ = YES;
	}
	return self;
}

// Memory
- (void) dealloc {
	am = nil;
	soundEngine = nil;
	bufferManager = nil;
	if(fadeTimer) [fadeTimer invalidate];
	[fadeTimer release];
	[super dealloc];
}

+(void) end {
	am = nil;
	[CDAudioManager end];
	[bufferManager release];
	[sharedEngine release];
	sharedEngine = nil;
}	

#pragma mark SimpleAudioEngine - background music

-(void) preloadBackgroundMusic:(NSString*) filePath {
	if(!musicIsOn) return;
	[am preloadBackgroundMusic:filePath];
}

-(void) playBackgroundMusic:(NSString*) filePath {
	if(!musicIsOn) return;
	if(fadeTimer) [self stopFade];
	[am playBackgroundMusic:filePath loop:TRUE];
}

-(void) playBackgroundMusic:(NSString*) filePath loop:(BOOL) loop {
	if(!musicIsOn) return;
	if(fadeTimer) [self stopFade];
	[am playBackgroundMusic:filePath loop:loop];
}

-(void) stopBackgroundMusic {
	[am stopBackgroundMusic];
}

-(void) pauseBackgroundMusic {
	[am pauseBackgroundMusic];
}	

-(void) resumeBackgroundMusic {
	if(!musicIsOn) return;
	[am resumeBackgroundMusic];
}	

-(void) rewindBackgroundMusic {
	[am rewindBackgroundMusic];
}

-(BOOL) isBackgroundMusicPlaying {
	return [am isBackgroundMusicPlaying];
}	

-(BOOL) willPlayBackgroundMusic {
	return [am willPlayBackgroundMusic];
}

#pragma mark SimpleAudioEngine - sound effects

-(ALuint) playEffect:(NSString*) filePath {
	if(!soundEffectsIsOn) {
		return CD_NO_SOUND;
	}
	return [self playEffect:filePath pitch:1.0f pan:0.0f gain:1.0f];
}

-(ALuint) playEffect:(NSString*) filePath pitch:(Float32) pitch pan:(Float32) pan gain:(Float32) gain {
	if(!soundEffectsIsOn) return CD_NO_SOUND;
	int soundId = [bufferManager bufferForFile:filePath create:YES];
	if (soundId != kCDNoBuffer) {
		return [soundEngine playSound:soundId sourceGroupId:0 pitch:pitch pan:pan gain:gain loop:false];
	} else {
		return CD_MUTE;
	}	
}

-(void) stopEffect:(ALuint) soundId {
	[soundEngine stopSound:soundId];
}	

-(void) preloadEffect:(NSString*) filePath {
	if(!soundEffectsIsOn) return;
	int soundId = [bufferManager bufferForFile:filePath create:YES];
	if (soundId == kCDNoBuffer) {
		CDLOG(@"Denshion::SimpleAudioEngine sound failed to preload %@",filePath);
	} else {
		CDLOG(@"Denshion::SimpleAudioEngine preloaded %@",filePath);
	}	
}

-(void) unloadEffect:(NSString*) filePath {
	CDLOG(@"Denshion::SimpleAudioEngine unloadedEffect %@",filePath);
	[bufferManager releaseBufferForFile:filePath];
}

#pragma mark Audio Interrupt Protocol
-(BOOL) mute {
	return mute_;
}

-(void) setMute:(BOOL) muteValue {
	if (mute_ != muteValue) {
		mute_ = muteValue;
		am.mute = mute_;
	}	
}

-(BOOL) enabled {
	return enabled_;
}

-(void) setEnabled:(BOOL) enabledValue {
	if (enabled_ != enabledValue) {
		enabled_ = enabledValue;
		am.enabled = enabled_;
	}	
}


#pragma mark SimpleAudioEngine - BackgroundMusicVolume
-(float) backgroundMusicVolume {
	return am.backgroundMusic.volume;
}	

-(void) setBackgroundMusicVolume:(float) volume {
	am.backgroundMusic.volume = volume;
}

-(void) fadeOutAndStopBackgroundMusic {
	NSTimer *temp_fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:(1.0/8) target:self selector:@selector( fadeLoop ) userInfo:nil repeats:YES ] retain];
	[self setFadeTimer:temp_fadeTimer];
	[temp_fadeTimer release];
	
}

-(void) fadeLoop {
	float fadeDelta = 0.1f;
	float currentVol = [self backgroundMusicVolume];
	if(currentVol > 0.0f) {
		currentVol = MAX(currentVol-fadeDelta,0.0f);
		[self setBackgroundMusicVolume:currentVol];
	} else {
		[self pauseBackgroundMusic];
		[self setBackgroundMusicVolume:1.0f];
		[fadeTimer invalidate];
		fadeTimer = nil;
	}
}

-(void) stopFade {
	[self pauseBackgroundMusic];
	[self setBackgroundMusicVolume:1.0f];
	[fadeTimer invalidate];
	fadeTimer = nil;	
}
	

#pragma mark SimpleAudioEngine - EffectsVolume
-(float) effectsVolume {
	return am.soundEngine.masterGain;
}	

-(void) setEffectsVolume:(float) volume {
	am.soundEngine.masterGain = volume;
}	

-(CDSoundSource *) soundSourceForFile:(NSString*) filePath {
	int soundId = [bufferManager bufferForFile:filePath create:YES];
	if (soundId != kCDNoBuffer) {
		CDSoundSource *result = [soundEngine soundSourceForSound:soundId sourceGroupId:0];
		CDLOG(@"Denshion::SimpleAudioEngine sound source created for %@",filePath);
		return result;
	} else {
		return nil;
	}	
}	

@end 
