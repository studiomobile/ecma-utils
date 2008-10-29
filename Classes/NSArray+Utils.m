#import "NSArray+Utils.h"
#import "NSObject+Utils.h"

void swap(id *mem, NSUInteger i, NSUInteger j) 
{
	id tmp = mem[i];
	mem[i] = mem[j];
	mem[j] = tmp;
}

@implementation NSArray(Randomization)

+ (NSArray*)shuffle:(NSArray*)array {
	[DebugCheck notNull:array message:@"Can not shuffle nil"];
	NSLog(@"This function is poorly tested. Use it on your own risk");
	NSUInteger count = [array count];
	if(count != 0) {
		id *tmpArray = (id*)malloc(sizeof(id)*count);
		for(int i = 0; i < count; ++i) {
			tmpArray[i] = [array objectAtIndex:i];
		}
		for(int n = count; n > 1; n--)
		{
			int rand_ind = random()%n;
			swap(tmpArray, rand_ind, n - 1);
		}
		return [NSArray arrayWithObjects:tmpArray count:count];
	}
	return array;	
}

@end

