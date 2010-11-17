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
	BOOL isTargetRetained;
}

@property (readonly) id target;
@property (assign) id delegate;
@property (retain) id observer;
@property (assign) SEL onSuccess;
@property (assign) SEL onError;

#pragma mark public

+ (AsyncObject*)asyncObjectForTarget:(id)target;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError;

// designated initializer
- (id)initWithTarget:(id)target retainTarget:(BOOL)retainTarget;
- (id)initWithTarget:(id)target; // retain = YES

- (void)dontRetainTarget;

- (void)setContextNamed: (NSString*)name;

// proxy construction
- (id)asyncProxy;
- (id)proxyWithCallback: (id<AsyncCallbackProtocol>)callback;
- (id)newAsyncProxy;
- (id)onSuccess: (SEL)_onSuccess onError: (SEL)_onError;

#pragma mark protected
-(Class)defaultAsyncCallbackClass;
-(id<AsyncCallbackProtocol>) makeCallbackWithSuccess:(SEL)_onSuccess error:(SEL)_onError;

@end