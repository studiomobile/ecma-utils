#include <AudioToolbox/AudioToolbox.h>
#import "AudioRecorder.h"
#import "AudioSession.h"

@interface AudioRecorder ()

- (void)recordBuffer:(AudioQueueBufferRef)inBuffer withPackets:(const AudioStreamPacketDescription *)inPacketDescr :(UInt32)inNumPackets;
- (void)notifyPropertyChange:(AudioQueuePropertyID)propertyID;
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
    if(propertyID == kAudioQueueProperty_IsRunning) {
        if(!self.isRunning) {
            [self writeMagicCookie];
            AudioFileClose(audioFileID);
            audioFileID = 0;
            if([delegate respondsToSelector:@selector(recordingFinished:)]) {
                [delegate recordingFinished:self];
            }
        } else {
            if([delegate respondsToSelector:@selector(recordingStarted:)]) {
                [delegate recordingStarted:self];
            }
        }
    }
	
}

- (void)recordBuffer:(AudioQueueBufferRef)inBuffer withPackets:(const AudioStreamPacketDescription*)inPacketDesc :(UInt32)inNumPackets {
    if (inNumPackets > 0) {
        AudioFileWritePackets (audioFileID,
                               FALSE,
                               inBuffer->mAudioDataByteSize,
                               inPacketDesc,
                               startingPacketNumber,
                               &inNumPackets,
                               inBuffer->mAudioData);
        startingPacketNumber += inNumPackets;		
    }
    if (self.isRunning) {
        AudioQueueEnqueueBuffer (queue, inBuffer, 0, NULL);
    }
}


- (id)initWithURL:(CFURLRef)file format:(AudioStreamBasicDescription*)format {
    if (self = [super initWithSoundFile:file]) {
        audioFormat = *format;
        delegate = nil;
        OSStatus status = [self setupRecording];
        if(status != noErr) {
            NSLog(@"Failed to create recorder: %d", status);
            [self autorelease];
            self = nil;
        }
        NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
        [c addObserver:self selector:@selector(stop) name:kAudioSessionInterrupted object:nil];
    }
    return self;
}

- (void)dealloc {
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    [c removeObserver:self];
    [self stop];
    [super dealloc];
}

- (OSStatus)record {
    OSStatus status = AudioQueueStart (queue, NULL);
    if (status == noErr) {
        state = kAudioRecorderStateRecording;
    }
    return status;
}

- (OSStatus)stop {
    OSStatus status = AudioQueueStop(queue, YES);
    if (status == noErr) {
        state = kAudioRecorderStateStopped;
    }
    return status;
}

- (OSStatus)pause {
    OSStatus status = AudioQueuePause(queue);
    if (status == noErr) {
        state = kAudioRecorderStatePaused;
    }
    return status;
}


#undef CHECK_STATUS
#define CHECK_STATUS if (status != noErr) { NSLog(@"__FILE__ __LINE__, error: %d", status); return status; }
- (OSStatus) setupRecording {
    OSStatus status = noErr;
    startingPacketNumber = 0;
	
    status = AudioQueueNewInput (&audioFormat,
                                 recordingCallback,
                                 self,
                                 NULL,
                                 NULL,
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

    int bufferByteSize = 65536;
    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberAudioDataBuffers; ++bufferIndex) {
        AudioQueueBufferRef buffer;
        AudioQueueAllocateBuffer(queue, bufferByteSize, &buffer);
        AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
    }							
    return noErr;
}

- (void)cleanUp {
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
