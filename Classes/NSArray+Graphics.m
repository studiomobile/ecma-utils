#import "NSArray+Graphics.h"
#import "CGGeometry+Utils.h"

@implementation NSArray (CGGeometry)

-(CGRect) pointsBoundingRect{
	
	CGRect rect = CGRectNull;
	
	for(NSValue* v in self){
		rect = CGRectConsume(rect, [v CGPointValue]);
	}
	
	return rect;	
}

@end