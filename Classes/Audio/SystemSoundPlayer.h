@interface SystemSoundPlayer : NSObject {
    NSMutableDictionary *soundIds;
}

+ (void)preloadSoundByFilename:(NSString*)name;
+ (void)playSoundByFilename:(NSString*)name vibrate:(BOOL)vibrate;
+ (void)reset;

+ (SystemSoundPlayer*)instance;

- (void)preloadSoundByFilename:(NSString*)name;
- (void)playSoundByFilename:(NSString*)name vibrate:(BOOL)vibrate;
- (void)reset;

@end
