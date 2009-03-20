#import "AsyncObject.h"

//===================
@interface AsyncProxy : NSObject {
	AsyncObject *async;
	NSOperationQueue *opQ;
}

- (id)initWithAsyncObject:(AsyncObject*)async;

@end

//=======================
@interface AsyncOperation : NSOperation {
	AsyncObject *async;
	NSInvocation *invocation;
	NSThread *clientThread;
}

- (id)initWithAsyncObject:(AsyncObject*)async invocation:(NSInvocation*)invocation;

@end

//=========================
@implementation AsyncObject

@synthesize target;
@synthesize delegate;
@synthesize observer;
@synthesize onSuccess;
@synthesize onError;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError {
	AsyncObject *async = [[[AsyncObject alloc] initWithTarget:target] autorelease];
	async.delegate = delegate;
	async.onSuccess = onSuccess;
	async.onError = onError;
	return async;
}


+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError {
	AsyncObject *async = [[[AsyncObject alloc] initWithTarget:target] autorelease];
	async.observer = observer;
	async.onSuccess = onSuccess;
	async.onError = onError;
	return async;
}


- (id)initWithTarget:(id)_target {
	if(self = [super init]) {
		target = [_target retain];
	}
	return self;
}


- (id)copyWithZone:(NSZone*)zone {
	AsyncObject *copy = [[self.class allocWithZone:zone] initWithTarget:self.target];
	copy.delegate = self.delegate;
	copy.observer = self.observer;
	copy.onSuccess = self.onSuccess;
	copy.onError = self.onError;
	return copy;
}


- (id)createAsyncProxy {
	return [[AsyncProxy alloc] initWithAsyncObject:self];
}


- (void)invocationCompletedWithResult:(id)result {}


- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread {
	[invocation setTarget:target];
	if(![invocation argumentsRetained]) {
		[invocation retainArguments];
	}

	id result = nil;
	[invocation invoke];
	[invocation getReturnValue:&result];
	[self invocationCompletedWithResult:result];
	
	id handler = delegate ? delegate : observer;
	if([result isKindOfClass:[NSError class]]) {
		[handler performSelector:onError onThread:clientThread withObject:result waitUntilDone:YES];
	} else {
		[handler performSelector:onSuccess onThread:clientThread withObject:result waitUntilDone:YES];
	}
}


- (void)dealloc {
	[target release];
	[observer release];
	[super dealloc];
}

@end

//========================
@implementation AsyncProxy


- (id)initWithAsyncObject:(AsyncObject*)_async {
	if (self = [super init]) {
		async = [_async copy];
		opQ = [NSOperationQueue new];
	}
	return self;
}


- (void)forwardInvocation:(NSInvocation*)invocation {
	[opQ addOperation:[[[AsyncOperation alloc] initWithAsyncObject:async invocation:invocation] autorelease]];
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	return [async.target methodSignatureForSelector:selector]; 
}


- (void)dealloc {
	[async release];
	[opQ release];
	[super dealloc];
}


@end


@implementation AsyncOperation

- (id)initWithAsyncObject:(AsyncObject*)_async invocation:(NSInvocation*)_invocation {
	if (self = [super init]) {
		async = [_async copy];
		invocation = [_invocation retain];
		clientThread = [NSThread currentThread];
	}
	return self;
}


- (void)main {
	[async invokeInvocation:invocation fromThread:clientThread];
}


- (void)dealloc {
	[async release];
	[invocation release];
	[super dealloc];
}

@end
