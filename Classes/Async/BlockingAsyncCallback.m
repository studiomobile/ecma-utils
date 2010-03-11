#import "BlockingAsyncCallback.h"
#import "UIBlockingView.h"
#import "NSError+Utils.h"

@interface NSObject (AsyncCallback)
-(void)__blockingAsyncCallbackDefaultErrorHandler: (NSError*)error;
@end


@implementation BlockingAsyncCallback

@synthesize blocker;
@synthesize indicatorDelay;

#pragma mark private

-(void)performForBlocker: (SEL)selector{
	[(NSObject*)blocker performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
}

-(void)onTimer: (NSTimer*)timer{
	indicatorTimer = nil;
	[blocker showIndicator];
}

-(void)stopTimer{
	[indicatorTimer invalidate];
	indicatorTimer = nil;
}

#pragma mark NSObject

- (void)dealloc {
	[indicatorTimer invalidate];
	if(blocker)[self performForBlocker:@selector(release)];
	[super dealloc];
}

#pragma mark public

+(BlockingAsyncCallback*) callbackWithDelegate: delegate 
									 onSuccess: (SEL)onSuccess 
									   onError: (SEL)onError
									   blocker: (id<UIBlockingView>) blocker{
	BlockingAsyncCallback* inst = [[[BlockingAsyncCallback alloc] initWithHandler:delegate retained:NO onSuccess:onSuccess onError:onError] autorelease];
	inst.blocker = blocker;
	return inst;
}

+(BlockingAsyncCallback*) callbackWithObserver: observer 
									 onSuccess: (SEL)onSuccess 
									   onError: (SEL)onError
									   blocker: (id<UIBlockingView>) blocker{
	BlockingAsyncCallback* inst = [[[BlockingAsyncCallback alloc] initWithHandler:observer retained:YES onSuccess:onSuccess onError:onError] autorelease];
	inst.blocker = blocker;
	return inst;
}


+(SEL)defaultErrorHandler{
	return @selector(__blockingAsyncCallbackDefaultErrorHandler:);
}

#pragma mark AsyncCallbackProtocol

-(void)scheduleTimer{
	indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:indicatorDelay
													  target:self 
													selector:@selector(onTimer:) 
													userInfo:nil 
													 repeats:NO];
}

-(void)asyncOperationStarted{
	if (indicatorDelay > 0) {
		[self performSelectorOnMainThread:@selector(scheduleTimer) withObject:nil waitUntilDone:NO];
	} else {
		[self performForBlocker: @selector(showIndicator)];
	}
	
	[self performForBlocker: @selector(blockUI)];	
	[super asyncOperationStarted];	
}

-(void)asyncOperationCanceled{
	[self stopTimer];
	[self performForBlocker: @selector(unblockUI)];
	[self performForBlocker: @selector(release)];
	blocker = nil;
	[super asyncOperationCanceled];	
}

-(void)asyncOperationFinishedWithResult:	(id)result{
	[self stopTimer];
	[super asyncOperationFinishedWithResult:result]; //		call callback first because in case of concurrent blockers 
													 //		we set finished flag in callback and then check it in custom blocker
	[self performForBlocker: @selector(unblockUI)];
}

-(void)asyncOperationFinishedWithError:		(NSError*)error{
	[self stopTimer];
	[super asyncOperationFinishedWithError:error];
	[self performForBlocker: @selector(unblockUI)];	
}

@end

@implementation NSObject (AsyncCallback)
-(void)__blockingAsyncCallbackDefaultErrorHandler: (NSError*)error{
	[error display];
}
@end
