#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"

#define kSecondsPerBuffer	0.1
#define kNumberOfPlayingAudioDataBuffers	3

typedef enum {
    kAudioPlayerStatePaused,
    kAudioPlayerStateStopped,
    kAudioPlayerStatePlaying,
    kAudioPlayerStateInterrupted
} AudioPlayerState;

@protocol AudioPlayerDelegate
@optional
- (void)playingStarted:(AudioPlayer*)player;
- (void)playingFinished:(AudioPlayer*)player;

@end

@interface AudioPlayer : AudioQueueObject {
    UInt32 numPacketsToRead;
    AudioStreamPacketDescription *packetDescriptions;
    NSObject<AudioPlayerDelegate> *delegate;
    AudioPlayerState state;
    AudioQueueBufferRef buffers[kNumberOfPlayingAudioDataBuffers];
    SInt64 playbackStartPacket;
    BOOL changingFrameOffset;
}

- (OSStatus)prepareToPlay;
- (OSStatus)play;
- (OSStatus)stop;
- (OSStatus)pause;
- (OSStatus)resume;
- (void)forward:(UInt64)packets;
- (void)backward:(UInt64)packets;

@property(readwrite, nonatomic, assign) NSObject<AudioPlayerDelegate> *delegate;
@property(readonly, nonatomic) Float32 currentTime;
@property(readonly, nonatomic) UInt64 frameOffset;
@property (readonly, nonatomic, assign) UInt64 packetsCount;
@property (readwrite, nonatomic, assign) SInt64 packetOffset;
@property(readonly, nonatomic) AudioPlayerState state;

@end
