#import "ESRandom.h"

#define ARC4RANDOM_MAX 0xFFFFFFFF

@implementation ESRandom

+(double)random{
	return (double)arc4random() / ARC4RANDOM_MAX;
}

+(int) from:(int)from to: (int)to{
	int min = MIN(from, to);
	int max = MAX(from, to);
	int diff = max - min;
	
	int rolled = arc4random() % (diff+1);
	return min + rolled;
}

+(int) to:(int)to{
	return [self from:0 to:to];
}

+(BOOL) isOccured:(double)probability{
	return (u_int64_t)arc4random() < (probability*((u_int64_t)ARC4RANDOM_MAX + 1));
}

@end
