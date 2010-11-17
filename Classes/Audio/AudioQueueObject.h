#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class AudioRecorder, AudioPlayer;

@interface AudioQueueObject : NSObject {
@protected
    AudioFileID audioFileID;
    AudioQueueRef queue;
    AudioQueueLevelMeterState *levels;
    CFURLRef soundFile;
    SInt64 startingPacketNumber;
    AudioStreamBasicDescription audioFormat;
}

- (id)initWithSoundFile:(CFURLRef)soundFile;
- (AudioQueueLevelMeterState*)audioLevels;
- (NSUInteger)channels;

- (void)cleanUp;
- (OSStatus)writeMagicCookie;
- (OSStatus)enableLevelMetering;

@property (readonly, nonatomic) CFURLRef soundFile;
@property (readonly, nonatomic) BOOL isRunning;
@property (readwrite, nonatomic) Float32 volume;
@property (readonly, nonatomic, assign) AudioStreamBasicDescription audioFormat;

@end
