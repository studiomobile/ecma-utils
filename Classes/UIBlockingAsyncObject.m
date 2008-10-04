#import "UIBlockingAsyncObject.h"
#import "UIApplication+AppAdditions.h"


@interface UnblockUIOp : NSOperation {
	NSOperationQueue *mainQueue;
}
@property (readwrite, nonatomic, retain) NSOperationQueue *mainQueue;
@end


@implementation UnblockUIOp
@synthesize mainQueue;

- (void)main {
	[mainQueue waitUntilAllOperationsAreFinished];
	[self performSelectorOnMainThread:@selector(enableUserInteractions) withObject:nil waitUntilDone:FALSE];
}

- (void)enableUserInteractions {
	[UIApplication navigationController].view.userInteractionEnabled = YES;
}

- (void)dealloc {
	[mainQueue release];
	[super dealloc];
}

@end


@implementation UIBlockingAsyncObject

- (id)initWithImpl:(id)impl{
	if(self = [super initWithImpl:impl]) {
		uiUnblockQueue = [[NSOperationQueue alloc] init];
	}
	return self;
}

- (void)dealloc {
	[uiUnblockQueue release];
	[super dealloc];
}

- (void)forwardInvocation:(NSInvocation*)anInvocation {
	[UIApplication navigationController].view.userInteractionEnabled = NO;
	[super forwardInvocation:anInvocation];
	UnblockUIOp *unblockUI = [[[UnblockUIOp alloc] init] autorelease];
	unblockUI.mainQueue = queue;
	[uiUnblockQueue addOperation:unblockUI];
}

@end
