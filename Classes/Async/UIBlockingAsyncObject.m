#import "UIBlockingAsyncObject.h"
#import "UIBlockingView.h"

@implementation UIBlockingAsyncObject

@synthesize blockViews;
@synthesize indicatorDelay;

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target] autorelease];
	async.delegate = delegate;
	async.onSuccess = onSuccess;
	async.onError = onError;
	async.blockViews = blockViews;
	return async;
}


+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target] autorelease];
	async.observer = observer;
	async.onSuccess = onSuccess;
	async.onError = onError;
	async.blockViews = blockViews;
	return async;
}


- (id)copyWithZone:(NSZone*)zone {
	UIBlockingAsyncObject *copy = [super copyWithZone:zone];
	copy.blockViews = self.blockViews;
	return copy;
}


- (void)forAllViewsPerformSelector:(SEL)selector {
	for (NSObject<UIBlockingView> *view in blockViews) {
		[view performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
	}
}


- (void)showIndicator {
	[self forAllViewsPerformSelector:@selector(showIndicator)];
}


- (void)invocationCompletedWithResult:(id)result {
	[indicatorTimer invalidate];
	indicatorTimer = nil;
}


- (void)invokeInvocation:(NSInvocation*)invocation fromThread:(NSThread*)clientThread {
	[self forAllViewsPerformSelector:@selector(blockUI)];

	if (indicatorDelay > 0) {
		indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:indicatorDelay target:self selector:@selector(showIndicator) userInfo:nil repeats:NO];
	} else {
		[self showIndicator];
	}
	
	[super invokeInvocation:invocation fromThread:clientThread];

	[self forAllViewsPerformSelector:@selector(unblockUI)];
}


- (void)dealloc {
	[blockViews release];
	[super dealloc];
}

@end
