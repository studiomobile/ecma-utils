#import "NSObject+Invocation.h"

@implementation NSInvocation(Utils)

-(NSInvocation*)copy{
	NSInvocation *copy = [[self target] invocationForMethod:[self selector] ];
	
	NSUInteger argsCount = [[self methodSignature] numberOfArguments];
	char argumentsBuffer[[[self methodSignature] frameLength]];	
	for (int i = 0; i < argsCount; ++i) {
		[self getArgument:argumentsBuffer atIndex:i];
		[copy setArgument:argumentsBuffer atIndex:i];
	}
	
	if([self argumentsRetained]) {
		[copy retainArguments];
	}
	
	int returnLength = [[self methodSignature] methodReturnLength];
	if(returnLength > 0){
		char resultBuffer[returnLength];	
		[self getReturnValue:resultBuffer];
		[copy setReturnValue:resultBuffer];		
	}
	
	return copy;
}

@end

