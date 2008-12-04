#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"

#define kSecondsPerBuffer	0.5

typedef enum {
	kAudioPlayerStatePaused,
	kAudioPlayerStateStopped,
	kAudioPlayerStatePlaying
} AudioPlayerState;

@protocol AudioPlayerDelegate
@optional
- (void)playingStarted:(AudioPlayer*)player;
- (void)playingFinished:(AudioPlayer*)player;

@end

@interface AudioPlayer : AudioQueueObject {
	UInt32 numPacketsToRead;
	AudioStreamPacketDescription *packetDescriptions;
	BOOL donePlayingFile;
	NSObject<AudioPlayerDelegate> *delegate;
	AudioPlayerState state;
}

- (OSStatus) play;
- (OSStatus) stop;
- (OSStatus) pause;
- (OSStatus) resume;

@property(readwrite, nonatomic, assign) NSObject<AudioPlayerDelegate> *delegate;
@property(readonly, nonatomic) long currentTime;
@property(readonly, nonatomic) AudioPlayerState state;

@end
