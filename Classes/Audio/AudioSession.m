#import "AudioSession.h"

static AudioSession *sessionStorage = nil;
static BOOL inited = FALSE;

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

+ (BOOL)open {
    @synchronized(sessionStorage) {
        if(sessionStorage == nil) {
            OSStatus status = noErr;
            if(!inited) {
                sessionStorage = [[AudioSession alloc] init];
                status = AudioSessionInitialize (NULL,
                                                 NULL,
                                                 interruptHandler,
                                                 sessionStorage);
                if(status == noErr || status == kNotImplemented /*simulator return unimpErr*/) {
                    inited = TRUE;
                }
            }
            if(status == noErr || status == kNotImplemented /*simulator return unimpErr*/) {
                status = AudioSessionSetActive(TRUE);
                if(status != noErr && status != kNotImplemented/*simulator return unimpErr*/) {
                    NSLog(@"Failed to activate AudioSession: %d", status);
                }
                return YES;
            }
        }
    }
    return NO;
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

- (void)activate {
    OSStatus status = AudioSessionSetActive(TRUE);
    if (status != noErr) {
        NSLog(@"activate: Failed to activate AudioSesison");
    }
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
