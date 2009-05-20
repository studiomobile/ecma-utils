/*
 
 WisdomReader(tm) eBook Software
 
 Version: 1.0
 
 Copyright (c) 2009 Tree of Life Publishing Inc. All Rights Reserved.
 
 Any redistribution, modification, or reproduction of part or all of the
 software or contents in any form is strictly prohibited without written
 permission by Tree of Life Publishing, Inc.
 
 Do not make illegal copies of this software.
 
 Contact:
 Tree of Life Publishing, Inc.
 548 Market St. # 60253
 San Francisco, CA 94104
 www.WisdomTitles.com
 
 IN NO EVENT SHALL TREE OF LIFE PUBLISHING, INC. BE LIABLE TO ANY PARTY FOR
 DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
 LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION,
 EVEN IF TREE OF LIFE PUBLISHING, INC. HAS BEEN ADVISED OF THE POSSIBILITY OF
 SUCH DAMAGE.
 
 TREE OF LIFE PUBLISHING, INC. SPECIFICALLY DISCLAIMS ANY WARRANTIES, INCLUDING,
 BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
 PARTICULAR PURPOSE. THE SOFTWARE AND ACCOMPANYING DOCUMENTATION, IF ANY,
 PROVIDED HEREUNDER IS PROVIDED "AS IS". TREE OF LIFE PUBLISHING, INC. HAS NO
 OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR
 MODIFICATIONS.
 
 */





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

- (void)activate;
- (AudioRecorder*)createRecorderForFile:(NSURL*)fileURL withFormat:(AudioStreamBasicDescription*)format;
- (AudioPlayer*)createPlayerForFile:(NSURL*)fileURL;

#ifdef __IPHONE_OS_VERSION_MIN_REQUIRED >= 20200 
- (BOOL)hasAudioInput;
#endif



@end
