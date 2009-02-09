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
    NSLog(@"AudioQueueNewInput: %d", status);
    if(status == noErr) {
        status = AudioQueueAddPropertyListener (queue,
                                                kAudioQueueProperty_IsRunning,
                                                propertyListenerCallback,
                                                self);
        NSLog(@"AudioQueueAddPropertyListener: %d", status);
    }
    if(status == noErr) {
        OSStatus levelMeteringStatus = [self enableLevelMetering];
        if (levelMeteringStatus != noErr) {
            NSLog(@"Level metering is not supported: %d", levelMeteringStatus);
        }
    }
    if(status == noErr) {
        status = AudioFileCreateWithURL (soundFile,
                                         kAudioFileCAFType,
                                         &audioFormat,
                                         kAudioFileFlags_EraseFile,
                                         &audioFileID);
        NSURL *u = (NSURL*)soundFile;
        NSLog(@"AudioFileCreateWithURL: %d, %@", status, u);
    }
    if(status == noErr) {
        status = [self writeMagicCookie];
        NSLog(@"writeMagicCookie: %d", status);
    }
    if(status == noErr) {
        int bufferByteSize = 65536;
        int bufferIndex;
        for (bufferIndex = 0; bufferIndex < kNumberAudioDataBuffers; ++bufferIndex) {
            AudioQueueBufferRef buffer;
            status = AudioQueueAllocateBuffer(queue, bufferByteSize, &buffer);
            if(status == noErr) {
                status = AudioQueueEnqueueBuffer(queue, buffer, 0, NULL);
                NSLog(@"AudioQueueEnqueueBuffer: %d", status);
            } else {
                break;
            }
        }							
    }
    //this is a HACK. Review SpeakHere example and fail only then speakhere would fail.
    //for now this removes the crash on 2G devices
    return noErr;
}

- (void)cleanUp {
    AudioQueueRemovePropertyListener(queue,
                                     kAudioQueueProperty_IsRunning,
                                     propertyListenerCallback,
                                     self);
    [super cleanUp];

}

@end
