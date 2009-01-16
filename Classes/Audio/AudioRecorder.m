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
        AudioQueueEnqueueBuffer (queue,
                                 inBuffer,
                                 0,
                                 NULL);
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
    }
    return self;
}

- (OSStatus)record {
    return AudioQueueStart (queue, NULL);;
}

- (OSStatus)stop {
    return AudioQueueStop(queue, YES);
}


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
    if(status == noErr) {
        status = AudioQueueAddPropertyListener (queue,
                                                kAudioQueueProperty_IsRunning,
                                                propertyListenerCallback,
                                                self);
    }
    if(status == noErr) {
        levels = (AudioQueueLevelMeterState *) calloc (sizeof (AudioQueueLevelMeterState), audioFormat.mChannelsPerFrame);
        if(!levels) {
            status = kMemFullError;				
        }
    }
    if(status == noErr) {
        status = [self enableLevelMetering];
    }
    if(status == noErr) {
        status = AudioFileCreateWithURL (soundFile,
                                         kAudioFileCAFType,
                                         &audioFormat,
                                         kAudioFileFlags_EraseFile,
                                         &audioFileID);
    }
    if(status == noErr) {
        status = [self writeMagicCookie];
    }
    if(status == noErr) {
        int bufferByteSize = 65536;
        int bufferIndex;
        for (bufferIndex = 0; bufferIndex < kNumberAudioDataBuffers; ++bufferIndex) {
            AudioQueueBufferRef buffer;
            status = AudioQueueAllocateBuffer(queue, bufferByteSize, &buffer);
            if(status == noErr) {
                status = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
            } else {
                break;
            }
        }							
    }
    if(status != noErr) {
        [self cleanUp];
    }
    return status;
}

@end
