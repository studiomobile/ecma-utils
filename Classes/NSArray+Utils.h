#import <Foundation/Foundation.h>

@interface NSArray(Randomization) 

- (NSString*)joinWith:(NSString*)d selector:(SEL)s;
- (NSString*)joinWith:(NSString*)d;

- (NSArray*)shuffle;

- (NSArray*)filterUsingSelector:(SEL)selector target:(id)target;


@end


@interface NSArray (Utils)


- (id)detect: (NSPredicate*)predicate;
- (NSArray *)select: (NSPredicate*)predicate;
- (NSArray *)reject: (NSPredicate*)predicate;
- (NSArray *)collect: (NSString*)keyPath;
- (NSArray *)take:(NSUInteger)count;
- (NSArray *)splitUsingSelector:(SEL)selector;

@end



