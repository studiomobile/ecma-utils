#import <UIKit/UIKit.h>

@interface AsyncObject : NSObject {
	id opTarget, handlerTarget;
	SEL method, successHandler, errorHandler;
	NSOperationQueue *queue;
}

- (id)initWithImpl:(id)impl;
- (id)ifSuccess:(SEL)successSelector ifError:(SEL)errorSelector target:(id)target;
@end
