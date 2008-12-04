#import "AudioSession.h"

static AudioSession *sessionStorage = nil;
static BOOL inited = FALSE;

@implementation AudioSession

+ (BOOL)open {
	@synchronized(sessionStorage) {
		if(sessionStorage == nil) {
			OSStatus status = noErr;
			if(!inited) {
				status = AudioSessionInitialize (NULL,
												 NULL,
												 NULL,
												 NULL);
				if(status == noErr || status == kNotImplemented /*simulator return unimpErr*/) {
					inited = TRUE;
				}
			}
			if(status == noErr || status == kNotImplemented /*simulator return unimpErr*/) {
				status = AudioSessionSetActive(TRUE);
				if(status == noErr || status == kNotImplemented/*simulator return unimpErr*/) {
					AudioSession *session = [[AudioSession alloc] init];
					sessionStorage = session;
				} else {
					NSLog(@"Failed to activate AudioSession: %d", status);
				}
			}
		}
	}
	return sessionStorage != nil;
}

+ (BOOL)close {
	@synchronized(sessionStorage) {
		if(sessionStorage != nil) {
			OSStatus status = AudioSessionSetActive(FALSE);
			if(status == noErr || status == kNotImplemented/*simulator return unimpErr*/) {
				[sessionStorage release];
				sessionStorage = nil;
			} else {
				NSLog(@"Failed to deactivate AudioSession: %d", status);
			}
		}
	}
	return sessionStorage == nil;
}

+ (AudioSession*)session {
	return sessionStorage;
}

- (AudioRecorder*)createRecorderForFile:(NSURL*)fileURL withFormat:(AudioStreamBasicDescription*)format {
	return [[AudioRecorder alloc] initWithURL:(CFURLRef)fileURL format:format];
}

- (AudioPlayer*)createPlayerForFile:(NSURL*)fileURL {
	CFURLRef url = (CFURLRef)fileURL;
	return [[AudioPlayer alloc] initWithSoundFile:url];
}

@end
