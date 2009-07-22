#import <Foundation/Foundation.h>

@interface NSObject (Invocation)

+ (NSInvocation*)invocationForClassMethod:(SEL)selector;

- (NSInvocation*)invocationForMethod:(SEL)selector;

@end
