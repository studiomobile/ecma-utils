#import <UIKit/UIKit.h>
#import "AsyncObject.h"
#import "UIBlocker.h"

@interface UIBlockingAsyncObject : AsyncObject {
	id<UIBlockingView> blocker;
	NSTimeInterval indicatorDelay;
}

@property (retain) id<UIBlockingView> blocker;
@property (assign) NSTimeInterval indicatorDelay;

// for backward compatibility
@property (retain) NSArray *blockViews;


+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate blocker: (id<UIBlockingView>)blocker;
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer blocker: (id<UIBlockingView>)blocker;

// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews;
// for backward compatibility
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews;

@end
