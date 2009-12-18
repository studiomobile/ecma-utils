#import "AsyncObject.h"
#import "NSInvocation+Utils.h"
#import "AsyncCallback.h"

@interface AsyncInvocationImpl : NSObject<AsyncInvocation>{
	NSOperation* op;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op;

@end

//===================
@interface AsyncProxy : NSObject<NSCopying> {	
	id target;	
	id<AsyncCallbackProtocol> callback;	
	AsyncContext* context;
	volatile BOOL isCanceled;
}

@property (readonly) id target;
@property (readonly) id<AsyncCallbackProtocol> callback;
@property (readonly) AsyncContext* context;

- (id)initWithTarget: (id)target 
			callback: (id<AsyncCallbackProtocol>)_callback 
			 context: (AsyncContext*)_context;

- (void)cancel;

@end

//=======================
@interface AsyncOperation : NSOperation {
	AsyncProxy *proxy;
	NSInvocation *invocation;
	NSThread *clientThread;
}

- (id)initWithAsyncProxy:(AsyncProxy*)proxy invocation:(NSInvocation*)invocation clientThread:(NSThread*)thread;

@end

//=======================
@interface AsyncObject ()

@property(retain, nonatomic) NSString* contextName;
@property(readonly) AsyncContext* context;

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

-(id<AsyncCallbackProtocol>) makeCallbackWithSuccess: (SEL) _onSuccess error: (SEL)_onError{
	id handler;
	BOOL isHandlerRetained;
	if(delegate){
		handler = delegate;
		isHandlerRetained = NO;
	}else {
		handler = observer;
		isHandlerRetained = YES;
	}
	
	return [[[[self defaultAsyncCallbackClass] alloc] initWithHandler: handler
															 retained: isHandlerRetained 
															onSuccess: _onSuccess 
															  onError: _onError] autorelease];
}

#pragma mark proctected

-(Class)defaultAsyncCallbackClass{
	return [AsyncCallback class];
}

-(id<AsyncCallbackProtocol>) makeCallback{
	return [self makeCallbackWithSuccess:onSuccess error:onError];	 
}

#pragma mark NSObject


- (id)initWithTarget:(id)_target {
    if (![super init]) return nil;
    target = [_target retain];
	return self;
}

- (void)dealloc {
	[contextName release];
	[target release];
	[observer release];
	[super dealloc];
}

#pragma mark properties

-(AsyncContext*)context{
	if(!contextName) return nil;
	return [AsyncContext contextNamed: contextName];
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

+ (AsyncObject*)asyncObjectForTarget:(id)target {
	return [AsyncObject asyncObjectForTarget:target delegate:nil onSuccess:nil onError:nil];
}


-(void)setContextNamed: (NSString*)name{
	self.contextName = name;
}

#pragma mark proxy creation

- (id)createAsyncProxy {
	return [[AsyncProxy alloc] initWithTarget:target callback: [self makeCallback] context: self.context];
}

- (id)asyncProxy {
	return [[self createAsyncProxy] autorelease];
}

- (id)proxyWithCallback: (id<AsyncCallbackProtocol>)callback{
	return [[[AsyncProxy alloc] initWithTarget:target callback: callback context: self.context] autorelease];
}

-(id) onSuccess: (SEL)_onSuccess onError: (SEL)_onError{		
	id<AsyncCallbackProtocol> callback = [self makeCallbackWithSuccess:_onSuccess error: _onError];	
	return [self proxyWithCallback: callback];
}

@end


//========================
@implementation AsyncProxy

@synthesize target;
@synthesize context;
@synthesize callback;

#pragma mark private

-(NSOperationQueue*)myOperationQueue{
	if(!self.context)
		return [AsyncContext defaultContext].queue;

	return context.queue;
}

- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread {
	
	if(isCanceled){
		[callback asyncOperationCanceled];
		return;
	}else {
		[callback asyncOperationStarted];
	}

	id result = nil;	
	[invocation setTarget:target];			
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
	
	if(isCanceled){
		[callback asyncOperationCanceled];
		return;
	}
	
	[self performSelector:@selector(asyncInvocationCompleted:) onThread:clientThread withObject:result waitUntilDone:NO];
}

- (void)asyncInvocationCompleted:(id)result {
	if(isCanceled){
		[callback asyncOperationCanceled];
		return;
	}
	
	if([result isKindOfClass:[NSError class]]) 	[callback asyncOperationFinishedWithError: result];
	else [callback asyncOperationFinishedWithResult: result];	
}


- (void)forwardInvocation:(NSInvocation*)invocation {
	
	if(![invocation argumentsRetained]) {
		[invocation retainArguments];
	}
	
	NSOperationQueue* opQ = self.myOperationQueue;	
	AsyncOperation* op = [[[AsyncOperation alloc] initWithAsyncProxy:self 
														  invocation:[invocation copy]
														clientThread:[NSThread currentThread]] autorelease];
	[opQ addOperation: op];	
	AsyncInvocationImpl* invocationInterface = [AsyncInvocationImpl asyncInvocationWithOperation:op];
	[invocation setReturnValue: &invocationInterface];
}


- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector {
	NSMethodSignature* sig = [target methodSignatureForSelector:selector];
	return sig;
}

#pragma mark NSObject

- (id) init{
	self = [super init];
	if (self != nil) {
		isCanceled = NO;
	}
	return self;
}

- (id)initWithTarget: (id)_target 
			callback: (id<AsyncCallbackProtocol>)_callback 
			 context: (AsyncContext*)_context{
	self = [self init];
	if (self != nil) {
		target = [_target retain];
		callback = [_callback retain];
		context = [_context retain];
	}
	return self;
}

- (id)initWithAsyncProxy:(AsyncProxy*)other {
	self = [self init];
	if(self != nil){
		target = [other.target retain];
		callback = [other.callback retain];
		context = [other.context retain];
	}
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
	AsyncObject *copy = [[self.class allocWithZone:zone] initWithAsyncProxy: self];
	return copy;
}

- (void)dealloc {
	[target release];
	[callback release];	
	[context release];

	[super dealloc];
}

#pragma mark public

-(void)cancel{
	isCanceled = YES;
}


@end

//============================
@implementation AsyncOperation

- (id)initWithAsyncProxy:(AsyncProxy*)_proxy invocation:(NSInvocation*)_invocation clientThread:(NSThread*)thread {
	if (self = [super init]) {
		proxy = [_proxy copy];
		invocation = [_invocation retain];
		clientThread = [thread retain];
	}
	return self;
}

-(void)cancel{
	[super cancel];
	[proxy cancel];	
}


- (void)main {
    if (![self isCancelled]) {
        [proxy invokeInvocation:invocation fromThread:clientThread];
    }
}


- (void)dealloc {
	[proxy release];
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

// ============================================

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
