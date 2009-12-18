#import "UIBlockingAsyncObject.h"
#import "UIBlockingView.h"
#import "NSObject+Utils.h"
#import "BlockingAsyncCallback.h"

// this class is for backward compatibiliy
@interface CompositeBlockingView : NSObject<UIBlockingView>{
	NSArray* blockers;
}

+(CompositeBlockingView*) compositeBlockingViewWithBlockers: (NSArray*)blockers;

@end

@implementation CompositeBlockingView

#pragma mark private

-(void)performWithEachBlocker: (SEL)selector{
	[blockers makeObjectsPerformSelector: selector];
}

#pragma mark NSObject

- (id) initWithBlockers: (NSArray*)_blockers {
	self = [super init];
	if (self != nil) {
		blockers = [_blockers retain];
	}
	return self;
}

+(CompositeBlockingView*) compositeBlockingViewWithBlockers: (NSArray*)blockers{
	return [[[CompositeBlockingView alloc] initWithBlockers: blockers] autorelease];	 
}

- (void) dealloc{
	[blockers release];
	[super dealloc];
}
#pragma mark UIBlockingView

- (void)blockUI{
	[self performWithEachBlocker: @selector(blockUI)];
}

- (void)unblockUI{
	[self performWithEachBlocker: @selector(unblockUI)];
}

- (void)showIndicator{
	[self performWithEachBlocker: @selector(showIndicator)];
}
@end

// ================================================

@implementation UIBlockingAsyncObject

@synthesize blocker;
@synthesize indicatorDelay;

#pragma mark protected

-(Class)defaultAsyncCallbackClass{
	return [BlockingAsyncCallback class];
}

-(id<AsyncCallbackProtocol>)makeCallback{
	BlockingAsyncCallback* cb = (BlockingAsyncCallback*)[super makeCallback];
	cb.blocker = blocker;
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

// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target] autorelease];
	async.delegate = delegate;
	async.onSuccess = onSuccess;
	async.onError = onError;
	async.blockViews = blockViews;
	return async;
}

// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews {
	UIBlockingAsyncObject *async = [[[UIBlockingAsyncObject alloc] initWithTarget:target] autorelease];
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
