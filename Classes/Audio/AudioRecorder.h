#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"

@protocol AudioRecorderDelegate
@optional
- (void)recordingStarted:(AudioRecorder*)rec;
- (void)recordingFinished:(AudioRecorder*)rec;

@end

typedef enum {
    kAudioRecorderStatePaused,
    kAudioRecorderStateStopped,
    kAudioRecorderStateRecording
} AudioRecorderState;


@interface AudioRecorder : AudioQueueObject {
    NSObject<AudioRecorderDelegate>* delegate;
    AudioRecorderState state;
}

- (id)initWithURL:(CFURLRef)file format:(AudioStreamBasicDescription*)audioFormat;
- (OSStatus)record;
- (OSStatus)stop;
- (OSStatus)pause;

@property(readwrite, nonatomic, assign) NSObject<AudioRecorderDelegate> *delegate;
@property (readonly, nonatomic, assign) AudioRecorderState state;

@end
