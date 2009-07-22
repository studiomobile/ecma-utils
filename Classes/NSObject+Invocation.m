#import "NSObject+Invocation.h"

@implementation NSObject (Invocation)

+ (NSInvocation*)invocationForClassMethod:(SEL)selector {
	NSMethodSignature *signature = [[self class] methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.target = [self class];
	invocation.selector = selector;
	return invocation;
}


- (NSInvocation*)invocationForMethod:(SEL)selector {
	NSMethodSignature *signature = [self methodSignatureForSelector:selector];
	NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
	invocation.target = self;
	invocation.selector = selector;
	return invocation;
}

@end
