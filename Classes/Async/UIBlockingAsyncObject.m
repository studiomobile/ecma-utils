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

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate blocker: (id<UIBlockingView>)blocker{
	return [self uiBlockingAsyncObjectForTarget:target 
									   delegate:delegate 
									  onSuccess:nil
										onError:nil
									 blockViews:[NSArray arrayWithObject: blocker]];
}

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer blocker: (id<UIBlockingView>)blocker{
	return [self uiBlockingAsyncObjectForTarget:target 
									   observer:observer 
									  onSuccess:nil
										onError:nil
									 blockViews:[NSArray arrayWithObject: blocker]];	
}


-(id<UIBlockingView>)blocker{
	if(!blockViews || blockViews.count == 0) return nil;
	return [blockViews objectAtIndex: 0];
}


-(void)setBlocker: (id<UIBlockingView>)blocker{
	if(!blockViews) self.blockViews = [NSArray array];

	if(![blockViews containsObject: blocker]){
		self.blockViews = [self.blockViews arrayByAddingObject: blocker];
	}
}



- (id)copyWithZone:(NSZone*)zone {
	UIBlockingAsyncObject *copy = [super copyWithZone:zone];
	copy.blockViews = self.blockViews;
	copy.indicatorDelay = self.indicatorDelay;
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
