#include <AudioToolbox/AudioToolbox.h>
#import "AudioRecorder.h"
#import "AudioSession.h"

#define kAudioConverterPropertyMaximumOutputPacketSize        'xops'

@interface AudioRecorder ()

- (void)recordBuffer:(AudioQueueBufferRef)inBuffer withPackets:(const AudioStreamPacketDescription *)inPacketDescr :(UInt32)inNumPackets;
- (void)notifyPropertyChange:(AudioQueuePropertyID)propertyID;
- (void)notifyRecordingStarted;
- (void)notifyRecordingPaused;
- (void)closeFileAndNotifyDelegate;
- (OSStatus)setupRecording;

@end


static void recordingCallback (void	*inUserData,
                               AudioQueueRef inAudioQueue,
                               AudioQueueBufferRef inBuffer,
                               const AudioTimeStamp *inStartTime,
                               UInt32 inNumPackets,
                               const AudioStreamPacketDescription *inPacketDesc) {
    AudioRecorder *recorder = (AudioRecorder *) inUserData;
    [recorder recordBuffer:inBuffer withPackets:inPacketDesc :inNumPackets];
}

static void propertyListenerCallback (void *inUserData,
                                      AudioQueueRef queueObject,
                                      AudioQueuePropertyID propertyID) {
    AudioRecorder *recorder = (AudioRecorder *) inUserData;
    [recorder notifyPropertyChange:propertyID];
}


@implementation AudioRecorder

@synthesize delegate;
@synthesize state;

- (void)notifyPropertyChange:(AudioQueuePropertyID)propertyID {
    NSLog(@"Is running: %d", self.isRunning);
    if(propertyID == kAudioQueueProperty_IsRunning) {
        if (!self.isRunning) {
            if (state == kAudioRecorderStateStopping) {
                [self closeFileAndNotifyDelegate];
                [self autorelease];
                [delegate autorelease];
            } else {
                [self notifyRecordingPaused];
            }
        } else {
            [self notifyRecordingStarted];
        }
    }	
}


- (void)notifyRecordingStarted {
    if([delegate respondsToSelector:@selector(recordingStarted:)]) {
        [delegate recordingStarted:self];
    }
}


- (void)notifyRecordingPaused {
    if([delegate respondsToSelector:@selector(recordingStopped:)]) {
        [delegate recordingStopped:self];
    }
}


- (void)closeFileAndNotifyDelegate {
    [self writeMagicCookie];
    AudioFileClose(audioFileID);
    NSLog(@"AudioRecorder: audio file closed");
    audioFileID = 0;
    state = kAudioRecorderStateStopped;
    if ([delegate respondsToSelector:@selector(recordingFinished:)]) {
        [delegate recordingFinished:self];
    }
}


- (void)recordBuffer:(AudioQueueBufferRef)inBuffer withPackets:(const AudioStreamPacketDescription*)inPacketDesc :(UInt32)inNumPackets {
    NSLog(@"AudioRecorder: buffer received");
    if (inNumPackets > 0) {
        OSStatus status = AudioFileWritePackets (audioFileID,
                                                 FALSE,
                                                 inBuffer->mAudioDataByteSize,
                                                 inPacketDesc,
                                                 startingPacketNumber,
                                                 &inNumPackets,
                                                 inBuffer->mAudioData);
        if (status != noErr) {
            NSLog(@"AudioRecorder error: %d", status);
        } else {
            startingPacketNumber += inNumPackets;
            NSLog(@"AudioRecorder: buffer written");
        }
    }
    AudioQueueEnqueueBuffer (queue, inBuffer, 0, NULL);
}


- (id)initWithURL:(CFURLRef)file format:(AudioStreamBasicDescription*)format {
    if (self = [super initWithSoundFile:file]) {
        audioFormat = *format;
        delegate = nil;
        OSStatus status = [self setupRecording];
        if(status != noErr) {
            [self autorelease];
            self = nil;
        }
        NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
        [c addObserver:self selector:@selector(stop) name:kAudioSessionInterrupted object:nil];
    }
    return self;
}


- (void)dealloc {
    NSLog(@"AudioRecorder: dealloc");
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    [c removeObserver:self];
    [super dealloc];
}


#define RETURN_IF_CLOSED if(state == kAudioRecorderStateStopped || state == kAudioRecorderStateStopping) return noErr
- (OSStatus)record {
    RETURN_IF_CLOSED;
    NSLog(@"AudioRecorder: record");
    OSStatus status = noErr;
    if (state == kAudioRecorderStateNotStarted) {
        for (int i = 0; i < kNumberOfRecordingAudioDataBuffers; ++i) {
            status = AudioQueueEnqueueBuffer(queue, buffers[i], 0, NULL);
            if (status != noErr) {
                NSLog(@"Debug: AudioQueueEnqueueBuffer failed with status %d", status);
            }
        }
    }
    status = AudioQueueStart (queue, NULL);
    if (status == noErr) {
        state = kAudioRecorderStateRecording;
    } else {
        NSLog(@"AudioRecorder error: %d", status);
    }
    return status;
}


- (OSStatus)pause {
    RETURN_IF_CLOSED;
    OSStatus status;
    NSLog(@"AudioRecorder: pause");
    AudioQueueFlush(queue);
    status = AudioQueuePause(queue);
    if (status == noErr) {
        state = kAudioRecorderStatePaused;
    } else {
        NSLog(@"AudioRecorder error: %d", status);
    }
    return status;
}


- (OSStatus)stop {
    RETURN_IF_CLOSED;
    OSStatus status = noErr;
    if (audioFileID) {
        NSLog(@"AudioRecorder: close");
        if (state == kAudioRecorderStatePaused) {
            [self closeFileAndNotifyDelegate];
        } else {
            state = kAudioRecorderStateStopping;
            [self retain];
            [delegate retain];
            AudioQueueStop(queue, NO);
        }
    }
    return status;
}


#undef CHECK_STATUS
#define CHECK_STATUS if (status != noErr) { NSLog(@"__FILE__ __LINE__, error: %d", status); return status; }
- (OSStatus) setupRecording {
    state = kAudioRecorderStateNotStarted;
    OSStatus status = noErr;
    startingPacketNumber = 0;

    status = AudioQueueNewInput (&audioFormat,
                                 recordingCallback,
                                 self,
                                 CFRunLoopGetCurrent(),
                                 kCFRunLoopCommonModes,
                                 0,
                                 &queue);
    CHECK_STATUS;
    
    status = AudioQueueAddPropertyListener (queue,
                                            kAudioQueueProperty_IsRunning,
                                            propertyListenerCallback,
                                            self);
    CHECK_STATUS;
    
    OSStatus levelMeteringStatus = [self enableLevelMetering];
    if (levelMeteringStatus != noErr) {
        NSLog(@"Level metering is not supported: %d", levelMeteringStatus);
    }

    status = AudioFileCreateWithURL (soundFile,
                                     kAudioFileCAFType,
                                     &audioFormat,
                                     kAudioFileFlags_EraseFile,
                                     &audioFileID);
    CHECK_STATUS;
    
    OSStatus magicCookieStatus = [self writeMagicCookie];
    if (magicCookieStatus != noErr) {
        NSLog(@"__FILE__ __LINE__ writeMagicCookie: %d", magicCookieStatus);
    }

    UInt32 bufferByteSize = 4*1024;
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberOfRecordingAudioDataBuffers; ++bufferIndex) {
        AudioQueueBufferRef buffer;
        OSStatus s = AudioQueueAllocateBuffer(queue, bufferByteSize, &buffer);
        if (s == noErr) {
            buffers[bufferIndex] = buffer;
        }
    }
    return noErr;
}


- (void)cleanUp {
    [self stop];
    AudioQueueRemovePropertyListener(queue,
                                     kAudioQueueProperty_IsRunning,
                                     propertyListenerCallback,
                                     self);
    [super cleanUp];

}


- (BOOL)isRunning {
    return kAudioRecorderStateRecording == state;
}

@end
