#import "NSMutableArray+Randomization.h"

@implementation NSMutableArray(Randomization)

- (NSMutableArray*)shuffle {
	NSUInteger count = [self count];
	if(count != 0) {
		for(int n = count; n > 1; n--)
		{
			int rand_ind = random()%n;
			[self exchangeObjectAtIndex:rand_ind withObjectAtIndex:n - 1];
		}
	}
	return self;
}

@end
