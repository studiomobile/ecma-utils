#import "AudioSession.h"

static AudioSession *sessionStorage = nil;

@interface AudioSession ()

@property (readwrite, nonatomic) BOOL interruptedOnPlayback;
- (void)onInterrupt;
- (void)onActivate;

@end

static void interruptHandler(void *data, UInt32  interruptionState) {
    AudioSession *session = (AudioSession *)data;
    if (interruptionState == kAudioSessionBeginInterruption) {
        [session onInterrupt];
    } else if ((interruptionState == kAudioSessionEndInterruption)) {
        [session onActivate];
    }
}

@implementation AudioSession

@synthesize interruptedOnPlayback;
#define CHECK_ERROR(errMsg) if (status != noErr && status != kNotImplemented /*simulator return unimpErr*/)\
        { NSLog(errMsg); [sessionStorage release]; sessionStorage = nil; return NO; }
+ (BOOL)open {
    OSStatus status = noErr;
    @synchronized (sessionStorage) {
        if (sessionStorage == nil) {
            sessionStorage = [[AudioSession alloc] init];
            status = AudioSessionInitialize (NULL,
                                             NULL,
                                             interruptHandler,
                                             sessionStorage);
            CHECK_ERROR(@"Failed to initialize audioSession");
        }
    }
    return status == noErr;
}


+ (BOOL)close {
    @synchronized(sessionStorage) {
        if(sessionStorage != nil) {
            OSStatus status = AudioSessionSetActive(FALSE);
            if(status != noErr && status != kNotImplemented/*simulator return unimpErr*/) {
                NSLog(@"Failed to deactivate AudioSession: %d", status);
                return NO;
            }
        }
    }
    return YES;
}

+ (AudioSession*)session {
    @synchronized(sessionStorage) {
        return sessionStorage;
    }
    return nil;
}

- (void)onInterrupt {
    NSNotification *n = [NSNotification notificationWithName:kAudioSessionInterrupted object:self];
    [[NSNotificationCenter defaultCenter] postNotification:n];
}


- (void)onActivate {
    OSStatus status = AudioSessionSetActive(TRUE);
    if(status != noErr) {
        NSLog(@"Failed to activated audio session after interruption");
    } else {
        NSNotification *n = [NSNotification notificationWithName:kAudioSessionActivated object:self];
        [[NSNotificationCenter defaultCenter] postNotification:n];    
    }
}


- (BOOL)activate:(UInt32)sessionCategory {
    AudioSessionSetProperty (kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory);
    OSStatus status = AudioSessionSetActive(TRUE);
    CHECK_ERROR(@"Failed to activate AudioSesison");
    return status == noErr;
}


- (AudioRecorder*)createRecorderForFile:(NSURL*)fileURL withFormat:(AudioStreamBasicDescription*)format {
    return [[AudioRecorder alloc] initWithURL:(CFURLRef)fileURL format:format];
}

- (AudioPlayer*)createPlayerForFile:(NSURL*)fileURL {
    CFURLRef url = (CFURLRef)fileURL;
    return [[AudioPlayer alloc] initWithSoundFile:url];
}

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED >= 20200 
- (BOOL)hasAudioInput {
    UInt32 audioInputIsAvailable;
    UInt32 propertySize = sizeof (audioInputIsAvailable);
    AudioSessionGetProperty (kAudioSessionProperty_AudioInputAvailable,
                             &propertySize,
                             &audioInputIsAvailable);
    return audioInputIsAvailable;
}
#endif

@end
