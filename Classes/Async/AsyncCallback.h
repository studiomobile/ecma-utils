#import "UIBlockingView.h"
#import "AsyncCallbackProtocol.h"

@interface AsyncCallback : NSObject<AsyncCallbackProtocol> {    
    id handler;
	BOOL isHandlerRetained;
    SEL onSuccess;
    SEL onError;
	
}

@property(assign) id delegate;
@property(retain) id observer;
@property(assign) SEL onSuccess;
@property(assign) SEL onError;

-(id) initWithHandler: (id)_handler retained: (BOOL)_isHandlerRetained onSuccess: (SEL)_onSuccess onError: (SEL)_onError;
+(AsyncCallback*) asyncCallbackWithHandler: handler retained: (BOOL)isHandlerRetained onSuccess: (SEL)onSuccess onError: (SEL)onError;
// just shortcuts to previous constructor
+(AsyncCallback*) asyncCallbackWithDelegate: delegate onSuccess: (SEL)onSuccess onError: (SEL)onError;
+(AsyncCallback*) asyncCallbackWithObserver: observer onSuccess: (SEL)onSuccess onError: (SEL)onError;

@end
