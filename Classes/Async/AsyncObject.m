#import "AsyncObject.h"
#import "NSInvocation+Utils.h"

static const int MAX_CONCURRENT_OPERATION_COUNT = 10;


@interface AsyncInvocationImpl : NSObject<AsyncInvocation>{
	NSOperation* op;
}
@end

@implementation AsyncInvocationImpl
- (id) initWithOperation: (NSOperation*)_op{
	self = [super init];
	if (self != nil) {
		op = [_op retain];
	}
	return self;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op{
	return [[[AsyncInvocationImpl alloc] initWithOperation: op] autorelease];
}

- (void) dealloc{
	[op release];
	[super dealloc];
}

-(void)cancel{
	[op cancel];
}


@end

//===================
@interface AsyncProxy : NSObject {
	AsyncObject *async;
}

@property(retain) NSOperation* lastOperation;

- (id)initWithAsyncObject:(AsyncObject*)async;

@end

//=======================
@interface AsyncOperation : NSOperation {
	AsyncObject *async;
	NSInvocation *invocation;
	NSThread *clientThread;
}

- (id)initWithAsyncObject:(AsyncObject*)async invocation:(NSInvocation*)invocation clientThread:(NSThread*)thread;

@end

//=========================
@implementation AsyncObject

@synthesize target;
@synthesize delegate;
@synthesize observer;
@synthesize onSuccess;
@synthesize onError;
@synthesize context;

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


+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate {
	return [AsyncObject asyncObjectForTarget:target delegate:delegate onSuccess:nil onError:nil];
}


+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer {
	return [AsyncObject asyncObjectForTarget:target observer:observer onSuccess:nil onError:nil];
}


- (id)initWithTarget:(id)_target {
    if (![super init]) return nil;
    target = [_target retain];
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

-(id) onSuccess: (SEL)_onSuccess onError: (SEL)_onError{
	AsyncObject* copy = [self copy];
	copy.onSuccess = _onSuccess;
	copy.onError = _onError;
	return [copy asyncProxy];
}


- (id)asyncProxy {
	return [[self createAsyncProxy] autorelease];
}


- (id)createAsyncProxy {
	return [[AsyncProxy alloc] initWithAsyncObject:self];
}


- (void)invocationCompletedWithResult:(id)result {}


- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread {
	[invocation setTarget:target];

	id result = nil;
	@try {
		[invocation invoke];
		[invocation getReturnValue:&result];
	}
	@catch (NSError * e) {
		result = e;
	}
	@catch (NSException * e) {
		NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:[e userInfo]];
		[dict setObject:[e reason] forKey:NSLocalizedFailureReasonErrorKey];
		NSError* err = [NSError errorWithDomain:[e name] code:0 userInfo:[dict copy]];
		result = err;		
	}	
	
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

@synthesize lastOperation;

-(id<AsyncInvocation>)lastInvocation{
	return (id<AsyncInvocation>)lastOperation;	
}

-(NSOperationQueue*)defaultQueue{
	static NSOperationQueue* defaultQueue;
	if(!defaultQueue){
		defaultQueue = [NSOperationQueue new];
		[defaultQueue setMaxConcurrentOperationCount: MAX_CONCURRENT_OPERATION_COUNT];
	}
	return defaultQueue;
}

-(NSMutableDictionary*) operationQueues{
	static NSMutableDictionary* queues;
	if(!queues){
		queues = [NSMutableDictionary new];
	}
	
	return queues;
}

-(NSOperationQueue*)myOperationQueue{
	if(!async.context)
		return self.defaultQueue;
	
	NSOperationQueue* myQueue = [self.operationQueues objectForKey: async.context];
	if(!myQueue){
		myQueue = [[NSOperationQueue new] autorelease];
		[myQueue setMaxConcurrentOperationCount:10];
		[self.operationQueues setObject: myQueue forKey:async.context];
	}
	
	return myQueue;
}

- (id)initWithAsyncObject:(AsyncObject*)_async {
    if (![super init]) return nil;
    async = [_async retain];
    return self;
}

-(void)checkThread{
	NSUInteger currentThreadHash = [[NSThread currentThread] hash];	
	if(myThreadHash != 0){
		NSAssert(myThreadHash == currentThreadHash, @"AsyncProxy should not be used from several threads");
	}else {
		myThreadHash = currentThreadHash;
	}	
}


- (void)forwardInvocation:(NSInvocation*)invocation {
	[self checkThread];	
	
	if(![invocation argumentsRetained]) {
		[invocation retainArguments];
	}
	
	NSOperationQueue* opQ = self.myOperationQueue;	
	AsyncOperation* op = [[[AsyncOperation alloc] initWithAsyncObject:async 
														   invocation:[invocation copy]
														 clientThread:[NSThread currentThread]] autorelease];
	[opQ addOperation: op];
	
	[invocation setReturnValue: &op];
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature* sig = [async.target methodSignatureForSelector:selector];
	return sig;
}

- (void)dealloc {
	[lastOperation release];
	[async release];
	[super dealloc];
}

@end

//============================
@implementation AsyncOperation

- (id)initWithAsyncObject:(AsyncObject*)_async invocation:(NSInvocation*)_invocation clientThread:(NSThread*)thread {
	if (self = [super init]) {
		async = [_async copy];
		invocation = [_invocation retain];
		clientThread = [thread retain];
	}
	return self;
}


- (void)main {
    if (![self isCancelled]) {
        [async invokeInvocation:invocation fromThread:clientThread];
    }
}


- (void)dealloc {
	[async release];
	[invocation release];
    [clientThread release];
	[super dealloc];
}

@end
