#import "CGGeometry+Utils.h"

CGRect CGRectConsume(CGRect r, CGPoint pt){	
	return CGRectUnion(r, CGRectMake(pt.x, pt.y, 0, 0));
}


