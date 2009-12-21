#import "AsyncInvocation.h"
#import "AsyncCallbackProtocol.h"

@interface AsyncContext : NSObject{
	NSOperationQueue* queue;
}
	@property(readonly) NSOperationQueue* queue;
	+(AsyncContext*) asyncContext;
	+(AsyncContext*) defaultContext;
	+(AsyncContext*) contextNamed: (NSString*)name;
@end

// Factory for AsyncProxy
@interface AsyncObject : NSObject {
	id target;
	id delegate;
	id observer;
	SEL onSuccess;
	SEL onError;  
	NSString *contextName;	
}

@property (readonly) id target;
@property (assign) id delegate;
@property (retain) id observer;
@property (assign) SEL onSuccess;
@property (assign) SEL onError;

+ (AsyncObject*)asyncObjectForTarget:(id)target;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError;

- (id)initWithTarget:(id)target;

-(void)setContextNamed: (NSString*)name;

// proxy constructors
- (id)asyncProxy;
- (id)proxyWithCallback: (id<AsyncCallbackProtocol>)callback;
- (id)createAsyncProxy;
- (id)onSuccess: (SEL)_onSuccess onError: (SEL)_onError;

// internals
-(Class)defaultAsyncCallbackClass;
-(id<AsyncCallbackProtocol>) makeCallbackWithSuccess: (SEL) _onSuccess error: (SEL)_onError;

@end