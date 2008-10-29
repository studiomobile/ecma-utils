#import <UIKit/UIKit.h>
#import "AsyncObject.h"

@interface UIBlockingAsyncObject : AsyncObject {
	NSOperationQueue *uiUnblockQueue;
	NSArray *views;
	UIActivityIndicatorView *indicator;
}

- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockView:(UIView*)v;
- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockViews:(NSArray*)v;
- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockView:(UIView*)v andDisplayIndicator:(UIActivityIndicatorView*)i;
- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target blockViews:(NSArray*)v andDisplayIndicator:(UIActivityIndicatorView*)i;
- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target displayIndicator:(UIActivityIndicatorView*)i;

@end
