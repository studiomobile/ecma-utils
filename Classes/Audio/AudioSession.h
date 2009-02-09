#import <UIKit/UIKit.h>
#import "AudioPlayer.h"
#import "AudioRecorder.h"

enum {
	kMemFullError = 0x216D656D, //!mem
	kNotImplemented = -4 //same as in MacErrors.h
};

@interface AudioSession : NSObject

+ (BOOL)open;
+ (BOOL)close;
+ (AudioSession*)session;

- (AudioRecorder*)createRecorderForFile:(NSURL*)fileURL withFormat:(AudioStreamBasicDescription*)format;
- (AudioPlayer*)createPlayerForFile:(NSURL*)fileURL;

@end
