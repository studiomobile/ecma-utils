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
#import "AudioQueueObject.h"

#define kSecondsPerBuffer	0.1
#define kNumberOfPlayingAudioDataBuffers	3

typedef enum {
    kAudioPlayerStatePaused,
    kAudioPlayerStateStopped,
    kAudioPlayerStatePlaying,
    kAudioPlayerStateInterrupted
} AudioPlayerState;

@protocol AudioPlayerDelegate
@optional
- (void)playingStarted:(AudioPlayer*)player;
- (void)playingFinished:(AudioPlayer*)player;

@end

@interface AudioPlayer : AudioQueueObject {
    UInt32 numPacketsToRead;
    AudioStreamPacketDescription *packetDescriptions;
    NSObject<AudioPlayerDelegate> *delegate;
    AudioPlayerState state;
    AudioQueueBufferRef buffers[kNumberOfPlayingAudioDataBuffers];
    SInt64 playbackStartPacket;
    BOOL changingFrameOffset;
}

- (OSStatus)prepareToPlay;
- (OSStatus)play;
- (OSStatus)stop;
- (OSStatus)pause;
- (OSStatus)resume;
- (void)forward:(UInt64)packets;
- (void)backward:(UInt64)packets;

@property(readwrite, nonatomic, assign) NSObject<AudioPlayerDelegate> *delegate;
@property(readonly, nonatomic) Float32 currentTime;
@property(readonly, nonatomic) UInt64 frameOffset;
@property (readonly, nonatomic, assign) UInt64 packetsCount;
@property (readwrite, nonatomic, assign) SInt64 packetOffset;
@property(readonly, nonatomic) AudioPlayerState state;

@end
