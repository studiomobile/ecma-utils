#import <UIKit/UIKit.h>

@interface NSArray(Randomization) 

- (NSArray*)shuffle;

- (NSArray*)filterUsingSelector:(SEL)selector target:(id)target;

@end