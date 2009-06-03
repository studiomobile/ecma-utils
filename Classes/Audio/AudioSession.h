#import <UIKit/UIKit.h>
#import "AudioPlayer.h"
#import "AudioRecorder.h"

enum {
	kMemFullError = 0x216D656D, //!mem
	kNotImplemented = -4 //same as in MacErrors.h
};

#define kAudioSessionInterrupted @"__AudioSessionInterrupted__"
#define kAudioSessionActivated @"__AudioSessionActivated__"

@interface AudioSession : NSObject {
    BOOL interruptedOnPlayback;
}

+ (BOOL)open;
+ (BOOL)close;
+ (AudioSession*)session;

- (BOOL)activate:(UInt32)sessionCategory;
- (AudioRecorder*)createRecorderForFile:(NSURL*)fileURL withFormat:(AudioStreamBasicDescription*)format;
- (AudioPlayer*)createPlayerForFile:(NSURL*)fileURL;

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED >= 20200 
- (BOOL)hasAudioInput;
#endif



@end
