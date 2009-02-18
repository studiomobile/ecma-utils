#import <UIKit/UIKit.h>

@interface NSArray(Randomization) 

- (NSString*)joinWith:(NSString*)d selector:(SEL)s;
- (NSString*)joinWith:(NSString*)d;

- (NSArray*)shuffle;

- (NSArray*)filterUsingSelector:(SEL)selector target:(id)target;

@end