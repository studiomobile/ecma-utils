#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"

#define kNumberOfRecordingAudioDataBuffers 3

@protocol AudioRecorderDelegate
@optional
- (void)recordingStarted:(AudioRecorder*)rec;
- (void)recordingStopped:(AudioRecorder*)rec;
- (void)recordingFinished:(AudioRecorder*)rec;

@end

typedef enum {
    kAudioRecorderStatePaused,
    kAudioRecorderStateRecording,
    kAudioRecorderStateStopping,
    kAudioRecorderStateStopped,
    kAudioRecorderStateNotStarted
} AudioRecorderState;


@interface AudioRecorder : AudioQueueObject {
    NSObject<AudioRecorderDelegate>* delegate;
    AudioRecorderState state;
    AudioQueueBufferRef buffers[kNumberOfRecordingAudioDataBuffers];
}

- (id)initWithURL:(CFURLRef)file format:(AudioStreamBasicDescription*)audioFormat;
- (OSStatus)record;
- (OSStatus)pause;
- (OSStatus)stop;

@property(readwrite, nonatomic, assign) NSObject<AudioRecorderDelegate> *delegate;
@property (readonly, nonatomic, assign) AudioRecorderState state;

@end
