#import "BlockingAsyncCallback.h"
#import "UIBlockingView.h"

@implementation BlockingAsyncCallback

@synthesize blocker;
@synthesize indicatorDelay;

#pragma mark private

-(void)performForBlocker: (SEL)selector{
	[(NSObject*)blocker performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
}

-(void)onTimer{
	indicatorTimer = nil;
	[self performForBlocker: @selector(showIndicator)];
}

-(void)stopTimer{
	[indicatorTimer invalidate];
	indicatorTimer = nil;
}

#pragma mark NSObject

- (void)dealloc {
	[indicatorTimer invalidate];
	[blocker release];	
	[super dealloc];
}

#pragma mark AsyncCallbackProtocol

-(void)asyncOperationStarted{
	if (indicatorDelay > 0) {
		indicatorTimer = [NSTimer scheduledTimerWithTimeInterval:indicatorDelay target:self selector:@selector(onTimer) userInfo:nil repeats:NO];
	} else {
		[self performForBlocker: @selector(showIndicator)];
	}
	
	[self performForBlocker: @selector(blockUI)];	
	[super asyncOperationStarted];	
}

-(void)asyncOperationCanceled{
	[self stopTimer];
	[self performForBlocker: @selector(unblockUI)];
	[super asyncOperationCanceled];	
}

-(void)asyncOperationFinishedWithResult:	(id)result{
	[self stopTimer];
	[self performForBlocker: @selector(unblockUI)];	
	[super asyncOperationFinishedWithResult:result];	
}

-(void)asyncOperationFinishedWithError:		(NSError*)error{
	[self stopTimer];
	[self performForBlocker: @selector(unblockUI)];	
	[super asyncOperationFinishedWithError:error];
}

@end