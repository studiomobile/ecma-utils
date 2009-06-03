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
