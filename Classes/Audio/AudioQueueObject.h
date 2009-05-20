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
#import <AudioToolbox/AudioToolbox.h>

@class AudioRecorder, AudioPlayer;

@interface AudioQueueObject : NSObject {
@protected
    AudioFileID audioFileID;
    AudioQueueRef queue;
    AudioQueueLevelMeterState *levels;
    CFURLRef soundFile;
    SInt64 startingPacketNumber;
    AudioStreamBasicDescription audioFormat;
}

- (id)initWithSoundFile:(CFURLRef)soundFile;
- (AudioQueueLevelMeterState*)audioLevels;
- (NSUInteger)channels;

- (void)cleanUp;
- (OSStatus)writeMagicCookie;
- (OSStatus)enableLevelMetering;

@property (readonly, nonatomic) CFURLRef soundFile;
@property (readonly, nonatomic) BOOL isRunning;
@property (readwrite, nonatomic) Float32 volume;
@property (readonly, nonatomic, assign) AudioStreamBasicDescription audioFormat;

@end
