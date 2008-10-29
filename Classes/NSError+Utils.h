#import <UIKit/UIKit.h>

#ifdef DEBUG_LOG
#define LOG1(a) NSLog(a)
#define LOG2(a, b) NSLog(a, b)
#else
#define LOG2(a,b)
#define LOG1(a)
#endif

@interface NSError(Utils)

- (void)display:(NSString*)actionDescription;

@end
