#import <AudioToolbox/AudioToolbox.h>
#import <math.h>

#import "AudioPlayer.h"
#import "AudioSession.h"

@interface AudioPlayer ()

- (UInt32)fillAndEnqueueBuffer:(AudioQueueBufferRef)buffer;
- (UInt32)fillQueueFromFile;
- (void)playbackCallback:(AudioQueueBufferRef)buffer;
- (OSStatus)startPlayback;
- (void)notifyPropertyChange:(AudioQueuePropertyID)propertyID;
- (OSStatus)setupPlayback;
- (void)notifyIsRinningPropertyChange;
- (OSStatus)stop:(BOOL)immediately;

@property(readwrite, nonatomic) AudioPlayerState state;

@end


static void playbackCallback (void *inUserData,
                              AudioQueueRef inAudioQueue,
                              AudioQueueBufferRef bufferReference) {
    AudioPlayer *player = (AudioPlayer *) inUserData;
    [player playbackCallback:bufferReference];
}

static void propertyListenerCallback (void *inUserData,
                                      AudioQueueRef queueObject,
                                      AudioQueuePropertyID propertyID) {
    AudioPlayer *player = (AudioPlayer *) inUserData;
    [player notifyPropertyChange:propertyID];
}


@implementation AudioPlayer

@synthesize delegate;
@synthesize state;

- (id)initWithSoundFile:(CFURLRef)file {
    if(self = [super initWithSoundFile:file]) {
        packetDescriptions = NULL;
        delegate = nil;
        self.state = kAudioPlayerStateStopped;
        OSStatus status = [self setupPlayback];
        if(status != noErr) {
            NSLog(@"Failed to create Audio Player: %d", status);
            [self autorelease];
            self = nil;
        } else {
            NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
            [c addObserver:self selector:@selector(interrupt) name:kAudioSessionInterrupted object:nil];
            [c addObserver:self selector:@selector(playIfWasInterrupted) name:kAudioSessionActivated object:nil];
        }
    }
    return self;
}


- (void)dealloc {
    NSNotificationCenter *c = [NSNotificationCenter defaultCenter];
    [c removeObserver:self];
    [self stop];
    [super dealloc];
}


- (void)interrupt {
    if (state == kAudioPlayerStatePlaying) {
        [self pause];
        self.state = kAudioPlayerStateInterrupted;
    }
}


- (void)playIfWasInterrupted {
    if (state == kAudioPlayerStateInterrupted) {
        [self resume];
    }
}


- (void)cleanUp {
    self.state = kAudioPlayerStateStopped;
    if(packetDescriptions) {
        free(packetDescriptions);
        packetDescriptions = NULL;
    }
    AudioQueueRemovePropertyListener (queue,
                                      kAudioQueueProperty_IsRunning,
                                      propertyListenerCallback,
                                      self);
    [super cleanUp];
}


- (void)notifyPropertyChange:(AudioQueuePropertyID)propertyID {
    if (!changingFrameOffset) {
        if(propertyID == kAudioQueueProperty_IsRunning) {
            [self notifyIsRinningPropertyChange];
        }
    }
}

- (void)notifyIsRinningPropertyChange {
    if(self.isRunning) {
        self.state = kAudioPlayerStatePlaying;
        if([delegate respondsToSelector:@selector(playingStarted:)]) {
            [delegate playingStarted:self];
        }
    } else {
        self.state = kAudioPlayerStateStopped;
        if([delegate respondsToSelector:@selector(playingFinished:)]) {
            [delegate playingFinished:self];
        }
    }
}


- (UInt32)fillAndEnqueueBuffer:(AudioQueueBufferRef)buffer {
    UInt32 numBytes = 0;
    UInt32 numPackets = numPacketsToRead;
    OSStatus status;
    status = AudioFileReadPackets (audioFileID,
                                   NO,
                                   &numBytes,
                                   packetDescriptions,
                                   startingPacketNumber,
                                   &numPackets, 
                                   buffer->mAudioData);    
    NSLog(@"AudioPlayer: read %d packets with status %d", numPackets, status);
    if (status == noErr) {
        startingPacketNumber += numPackets;
    }
    if (numPackets > 0) {
        buffer->mAudioDataByteSize = numBytes;
        status = AudioQueueEnqueueBuffer (queue,
                                          buffer,
                                          numPackets,
                                          packetDescriptions);

    }
    if (status != noErr) {
        NSLog(@"Playback failed: %d", status);
    }
    return numPackets;
}

- (void)playbackCallback:(AudioQueueBufferRef)buffer {
    NSLog(@"AudioPlayer: buffer received");
    if (!changingFrameOffset) {
        UInt32 packetsRead = [self fillAndEnqueueBuffer:buffer];
        if (packetsRead == 0) {
            [self stop:NO];
        }
    }
}


#undef CHECK_STATUS
#define CHECK_STATUS if (status != noErr) { NSLog(@"__FILE__:__LINE__ failed with status: %d", status); [self cleanUp]; return status; }
- (OSStatus)setupPlayback {
    OSStatus status;
    status = AudioFileOpenURL ((CFURLRef) soundFile,
                               kAudioFileReadPermission,
                               kAudioFileCAFType,
                               &audioFileID);
    CHECK_STATUS;

    UInt32 sizeOfASBD = sizeof (audioFormat);
    status = AudioFileGetProperty (audioFileID, 
                                   kAudioFilePropertyDataFormat,
                                   &sizeOfASBD,
                                   &audioFormat);
    CHECK_STATUS;

    SInt64 bufferByteSize = 0x10000;
    UInt32 maxPacketSize;
    UInt32 propertySize = sizeof (maxPacketSize);
		
    status = AudioFileGetProperty (audioFileID, 
                                   kAudioFilePropertyPacketSizeUpperBound,
                                   &propertySize,
                                   &maxPacketSize);
    CHECK_STATUS;

    numPacketsToRead = bufferByteSize/maxPacketSize;
    if(numPacketsToRead <= 0) {
        status = kAudioFormatUnsupportedDataFormatError;
    }
    CHECK_STATUS;
    
    packetDescriptions = (AudioStreamPacketDescription*)calloc(numPacketsToRead, sizeof(AudioStreamPacketDescription));
    if(!packetDescriptions) {
        status = kMemFullError;
    } 
    CHECK_STATUS;

    status = AudioQueueNewOutput (&audioFormat,
                                  playbackCallback,
                                  self, 
                                  CFRunLoopGetCurrent (),
                                  kCFRunLoopCommonModes,
                                  0,
                                  &queue);
    CHECK_STATUS;

    status = AudioQueueSetParameter (queue,
                                     kAudioQueueParam_Volume,
                                     1.0);

    CHECK_STATUS;

    OSStatus levelMeteringStatus = [self enableLevelMetering];
    if (levelMeteringStatus != noErr) {
        NSLog(@"Level metering is not supported: %d", levelMeteringStatus);
    }
    status = AudioQueueAddPropertyListener (queue,
                                            kAudioQueueProperty_IsRunning,
                                            propertyListenerCallback,
                                            self);
    CHECK_STATUS;

    int bufferIndex;
    for (bufferIndex = 0; bufferIndex < kNumberOfPlayingAudioDataBuffers; ++bufferIndex) {
        AudioQueueBufferRef buffer;
        status = AudioQueueAllocateBuffer (queue,
                                           bufferByteSize,
                                           &buffer);
        if(status != noErr) {
            break;
        } else {
            buffers[bufferIndex] = buffer;
        }
    }
    CHECK_STATUS;
    
    [self writeMagicCookie];
    return status;
}


- (UInt32)fillQueueFromFile {
    for (int i = 0; i < kNumberOfPlayingAudioDataBuffers; ++i) {
        if (buffers[i] != NULL) {
            UInt32 packetsRead = [self fillAndEnqueueBuffer:buffers[i]];
            if (packetsRead == 0) {
                return i;
            }
        }
    }
    return kNumberOfPlayingAudioDataBuffers;
}

- (OSStatus)startPlayback {
    OSStatus status = AudioQueueStart(queue, NULL);
    if(status == noErr) {
        self.state = kAudioPlayerStatePlaying;
    }
    return status;
}


- (OSStatus)prepareToPlay {
    UInt32 prepared = 0;
    return AudioQueuePrime(queue, audioFormat.mSampleRate/2, &prepared);
}


- (OSStatus)play {
    if (state == kAudioPlayerStateStopped) {
        UInt32 buffersRead = [self fillQueueFromFile];
        if (buffersRead > 0) {
            return [self startPlayback];
        }
    }
    return noErr;
}


- (OSStatus)stop {
    return [self stop:YES];
}

- (OSStatus)stop:(BOOL)immediately {
    OSStatus status = noErr;
    startingPacketNumber = 0;
    playbackStartPacket = 0;
    status = AudioQueueStop(queue, immediately);
    if(status == noErr) {
        self.state = kAudioPlayerStateStopped;
    }
    return status;
}


- (OSStatus)pause {
    OSStatus status = noErr;
    if (state == kAudioPlayerStatePlaying) {
        status = AudioQueuePause (queue);
        if(status == noErr) {
            self.state = kAudioPlayerStatePaused;
        }
    }
    return status;
}


- (OSStatus)resume {
    OSStatus status = noErr;
    if (state == kAudioPlayerStatePaused) {
        status = AudioQueueStart(queue, NULL);
        if(status == noErr) {
            self.state = kAudioPlayerStatePlaying;
        }        
    }
    return status;
}


- (Float32)currentTime {
    return self.frameOffset/audioFormat.mSampleRate;
}


- (UInt64)frameOffset {
    UInt64 frameOffset = 0;
    if (self.isRunning) {
        AudioTimeStamp stamp;
        stamp.mFlags = kAudioTimeStampSampleTimeValid;
        OSStatus s = AudioQueueGetCurrentTime(queue, nil, &stamp, NULL);
        if (s == noErr) {
            frameOffset = (UInt64)stamp.mSampleTime + playbackStartPacket * audioFormat.mFramesPerPacket;
        } else {
            NSLog(@"Debug: AudioQueueGetCurrentTime failed with error code: %d", s);
        }
    } else {
        frameOffset = playbackStartPacket * audioFormat.mFramesPerPacket;
    }
    return frameOffset;
}


- (void)forward:(UInt64)packets {
    UInt64 targetPacket = self.packetOffset + packets;
    if (targetPacket > self.packetsCount) {
        [self stop];
    } else {
        self.packetOffset = targetPacket;
    }
}


- (void)backward:(UInt64)packets {
    SInt64 targetPacket = self.packetOffset - packets;
    if (targetPacket >= 0) {
        self.packetOffset = targetPacket;
    }
}


- (SInt64)packetOffset {
    SInt64 packetOffset = 0;
    if (self.isRunning) {
        packetOffset = self.frameOffset / audioFormat.mFramesPerPacket;
    } else {
        packetOffset = playbackStartPacket;
    }
    return packetOffset;
}


- (void)setPacketOffset:(SInt64)packets {
    NSAssert1(packets >= 0 && packets <= self.packetsCount, @"packets argument should be between 0 and %d", self.packetsCount);
    changingFrameOffset = YES;
    AudioQueueStop(queue, YES);
    changingFrameOffset = NO;

    startingPacketNumber = packets;
    playbackStartPacket = startingPacketNumber;
    UInt32 buffersRead = 0;
    switch (state) {           
    case kAudioPlayerStatePlaying:
        buffersRead = [self fillQueueFromFile];
        if (buffersRead == 0) {
            [self stop];
        } else {
            [self startPlayback];
        }
        break;
    case kAudioPlayerStateInterrupted:
    case kAudioPlayerStatePaused:
        buffersRead = [self fillQueueFromFile];
        if (buffersRead == 0) {
            [self stop];
        } else {
            AudioQueuePause(queue);
        }
        break;
    case kAudioPlayerStateStopped:
        //do nothing
        break;
    }
}


- (BOOL)isRunning {
    UInt32 isRunning;
    UInt32 propertySize = sizeof (UInt32);
    OSStatus result;
    result = AudioQueueGetProperty (queue,
                                    kAudioQueueProperty_IsRunning,
                                    &isRunning,
                                    &propertySize);
    if (result != noErr) {
        return FALSE;
    } else {
        return isRunning;
    }
    return NO;
}


- (void)setState:(AudioPlayerState)newState {
    state = newState;
}

- (UInt64)packetsCount {
    UInt64 packetsCount = 0;
    UInt32 propertySize = sizeof (packetsCount);
    AudioFileGetProperty (audioFileID, 
                          kAudioFilePropertyAudioDataPacketCount,
                          &propertySize,
                          &packetsCount);
    return packetsCount;
}


@end
