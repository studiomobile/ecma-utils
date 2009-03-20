#import <UIKit/UIKit.h>
#import "AsyncObject.h"
#import "UIBlockingView.h"


@interface UIBlockingAsyncObject : AsyncObject {
	NSArray *blockViews;
	NSTimeInterval indicatorDelay;
	NSTimer *indicatorTimer;
}
@property (retain) NSArray *blockViews;
@property (assign) NSTimeInterval indicatorDelay;

+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target delegate:(id)delegate onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews;
+ (UIBlockingAsyncObject*)uiBlockingAsyncObjectForTarget:(id)target observer:(id)observer onSuccess:(SEL)onSuccess onError:(SEL)onError blockViews:(NSArray*)blockViews;

@end
