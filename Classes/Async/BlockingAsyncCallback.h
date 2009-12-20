#import "AsyncCallback.h"
#import "UIBlockingView.h"

@interface BlockingAsyncCallback : AsyncCallback{
    id<UIBlockingView> blocker;	
	NSTimeInterval indicatorDelay;
	NSTimer *indicatorTimer;	
}
@property (retain) id<UIBlockingView> blocker;
@property (assign) NSTimeInterval indicatorDelay;

+(BlockingAsyncCallback*) callbackWithDelegate: delegate 
									  onSuccess: (SEL)onSuccess 
										onError: (SEL)onError
										blocker: (id<UIBlockingView>) blocker;

+(SEL)defaultErrorHandler;

@end
