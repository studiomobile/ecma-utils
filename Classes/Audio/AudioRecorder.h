#import <UIKit/UIKit.h>
#import "AudioQueueObject.h"

@protocol AudioRecorderDelegate
@optional
- (void)recordingStarted:(AudioRecorder*)rec;
- (void)recordingFinished:(AudioRecorder*)rec;

@end

@interface AudioRecorder : AudioQueueObject {
    NSObject<AudioRecorderDelegate>* delegate;
}

- (id)initWithURL:(CFURLRef)file format:(AudioStreamBasicDescription*)audioFormat;
- (OSStatus)record;
- (OSStatus)stop;

@property(readwrite, nonatomic, assign) NSObject<AudioRecorderDelegate> *delegate;

@end
