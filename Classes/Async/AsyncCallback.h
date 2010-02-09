#import "AsyncCallbackProtocol.h"

@class Callback;

@interface AsyncCallback : NSObject<AsyncCallbackProtocol> {    
    id handler;
	BOOL isHandlerRetained;
	
	Callback *onSuccessCb;
	Callback *onErrorCb;
}

@property(assign) id delegate;
@property(retain) id observer;

-(id) initWithHandler: (id)_handler retained: (BOOL)_isHandlerRetained onSuccess: (SEL)_onSuccess onError: (SEL)_onError;
+(AsyncCallback*) callbackWithHandler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError;
// just shortcuts to previous constructor
+(AsyncCallback*) callbackWithDelegate: delegate onSuccess: (SEL)onSuccess onError: (SEL)onError;
+(AsyncCallback*) callbackWithObserver: observer onSuccess: (SEL)onSuccess onError: (SEL)onError;

@end

/////////////////////////////////////////////////////////////////////////////////////////////////

@interface AsyncCallbackChain : AsyncCallback{
	AsyncCallback *chain;
	
	BOOL passed;
}

-(id) initWithChain:(AsyncCallback*)_chain handler:(id)_handler retained:(BOOL)_isHandlerRetained onSuccess:(SEL)_onSuccess onError:(SEL)_onError;
+(AsyncCallbackChain*) callbackWithChain: (AsyncCallback*)chain handler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError;

- (void)passResult:(id)result;
- (void)passError:(NSError*)error;

@end



