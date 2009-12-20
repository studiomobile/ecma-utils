#import "CompositeBlockingView.h"

@implementation CompositeBlockingView

#pragma mark private

-(void)performWithEachBlocker: (SEL)selector{
	[blockers makeObjectsPerformSelector: selector];
}

#pragma mark NSObject

- (id) initWithBlockers: (NSArray*)_blockers {
	self = [super init];
	if (self != nil) {
		blockers = [_blockers retain];
	}
	return self;
}

+(CompositeBlockingView*) compositeBlockingViewWithBlockers: (NSArray*)blockers{
	return [[[CompositeBlockingView alloc] initWithBlockers: blockers] autorelease];	 
}

- (void) dealloc{
	[blockers release];
	[super dealloc];
}
#pragma mark UIBlockingView

- (void)blockUI{
	[self performWithEachBlocker: @selector(blockUI)];
}

- (void)unblockUI{
	[self performWithEachBlocker: @selector(unblockUI)];
}

- (void)showIndicator{
	[self performWithEachBlocker: @selector(showIndicator)];
}
@end