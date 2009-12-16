#import <UIKit/UIKit.h>

#import "AsyncInvocation.h"

@interface AsyncContext : NSObject{
	NSOperationQueue* queue;
}
	@property(readonly) NSOperationQueue* queue;
	+(AsyncContext*) asyncContext;
	+(AsyncContext*) defaultContext;
	+(AsyncContext*) contextNamed: (NSString*)name;
@end

@interface AsyncObject : NSObject<NSCopying> {
	id target;
	id delegate;
	id observer;
	SEL onSuccess;
	SEL onError;
	NSString *contextName;
	volatile BOOL isCanceled;
}
@property (readonly) id target;
@property (assign) id delegate;
@property (retain) id observer;
@property (assign) SEL onSuccess;
@property (assign) SEL onError;
@property (readonly) AsyncContext* context;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError;

- (id)initWithTarget:(id)target;

-(void)setContextNamed: (NSString*)name;

- (id)asyncProxy;
- (id)createAsyncProxy;
- (id)onSuccess: (SEL)_onSuccess onError: (SEL)_onError;

// This method is invoked asyncronously from background thread, don't call it directly
- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread;

@end
