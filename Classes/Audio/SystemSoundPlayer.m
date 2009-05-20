/*
 
 WisdomReader(tm) eBook Software
 
 Version: 1.0
 
 Copyright (c) 2009 Tree of Life Publishing Inc. All Rights Reserved.
 
 Any redistribution, modification, or reproduction of part or all of the
 software or contents in any form is strictly prohibited without written
 permission by Tree of Life Publishing, Inc.
 
 Do not make illegal copies of this software.
 
 Contact:
 Tree of Life Publishing, Inc.
 548 Market St. # 60253
 San Francisco, CA 94104
 www.WisdomTitles.com
 
 IN NO EVENT SHALL TREE OF LIFE PUBLISHING, INC. BE LIABLE TO ANY PARTY FOR
 DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 EVEN IF TREE OF LIFE PUBLISHING, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.
 
 TREE OF LIFE PUBLISHING, INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
 BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY,
 PROVIDED HEREUNDER IS PROVIDED "AS IS". TREE OF LIFE PUBLISHING, INC. HAS NO
 OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 MODIFICATIONS.
 
 */





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
