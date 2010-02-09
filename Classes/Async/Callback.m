#import "Callback.h"
#import "NSObject+Invocation.h"

@implementation Callback
@synthesize selector;

#pragma mark private

// construct bound arguments array
// fill the gaps with passed args
-(NSArray*)newFinalArgumentsWith: (NSArray*)args{	
	NSMutableArray* result = [NSMutableArray new];
	NSMutableArray* argumentsLeft = [args mutableCopy];
	NSArray* boundNumbers = [boundArguments allKeys];
	
	if(boundNumbers.count > 0){
		int max = [[boundNumbers valueForKeyPath: @"@max.intValue"] intValue];
		for(int i = 0; i <= max; i++){
			NSNumber* key = [NSNumber numberWithInt: i];
			id val = [boundArguments objectForKey: key];
			if(val){
				[result addObject: val];			
			}else if(argumentsLeft.count){			
				[result addObject: [argumentsLeft objectAtIndex:0]];
				[argumentsLeft removeObjectAtIndex:0];
			}else {
				[result addObject: [NSNull null]];
			}
		}		
	}

	while (argumentsLeft.count) {
		[result addObject: [argumentsLeft objectAtIndex:0]];
		[argumentsLeft removeObjectAtIndex:0];
	}
	
	[argumentsLeft release];
	
	return result;
}

-(id) convertNull: arg{
	return arg ? arg : [NSNull null];
}

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
	if(!_selector){
		[self release];
		return nil;	
	}
	self = [super init];
	if (self != nil) {
		isHandlerRetained = _isHandlerRetained;
		boundArguments = [[NSMutableDictionary dictionary] retain];
		
		if(isHandlerRetained) self.observer = _handler;
		else self.delegate = _handler;
		self.selector = _selector;
	}	
    
    return self;
}


- (void) dealloc{
	[boundArguments release];
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
	NSArray* newArgs = [self newFinalArgumentsWith: args];
	
	NSInvocation* inv = [handler invocationForMethod: selector];
	for(int i = 2; i < inv.methodSignature.numberOfArguments; i++){
		int argN = i - 2;
		id arg = argN < newArgs.count ? [newArgs objectAtIndex: argN] : nil;
		if(arg == [NSNull null]) arg = nil;
		[inv setArgument: &arg atIndex:i];
	}
	
	[newArgs release];

	[inv invoke];
}

-(void)call{
	NSArray* args = [NSArray new];
	[self callWithArguments: args];
	[args release];
}

-(void)callWith: arg{	
	arg = [self convertNull:arg];
	
	NSArray* args = [[NSArray alloc] initWithObjects: arg, nil];
	[self callWithArguments: [NSArray arrayWithObject: arg]];
	[args release];
}

-(void)callWith: arg1 with: arg2{
	arg1 = [self convertNull:arg1];
	arg2 = [self convertNull:arg2];
	
	NSArray* args = [[NSArray alloc] initWithObjects: arg1, arg2, nil];
	[self callWithArguments: args];
	[args release];
}

-(void)callWith: arg1 with: arg2 with: arg3{
	arg1 = [self convertNull:arg1];
	arg2 = [self convertNull:arg2];
	arg3 = [self convertNull:arg3];
	
	NSArray* args = [[NSArray alloc] initWithObjects: arg1, arg2, arg3, nil];
	[self callWithArguments: args];
	[args release];
}

-(void)bindArgument: (int)number with: (id)value{
	value = [self convertNull: value];
	[boundArguments setObject: value forKey: [NSNumber numberWithInt: number]];
}

-(void)bind0: value{
	[self bindArgument:0 with:value];
}

-(void)bind1: value{
	[self bindArgument:1 with:value];
}

-(void)bind2: value{
	[self bindArgument:2 with:value];
}



@end
