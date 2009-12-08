#import <UIKit/UIKit.h>

@protocol AsyncInvocation

-(void)cancel;

@end


@interface AsyncObject : NSObject<NSCopying> {
	id target;
	id delegate;
	id observer;
	SEL onSuccess;
	SEL onError;
	NSString *context;
}
@property (readonly) id target;
@property (assign) id delegate;
@property (retain) id observer;
@property (assign) SEL onSuccess;
@property (assign) SEL onError;
@property (readwrite, nonatomic, retain) NSString *context;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer;

+ (AsyncObject*)asyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError;
+ (AsyncObject*)asyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError;

- (id)initWithTarget:(id)target;

- (id)asyncProxy;
- (id)createAsyncProxy;

// This method is invoked asyncronously from background thread, don't call it directly
- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread;

@end
