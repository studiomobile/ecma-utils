#import "NSArray+Utils.h"
#import "NSObject+Utils.h"

@implementation NSArray(Randomization)

- (NSArray*)shuffle {
	NSMutableArray *shuffle = [NSMutableArray arrayWithArray:self];
	[shuffle inplaceShuffle];
	return [[shuffle copy] autorelease];
}

@end

