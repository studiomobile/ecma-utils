#import "AsyncObject.h"
#import "NSInvocation+Utils.h"

//===================
@interface AsyncInvocationImpl : NSObject<AsyncInvocation>{
	NSOperation* op;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op;

@end

//===================
@interface AsyncProxy : NSObject {
	AsyncObject *async;
}

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

//=======================
@interface AsyncObject ()

@property(retain, nonatomic) NSString* contextName;

-(void)cancel;

@end


//=========================
@implementation AsyncObject

@synthesize target;
@synthesize delegate;
@synthesize observer;
@synthesize onSuccess;
@synthesize onError;
@synthesize contextName;


#pragma mark private

- (void)invocationCompletedWithResult:(id)result {}


- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread {
	if(isCanceled) return;
		
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
	
	if(isCanceled) return;	
	
	[self performSelector:@selector(asyncInvocationCompleted:) onThread:clientThread withObject:result waitUntilDone:NO];
}


- (void)asyncInvocationCompleted:(id)result {
	if (!isCanceled) {
		id handler = delegate ? delegate : observer;
		if([result isKindOfClass:[NSError class]]) {
			[handler performSelector:onError withObject:result];
		} else {
			[handler performSelector:onSuccess withObject:result];
		}		
	}
}

#pragma mark properties

-(AsyncContext*)context{
	if(!contextName) return nil;
	return [AsyncContext contextNamed: contextName];
}

#pragma mark NSObject


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

- (void)dealloc {
	[target release];
	[observer release];
	[super dealloc];
}

#pragma mark public

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


-(void)cancel{
	isCanceled = YES;
}

-(void)setContextNamed: (NSString*)name{
	self.contextName = name;
}

- (id)asyncProxy {
	return [[self createAsyncProxy] autorelease];
}


- (id)createAsyncProxy {
	return [[AsyncProxy alloc] initWithAsyncObject:self];
}

-(id) onSuccess: (SEL)_onSuccess onError: (SEL)_onError{
	AsyncObject* copy = [self copy];
	copy.onSuccess = _onSuccess;
	copy.onError = _onError;
	return [copy asyncProxy];
}


@end


//========================
@implementation AsyncProxy

-(NSOperationQueue*)myOperationQueue{
	if(!async.context)
		return [AsyncContext defaultContext].queue;

	return async.context.queue;
}

- (id)initWithAsyncObject:(AsyncObject*)_async {
    if (![super init]) return nil;
    async = [_async retain];
    return self;
}


- (void)forwardInvocation:(NSInvocation*)invocation {

	if(![invocation argumentsRetained]) {
		[invocation retainArguments];
	}
	
	NSOperationQueue* opQ = self.myOperationQueue;	
	AsyncOperation* op = [[[AsyncOperation alloc] initWithAsyncObject:async 
														   invocation:[invocation copy]
														 clientThread:[NSThread currentThread]] autorelease];
	[opQ addOperation: op];	
	AsyncInvocationImpl* invocationInterface = [AsyncInvocationImpl asyncInvocationWithOperation:op];
	[invocation setReturnValue: &invocationInterface];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature* sig = [async.target methodSignatureForSelector:selector];
	return sig;
}

- (void)dealloc {
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

-(void)cancel{
	[super cancel];
	[async cancel];	
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


//============================
@implementation AsyncContext
@synthesize queue;

+(AsyncContext*) asyncContext{
	return [[self new] autorelease];
}

+(AsyncContext*) defaultContext{
	static AsyncContext* defaultContext;
	if(!defaultContext){
		defaultContext = [AsyncContext new];
	}
	
	return defaultContext;
}

+(AsyncContext*) contextNamed: (NSString*)name{
	if(!name) return nil;

	static NSMutableDictionary* contexts;
	if(!contexts){
		contexts = [NSMutableDictionary new];
	}
	
	AsyncContext* context = [contexts objectForKey: name];	
	if(!context){
		context = [self asyncContext];		
		[contexts setObject: context forKey:name];
	}
	
	return context;	
}

- (id) init{
	self = [super init];
	if (self != nil) {
		queue = [NSOperationQueue new];
		[queue setMaxConcurrentOperationCount: 10];
	}
	return self;
}


- (void) dealloc{
	[queue release];
	[super dealloc];
}

@end

//============================

@implementation AsyncInvocationImpl
- (id) initWithOperation: (NSOperation*)_op{
	 self = [super init];
	 if (self != nil) {
	    op = [_op retain];
	 }
	 return self;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op {
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

