#import "NSArray+Utils.h"
#import "NSObject+Utils.h"
#import "NSMutableArray+Utils.h"

@implementation NSArray(Randomization)

- (NSArray*)shuffle {
	NSMutableArray *shuffle = [NSMutableArray arrayWithArray:self];
	[shuffle inplaceShuffle];
	return [[shuffle copy] autorelease];
}

- (NSArray*)filterUsingSelector:(SEL)selector target:(id)target {
	NSMutableArray *filtered = [NSMutableArray arrayWithArray:self];
	[filtered removeAllUsingSelector:selector target:target];
	return [[self copy] autorelease];
}

@end

