#import "AsyncCallback.h"
#import "Callback.h"

@implementation AsyncCallback

#pragma mark properties

- (void) setDelegate:(id)delegate{
	if(isHandlerRetained) [handler release];
    handler = delegate;
	isHandlerRetained = NO;
}

-(id)observer{
	return isHandlerRetained ? handler : nil;
}


- (void) setObserver:(id)observer{
    [observer retain];
	if(isHandlerRetained) [handler release];
    handler = observer;
	isHandlerRetained = YES;
}

-(id)delegate{
	return isHandlerRetained ? nil : handler;
}

#pragma mark NSObject

-(id) initWithHandler: (id)_handler 
			  retained: (BOOL)_isHandlerRetained 
			 onSuccess: (SEL)_onSuccess 
			   onError: (SEL)_onError{
	self = [super init];
	if (self != nil) {
		isHandlerRetained = _isHandlerRetained;
		if(isHandlerRetained) self.observer = _handler;
		else self.delegate = _handler;
		onSuccessCb = [[Callback alloc] initWithHandler:_handler retained:_isHandlerRetained selector:_onSuccess];
		onErrorCb = [[Callback alloc] initWithHandler:_handler retained:_isHandlerRetained selector:_onError];
	}	
    
    return self;
}


- (void) dealloc{
	[onSuccessCb release];
	[onErrorCb release];
	if(isHandlerRetained) [handler release];
	[super dealloc];
}

#pragma mark public

+(AsyncCallback*) callbackWithHandler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError{
	return [[[[self class] alloc] initWithHandler:handler 
										 retained:isHandlerRetained 
										onSuccess:onSuccess 
										  onError:onError] autorelease];
}

+(AsyncCallback*) callbackWithDelegate: delegate onSuccess: (SEL)onSuccess onError: (SEL)onError{
	return [[[[self class] alloc] initWithHandler: delegate retained:NO onSuccess:onSuccess onError:onError] autorelease];
}

+(AsyncCallback*) callbackWithObserver: observer onSuccess: (SEL)onSuccess onError: (SEL)onError{
	return [[[[self class] alloc] initWithHandler: observer retained:YES onSuccess:onSuccess onError:onError] autorelease];
}

#pragma mark AsyncConnectionProtocol

-(void)asyncOperationStarted {}
-(void)asyncOperationCanceled {}

-(void)asyncOperationFinishedWithResult:	(id)result{
	[onSuccessCb callWith:result with:self];
}

-(void)asyncOperationFinishedWithError:		(NSError*)error{
	[onErrorCb callWith:error with:self];
}


@end

/////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AsyncCallbackChain

#pragma mark AsyncCallback

-(id) initWithChain:(AsyncCallback*)_chain handler:(id)_handler retained:(BOOL)_isHandlerRetained onSuccess:(SEL)_onSuccess onError:(SEL)_onError{
	self = [super initWithHandler:_handler retained:_isHandlerRetained onSuccess:_onSuccess onError:_onError];
	if (self != nil) {
		chain = [_chain retain];
	}
	return self;	
}

+(AsyncCallback*) callbackWithChain: (AsyncCallback*)chain handler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError{
	return [[[[self class] alloc] initWithChain:chain handler:handler retained:isHandlerRetained onSuccess:onSuccess onError:onError] autorelease];
}

- (void) dealloc{
	[chain release];
	[super dealloc];
}


#pragma mark public

- (void)passResult:(id)result{
	[chain asyncOperationFinishedWithResult:result];
	passed = YES;
}

- (void)passError:(NSError*)error{
	[chain asyncOperationFinishedWithError:error];
	passed = YES;
}

#pragma mark AsyncCallbackProtocol

-(void)asyncOperationStarted{
	[super asyncOperationStarted];
	[chain asyncOperationStarted];
}

-(void)asyncOperationCanceled{
	[super asyncOperationCanceled];
	[chain asyncOperationCanceled];
}

-(void)asyncOperationFinishedWithResult:	(id)result{
	passed = NO;
	[super asyncOperationFinishedWithResult:result];
	if(!passed) [chain asyncOperationFinishedWithResult:result];
	passed = NO;
}

-(void)asyncOperationFinishedWithError:		(NSError*)error{
	passed = NO;
	[super asyncOperationFinishedWithError:error];
	if(!passed) [chain asyncOperationFinishedWithError:error];
	passed = NO;
}

@end
