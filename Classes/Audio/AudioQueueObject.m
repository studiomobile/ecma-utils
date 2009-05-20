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





#import <AudioToolbox/AudioToolbox.h>
#import "AudioQueueObject.h"

@implementation AudioQueueObject

@dynamic isRunning;
@synthesize soundFile;
@synthesize audioFormat;

- (BOOL)isRunning {
    return NO;
}

- (NSUInteger)channels {
    return audioFormat.mChannelsPerFrame;
}

- (id)initWithSoundFile:(CFURLRef)file {
    if(self = [super init]) {
        soundFile = CFRetain(file);
        queue = NULL;
        audioFileID = 0;
        levels = NULL;
    }
    return self;
}

- (void)cleanUp {
    OSStatus status = noErr;
    if(status == noErr && queue && (status = AudioQueueDispose(queue, YES)) == noErr) {
        queue = NULL;
    }
    if(levels) {
        free(levels);
        levels = NULL;
    }
    if(status == noErr && audioFileID && (status = AudioFileClose(audioFileID)) == noErr) {
        audioFileID = 0;
    }
}

- (void) dealloc {
    [self cleanUp];
    if(soundFile) {
        CFRelease(soundFile);
    }
    [super dealloc];
}


- (OSStatus)writeMagicCookie {
    OSStatus	status;
    UInt32		propertySize;
    status = AudioQueueGetPropertySize (queue,
                                        kAudioQueueProperty_MagicCookie,
                                        &propertySize);
    if (status == noErr && propertySize > 0) {
        Byte *magicCookie = (Byte *) malloc (propertySize);
        status = AudioQueueGetProperty (queue,
                                        kAudioQueueProperty_MagicCookie,
                                        magicCookie,
                                        &propertySize);
        if(status == noErr) {
            status = AudioFileSetProperty (audioFileID,
                                           kAudioQueueProperty_MagicCookie,
                                           propertySize,
                                           magicCookie);
        }
        free (magicCookie);
    }
    return status;
}


- (OSStatus)enableLevelMetering {
    levels = (AudioQueueLevelMeterState *) calloc (sizeof (AudioQueueLevelMeterState), audioFormat.mChannelsPerFrame);
    UInt32 trueValue = true;
    return AudioQueueSetProperty (queue,
                                  kAudioQueueProperty_EnableLevelMetering,
                                  &trueValue,
                                  sizeof (UInt32));
}

- (AudioQueueLevelMeterState*)audioLevels {
    if(levels) {
        UInt32 propertySize = audioFormat.mChannelsPerFrame * sizeof (AudioQueueLevelMeterState);
        OSStatus status;
        status = AudioQueueGetProperty (queue,
                                        (AudioQueuePropertyID) kAudioQueueProperty_CurrentLevelMeter,
                                        levels,
                                        &propertySize);
        if(status == noErr) {
            return levels;
        }
    }
    return NULL;
}

- (Float32)volume {
    OSStatus status;
    AudioQueueParameterValue volume;
    status = AudioQueueGetParameter(queue, kAudioQueueParam_Volume, &volume);
    if(status == noErr) {
        return volume;
    }
    return -1;
}

- (void)setVolume:(Float32)val {
    OSStatus status;
    AudioQueueParameterValue volume = val;
    status = AudioQueueSetParameter(queue, kAudioQueueParam_Volume, volume);
    if(status != noErr) {
        NSLog(@"Failed to set queue volume: %d", status);
    }
}

@end
