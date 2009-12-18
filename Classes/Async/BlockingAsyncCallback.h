#import "AsyncCallback.h"
#import "UIBlockingView.h"

@interface BlockingAsyncCallback : AsyncCallback{
    id<UIBlockingView> blocker;	
	NSTimeInterval indicatorDelay;
	NSTimer *indicatorTimer;	
}
@property (retain) id<UIBlockingView> blocker;
@property (assign) NSTimeInterval indicatorDelay;

@end
