#import "AsyncObject.h"

@interface InvokeAsyncMethod : NSOperation {
	id handlerTarget;
	SEL successHandler, errorHandler;
	NSInvocation *invocation;
	NSThread *clientThread;
}

+ (id)using:(NSInvocation*)i ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target;
@end

@implementation InvokeAsyncMethod

- (id)initWithInvocation:(NSInvocation*)i ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target{
	if(self = [super init]) {
		handlerTarget = [target retain];
		invocation = [i retain];
		clientThread = [NSThread currentThread];
		errorHandler = errorSelector;
		successHandler = successSelector;
	}
	return self;
}

+ (id)using:(NSInvocation*)i ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target {
	return [[[InvokeAsyncMethod alloc] initWithInvocation:i ifSuccess:successSelector ifError:errorSelector target:target] autorelease];
}

- (void)main {
//	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[invocation invoke];
	id result = nil;
	[invocation getReturnValue:&result];
	if([result isKindOfClass:[NSError class]]) {
		[handlerTarget performSelector:errorHandler onThread:clientThread withObject:result waitUntilDone:YES];
	} else {
		[handlerTarget performSelector:successHandler onThread:clientThread withObject:result waitUntilDone:YES];
	}
//	[pool release];
}

- (void)dealloc {
	[handlerTarget release];
	[invocation release];
	[super dealloc];
}

@end


@implementation AsyncObject

- (id)initWithImpl:(id)impl {
	if(self = [super init]) {
		opTarget = [impl retain];
		queue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)dealloc {
	[opTarget release];
	[queue release];
	[handlerTarget release];
	handlerTarget = nil;
	[super dealloc];
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target {
	successHandler = successSelector;
	errorHandler = errorSelector;
	handlerTarget = [target retain];
	return self;
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
	[anInvocation setTarget:opTarget];
	if(![anInvocation argumentsRetained]) {
		[anInvocation retainArguments];
	}
	InvokeAsyncMethod *op = [InvokeAsyncMethod using:anInvocation ifSuccess:successHandler ifError:errorHandler target:handlerTarget];
	[queue addOperation:op];
	//[anInvocation setReturnValue:<some result proxy here>]; //then somebody tries to access result proxy stop thread until real result is not ready
	[handlerTarget release];
	handlerTarget = nil;
	successHandler = nil;
	errorHandler = nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
	return [opTarget methodSignatureForSelector:aSelector]; 
}

@end
