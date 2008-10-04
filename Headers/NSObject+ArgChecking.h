#import <UIKit/UIKit.h>


@interface NSObject(ArgChecking) 

+ (void)notNull:(id)value message:(NSString*)format, ...;
+ (void)state:(BOOL)result message:(NSString*)format, ...;
+ (void)argument:(BOOL)result message:(NSString*)format, ...;

@end

typedef NSObject DebugCheck;
