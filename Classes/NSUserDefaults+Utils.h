#import <UIKit/UIKit.h>

@interface NSUserDefaults(Utils)

+ (NSMutableArray*)loadArray:(NSString*)key;
+ (void)saveArray:(NSMutableArray*)array forKey:(NSString*)key;

@end


@interface NSObject(NSUserDefaults)

- (void)initDefaults;
- (void)initDefaults:(NSUserDefaults*)defaults;

@end
