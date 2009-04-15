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


