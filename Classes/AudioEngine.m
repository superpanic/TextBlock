#import "AudioEngine.h"
#import "AudioToolbox/AudioToolbox.h"

@implementation AudioEngine

@synthesize players;

static AudioEngine *_sharedEngine = nil;

+ (AudioEngine *) sharedEngine
{
	@synchronized( [AudioEngine class] )
	{
		if( !_sharedEngine ) {
			[[self alloc] init];
		}
		
		return _sharedEngine;
	}
	
	return nil;
}

+ (id) alloc
{
	@synchronized( [AudioEngine class] )
	{
		NSAssert( _sharedEngine == nil, @"Attempted to allocate a second instance of a singleton" );
		_sharedEngine = [super alloc];
		return _sharedEngine;
	}
	
	return nil;
}

- (id) init
{
	if ( (self = [super init]) ) {
		players = [[NSMutableDictionary alloc] initWithCapacity:10];
	}
	
	return self;
}

- (void) dealloc
{
	[players release];
	[super dealloc];
}

- (void) addSound:(NSString *)key name:(NSString *)theName ofType:(NSString *)theType delegate:(id)theDelegate loop:(BOOL)loopFlag
{
	NSString *file = [[NSBundle mainBundle] pathForResource:theName ofType:theType];
	AVAudioPlayer *audioPlayer =  [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:file] error:NULL];
	
	[audioPlayer setDelegate:theDelegate];
	[audioPlayer prepareToPlay];
	
	if ( loopFlag ) {
		audioPlayer.numberOfLoops = -1;
	}
	
	[players setObject:audioPlayer forKey:theName];
	
	[audioPlayer release];
}

- (AVAudioPlayer *) getPlayer:(NSString *)key
{
	return [players objectForKey:key];
}

- (void) playSoundWithKey:(NSString *)key volume:(double)gain
{
	AVAudioPlayer *player = [players objectForKey:key];
	player.volume = gain;
	[player play];
}

- (void) stopSoundWithKey:(NSString *)key
{
	AVAudioPlayer *player = [players objectForKey:key];
	[player stop];
}

- (BOOL) isSoundPlaying:(NSString *)key
{
	AVAudioPlayer *player = [players objectForKey:key];
	return [player isPlaying];
}

- (void)vibrate
{
	AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
}

@end

