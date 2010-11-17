#import "NSMutableArray+Utils.h"

@implementation NSMutableArray(Utils)

- (void)inplaceShuffle {
	NSUInteger count = [self count];
	for(int n = count - 1; n >= 0; n--)
	{
		[self exchangeObjectAtIndex:n withObjectAtIndex:n + (arc4random() % (count - n))];
	}
}

- (void)removeAllUsingSelector:(SEL)selector target:(id)target {
	NSUInteger itemsCount = [self count];
	NSMutableIndexSet *toRemove = [NSMutableIndexSet indexSet];
	for(int i = 0; i < itemsCount; ++i) {
		id item = [self objectAtIndex:i];
		if([target performSelector:selector withObject:item]) {
			[toRemove addIndex:i];
		}
	}
	[self removeObjectsAtIndexes:toRemove];
}

@end
