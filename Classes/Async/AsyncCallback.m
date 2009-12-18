#import "AsyncCallback.h"

@implementation AsyncCallback
@synthesize onSuccess;
@synthesize onError;

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
		if(isHandlerRetained) self.observer = _handler;
		else self.delegate = _handler;
		self.onSuccess = _onSuccess;
		self.onError = _onError;		
	}	
    
    return self;
}

+(AsyncCallback*) callbackWithHandler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError{
	return [[[[self class] alloc] initWithHandler: handler 
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

- (void) dealloc{
	if(isHandlerRetained) [handler release];
	[super dealloc];
}


#pragma mark AsyncConnectionProtocol

-(void)asyncOperationStarted {}
-(void)asyncOperationCanceled {}

-(void)asyncOperationFinishedWithResult:	(id)result{
	if(onSuccess)	[handler performSelector:onSuccess withObject: result];
}

-(void)asyncOperationFinishedWithError:		(NSError*)error{
	if(onError)	[handler performSelector:onError withObject: error];
}


@end

