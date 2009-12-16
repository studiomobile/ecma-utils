#import "AsyncInvocation.h"

@implementation AsyncInvocationImpl
- (id) initWithOperation: (NSOperation*)_op{
	self = [super init];
	if (self != nil) {
	    op = [_op retain];
	}
	return self;
}

+(AsyncInvocationImpl*)asyncInvocationWithOperation: (NSOperation*)op {
	return [[[AsyncInvocationImpl alloc] initWithOperation: op] autorelease];
}

- (void) dealloc{
	[op release];
	[super dealloc];
}

-(void)cancel{	
	[op cancel];
}


@end
