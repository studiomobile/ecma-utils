#import "CGGeometry+Utils.h"

CGRect CGRectConsume(CGRect r, CGPoint pt){	
	return CGRectUnion(r, CGRectMake(pt.x, pt.y, 0, 0));
}

CGSize CGSizeFitIntoSize(CGSize original, CGSize fitInto){
	if(fitInto.width == 0.0 || fitInto.height == 0){
		return CGSizeMake(0, 0);
	}
	
	double originalRatio = original.width / original.height;
	double destRatio = fitInto.width / fitInto.height;
	
	CGSize result;	
	if(originalRatio > destRatio){
		result.width = fitInto.width;
		result.height = result.width / originalRatio;
	}else{
		result.height = fitInto.height;
		result.width = result.height * originalRatio;
	}
	
	return result;	 
}


CGPoint CGRectCenter(CGRect r){
	return CGPointMake(CGRectGetMidX(r), CGRectGetMidY(r));	
}

CGRect CGRectCenterToPoint(CGRect original, CGPoint newCenter){
	CGPoint oldCenter = CGRectCenter(original);	
	original.origin.x += (newCenter.x - oldCenter.x);
	original.origin.y += (newCenter.y - oldCenter.y);
	return original;
}

CGRect CGRectCenterToRect(CGRect original, CGRect otherRect){
	return CGRectCenterToPoint(original, CGRectCenter(otherRect));	 
}


CGFloat CGPointDistanceToPoint(CGPoint point1, CGPoint point2) {
    CGFloat xDiff = point1.x - point2.x;
    CGFloat yDiff = point1.y - point2.y;
    return sqrt(xDiff*xDiff + yDiff*yDiff);
}