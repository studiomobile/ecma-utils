#import "UIBlockingAsyncObject.h"
#import "UIBlockingView.h"
#import "NSObject+Utils.h"
#import "BlockingAsyncCallback.h"
#import "CompositeBlockingView.h"

@implementation UIBlockingAsyncObject

@synthesize blocker;
@synthesize indicatorDelay;

#pragma mark protected

-(Class)defaultAsyncCallbackClass{
	return [BlockingAsyncCallback class];
}

-(id<AsyncCallbackProtocol>) makeCallbackWithSuccess: (SEL) _onSuccess error: (SEL)_onError{
	BlockingAsyncCallback* cb = (BlockingAsyncCallback*)[super makeCallbackWithSuccess:_onSuccess error:_onError];
	cb.blocker = blocker;
	cb.indicatorDelay = indicatorDelay;
	return cb;
}


// for backward compatibility
- (void) setBlockViews:(NSArray*)blockers{
	CompositeBlockingView* composite = [CompositeBlockingView compositeBlockingViewWithBlockers: blockers];
	[composite retain];
    [blocker release];
    blocker = composite;
}

// for backward compatibility
-(NSArray*)blockViews{
	return [NSArray arrayWithObject: blocker];
}

#pragma mark NSObject

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate blocker: (id<UIBlockingView>)blocker{
	NSArray *blockers = blocker ? [NSArray arrayWithObject:blocker] : nil;
	return [self uiBlockingAsyncObjectForTarget:target 
									   delegate:delegate 
									  onSuccess:nil
										onError:nil
									 blockViews:blockers];
}

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer blocker: (id<UIBlockingView>)blocker{
	NSArray *blockers = blocker ? [NSArray arrayWithObject:blocker] : nil;
	return [self uiBlockingAsyncObjectForTarget:target 
									   observer:observer 
									  onSuccess:nil
										onError:nil
									 blockViews:blockers];	
}

// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target retainTarget:YES] autorelease];
	async.delegate = delegate;
	async.onSuccess = onSuccess;
	async.onError = onError;
	async.blockViews = blockViews;
	return async;
}

// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target retainTarget:YES] autorelease];
	async.observer = observer;
	async.onSuccess = onSuccess;
	async.onError = onError;
	async.blockViews = blockViews;
	return async;
}


- (void)dealloc {
	[blocker release];
	[super dealloc];
}

@end
