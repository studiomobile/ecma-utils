#import "Callback.h"
#import "NSObject+Invocation.h"

@implementation Callback
@synthesize selector;

#pragma mark properties

-(id)delegate{
	return isHandlerRetained ? nil : handler;
}

-(id)observer{
	return isHandlerRetained ? handler : nil;
}

- (void) setDelegate:(id)delegate{
	if(isHandlerRetained) [handler release];
    handler = delegate;
	isHandlerRetained = NO;
}

- (void) setObserver:(id)observer{
    [observer retain];
	if(isHandlerRetained) [handler release];
    handler = observer;
	isHandlerRetained = YES;
}


#pragma mark NSObject

-(id) initWithHandler: (id)_handler 
			 retained: (BOOL)_isHandlerRetained 
			selector: (SEL)_selector {
	self = [super init];
	if (self != nil) {
		if(isHandlerRetained) self.observer = _handler;
		else self.delegate = _handler;
		self.selector = _selector;
	}	
    
    return self;
}


- (void) dealloc{
	if(isHandlerRetained) [handler release];
	[super dealloc];
}

#pragma mark public

+(Callback*) callbackWithDelegate: delegate selector: (SEL)selector{
	return [[[[self class] alloc] initWithHandler: delegate retained:NO selector:selector] autorelease];
}

+(Callback*) callbackWithObserver: observer selector: (SEL)selector{
	return [[[[self class] alloc] initWithHandler: observer retained:YES selector:selector] autorelease];
}

-(void)callWithArguments: (NSArray*)args{
	NSInvocation* inv = [handler invocationForMethod: selector];
	for(int i = 2; i < inv.methodSignature.numberOfArguments; i++){
		int argN = i - 2;
		id arg = argN < args.count ? [args objectAtIndex: argN] : nil;
		[inv setArgument:  &arg atIndex:i];
	}

	[inv invoke];
}

-(void)call{
	[self callWithArguments: [NSArray array]];
}

-(void)callWith: arg{	
	[self callWithArguments: [NSArray arrayWithObject: arg]];
}

-(void)callWith: arg1 with: arg2{
	[self callWithArguments: [NSArray arrayWithObjects: arg1, arg2, nil]];
}


@end
