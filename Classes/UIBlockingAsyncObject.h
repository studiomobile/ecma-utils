#import <UIKit/UIKit.h>
#import "AsyncObject.h"

@interface UIBlockingAsyncObject : AsyncObject {
	NSOperationQueue *uiUnblockQueue;
}

@end
