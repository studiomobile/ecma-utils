#import <UIKit/UIKit.h>

@interface NSMutableArray(Utils)

- (void)inplaceShuffle;
- (void)removeAllUsingSelector:(SEL)selector target:(id)target;

@end
