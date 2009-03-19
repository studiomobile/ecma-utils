#import "NSValue+Utils.h"

@implementation NSValue (Utils)

+(id)valueWithCGPoint: (CGPoint)pt{
	return [self valueWithPoint: (NSPointFromCGPoint(pt))];
}

-(CGPoint) cgpointValue{
	return NSPointToCGPoint([self pointValue]);
}

@end
