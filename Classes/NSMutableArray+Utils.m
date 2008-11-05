#import "NSMutableArray+Utils.h"

@implementation NSMutableArray(Utils)

- (void)inplaceShuffle {
	NSUInteger count = [self count];
	for(int n = count - 1; n >= 0; n--)
	{
		[self exchangeObjectAtIndex:n withObjectAtIndex:(arc4random() % count)];
	}
}

@end
