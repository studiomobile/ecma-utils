#import "SystemSoundPlayer.h"
#import <AudioToolbox/AudioToolbox.h>

static SystemSoundPlayer *instance = nil;

@implementation SystemSoundPlayer

- (void)preloadSoundByFilename:(NSString*)name {
	if([[soundIds allKeys] indexOfObject:name] == NSNotFound) {
		NSString *soundPath = [[NSBundle mainBundle] pathForResource:name ofType:@""];
		if(soundPath) {
            SystemSoundID newSoundId;
            OSStatus status = AudioServicesCreateSystemSoundID((CFURLRef)[NSURL fileURLWithPath:soundPath], &newSoundId);
            
            if(status == kAudioServicesNoError) {
                [soundIds setObject:[NSNumber numberWithLong:newSoundId] forKey:name];
            } else {
                NSLog(@"sound %@ can't be loaded - error code %d", name, status);
            }
        }
	}
}


- (void)playSoundByFilename:(NSString*)name vibrate:(BOOL)vibrate {
    [self preloadSoundByFilename:name];
	
    NSNumber *soundIdNum = [soundIds objectForKey:name];
    if(soundIdNum) {
        if(vibrate) {
            AudioServicesPlayAlertSound((SystemSoundID)[soundIdNum longValue]);
        } else {
            AudioServicesPlaySystemSound((SystemSoundID)[soundIdNum longValue]);
        }
    }
}


+ (void)preloadSoundByFilename:(NSString*)name {
	[[SystemSoundPlayer instance] preloadSoundByFilename:name];
}


+ (void)playSoundByFilename:(NSString*)name vibrate:(BOOL)vibrate {
	[[SystemSoundPlayer instance] playSoundByFilename:name vibrate:vibrate];
}


- (void)reset {
    for(NSNumber *sIdNumber in [soundIds allValues]) {
        AudioServicesDisposeSystemSoundID([sIdNumber longValue]);
    }

    [soundIds removeAllObjects];
}


+ (void)reset {
	[[SystemSoundPlayer instance] reset];
}

// singletone
+ (SystemSoundPlayer*)instance {
	@synchronized(self) {
		if(instance == nil) {
			[[self alloc] init];
		}
	}
	
	return instance;
}

+ (id)allocWithZone:(NSZone*)zone {
	@synchronized(self) {
		if(instance == nil) {
			instance = [super allocWithZone:zone];
			return instance;
		}
	}
	
	return nil;
}


- (id)init {
	if(self = [super init]) {
		soundIds = [[NSMutableDictionary dictionary] retain];
	}
	
	return self;
}


- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;
}

- (void)release {
}

- (id)autorelease {
    return self;
}

@end
